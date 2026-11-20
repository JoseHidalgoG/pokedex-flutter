import 'package:async/async.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';
import 'package:pokedex_flutter/features/catalog/data/catalog_fingerprint.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_dao.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';

const bulbasaur = CatalogEntry(
  id: 1,
  name: 'bulbasaur',
  imageUrl: 'https://example.com/1.png',
  typeNames: ['grass', 'poison'],
  speciesId: 1,
  generationId: 1,
  heightDm: 7,
  weightHg: 69,
  baseStats: {
    'hp': 45,
    'attack': 49,
    'defense': 49,
    'special-attack': 65,
    'special-defense': 65,
    'speed': 45,
  },
);
const charmander = CatalogEntry(
  id: 4,
  name: 'charmander',
  imageUrl: 'https://example.com/4.png',
  typeNames: ['fire'],
  baseStats: {'hp': 39, 'speed': 65},
);
const squirtle = CatalogEntry(
  id: 7,
  name: 'squirtle',
  imageUrl: 'https://example.com/7.png',
  typeNames: ['water'],
  baseStats: {'hp': 44, 'speed': 43},
);

void main() {
  late AppDatabase database;
  late CatalogDao catalogDao;
  final savedAt = DateTime(2026, 11, 7, 10, 30);

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    catalogDao = database.catalogDao;
  });

  tearDown(() => database.close());

  Future<void> savePage(
    List<CatalogEntry> entries, {
    int nextOffset = 50,
    bool isComplete = false,
    int? totalCount,
  }) {
    return catalogDao.saveCatalogPage(
      entries: entries,
      nextOffset: nextOffset,
      isComplete: isComplete,
      savedAt: savedAt,
      totalCount: totalCount,
    );
  }

  Future<PokemonRow> savedPokemonRow(int id) {
    return (database.select(
      database.pokemonTable,
    )..where((pokemon) => pokemon.id.equals(id))).getSingle();
  }

  Future<Map<String, int>> savedStatsOf(int pokemonId) async {
    final rows = await (database.select(
      database.pokemonStatsTable,
    )..where((stat) => stat.pokemonId.equals(pokemonId))).get();
    return {for (final row in rows) row.statName: row.baseStat};
  }

  Future<int> countRowsIn(TableInfo<Table, Object?> table) {
    return database.select(table).get().then((rows) => rows.length);
  }

  List<int> idsOf(List<CatalogEntry> entries) => [
    for (final entry in entries) entry.id,
  ];

  test('guardar el mismo lote tres veces no duplica Pokémon, tipos ni estadísticas', () async {
    await savePage([bulbasaur, charmander, squirtle]);
    await savePage([bulbasaur, charmander, squirtle]);
    await savePage([bulbasaur, charmander, squirtle]);

    expect(await countRowsIn(database.pokemonTable), 3);
    expect(await countRowsIn(database.pokemonTypesTable), 4);
    expect(await countRowsIn(database.pokemonStatsTable), 10);
  });

  test(
    'guarda especie, generación, medidas, total y huella de cada Pokémon',
    () async {
      await savePage([bulbasaur]);

      final row = await savedPokemonRow(1);

      expect(row.speciesId, 1);
      expect(row.generationId, 1);
      expect(row.isDefault, isTrue);
      expect(row.heightDm, 7);
      expect(row.weightHg, 69);
      expect(row.baseStatTotal, 318);
      expect(row.remoteFingerprint, catalogFingerprintOf(bulbasaur));
      expect(await savedStatsOf(1), bulbasaur.baseStats);
    },
  );

  test(
    'reemplaza las estadísticas y la huella cuando el Pokémon vuelve cambiado',
    () async {
      const changedBulbasaur = CatalogEntry(
        id: 1,
        name: 'bulbasaur',
        imageUrl: 'https://example.com/1.png',
        typeNames: ['grass', 'poison'],
        baseStats: {'hp': 50, 'attack': 49},
      );
      await savePage([bulbasaur]);

      await savePage([changedBulbasaur]);
      final row = await savedPokemonRow(1);

      expect(await savedStatsOf(1), {'hp': 50, 'attack': 49});
      expect(row.baseStatTotal, 99);
      expect(row.remoteFingerprint, catalogFingerprintOf(changedBulbasaur));
    },
  );

  test(
    'guarda el total del primer lote y lo conserva en los siguientes',
    () async {
      await savePage([bulbasaur], nextOffset: 100, totalCount: 1025);
      await savePage([charmander], nextOffset: 200);

      final progress = await catalogDao.readCatalogSyncProgress();

      expect(progress?.totalCount, 1025);
      expect(progress?.nextOffset, 200);
    },
  );

  test(
    'reemplaza los tipos de un Pokémon cuando vuelve a llegar con otros',
    () async {
      await savePage([bulbasaur]);
      await savePage([
        const CatalogEntry(
          id: 1,
          name: 'bulbasaur',
          imageUrl: 'https://example.com/1.png',
          typeNames: ['grass'],
        ),
      ]);

      final catalog = await catalogDao.watchCatalog().first;

      expect(catalog.single.typeNames, ['grass']);
    },
  );

  test(
    'emite el catálogo ordenado por número con los tipos en orden de slot',
    () async {
      await savePage([squirtle, bulbasaur, charmander]);

      final catalog = await catalogDao.watchCatalog().first;

      expect(idsOf(catalog), [1, 4, 7]);
      expect(catalog.first.name, 'bulbasaur');
      expect(catalog.first.imageUrl, 'https://example.com/1.png');
      expect(catalog.first.typeNames, ['grass', 'poison']);
    },
  );

  test('vuelve a emitir el catálogo cuando se guarda una página', () async {
    final catalogUpdates = StreamQueue(catalogDao.watchCatalog().map(idsOf));
    addTearDown(catalogUpdates.cancel);

    expect(await catalogUpdates.next, isEmpty);

    await savePage([bulbasaur, charmander]);
    expect(await catalogUpdates.next, [1, 4]);

    await savePage([squirtle], nextOffset: 100);
    expect(await catalogUpdates.next, [1, 4, 7]);
  });

  test(
    'emite solo los Pokémon de la página pedida aunque tengan varios tipos',
    () async {
      await savePage([squirtle, bulbasaur, charmander]);

      final firstPage = await catalogDao
          .watchCatalogPage(limit: 2, offset: 0)
          .first;

      expect(idsOf(firstPage), [1, 4]);
      expect(firstPage.first.typeNames, ['grass', 'poison']);
    },
  );

  test('la última página trae solo los Pokémon que quedan', () async {
    await savePage([bulbasaur, charmander, squirtle]);

    final lastPage = await catalogDao
        .watchCatalogPage(limit: 2, offset: 2)
        .first;
    final pageAfterTheEnd = await catalogDao
        .watchCatalogPage(limit: 2, offset: 4)
        .first;

    expect(idsOf(lastPage), [7]);
    expect(pageAfterTheEnd, isEmpty);
  });

  test('vuelve a emitir la página cuando se guardan Pokémon en ella', () async {
    final pageUpdates = StreamQueue(
      catalogDao.watchCatalogPage(limit: 2, offset: 0).map(idsOf),
    );
    addTearDown(pageUpdates.cancel);

    expect(await pageUpdates.next, isEmpty);

    await savePage([charmander, squirtle]);
    expect(await pageUpdates.next, [4, 7]);

    await savePage([bulbasaur], nextOffset: 100);
    expect(await pageUpdates.next, [1, 4]);
  });

  test(
    'cuenta Pokémon y no filas de tipos, y se actualiza al guardar',
    () async {
      final countUpdates = StreamQueue(catalogDao.watchCatalogCount());
      addTearDown(countUpdates.cancel);

      expect(await countUpdates.next, 0);

      await savePage([bulbasaur, charmander]);
      expect(await countUpdates.next, 2);

      await savePage([squirtle], nextOffset: 100);
      expect(await countUpdates.next, 3);
    },
  );

  test(
    'emite solo los Pokémon pedidos, con sus tipos en orden de slot',
    () async {
      await savePage([bulbasaur, charmander, squirtle]);

      final requested = await catalogDao.watchPokemonByIds([1, 7]).first;

      expect(idsOf(requested), [1, 7]);
      expect(requested.first.name, 'bulbasaur');
      expect(requested.first.imageUrl, 'https://example.com/1.png');
      expect(requested.first.typeNames, ['grass', 'poison']);
      expect(requested.last.typeNames, ['water']);
    },
  );

  test('emite los Pokémon en el orden en que se pidieron los ids', () async {
    await savePage([bulbasaur, charmander, squirtle]);

    final requested = await catalogDao.watchPokemonByIds([7, 1, 4]).first;

    expect(idsOf(requested), [7, 1, 4]);
  });

  test(
    'omite los ids que no están en el catálogo y no repite los duplicados',
    () async {
      await savePage([bulbasaur, charmander]);

      final requested = await catalogDao.watchPokemonByIds([4, 25, 4]).first;

      expect(idsOf(requested), [4]);
    },
  );

  test('una lista de ids vacía emite una lista vacía', () async {
    await savePage([bulbasaur]);

    expect(await catalogDao.watchPokemonByIds(const []).first, isEmpty);
  });

  test('vuelve a emitir cuando se guardan los Pokémon pedidos', () async {
    final requestedUpdates = StreamQueue(
      catalogDao.watchPokemonByIds([1, 4]).map(idsOf),
    );
    addTearDown(requestedUpdates.cancel);

    expect(await requestedUpdates.next, isEmpty);

    await savePage([bulbasaur]);
    expect(await requestedUpdates.next, [1]);

    await savePage([charmander, squirtle], nextOffset: 100);
    expect(await requestedUpdates.next, [1, 4]);
  });

  test('guarda el siguiente offset junto con la página', () async {
    await savePage([bulbasaur, charmander, squirtle], nextOffset: 50);

    final progress = await catalogDao.readCatalogSyncProgress();

    expect(progress?.nextOffset, 50);
    expect(progress?.isComplete, isFalse);
    expect(progress?.lastSyncedAt, savedAt);
    expect(progress?.lastError, isNull);
  });

  test('no tiene progreso antes de la primera sincronización', () async {
    expect(await catalogDao.readCatalogSyncProgress(), isNull);
  });

  test('limpia el último error cuando una página se guarda bien', () async {
    await database.syncMetadataDao.recordPending(
      CatalogDao.catalogSyncKey,
      failure: const NoConnection(),
    );

    await savePage([bulbasaur], nextOffset: 50, isComplete: true);
    final progress = await catalogDao.readCatalogSyncProgress();

    expect(progress?.lastError, isNull);
    expect(progress?.isComplete, isTrue);
  });

  test('resincronizar el catálogo no toca los favoritos', () async {
    await savePage([bulbasaur, charmander]);
    await database
        .into(database.favoritesTable)
        .insert(
          FavoritesTableCompanion.insert(
            pokemonId: const Value(4),
            createdAt: savedAt,
          ),
        );

    await savePage([bulbasaur, charmander]);
    final favorites = await database.select(database.favoritesTable).get();

    expect([for (final favorite in favorites) favorite.pokemonId], [4]);
  });

  group('revalidación de lo visible', () {
    final limit = savedAt.add(const Duration(minutes: 30));

    test(
      'staleIdsAmong devuelve solo los ids pedidos guardados antes del límite',
      () async {
        await savePage([bulbasaur, charmander]);
        await catalogDao.saveRevalidated([
          squirtle,
        ], savedAt: limit.add(const Duration(minutes: 1)));

        final staleIds = await catalogDao.staleIdsAmong([
          7,
          4,
          1,
          150,
        ], olderThan: limit);

        expect(staleIds, [1, 4]);
      },
    );

    test(
      'staleIdsAmong no cuenta los ids que no están en el catálogo',
      () async {
        await savePage([bulbasaur]);

        expect(
          await catalogDao.staleIdsAmong([150], olderThan: limit),
          isEmpty,
        );
      },
    );

    test('saveRevalidated actualiza los Pokémon sin tocar el progreso del catálogo', () async {
      const renamedBulbasaur = CatalogEntry(
        id: 1,
        name: 'bulbasaur-renombrado',
        imageUrl: 'https://example.com/1.png',
        typeNames: ['grass'],
        baseStats: {'hp': 50},
      );
      await savePage([bulbasaur, charmander], nextOffset: 50);

      await catalogDao.saveRevalidated([renamedBulbasaur], savedAt: limit);
      final row = await savedPokemonRow(1);
      final progress = await catalogDao.readCatalogSyncProgress();

      expect(row.name, 'bulbasaur-renombrado');
      expect(row.updatedAt, limit);
      expect(row.remoteFingerprint, catalogFingerprintOf(renamedBulbasaur));
      expect(await savedStatsOf(1), {'hp': 50});
      expect((await savedPokemonRow(4)).updatedAt, savedAt);
      expect(progress?.nextOffset, 50);
      expect(progress?.lastSyncedAt, savedAt);
    });

    test('la página vuelve a emitirse con el nombre revalidado', () async {
      await savePage([bulbasaur, charmander]);
      final pageNames = StreamQueue(
        catalogDao
            .watchCatalogPage(limit: 2, offset: 0)
            .map((entries) => [for (final entry in entries) entry.name]),
      );
      addTearDown(pageNames.cancel);

      expect(await pageNames.next, ['bulbasaur', 'charmander']);

      await catalogDao.saveRevalidated(const [
        CatalogEntry(
          id: 4,
          name: 'charmander-renombrado',
          imageUrl: 'https://example.com/4.png',
          typeNames: ['fire'],
        ),
      ], savedAt: limit);

      expect(await pageNames.next, ['bulbasaur', 'charmander-renombrado']);
    });
  });

  test('el esquema crea los índices de búsqueda, filtros y ranking', () async {
    final indexes = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name NOT LIKE 'sqlite_autoindex_%'",
        )
        .map((row) => row.read<String>('name'))
        .get();

    expect(
      indexes,
      containsAll([
        'pokemon_name_nocase',
        'pokemon_generation_id',
        'pokemon_base_stat_total',
        'pokemon_species_id',
        'pokemon_types_by_type',
        'pokemon_moves_by_version_and_method',
        'trivia_results_by_score',
      ]),
    );
  });
}
