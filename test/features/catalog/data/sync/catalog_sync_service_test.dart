import 'package:async/async.dart';
import 'package:drift/native.dart';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_dao.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_page_request_failed.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_remote_data_source.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto_mapper.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/catalog_sync_service.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_sync_status.dart';

class FakePokeApiCatalog implements CatalogRemoteDataSource {
  FakePokeApiCatalog({required int pokemonCount, this.failingOffset})
    : _catalog = [
        for (var id = 1; id <= pokemonCount; id++)
          PokemonDto(id: id, name: 'pokemon-$id', typeNames: const ['normal']),
      ];

  final List<PokemonDto> _catalog;
  final int? failingOffset;
  final requestedOffsets = <int>[];

  List<PokemonDto> pokemonUpTo(int count) => _catalog.take(count).toList();

  @override
  Future<List<PokemonDto>> fetchCatalogPage({
    required int limit,
    required int offset,
  }) async {
    requestedOffsets.add(offset);
    if (offset == failingOffset) {
      throw const CatalogPageRequestFailed('503 Service Unavailable');
    }
    return _catalog.skip(offset).take(limit).toList();
  }
}

Matcher failedBecauseOf(CatalogSyncFailureReason reason) {
  return isA<CatalogSyncFailed>().having(
    (failed) => failed.reason,
    'reason',
    reason,
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
  }) {
    return catalogDao.saveCatalogPage(
      entries: [
        for (final pokemon in remoteCatalog.pokemonUpTo(count))
          pokemon.toCatalogEntry(),
      ],
      nextOffset: count,
      isComplete: isComplete,
      savedAt: savedAt,
    );
  }

  Future<List<int>> savedPokemonIds() async {
    final rows = await database.select(database.pokemonTable).get();
    return [for (final row in rows) row.id];
  }

  test('descarga todas las páginas hasta recibir una incompleta', () async {
    final remoteCatalog = FakePokeApiCatalog(pokemonCount: 120);

    await syncServiceOver(remoteCatalog).syncCatalog();
    final progress = await catalogDao.readCatalogSyncProgress();

    expect(remoteCatalog.requestedOffsets, [0, 50, 100]);
    expect(await savedPokemonIds(), hasLength(120));
    expect(progress?.nextOffset, 120);
    expect(progress?.isComplete, isTrue);
  });

  test(
    'marca el catálogo completo cuando la última página llega vacía',
    () async {
      final remoteCatalog = FakePokeApiCatalog(pokemonCount: 100);

      await syncServiceOver(remoteCatalog).syncCatalog();
      final progress = await catalogDao.readCatalogSyncProgress();

      expect(remoteCatalog.requestedOffsets, [0, 50, 100]);
      expect(await savedPokemonIds(), hasLength(100));
      expect(progress?.isComplete, isTrue);
    },
  );

  test('continúa desde el offset guardado tras reiniciar', () async {
    final remoteCatalog = FakePokeApiCatalog(pokemonCount: 120);
    await saveAlreadyDownloaded(
      remoteCatalog,
      count: 50,
      isComplete: false,
      savedAt: now.subtract(const Duration(minutes: 5)),
    );

    await syncServiceOver(remoteCatalog).syncCatalog();

    expect(remoteCatalog.requestedOffsets, [50, 100]);
    expect(await savedPokemonIds(), hasLength(120));
  });

  test('no pide nada si el catálogo está completo y se sincronizó hace menos de 24 h', () async {
    final remoteCatalog = FakePokeApiCatalog(pokemonCount: 120);
    await saveAlreadyDownloaded(
      remoteCatalog,
      count: 120,
      isComplete: true,
      savedAt: now.subtract(const Duration(hours: 23)),
    );
    final syncService = syncServiceOver(remoteCatalog);

    await syncService.syncCatalog();

    expect(remoteCatalog.requestedOffsets, isEmpty);
    expect(syncService.currentStatus, isA<CatalogSyncSucceeded>());
  });

  test('vuelve a empezar desde el inicio cuando la sincronización completa tiene más de 24 h', () async {
    final remoteCatalog = FakePokeApiCatalog(pokemonCount: 120);
    await saveAlreadyDownloaded(
      remoteCatalog,
      count: 120,
      isComplete: true,
      savedAt: now.subtract(const Duration(hours: 25)),
    );

    await syncServiceOver(remoteCatalog).syncCatalog();
    final progress = await catalogDao.readCatalogSyncProgress();

    expect(remoteCatalog.requestedOffsets, [0, 50, 100]);
    expect(progress?.isComplete, isTrue);
    expect(progress?.lastSyncedAt, now);
  });

  test('sin conexión no pide nada, conserva los datos y emite fallo por falta de conexión', () async {
    final remoteCatalog = FakePokeApiCatalog(pokemonCount: 120);
    await saveAlreadyDownloaded(
      remoteCatalog,
      count: 50,
      isComplete: false,
      savedAt: now,
    );
    final syncService = syncServiceOver(
      remoteCatalog,
      hasInternetAccess: () async => false,
    );

    await syncService.syncCatalog();

    expect(remoteCatalog.requestedOffsets, isEmpty);
    expect(await savedPokemonIds(), hasLength(50));
    expect(
      syncService.currentStatus,
      failedBecauseOf(CatalogSyncFailureReason.noConnection),
    );
  });

  test('ante un error guarda last_error, se detiene y conserva las páginas ya guardadas', () async {
    final remoteCatalog = FakePokeApiCatalog(
      pokemonCount: 120,
      failingOffset: 50,
    );
    final syncService = syncServiceOver(remoteCatalog);

    await syncService.syncCatalog();
    final progress = await catalogDao.readCatalogSyncProgress();

    expect(remoteCatalog.requestedOffsets, [0, 50]);
    expect(await savedPokemonIds(), hasLength(50));
    expect(progress?.nextOffset, 50);
    expect(progress?.isComplete, isFalse);
    expect(progress?.lastError, contains('503'));
    expect(
      syncService.currentStatus,
      failedBecauseOf(CatalogSyncFailureReason.requestFailed),
    );
  });

  test('informa falta de conexión cuando la red se pierde a mitad de la sincronización', () async {
    final remoteCatalog = FakePokeApiCatalog(
      pokemonCount: 120,
      failingOffset: 50,
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

    expect(
      syncService.currentStatus,
      failedBecauseOf(CatalogSyncFailureReason.noConnection),
    );
  });

  test('no inicia dos sincronizaciones a la vez', () async {
    final remoteCatalog = FakePokeApiCatalog(pokemonCount: 120);
    final syncService = syncServiceOver(remoteCatalog);

    final firstSync = syncService.syncCatalog();
    final secondSync = syncService.syncCatalog();
    await Future.wait([firstSync, secondSync]);

    expect(identical(firstSync, secondSync), isTrue);
    expect(remoteCatalog.requestedOffsets, [0, 50, 100]);
  });

  test('emite En curso y después Completada', () async {
    final syncService = syncServiceOver(FakePokeApiCatalog(pokemonCount: 120));
    final statusUpdates = StreamQueue(syncService.watchStatus());
    addTearDown(statusUpdates.cancel);

    expect(await statusUpdates.next, isA<CatalogSyncIdle>());

    final sync = syncService.syncCatalog();
    expect(await statusUpdates.next, isA<CatalogSyncInProgress>());
    expect(await statusUpdates.next, isA<CatalogSyncSucceeded>());
    await sync;
  });

  test('sincronizar dos veces no repite ningún id', () async {
    final remoteCatalog = FakePokeApiCatalog(pokemonCount: 120);
    final syncService = syncServiceOver(remoteCatalog);

    await syncService.syncCatalog();
    now = now.add(const Duration(hours: 25));
    await syncService.syncCatalog();
    final ids = await savedPokemonIds();

    expect(remoteCatalog.requestedOffsets, [0, 50, 100, 0, 50, 100]);
    expect(ids, hasLength(120));
    expect(ids.toSet(), hasLength(120));
  });


  test('emite fallo si la comprobación de Internet lanza una excepción', () async {
    final remoteCatalog = FakePokeApiCatalog(pokemonCount: 120);

    final syncService = syncServiceOver(
      remoteCatalog,
      hasInternetAccess: () async {
        throw StateError('No se pudo comprobar la conexión');
      },
    );

    await expectLater(
      syncService.syncCatalog(),
      throwsA(isA<StateError>()),
    );

    expect(remoteCatalog.requestedOffsets, isEmpty);

    expect(
      syncService.currentStatus,
      failedBecauseOf(CatalogSyncFailureReason.requestFailed),
    );
  });


  test('marca sincronización en curso antes de comprobar Internet', () async {
    final remoteCatalog = FakePokeApiCatalog(pokemonCount: 120);
    final connectionCheck = Completer<bool>();

    final syncService = syncServiceOver(
      remoteCatalog,
      hasInternetAccess: () => connectionCheck.future,
    );

    final sync = syncService.syncCatalog();

    expect(
      syncService.currentStatus,
      isA<CatalogSyncInProgress>(),
    );

    connectionCheck.complete(false);
    await sync;

    expect(
      syncService.currentStatus,
      failedBecauseOf(CatalogSyncFailureReason.noConnection),
    );
  });

}
