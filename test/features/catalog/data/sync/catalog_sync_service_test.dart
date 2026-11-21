import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/core/sync/domain/call_budget.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_job.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';
import 'package:pokedex_flutter/features/catalog/data/catalog_fingerprint.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_dao.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_batch.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_remote_data_source.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto_mapper.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/catalog_sync_service.dart';

typedef CatalogPageRequest = ({int offset, bool withTotal});

class FakePokeApiCatalog implements CatalogRemoteDataSource {
  FakePokeApiCatalog({
    required int pokemonCount,
    this.failingOffset,
    this.failsRequestsByIds = false,
  }) : _catalog = [
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
  final bool failsRequestsByIds;
  final requests = <CatalogPageRequest>[];
  final requestedIdLists = <List<int>>[];

  List<int> get requestedOffsets => [
    for (final request in requests) request.offset,
  ];

  List<PokemonDto> pokemonUpTo(int count) => _catalog.take(count).toList();

  List<PokemonDto> pokemonWithIds(List<int> ids) => [
    for (final pokemon in _catalog)
      if (ids.contains(pokemon.id)) pokemon,
  ];

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

  @override
  Future<List<PokemonDto>> fetchPokemonByIds(
    List<int> ids, {
    CallPriority priority = CallPriority.user,
  }) async {
    requestedIdLists.add(ids);
    if (failsRequestsByIds) {
      throw const ServerError(503);
    }
    return [
      for (final pokemon in pokemonWithIds(ids))
        PokemonDto(
          id: pokemon.id,
          name: '${pokemon.name}-revalidado',
          typeNames: pokemon.typeNames,
          baseStats: pokemon.baseStats,
        ),
    ];
  }
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

  CatalogSyncService syncServiceOver(FakePokeApiCatalog remoteCatalog) {
    return CatalogSyncService(
      remoteDataSource: remoteCatalog,
      catalogDao: catalogDao,
      now: () => now,
    );
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

  group('la pasada completa', () {
    test('descarga los 1025 Pokémon en 11 llamadas y solo la primera pide el total', () async {
      final remoteCatalog = FakePokeApiCatalog(pokemonCount: 1025);

      final outcome = await syncServiceOver(remoteCatalog).syncCatalog();
      final progress = await catalogDao.readCatalogSyncProgress();

      expect(outcome, SyncOutcome.revalidated);
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
    });

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
      'sobrescribe con el dato de PokeAPI un Pokémon alterado en la base',
      () async {
        final remoteCatalog = FakePokeApiCatalog(pokemonCount: 120);
        await saveAlreadyDownloaded(
          remoteCatalog,
          count: 120,
          isComplete: true,
          savedAt: now.subtract(const Duration(minutes: 10)),
        );
        await database.customStatement(
          "UPDATE pokemon SET name = 'alterado' WHERE id = 25",
        );

        await syncServiceOver(remoteCatalog).syncCatalog(force: true);
        final stored = await catalogDao.readEntriesWithFingerprint();
        final pokemon25 = stored.singleWhere((item) => item.entry.id == 25);

        expect(pokemon25.entry.name, 'pokemon-25');
        expect(
          catalogFingerprintOf(pokemon25.entry),
          pokemon25.storedFingerprint,
        );
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
  });

  group('continuar una pasada cortada', () {
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
  });

  group('vigencia de 1 h', () {
    test('no pide nada si el catálogo está completo y la última pasada tiene menos de 1 h', () async {
      final remoteCatalog = FakePokeApiCatalog(pokemonCount: 120);
      await saveAlreadyDownloaded(
        remoteCatalog,
        count: 120,
        isComplete: true,
        savedAt: now.subtract(const Duration(minutes: 59)),
      );

      final outcome = await syncServiceOver(remoteCatalog).syncCatalog();

      expect(outcome, SyncOutcome.upToDate);
      expect(remoteCatalog.requestedOffsets, isEmpty);
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

      final outcome = await syncServiceOver(remoteCatalog).syncCatalog();
      final progress = await catalogDao.readCatalogSyncProgress();

      expect(outcome, SyncOutcome.revalidated);
      expect(remoteCatalog.requests, [
        (offset: 0, withTotal: true),
        (offset: 100, withTotal: false),
      ]);
      expect(progress?.isComplete, isTrue);
      expect(progress?.lastSyncedAt, now);
    });

    test('force true vuelve a descargar un catálogo reciente', () async {
      final remoteCatalog = FakePokeApiCatalog(pokemonCount: 120);
      await saveAlreadyDownloaded(
        remoteCatalog,
        count: 120,
        isComplete: true,
        savedAt: now.subtract(const Duration(minutes: 10)),
      );

      final outcome = await syncServiceOver(remoteCatalog)
          .syncCatalog(force: true);
      final progress = await catalogDao.readCatalogSyncProgress();

      expect(outcome, SyncOutcome.revalidated);
      expect(remoteCatalog.requestedOffsets, [0, 100]);
      expect(progress?.lastSyncedAt, now);
    });
  });

  group('fallos', () {
    test(
      'ante un error lanza el fallo y conserva los lotes ya guardados',
      () async {
        final remoteCatalog = FakePokeApiCatalog(
          pokemonCount: 250,
          failingOffset: 100,
        );

        await expectLater(
          syncServiceOver(remoteCatalog).syncCatalog(),
          throwsA(const ServerError(503)),
        );
        final progress = await catalogDao.readCatalogSyncProgress();

        expect(remoteCatalog.requestedOffsets, [0, 100]);
        expect(await savedPokemonIds(), hasLength(100));
        expect(progress?.nextOffset, 100);
        expect(progress?.isComplete, isFalse);
      },
    );

    test('force true conserva los datos cuando PokeAPI falla', () async {
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

      await expectLater(
        syncServiceOver(remoteCatalog).syncCatalog(force: true),
        throwsA(const ServerError(503)),
      );

      expect(await savedPokemonIds(), hasLength(120));
    });

    test('un error de la base sale como SyncFailure', () async {
      final remoteCatalog = FakePokeApiCatalog(pokemonCount: 120);
      await database.customStatement('DROP TABLE pokemon_stats');

      await expectLater(
        syncServiceOver(remoteCatalog).syncCatalog(),
        throwsA(
          isA<QueryError>().having(
            (failure) => failure.message,
            'message',
            contains('pokemon_stats'),
          ),
        ),
      );
    });
  });

  group('revalidación de lo visible', () {
    Future<PokemonRow> savedPokemonRow(int id) {
      return (database.select(
        database.pokemonTable,
      )..where((pokemon) => pokemon.id.equals(id))).getSingle();
    }

    Future<void> saveRevalidatedAgo(
      FakePokeApiCatalog remoteCatalog,
      Duration age, {
      required List<int> ids,
    }) {
      return catalogDao.saveRevalidated([
        for (final pokemon in remoteCatalog.pokemonWithIds(ids))
          pokemon.toCatalogEntry(),
      ], savedAt: now.subtract(age));
    }

    test(
      'con todos los ids guardados hace menos de 15 min no llama a PokeAPI',
      () async {
        final remoteCatalog = FakePokeApiCatalog(pokemonCount: 3);
        await saveRevalidatedAgo(
          remoteCatalog,
          const Duration(minutes: 14),
          ids: [1, 2, 3],
        );
        final syncService = syncServiceOver(remoteCatalog);

        final outcome = await syncService.revalidatePokemon([1, 2, 3]);

        expect(outcome, SyncOutcome.upToDate);
        expect(await syncService.hasStalePokemonAmong([1, 2, 3]), isFalse);
        expect(remoteCatalog.requestedIdLists, isEmpty);
      },
    );

    test('pide solo los ids vencidos en una llamada y los guarda con la hora actual', () async {
      final remoteCatalog = FakePokeApiCatalog(pokemonCount: 3);
      await saveRevalidatedAgo(
        remoteCatalog,
        const Duration(minutes: 16),
        ids: [1, 3],
      );
      await saveRevalidatedAgo(
        remoteCatalog,
        const Duration(minutes: 5),
        ids: [2],
      );
      final syncService = syncServiceOver(remoteCatalog);

      expect(await syncService.hasStalePokemonAmong([1, 2, 3]), isTrue);
      final outcome = await syncService.revalidatePokemon([1, 2, 3]);

      expect(outcome, SyncOutcome.revalidated);
      expect(remoteCatalog.requestedIdLists, [
        [1, 3],
      ]);
      expect((await savedPokemonRow(1)).name, 'pokemon-1-revalidado');
      expect((await savedPokemonRow(1)).updatedAt, now);
      expect((await savedPokemonRow(2)).name, 'pokemon-2');
    });

    test('force pide todos los ids aunque estén frescos', () async {
      final remoteCatalog = FakePokeApiCatalog(pokemonCount: 2);
      await saveRevalidatedAgo(
        remoteCatalog,
        const Duration(minutes: 1),
        ids: [1, 2],
      );

      final outcome = await syncServiceOver(remoteCatalog)
          .revalidatePokemon([1, 2], force: true);

      expect(outcome, SyncOutcome.revalidated);
      expect(remoteCatalog.requestedIdLists, [
        [1, 2],
      ]);
    });

    test('ante un fallo de PokeAPI lo lanza y conserva los datos', () async {
      final remoteCatalog = FakePokeApiCatalog(
        pokemonCount: 1,
        failsRequestsByIds: true,
      );
      await saveRevalidatedAgo(
        remoteCatalog,
        const Duration(hours: 2),
        ids: [1],
      );

      await expectLater(
        syncServiceOver(remoteCatalog).revalidatePokemon([1]),
        throwsA(const ServerError(503)),
      );
      expect((await savedPokemonRow(1)).name, 'pokemon-1');
    });

    test(
      'la tarea usa la clave catalog:visible y la prioridad del usuario',
      () async {
        final remoteCatalog = FakePokeApiCatalog(pokemonCount: 1);
        await saveRevalidatedAgo(
          remoteCatalog,
          const Duration(hours: 2),
          ids: [1],
        );

        final job = syncServiceOver(remoteCatalog)
            .visiblePokemonJob([1], force: true);
        final outcome = await job.perform();

        expect(job.key, 'catalog:visible');
        expect(job.priority, CallPriority.user);
        expect(job.runningStatus, isA<SyncRevalidating>());
        expect(job.force, isTrue);
        expect(outcome, SyncOutcome.revalidated);
      },
    );
  });

  test('la tarea de la pasada completa usa la clave catalog y la prioridad de fondo', () async {
    final remoteCatalog = FakePokeApiCatalog(pokemonCount: 120);

    final job = syncServiceOver(remoteCatalog).fullPassJob(force: true);
    final outcome = await job.perform();

    expect(job.key, 'catalog');
    expect(job.priority, CallPriority.background);
    expect(job.runningStatus, isA<SyncFullPassInProgress>());
    expect(job.force, isTrue);
    expect(outcome, SyncOutcome.revalidated);
    expect(remoteCatalog.requestedOffsets, [0, 100]);
  });
}
