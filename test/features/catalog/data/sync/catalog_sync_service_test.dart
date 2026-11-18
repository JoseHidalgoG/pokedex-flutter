import 'dart:async';

import 'package:async/async.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_dao.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_batch.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_remote_data_source.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto_mapper.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/catalog_sync_service.dart';

typedef CatalogPageRequest = ({int offset, bool withTotal});

class FakePokeApiCatalog implements CatalogRemoteDataSource {
  FakePokeApiCatalog({required int pokemonCount, this.failingOffset})
    : _catalog = [
        for (var id = 1; id <= pokemonCount; id++)
          PokemonDto(
            id: id,
            name: 'pokemon-$id',
            typeNames: const ['normal'],
            baseStats: const {'hp': 50, 'speed': 50},
          ),
      ];

  final List<PokemonDto> _catalog;
  final int? failingOffset;
  final requests = <CatalogPageRequest>[];

  List<int> get requestedOffsets => [
    for (final request in requests) request.offset,
  ];

  List<PokemonDto> pokemonUpTo(int count) => _catalog.take(count).toList();

  @override
  Future<CatalogBatch> fetchCatalogPage({
    required int limit,
    required int offset,
    bool withTotal = false,
  }) async {
    requests.add((offset: offset, withTotal: withTotal));
    if (offset == failingOffset) {
      throw const ServerError(503);
    }
    return CatalogBatch(
      pokemon: _catalog.skip(offset).take(limit).toList(),
      totalCount: withTotal ? _catalog.length : null,
    );
  }
}

Matcher failedWith(Object failure) {
  return isA<SyncFailed>().having(
    (failed) => failed.failure,
    'failure',
    failure,
  );
}

void main() {
  late AppDatabase database;
  late CatalogDao catalogDao;
  late DateTime now;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    catalogDao = database.catalogDao;
    now = DateTime(2026, 11, 9, 10);
  });

  tearDown(() => database.close());

  CatalogSyncService syncServiceOver(
    FakePokeApiCatalog remoteCatalog, {
    Future<bool> Function()? hasInternetAccess,
  }) {
    final service = CatalogSyncService(
      remoteDataSource: remoteCatalog,
      catalogDao: catalogDao,
      hasInternetAccess: hasInternetAccess ?? () async => true,
      now: () => now,
    );
    addTearDown(service.dispose);
    return service;
  }

  Future<void> saveAlreadyDownloaded(
    FakePokeApiCatalog remoteCatalog, {
    required int count,
    required bool isComplete,
    required DateTime savedAt,
    int? totalCount,
  }) {
    return catalogDao.saveCatalogPage(
      entries: [
        for (final pokemon in remoteCatalog.pokemonUpTo(count))
          pokemon.toCatalogEntry(),
      ],
      nextOffset: count,
      isComplete: isComplete,
      savedAt: savedAt,
      totalCount: totalCount,
    );
  }

  Future<List<int>> savedPokemonIds() async {
    final rows = await database.select(database.pokemonTable).get();
    return [for (final row in rows) row.id];
  }

  test(
    'descarga los 1025 Pokémon en 11 llamadas y solo la primera pide el total',
    () async {
      final remoteCatalog = FakePokeApiCatalog(pokemonCount: 1025);

      await syncServiceOver(remoteCatalog).syncCatalog();
      final progress = await catalogDao.readCatalogSyncProgress();

      expect(remoteCatalog.requestedOffsets, [
        for (var offset = 0; offset <= 1000; offset += 100) offset,
      ]);
      expect(
        [for (final request in remoteCatalog.requests) request.withTotal],
        [true, for (var call = 2; call <= 11; call++) false],
      );
      expect(await savedPokemonIds(), hasLength(1025));
      expect(progress?.totalCount, 1025);
      expect(progress?.nextOffset, 1025);
      expect(progress?.isComplete, isTrue);
    },
  );

  test(
    'se detiene al llegar al total sin pedir un lote vacío al final',
    () async {
      final remoteCatalog = FakePokeApiCatalog(pokemonCount: 200);

      await syncServiceOver(remoteCatalog).syncCatalog();
      final progress = await catalogDao.readCatalogSyncProgress();

      expect(remoteCatalog.requestedOffsets, [0, 100]);
      expect(progress?.isComplete, isTrue);
    },
  );

  test('descarga lotes hasta recibir uno incompleto', () async {
    final remoteCatalog = FakePokeApiCatalog(pokemonCount: 120);

    await syncServiceOver(remoteCatalog).syncCatalog();
    final progress = await catalogDao.readCatalogSyncProgress();

    expect(remoteCatalog.requestedOffsets, [0, 100]);
    expect(await savedPokemonIds(), hasLength(120));
    expect(progress?.nextOffset, 120);
    expect(progress?.isComplete, isTrue);
  });

  test(
    'continúa desde el offset guardado sin volver a pedir el total conocido',
    () async {
      final remoteCatalog = FakePokeApiCatalog(pokemonCount: 250);
      await saveAlreadyDownloaded(
        remoteCatalog,
        count: 100,
        isComplete: false,
        savedAt: now.subtract(const Duration(minutes: 5)),
        totalCount: 250,
      );

      await syncServiceOver(remoteCatalog).syncCatalog();

      expect(remoteCatalog.requests, [
        (offset: 100, withTotal: false),
        (offset: 200, withTotal: false),
      ]);
      expect(await savedPokemonIds(), hasLength(250));
    },
  );

  test('al continuar sin total guardado lo pide en el primer lote', () async {
    final remoteCatalog = FakePokeApiCatalog(pokemonCount: 250);
    await saveAlreadyDownloaded(
      remoteCatalog,
      count: 100,
      isComplete: false,
      savedAt: now.subtract(const Duration(minutes: 5)),
    );

    await syncServiceOver(remoteCatalog).syncCatalog();

    expect(remoteCatalog.requests, [
      (offset: 100, withTotal: true),
      (offset: 200, withTotal: false),
    ]);
  });

  test('termina cuando un lote llega incompleto aunque el total guardado sea mayor', () async {
    final remoteCatalog = FakePokeApiCatalog(pokemonCount: 150);
    await saveAlreadyDownloaded(
      remoteCatalog,
      count: 100,
      isComplete: false,
      savedAt: now.subtract(const Duration(minutes: 5)),
      totalCount: 300,
    );

    await syncServiceOver(remoteCatalog).syncCatalog();
    final progress = await catalogDao.readCatalogSyncProgress();

    expect(remoteCatalog.requestedOffsets, [100]);
    expect(progress?.isComplete, isTrue);
  });

  test('no pide nada si el catálogo está completo y la última pasada tiene menos de 1 h', () async {
    final remoteCatalog = FakePokeApiCatalog(pokemonCount: 120);
    await saveAlreadyDownloaded(
      remoteCatalog,
      count: 120,
      isComplete: true,
      savedAt: now.subtract(const Duration(minutes: 59)),
    );
    final syncService = syncServiceOver(remoteCatalog);

    await syncService.syncCatalog();

    expect(remoteCatalog.requestedOffsets, isEmpty);
    expect(syncService.currentStatus, isA<SyncIdle>());
  });

  test('vuelve a empezar desde el inicio cuando la última pasada completa tiene más de 1 h', () async {
    final remoteCatalog = FakePokeApiCatalog(pokemonCount: 120);
    await saveAlreadyDownloaded(
      remoteCatalog,
      count: 120,
      isComplete: true,
      savedAt: now.subtract(const Duration(minutes: 61)),
      totalCount: 120,
    );

    await syncServiceOver(remoteCatalog).syncCatalog();
    final progress = await catalogDao.readCatalogSyncProgress();

    expect(remoteCatalog.requests, [
      (offset: 0, withTotal: true),
      (offset: 100, withTotal: false),
    ]);
    expect(progress?.isComplete, isTrue);
    expect(progress?.lastSyncedAt, now);
  });

  test('sin conexión no pide nada, conserva los datos y emite fallo por falta de conexión', () async {
    final remoteCatalog = FakePokeApiCatalog(pokemonCount: 120);
    await saveAlreadyDownloaded(
      remoteCatalog,
      count: 100,
      isComplete: false,
      savedAt: now,
    );
    final syncService = syncServiceOver(
      remoteCatalog,
      hasInternetAccess: () async => false,
    );

    await syncService.syncCatalog();

    expect(remoteCatalog.requestedOffsets, isEmpty);
    expect(await savedPokemonIds(), hasLength(100));
    expect(syncService.currentStatus, failedWith(const NoConnection()));
  });

  test('ante un error guarda last_error, se detiene y conserva los lotes ya guardados', () async {
    final remoteCatalog = FakePokeApiCatalog(
      pokemonCount: 250,
      failingOffset: 100,
    );
    final syncService = syncServiceOver(remoteCatalog);

    await syncService.syncCatalog();
    final progress = await catalogDao.readCatalogSyncProgress();

    expect(remoteCatalog.requestedOffsets, [0, 100]);
    expect(await savedPokemonIds(), hasLength(100));
    expect(progress?.nextOffset, 100);
    expect(progress?.isComplete, isFalse);
    expect(progress?.lastError, contains('503'));
    expect(syncService.currentStatus, failedWith(const ServerError(503)));
  });

  test('informa falta de conexión cuando la red se pierde a mitad de la sincronización', () async {
    final remoteCatalog = FakePokeApiCatalog(
      pokemonCount: 250,
      failingOffset: 100,
    );
    final connectionAnswers = [true, false].iterator;
    final syncService = syncServiceOver(
      remoteCatalog,
      hasInternetAccess: () async {
        connectionAnswers.moveNext();
        return connectionAnswers.current;
      },
    );

    await syncService.syncCatalog();

    expect(syncService.currentStatus, failedWith(const NoConnection()));
  });

  test('no inicia dos sincronizaciones a la vez', () async {
    final remoteCatalog = FakePokeApiCatalog(pokemonCount: 120);
    final syncService = syncServiceOver(remoteCatalog);

    final firstSync = syncService.syncCatalog();
    final secondSync = syncService.syncCatalog();
    await Future.wait([firstSync, secondSync]);

    expect(identical(firstSync, secondSync), isTrue);
    expect(remoteCatalog.requestedOffsets, [0, 100]);
  });

  test(
    'emite la pasada completa en curso y después revalidado ahora',
    () async {
      final syncService = syncServiceOver(
        FakePokeApiCatalog(pokemonCount: 120),
      );
      final statusUpdates = StreamQueue(syncService.watchStatus());
      addTearDown(statusUpdates.cancel);

      expect(await statusUpdates.next, isA<SyncIdle>());

      final sync = syncService.syncCatalog();
      expect(await statusUpdates.next, isA<SyncFullPassInProgress>());
      expect(
        await statusUpdates.next,
        isA<SyncRevalidated>().having((status) => status.at, 'at', now),
      );
      await sync;
    },
  );

  test(
    'sin pedir nada a PokeAPI vuelve a reposo y no anuncia datos revalidados',
    () async {
      final remoteCatalog = FakePokeApiCatalog(pokemonCount: 120);
      await saveAlreadyDownloaded(
        remoteCatalog,
        count: 120,
        isComplete: true,
        savedAt: now.subtract(const Duration(minutes: 30)),
      );
      final syncService = syncServiceOver(remoteCatalog);
      final statusUpdates = StreamQueue(syncService.watchStatus());
      addTearDown(statusUpdates.cancel);

      expect(await statusUpdates.next, isA<SyncIdle>());

      final sync = syncService.syncCatalog();
      expect(await statusUpdates.next, isA<SyncFullPassInProgress>());
      expect(await statusUpdates.next, isA<SyncIdle>());
      await sync;
    },
  );

  test('sincronizar dos veces no repite ningún id', () async {
    final remoteCatalog = FakePokeApiCatalog(pokemonCount: 120);
    final syncService = syncServiceOver(remoteCatalog);

    await syncService.syncCatalog();
    now = now.add(const Duration(hours: 2));
    await syncService.syncCatalog();
    final ids = await savedPokemonIds();

    expect(remoteCatalog.requestedOffsets, [0, 100, 0, 100]);
    expect(ids, hasLength(120));
    expect(ids.toSet(), hasLength(120));
  });

  test(
    'emite fallo si la comprobación de Internet lanza una excepción',
    () async {
      final remoteCatalog = FakePokeApiCatalog(pokemonCount: 120);

      final syncService = syncServiceOver(
        remoteCatalog,
        hasInternetAccess: () async {
          throw StateError('No se pudo comprobar la conexión');
        },
      );

      await expectLater(syncService.syncCatalog(), throwsA(isA<StateError>()));

      expect(remoteCatalog.requestedOffsets, isEmpty);

      expect(syncService.currentStatus, failedWith(isA<QueryError>()));
    },
  );

  test('marca sincronización en curso antes de comprobar Internet', () async {
    final remoteCatalog = FakePokeApiCatalog(pokemonCount: 120);
    final connectionCheck = Completer<bool>();

    final syncService = syncServiceOver(
      remoteCatalog,
      hasInternetAccess: () => connectionCheck.future,
    );

    final sync = syncService.syncCatalog();

    expect(syncService.currentStatus, isA<SyncFullPassInProgress>());

    connectionCheck.complete(false);
    await sync;

    expect(syncService.currentStatus, failedWith(const NoConnection()));
  });

  test('force true vuelve a descargar un catálogo reciente', () async {
    final remoteCatalog = FakePokeApiCatalog(pokemonCount: 120);

    await saveAlreadyDownloaded(
      remoteCatalog,
      count: 120,
      isComplete: true,
      savedAt: now.subtract(const Duration(minutes: 10)),
    );

    final syncService = syncServiceOver(remoteCatalog);

    await syncService.syncCatalog(force: true);

    final progress = await catalogDao.readCatalogSyncProgress();

    expect(remoteCatalog.requestedOffsets, [0, 100]);
    expect(await savedPokemonIds(), hasLength(120));
    expect(progress?.isComplete, isTrue);
    expect(progress?.lastSyncedAt, now);
    expect(syncService.currentStatus, isA<SyncRevalidated>());
  });

  test('force true sin Internet conserva el catálogo local', () async {
    final remoteCatalog = FakePokeApiCatalog(pokemonCount: 120);

    await saveAlreadyDownloaded(
      remoteCatalog,
      count: 120,
      isComplete: true,
      savedAt: now.subtract(const Duration(minutes: 10)),
    );

    final syncService = syncServiceOver(
      remoteCatalog,
      hasInternetAccess: () async => false,
    );

    await syncService.syncCatalog(force: true);

    expect(remoteCatalog.requestedOffsets, isEmpty);
    expect(await savedPokemonIds(), hasLength(120));

    expect(syncService.currentStatus, failedWith(const NoConnection()));
  });

  test('force true conserva los datos cuando PokéAPI falla', () async {
    final remoteCatalog = FakePokeApiCatalog(
      pokemonCount: 120,
      failingOffset: 0,
    );

    await saveAlreadyDownloaded(
      remoteCatalog,
      count: 120,
      isComplete: true,
      savedAt: now.subtract(const Duration(minutes: 10)),
    );

    final syncService = syncServiceOver(
      remoteCatalog,
      hasInternetAccess: () async => true,
    );

    await syncService.syncCatalog(force: true);

    final progress = await catalogDao.readCatalogSyncProgress();

    expect(remoteCatalog.requestedOffsets, [0]);
    expect(await savedPokemonIds(), hasLength(120));
    expect(progress?.lastError, contains('503'));

    expect(syncService.currentStatus, failedWith(const ServerError(503)));
  });
}
