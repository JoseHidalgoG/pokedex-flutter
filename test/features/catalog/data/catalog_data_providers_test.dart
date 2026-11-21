import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/core/database/app_database_provider.dart';
import 'package:pokedex_flutter/core/network/call_budget_link.dart';
import 'package:pokedex_flutter/core/network/pokeapi_graphql_client.dart';
import 'package:pokedex_flutter/core/network/pokeapi_graphql_client_provider.dart';
import 'package:pokedex_flutter/core/sync/domain/call_budget.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';
import 'package:pokedex_flutter/features/catalog/data/catalog_data_providers.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_page_query.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto_mapper.dart';
import 'package:pokedex_flutter/features/connectivity/connectivity_providers.dart';
import 'package:pokedex_flutter/features/connectivity/domain/connectivity_status.dart';

import '../../../fixtures/catalog_batch_fixture.dart';

class SavedBatchPokeApiLink extends Link {
  SavedBatchPokeApiLink({this.unreachableRequests = 0});

  int unreachableRequests;
  final receivedRequests = <Request>[];

  int get requests => receivedRequests.length;

  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    receivedRequests.add(request);
    if (unreachableRequests > 0) {
      unreachableRequests--;
      return Stream.error(const SocketException('Failed host lookup'));
    }
    final savedResponse = savedCatalogBatchResponse();
    return Stream.value(
      Response(
        data: savedResponse['data'] as Map<String, Object?>?,
        response: savedResponse,
      ),
    );
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

  ProviderContainer startAppOver(SavedBatchPokeApiLink pokeApi) {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        connectivityStatusProvider.overrideWith((ref) => connectivity.stream),
        pokeApiGraphQLClientProvider.overrideWithValue(
          createPokeApiGraphQLClient(link: pokeApi),
        ),
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
    expect(pokeApi.requests, 1);
  });

  test(
    'si al arrancar no hay conexión, repite la pasada al pasar a en línea',
    () async {
      final pokeApi = SavedBatchPokeApiLink(unreachableRequests: 1);

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
      expect(pokeApi.requests, 2);
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
    final request = pokeApi.receivedRequests.single;
    expect(request.operation.document, same(pokemonByIdsQuery));
    expect(request.variables, {
      'ids': [1],
    });
    expect(
      request.context.entry<CallPriorityEntry>()?.priority,
      CallPriority.restoration,
    );
  });

  test('una reconexión con el catálogo fresco no llama a PokeAPI', () async {
    final pokeApi = SavedBatchPokeApiLink();
    final container = startAppOver(pokeApi);
    await expectLater(
      catalogStatusIn(container),
      emitsThrough(isA<SyncRevalidated>()),
    );

    connectivity
      ..add(ConnectivityStatus.serviceUnavailable)
      ..add(ConnectivityStatus.online);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(pokeApi.requests, 1);
    expect(await catalogStatusIn(container).first, isA<SyncRevalidated>());
  });
}
