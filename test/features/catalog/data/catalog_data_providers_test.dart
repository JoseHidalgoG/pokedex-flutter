import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/core/database/app_database_provider.dart';
import 'package:pokedex_flutter/core/network/call_budget_link.dart';
import 'package:pokedex_flutter/core/network/pokeapi_graphql_client.dart';
import 'package:pokedex_flutter/core/network/pokeapi_graphql_client_provider.dart';
import 'package:pokedex_flutter/core/sync/domain/call_budget.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';
import 'package:pokedex_flutter/core/sync/domain/retry_policy.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_job.dart';
import 'package:pokedex_flutter/core/sync/sync_providers.dart';
import 'package:pokedex_flutter/core/sync/sync_scheduler.dart';
import 'package:pokedex_flutter/features/catalog/data/catalog_data_providers.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_dao.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_page_query.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto_mapper.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/type_efficacy_query.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/catalog_sync_service.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/interrupted_sync_report.dart';
import 'package:pokedex_flutter/features/connectivity/connectivity_providers.dart';
import 'package:pokedex_flutter/features/connectivity/domain/connectivity_status.dart';

import '../../../fixtures/catalog_batch_fixture.dart';
import '../../../fixtures/pokemon_detail_fixture.dart';

class SavedBatchPokeApiLink extends Link {
  SavedBatchPokeApiLink({this.unreachableCatalogRequests = 0});

  int unreachableCatalogRequests;
  final receivedRequests = <Request>[];

  int get requests => receivedRequests.length;

  int get catalogRequests =>
      receivedRequests.length - requestsFor(typeEfficacyQuery).length;

  List<Request> requestsFor(DocumentNode document) => [
    for (final request in receivedRequests)
      if (identical(request.operation.document, document)) request,
  ];

  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    receivedRequests.add(request);
    if (identical(request.operation.document, typeEfficacyQuery)) {
      return Stream.value(_responseFrom(savedTypeEfficacyResponse()));
    }
    if (unreachableCatalogRequests > 0) {
      unreachableCatalogRequests--;
      return Stream.error(const SocketException('Failed host lookup'));
    }
    return Stream.value(_responseFrom(savedCatalogBatchResponse()));
  }

  static Response _responseFrom(Map<String, Object?> savedResponse) {
    return Response(
      data: savedResponse['data'] as Map<String, Object?>?,
      response: savedResponse,
    );
  }
}

class PagedCatalogPokeApiLink extends Link {
  PagedCatalogPokeApiLink({required this.pokemonCount})
    : _bulbasaur = savedPokemonJson(name: 'bulbasaur');

  final int pokemonCount;
  final Map<String, Object?> _bulbasaur;
  final receivedRequests = <Request>[];

  List<int> get requestedCatalogOffsets => [
    for (final request in requestsFor(catalogPageQuery))
      request.variables['offset']! as int,
  ];

  List<Request> requestsFor(DocumentNode document) => [
    for (final request in receivedRequests)
      if (identical(request.operation.document, document)) request,
  ];

  CatalogEntry entryWithId(int id) {
    return PokemonDto.fromJson(_pokemonJsonWithId(id)).toCatalogEntry();
  }

  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    receivedRequests.add(request);
    if (identical(request.operation.document, typeEfficacyQuery)) {
      return Stream.value(_responseWith(savedTypeEfficacyResponse()));
    }
    final offset = request.variables['offset']! as int;
    final limit = request.variables['limit']! as int;
    final lastId = min(offset + limit, pokemonCount);
    return Stream.value(
      _responseWith({
        'data': {
          'pokemon': [
            for (var id = offset + 1; id <= lastId; id++)
              _pokemonJsonWithId(id),
          ],
          if (request.variables['withTotal'] == true)
            'pokemon_aggregate': {
              'aggregate': {'count': pokemonCount},
            },
        },
      }),
    );
  }

  Map<String, Object?> _pokemonJsonWithId(int id) {
    return {
      ..._bulbasaur,
      'id': id,
      'name': 'pokemon-$id',
      'pokemonspecy': {'id': id, 'generation_id': 1},
    };
  }

  static Response _responseWith(Map<String, Object?> body) {
    return Response(
      data: body['data'] as Map<String, Object?>?,
      response: body,
    );
  }
}

class PeriodicJobsRecordingScheduler extends SyncScheduler {
  PeriodicJobsRecordingScheduler(AppDatabase database)
    : super(
        budget: CallBudget(),
        retryPolicy: RetryPolicy(),
        store: database.syncMetadataDao,
      );

  final periods = <String, Duration>{};

  @override
  void runEveryWhileOnline(SyncJob job, Duration period) {
    periods[job.key] = period;
    super.runEveryWhileOnline(job, period);
  }
}

void main() {
  late AppDatabase database;
  late StreamController<ConnectivityStatus> connectivity;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    connectivity = StreamController<ConnectivityStatus>();
  });

  tearDown(() async {
    await connectivity.close();
    await database.close();
  });

  ProviderContainer startAppOver(
    Link pokeApi, {
    List<Override> overrides = const [],
  }) {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        connectivityStatusProvider.overrideWith((ref) => connectivity.stream),
        pokeApiGraphQLClientProvider.overrideWithValue(
          createPokeApiGraphQLClient(link: pokeApi),
        ),
        ...overrides,
      ],
    );
    addTearDown(container.dispose);
    container.listen(catalogSyncTriggersProvider, (_, _) {});
    return container;
  }

  Stream<SyncStatus> catalogStatusIn(ProviderContainer container) {
    return container
        .read(offlineFirstCatalogRepositoryProvider)
        .watchSyncStatus();
  }

  test('al arrancar descarga el catálogo sin esperar a la conexión', () async {
    final pokeApi = SavedBatchPokeApiLink();

    final container = startAppOver(pokeApi);

    await expectLater(database.catalogDao.watchCatalogCount(), emitsThrough(4));
    await expectLater(
      catalogStatusIn(container),
      emitsThrough(isA<SyncRevalidated>()),
    );
    expect(pokeApi.catalogRequests, 1);
  });

  test(
    'al arrancar descarga la tabla de tipos una vez con prioridad de fondo',
    () async {
      final pokeApi = SavedBatchPokeApiLink();

      startAppOver(pokeApi);

      await expectLater(
        database.pokemonDetailDao.watchTypeEfficacy(),
        emitsThrough(hasLength(324)),
      );
      final request = pokeApi.requestsFor(typeEfficacyQuery).single;
      expect(
        request.context.entry<CallPriorityEntry>()?.priority,
        CallPriority.background,
      );
    },
  );

  test(
    'si al arrancar no hay conexión, repite la pasada al pasar a en línea',
    () async {
      final pokeApi = SavedBatchPokeApiLink(unreachableCatalogRequests: 1);

      final container = startAppOver(pokeApi);
      await expectLater(
        catalogStatusIn(container),
        emitsThrough(
          isA<SyncFailed>().having(
            (status) => status.failure,
            'failure',
            const NoConnection(),
          ),
        ),
      );
      connectivity.add(ConnectivityStatus.offline);
      connectivity.add(ConnectivityStatus.online);

      await expectLater(
        database.catalogDao.watchCatalogCount(),
        emitsThrough(4),
      );
      expect(pokeApi.catalogRequests, 2);
    },
  );

  test('al arrancar con el catálogo fresco restaura un Pokémon alterado con una llamada de restauración', () async {
    final savedPokemon = [
      for (final name in ['bulbasaur', 'ivysaur', 'venusaur', 'charmander'])
        PokemonDto.fromJson(savedPokemonJson(name: name)).toCatalogEntry(),
    ];
    await database.catalogDao.saveCatalogPage(
      entries: savedPokemon,
      nextOffset: savedPokemon.length,
      isComplete: true,
      savedAt: DateTime.now(),
      totalCount: savedPokemon.length,
    );
    await database.customStatement(
      "UPDATE pokemon SET name = 'bulbasaurx' WHERE id = 1",
    );
    final pokeApi = SavedBatchPokeApiLink();

    startAppOver(pokeApi);

    await expectLater(
      database.catalogDao.watchCatalog().map((catalog) => catalog.first.name),
      emitsThrough('bulbasaur'),
    );
    final request = pokeApi.requestsFor(pokemonByIdsQuery).single;
    expect(request.variables, {
      'ids': [1],
    });
    expect(
      request.context.entry<CallPriorityEntry>()?.priority,
      CallPriority.restoration,
    );
  });

  test('con servicio repite la pasada completa cada hora y la verificación de huellas cada 60 s', () async {
    final scheduler = PeriodicJobsRecordingScheduler(database);
    addTearDown(scheduler.dispose);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        connectivityStatusProvider.overrideWith((ref) => connectivity.stream),
        pokeApiGraphQLClientProvider.overrideWithValue(
          createPokeApiGraphQLClient(link: SavedBatchPokeApiLink()),
        ),
        syncSchedulerProvider.overrideWithValue(scheduler),
      ],
    );
    addTearDown(container.dispose);
    container.listen(connectivityStatusProvider, (_, _) {});

    container.listen(catalogSyncTriggersProvider, (_, _) {});

    expect(scheduler.periods, {
      'catalog': const Duration(hours: 1),
      'catalog:restore': const Duration(seconds: 60),
    });
    await expectLater(
      catalogStatusIn(container),
      emitsThrough(isA<SyncRevalidated>()),
    );
    await expectLater(
      database.pokemonDetailDao.watchTypeEfficacy(),
      emitsThrough(hasLength(324)),
    );
  });

  test('una pasada interrumpida en 300 de 1025 se reanuda al arrancar y pide solo los lotes que faltan', () async {
    final pokeApi = PagedCatalogPokeApiLink(pokemonCount: 1025);
    await database.catalogDao.saveCatalogPage(
      entries: [for (var id = 1; id <= 300; id++) pokeApi.entryWithId(id)],
      nextOffset: 300,
      isComplete: false,
      savedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      totalCount: 1025,
    );
    await database.syncMetadataDao.recordStarted(CatalogDao.catalogSyncKey);
    final logs = <String>[];

    final container = startAppOver(
      pokeApi,
      overrides: [
        catalogSyncServiceProvider.overrideWith(
          (ref) => CatalogSyncService(
            remoteDataSource: ref.watch(catalogRemoteDataSourceProvider),
            catalogDao: ref.watch(appDatabaseProvider).catalogDao,
            write: logs.add,
          ),
        ),
        interruptedSyncReportProvider.overrideWith(
          (ref) => InterruptedSyncReport(
            syncMetadata: ref.watch(appDatabaseProvider).syncMetadataDao,
            write: logs.add,
          ),
        ),
      ],
    );
    await expectLater(
      catalogStatusIn(container),
      emitsThrough(isA<SyncRevalidated>()),
    );
    final progress = await database.catalogDao.readCatalogSyncProgress();
    final storedIds = [
      for (final row in await database.select(database.pokemonTable).get())
        row.id,
    ]..sort();

    expect(pokeApi.requestedCatalogOffsets, [
      for (var offset = 300; offset <= 1000; offset += 100) offset,
    ]);
    expect(pokeApi.requestsFor(pokemonByIdsQuery), isEmpty);
    expect(progress?.status, 'idle');
    expect(progress?.isComplete, isTrue);
    expect(progress?.nextOffset, 1025);
    expect(storedIds, [for (var id = 1; id <= 1025; id++) id]);
    expect(
      logs,
      containsAllInOrder([
        'catalog: la pasada anterior se interrumpió en 300 de 1025; '
            'se reanuda',
        'catalog: se reanuda desde 300 de 1025',
      ]),
    );
  });

  test('una reconexión con el catálogo y la tabla de tipos frescos no llama a PokeAPI', () async {
    final pokeApi = SavedBatchPokeApiLink();
    final container = startAppOver(pokeApi);
    await expectLater(
      catalogStatusIn(container),
      emitsThrough(isA<SyncRevalidated>()),
    );
    await expectLater(
      database.pokemonDetailDao.watchTypeEfficacy(),
      emitsThrough(hasLength(324)),
    );
    final requestsBeforeReconnect = pokeApi.requests;

    connectivity
      ..add(ConnectivityStatus.serviceUnavailable)
      ..add(ConnectivityStatus.online);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(requestsBeforeReconnect, 2);
    expect(pokeApi.requests, requestsBeforeReconnect);
    expect(await catalogStatusIn(container).first, isA<SyncRevalidated>());
  });
}
