import 'package:async/async.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';
import 'package:pokedex_flutter/features/catalog/data/catalog_fingerprint.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_dao.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query.dart';

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

const ivysaur = CatalogEntry(
  id: 2,
  name: 'ivysaur',
  imageUrl: 'https://example.com/2.png',
  typeNames: ['grass', 'poison'],
  baseStats: {
    'hp': 60,
    'attack': 62,
    'defense': 63,
    'special-attack': 80,
    'special-defense': 80,
    'speed': 60,
  },
);

const pikachu = CatalogEntry(
  id: 25,
  name: 'pikachu',
  imageUrl: 'https://example.com/25.png',
  typeNames: ['electric'],
);

const raichu = CatalogEntry(
  id: 26,
  name: 'raichu',
  imageUrl: 'https://example.com/26.png',
  typeNames: ['electric'],
  speciesId: 26,
  baseStats: {
    'hp': 60,
    'attack': 90,
    'defense': 55,
    'special-attack': 90,
    'special-defense': 80,
    'speed': 110,
  },
);

const alolanRaichu = CatalogEntry(
  id: 10100,
  name: 'raichu-alola',
  imageUrl: 'https://example.com/10100.png',
  typeNames: ['electric', 'psychic'],
  speciesId: 26,
  isDefault: false,
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

  Future<List<CatalogEntry>> filteredPage({
    CatalogQuery query = const CatalogQuery(),
    int limit = 50,
    int offset = 0,
  }) {
    return catalogDao
        .watchFilteredCatalogPage(limit: limit, offset: offset, query: query)
        .first;
  }

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

  group('lectura para verificar huellas', () {
    test('readEntriesWithFingerprint arma cada Pokémon completo con su huella guardada', () async {
      await savePage([squirtle, bulbasaur]);

      final stored = await catalogDao.readEntriesWithFingerprint();
      final (:entry, :storedFingerprint) = stored.first;

      expect([for (final item in stored) item.entry.id], [1, 7]);
      expect(entry.name, 'bulbasaur');
      expect(entry.imageUrl, 'https://example.com/1.png');
      expect(entry.typeNames, ['grass', 'poison']);
      expect(entry.speciesId, 1);
      expect(entry.generationId, 1);
      expect(entry.isDefault, isTrue);
      expect(entry.heightDm, 7);
      expect(entry.weightHg, 69);
      expect(entry.baseStats, bulbasaur.baseStats);
      expect(storedFingerprint, catalogFingerprintOf(bulbasaur));
      expect(catalogFingerprintOf(entry), storedFingerprint);
    });

    test(
      'readEntriesWithFingerprint ve un UPDATE hecho por fuera de la app',
      () async {
        await savePage([bulbasaur]);
        await database.customStatement(
          "UPDATE pokemon_types SET type_name = 'fire' WHERE pokemon_id = 1 "
          'AND slot = 1',
        );

        final stored = await catalogDao.readEntriesWithFingerprint();

        expect(stored.single.entry.typeNames, ['fire', 'poison']);
        expect(
          catalogFingerprintOf(stored.single.entry),
          isNot(stored.single.storedFingerprint),
        );
      },
    );

    test(
      'un Pokémon sin tipos ni estadísticas sale con listas vacías',
      () async {
        await savePage([bulbasaur]);
        await database.customStatement(
          'DELETE FROM pokemon_types WHERE pokemon_id = 1',
        );
        await database.customStatement(
          'DELETE FROM pokemon_stats WHERE pokemon_id = 1',
        );

        final stored = await catalogDao.readEntriesWithFingerprint();

        expect(stored.single.entry.typeNames, isEmpty);
        expect(stored.single.entry.baseStats, isEmpty);
      },
    );

    test('storedFingerprintsOf devuelve solo las huellas pedidas', () async {
      await savePage([bulbasaur, charmander, squirtle]);
      await database.customStatement(
        'UPDATE pokemon SET remote_fingerprint = NULL WHERE id = 4',
      );

      final fingerprints = await catalogDao.storedFingerprintsOf([1, 4, 150]);

      expect(fingerprints, {1: catalogFingerprintOf(bulbasaur), 4: null});
    });

    test('recordFingerprintsVerified anota la hora sin tocar el progreso del catálogo', () async {
      await savePage([bulbasaur], nextOffset: 50);
      final verifiedAt = savedAt.add(const Duration(minutes: 1));

      await catalogDao.recordFingerprintsVerified(at: verifiedAt);
      final restoration = await database.syncMetadataDao.readByKey(
        'catalog:restore',
      );
      final catalog = await catalogDao.readCatalogSyncProgress();

      expect(restoration?.lastVerifiedAt, verifiedAt);
      expect(catalog?.lastVerifiedAt, isNull);
      expect(catalog?.nextOffset, 50);
    });
  });

  group('formas que no son Pokémon por defecto', () {
    const alolanRaichu = CatalogEntry(
      id: 10100,
      name: 'raichu-alola',
      imageUrl: 'https://example.com/10100.png',
      typeNames: ['electric', 'psychic'],
      speciesId: 26,
      isDefault: false,
    );
    const raichu = CatalogEntry(
      id: 26,
      name: 'raichu',
      imageUrl: 'https://example.com/26.png',
      typeNames: ['electric'],
      speciesId: 26,
    );

    test(
      'el catálogo, sus páginas y su conteo dejan fuera las formas',
      () async {
        await savePage([bulbasaur, raichu]);
        await catalogDao.saveRevalidated([alolanRaichu], savedAt: savedAt);

        final catalog = await catalogDao.watchCatalog().first;
        final page = await catalogDao
            .watchCatalogPage(limit: 50, offset: 0)
            .first;

        expect(idsOf(catalog), [1, 26]);
        expect(idsOf(page), [1, 26]);
        expect(await catalogDao.watchCatalogCount().first, 2);
      },
    );

    test('una forma guardada se puede pedir por su id', () async {
      await catalogDao.saveRevalidated([alolanRaichu], savedAt: savedAt);

      final byIds = await catalogDao.watchPokemonByIds([10100]).first;

      expect(idsOf(byIds), [10100]);
    });

    test(
      'readEntriesOfSpecies trae el Pokémon y sus formas completos',
      () async {
        await savePage([bulbasaur, raichu]);
        await catalogDao.saveRevalidated([alolanRaichu], savedAt: savedAt);

        final forms = await catalogDao.readEntriesOfSpecies(26);

        expect(idsOf(forms), [26, 10100]);
        expect(forms.last.typeNames, ['electric', 'psychic']);
        expect(forms.last.isDefault, isFalse);
      },
    );

    test('readEntry trae un Pokémon con sus estadísticas', () async {
      await savePage([bulbasaur, charmander]);

      final entry = await catalogDao.readEntry(1);

      expect(entry?.name, 'bulbasaur');
      expect(entry?.typeNames, ['grass', 'poison']);
      expect(entry?.baseStats, bulbasaur.baseStats);
      expect(await catalogDao.readEntry(999), isNull);
    });
  });

  group('progreso del catálogo', () {
    test('empieza sin Pokémon guardados ni total conocido', () async {
      final progress = await catalogDao.watchCatalogProgress().first;

      expect(progress, (savedCount: 0, totalCount: null));
    });

    test(
      'cuenta los Pokémon por defecto guardados y el total de PokeAPI',
      () async {
        await savePage([bulbasaur, charmander], totalCount: 3);
        await catalogDao.saveRevalidated([
          const CatalogEntry(
            id: 10001,
            name: 'deoxys-attack',
            imageUrl: 'https://example.com/10001.png',
            typeNames: ['psychic'],
            isDefault: false,
          ),
        ], savedAt: savedAt);

        final progress = await catalogDao.watchCatalogProgress().first;

        expect(progress, (savedCount: 2, totalCount: 3));
      },
    );

    test('solo vuelve a emitir cuando el progreso cambia', () async {
      await savePage([bulbasaur, charmander], totalCount: 3);
      final progressUpdates = StreamQueue(catalogDao.watchCatalogProgress());
      addTearDown(progressUpdates.cancel);

      expect(await progressUpdates.next, (savedCount: 2, totalCount: 3));

      await catalogDao.recordFingerprintsVerified(at: savedAt);
      await savePage([squirtle], nextOffset: 3, isComplete: true);

      expect(await progressUpdates.next, (savedCount: 3, totalCount: 3));
    });
  });

  group('búsqueda, filtrado y ordenamiento del catálogo', () {
    setUp(() async {
      await savePage([
        raichu,
        squirtle,
        pikachu,
        charmander,
        ivysaur,
        bulbasaur,
        alolanRaichu,
      ]);
    });

    test('una consulta vacía devuelve todos los Pokémon por defecto', () async {
      final entries = await filteredPage();

      expect(idsOf(entries), [1, 2, 4, 7, 25, 26]);

      expect(
        await catalogDao.watchFilteredCatalogCount(const CatalogQuery()).first,
        6,
      );
    });

    group('búsqueda', () {
      test('encuentra un Pokémon por su nombre completo', () async {
        final entries = await filteredPage(
          query: const CatalogQuery(search: 'pikachu'),
        );

        expect(idsOf(entries), [25]);
      });

      test('encuentra Pokémon por una parte de su nombre', () async {
        final entries = await filteredPage(
          query: const CatalogQuery(search: 'saur'),
        );

        expect(idsOf(entries), [1, 2]);
      });

      test('la búsqueda no distingue mayúsculas y minúsculas', () async {
        final entries = await filteredPage(
          query: const CatalogQuery(search: 'PiKaChU'),
        );

        expect(idsOf(entries), [25]);
      });

      test('ignora los espacios al inicio y al final', () async {
        final entries = await filteredPage(
          query: const CatalogQuery(search: '  pikachu  '),
        );

        expect(idsOf(entries), [25]);
      });

      test('una búsqueda con solo espacios devuelve el catálogo', () async {
        final entries = await filteredPage(
          query: const CatalogQuery(search: '   '),
        );

        expect(idsOf(entries), [1, 2, 4, 7, 25, 26]);
      });

      test('encuentra un Pokémon por su número exacto', () async {
        final entries = await filteredPage(
          query: const CatalogQuery(search: '25'),
        );

        expect(idsOf(entries), [25]);
      });

      test('acepta números con ceros a la izquierda', () async {
        final entries = await filteredPage(
          query: const CatalogQuery(search: '0025'),
        );

        expect(idsOf(entries), [25]);
      });

      test('la búsqueda numérica no utiliza coincidencias parciales', () async {
        final entries = await filteredPage(
          query: const CatalogQuery(search: '2'),
        );

        expect(idsOf(entries), [2]);
      });

      test('devuelve una lista vacía si el nombre no existe', () async {
        final entries = await filteredPage(
          query: const CatalogQuery(search: 'inexistente'),
        );

        expect(entries, isEmpty);
      });

      test('devuelve una lista vacía si el número no existe', () async {
        final entries = await filteredPage(
          query: const CatalogQuery(search: '99999'),
        );

        expect(entries, isEmpty);
      });

      test('interpreta el porcentaje como un carácter literal', () async {
        final entries = await filteredPage(
          query: const CatalogQuery(search: '%'),
        );

        expect(entries, isEmpty);
      });

      test('interpreta el guion bajo como un carácter literal', () async {
        final entries = await filteredPage(
          query: const CatalogQuery(search: '_'),
        );

        expect(entries, isEmpty);
      });

      test('interpreta la barra invertida como un carácter literal', () async {
        final entries = await filteredPage(
          query: const CatalogQuery(search: r'\'),
        );

        expect(entries, isEmpty);
      });
    });

    group('filtrado por tipo', () {
      const expectedIdsByType = <String, List<int>>{
        'normal': [],
        'fire': [4],
        'water': [7],
        'electric': [25, 26],
        'grass': [1, 2],
        'ice': [],
        'fighting': [],
        'poison': [1, 2],
        'ground': [],
        'flying': [],
        'psychic': [],
        'bug': [],
        'rock': [],
        'ghost': [],
        'dragon': [],
        'dark': [],
        'steel': [],
        'fairy': [],
      };

      for (final entry in expectedIdsByType.entries) {
        test('filtra correctamente por el tipo ${entry.key}', () async {
          final query = CatalogQuery(type: entry.key);

          final entries = await filteredPage(query: query);

          final count = await catalogDao.watchFilteredCatalogCount(query).first;

          expect(idsOf(entries), entry.value);
          expect(count, entry.value.length);
        });
      }

      test('encuentra Pokémon por su segundo tipo', () async {
        final entries = await filteredPage(
          query: const CatalogQuery(type: 'poison'),
        );

        expect(idsOf(entries), [1, 2]);
        expect(entries.first.typeNames, ['grass', 'poison']);
        expect(entries.last.typeNames, ['grass', 'poison']);
      });

      test('no duplica Pokémon que tienen varios tipos', () async {
        final entries = await filteredPage(
          query: const CatalogQuery(type: 'grass'),
        );

        expect(entries.length, 2);
        expect(idsOf(entries), [1, 2]);
      });

      test('un tipo vacío no restringe el catálogo', () async {
        final entries = await filteredPage(query: const CatalogQuery(type: ''));

        expect(idsOf(entries), [1, 2, 4, 7, 25, 26]);
      });
    });

    group('ordenamiento', () {
      test('ordena por número ascendente', () async {
        final entries = await filteredPage(
          query: const CatalogQuery(sort: CatalogSort.numberAscending),
        );

        expect(idsOf(entries), [1, 2, 4, 7, 25, 26]);
      });

      test('ordena por número descendente', () async {
        final entries = await filteredPage(
          query: const CatalogQuery(sort: CatalogSort.numberDescending),
        );

        expect(idsOf(entries), [26, 25, 7, 4, 2, 1]);
      });

      test('ordena por nombre ascendente', () async {
        final entries = await filteredPage(
          query: const CatalogQuery(sort: CatalogSort.nameAscending),
        );

        expect(idsOf(entries), [1, 4, 2, 25, 26, 7]);
      });

      test('ordena por nombre descendente', () async {
        final entries = await filteredPage(
          query: const CatalogQuery(sort: CatalogSort.nameDescending),
        );

        expect(idsOf(entries), [7, 26, 25, 2, 4, 1]);
      });

      test('ordena por nombre sin distinguir mayúsculas', () async {
        await savePage(const [
          CatalogEntry(
            id: 150,
            name: 'Abra',
            imageUrl: '',
            typeNames: ['psychic'],
          ),
          CatalogEntry(
            id: 151,
            name: 'Zubat',
            imageUrl: '',
            typeNames: ['poison', 'flying'],
          ),
        ]);

        final entries = await filteredPage(
          query: const CatalogQuery(sort: CatalogSort.nameAscending),
        );

        expect(idsOf(entries), [150, 1, 4, 2, 25, 26, 7, 151]);
      });

      test('ordena por estadísticas base totales ascendentes', () async {
        final entries = await filteredPage(
          query: const CatalogQuery(sort: CatalogSort.baseStatTotalAscending),
        );

        expect(idsOf(entries), [7, 4, 1, 2, 26, 25]);
      });

      test('ordena por estadísticas base totales descendentes', () async {
        final entries = await filteredPage(
          query: const CatalogQuery(sort: CatalogSort.baseStatTotalDescending),
        );

        expect(idsOf(entries), [26, 2, 1, 4, 7, 25]);
      });

      test('los Pokémon sin estadísticas quedan al final', () async {
        final row = await savedPokemonRow(25);

        expect(row.baseStatTotal, isNull);

        final ascending = await filteredPage(
          query: const CatalogQuery(sort: CatalogSort.baseStatTotalAscending),
        );

        final descending = await filteredPage(
          query: const CatalogQuery(sort: CatalogSort.baseStatTotalDescending),
        );

        expect(ascending.last.id, 25);
        expect(descending.last.id, 25);
      });

      test('desempata estadísticas iguales por número ascendente', () async {
        await savePage(const [
          CatalogEntry(
            id: 10,
            name: 'pokemon-a',
            imageUrl: '',
            typeNames: ['bug'],
            baseStats: {'hp': 100},
          ),
          CatalogEntry(
            id: 11,
            name: 'pokemon-b',
            imageUrl: '',
            typeNames: ['bug'],
            baseStats: {'hp': 100},
          ),
        ]);

        final ascending = await filteredPage(
          query: const CatalogQuery(
            type: 'bug',
            sort: CatalogSort.baseStatTotalAscending,
          ),
        );

        final descending = await filteredPage(
          query: const CatalogQuery(
            type: 'bug',
            sort: CatalogSort.baseStatTotalDescending,
          ),
        );

        expect(idsOf(ascending), [10, 11]);
        expect(idsOf(descending), [10, 11]);
      });

      test('desempata estadísticas nulas por número ascendente', () async {
        await savePage(const [
          CatalogEntry(
            id: 100,
            name: 'pokemon-sin-estadisticas',
            imageUrl: '',
            typeNames: ['electric'],
          ),
        ]);

        final entries = await filteredPage(
          query: const CatalogQuery(
            type: 'electric',
            sort: CatalogSort.baseStatTotalDescending,
          ),
        );

        expect(idsOf(entries), [26, 25, 100]);
      });
    });

    group('combinación de criterios', () {
      test('combina búsqueda por nombre y tipo', () async {
        final entries = await filteredPage(
          query: const CatalogQuery(search: 'saur', type: 'grass'),
        );

        expect(idsOf(entries), [1, 2]);
      });

      test('combina búsqueda, tipo y ordenamiento', () async {
        final entries = await filteredPage(
          query: const CatalogQuery(
            search: 'saur',
            type: 'poison',
            sort: CatalogSort.numberDescending,
          ),
        );

        expect(idsOf(entries), [2, 1]);
      });

      test('combina búsqueda numérica y tipo', () async {
        final entries = await filteredPage(
          query: const CatalogQuery(search: '25', type: 'electric'),
        );

        expect(idsOf(entries), [25]);
      });

      test('devuelve una lista vacía si los criterios no coinciden', () async {
        final entries = await filteredPage(
          query: const CatalogQuery(search: 'pikachu', type: 'water'),
        );

        expect(entries, isEmpty);
      });

      test('excluye las formas alternativas al buscar por nombre', () async {
        final entries = await filteredPage(
          query: const CatalogQuery(search: 'raichu'),
        );

        expect(idsOf(entries), [26]);
      });

      test('excluye las formas alternativas al buscar por número', () async {
        final entries = await filteredPage(
          query: const CatalogQuery(search: '10100'),
        );

        expect(entries, isEmpty);
      });
    });

    group('paginación filtrada', () {
      test('aplica el filtro antes de paginar', () async {
        const query = CatalogQuery(type: 'electric');

        final firstPage = await filteredPage(query: query, limit: 1, offset: 0);

        final secondPage = await filteredPage(
          query: query,
          limit: 1,
          offset: 1,
        );

        expect(idsOf(firstPage), [25]);
        expect(idsOf(secondPage), [26]);
      });

      test('aplica el ordenamiento antes de paginar', () async {
        const query = CatalogQuery(sort: CatalogSort.nameAscending);

        final firstPage = await filteredPage(query: query, limit: 2, offset: 0);

        final secondPage = await filteredPage(
          query: query,
          limit: 2,
          offset: 2,
        );

        final thirdPage = await filteredPage(query: query, limit: 2, offset: 4);

        expect(idsOf(firstPage), [1, 4]);
        expect(idsOf(secondPage), [2, 25]);
        expect(idsOf(thirdPage), [26, 7]);
      });

      test('pagina correctamente el ranking descendente', () async {
        const query = CatalogQuery(sort: CatalogSort.baseStatTotalDescending);

        final firstPage = await filteredPage(query: query, limit: 2, offset: 0);

        final secondPage = await filteredPage(
          query: query,
          limit: 2,
          offset: 2,
        );

        final thirdPage = await filteredPage(query: query, limit: 2, offset: 4);

        expect(idsOf(firstPage), [26, 2]);
        expect(idsOf(secondPage), [1, 4]);
        expect(idsOf(thirdPage), [7, 25]);
      });

      test(
        'la última página devuelve únicamente los resultados restantes',
        () async {
          final entries = await filteredPage(limit: 4, offset: 4);

          expect(idsOf(entries), [25, 26]);
        },
      );

      test(
        'devuelve una página vacía si el offset supera los resultados',
        () async {
          final entries = await filteredPage(
            query: const CatalogQuery(type: 'grass'),
            limit: 2,
            offset: 2,
          );

          expect(entries, isEmpty);
        },
      );

      test(
        'un Pokémon con dos tipos ocupa un solo lugar en la página',
        () async {
          final entries = await filteredPage(
            query: const CatalogQuery(type: 'grass'),
            limit: 1,
          );

          expect(idsOf(entries), [1]);
          expect(entries.single.typeNames, ['grass', 'poison']);
        },
      );
    });

    group('conteo filtrado', () {
      test('cuenta únicamente los resultados de la búsqueda', () async {
        final count = await catalogDao
            .watchFilteredCatalogCount(const CatalogQuery(search: 'saur'))
            .first;

        expect(count, 2);
      });

      test('cuenta correctamente una búsqueda numérica', () async {
        final count = await catalogDao
            .watchFilteredCatalogCount(const CatalogQuery(search: '25'))
            .first;

        expect(count, 1);
      });

      test('combina búsqueda y tipo en el conteo', () async {
        final count = await catalogDao
            .watchFilteredCatalogCount(
              const CatalogQuery(search: 'saur', type: 'poison'),
            )
            .first;

        expect(count, 2);
      });

      test('devuelve cero cuando no existen coincidencias', () async {
        final count = await catalogDao
            .watchFilteredCatalogCount(
              const CatalogQuery(search: 'pikachu', type: 'fire'),
            )
            .first;

        expect(count, 0);
      });

      test('el ordenamiento no modifica el conteo', () async {
        for (final sort in CatalogSort.values) {
          final count = await catalogDao
              .watchFilteredCatalogCount(
                CatalogQuery(type: 'electric', sort: sort),
              )
              .first;

          expect(count, 2);
        }
      });

      test('el conteo no está limitado al tamaño de la página', () async {
        const query = CatalogQuery(type: 'grass');

        final entries = await filteredPage(query: query, limit: 1);

        final count = await catalogDao.watchFilteredCatalogCount(query).first;

        expect(entries.length, 1);
        expect(count, 2);
      });
    });

    group('actualizaciones reactivas', () {
      test(
        'la búsqueda vuelve a emitir cuando aparece una coincidencia',
        () async {
          const query = CatalogQuery(search: 'char');

          final updates = StreamQueue(
            catalogDao
                .watchFilteredCatalogPage(limit: 50, offset: 0, query: query)
                .map(idsOf)
                .distinct(
                  (previous, next) =>
                      previous.length == next.length &&
                      previous.asMap().entries.every(
                        (entry) => entry.value == next[entry.key],
                      ),
                ),
          );

          addTearDown(updates.cancel);

          expect(await updates.next, [4]);

          await savePage(const [
            CatalogEntry(
              id: 6,
              name: 'charizard',
              imageUrl: '',
              typeNames: ['fire', 'flying'],
            ),
          ]);

          expect(await updates.next, [4, 6]);
        },
      );

      test(
        'el filtro vuelve a emitir cuando cambia el tipo de un Pokémon',
        () async {
          const query = CatalogQuery(type: 'fire');

          final updates = StreamQueue(
            catalogDao
                .watchFilteredCatalogPage(limit: 50, offset: 0, query: query)
                .map(idsOf),
          );

          addTearDown(updates.cancel);

          expect(await updates.next, [4]);

          await catalogDao.saveRevalidated(const [
            CatalogEntry(
              id: 25,
              name: 'pikachu',
              imageUrl: '',
              typeNames: ['fire'],
            ),
          ], savedAt: savedAt.add(const Duration(minutes: 1)));

          expect(await updates.next, [4, 25]);
        },
      );

      test('el conteo se actualiza al guardar nuevas coincidencias', () async {
        final updates = StreamQueue(
          catalogDao
              .watchFilteredCatalogCount(const CatalogQuery(type: 'fire'))
              .distinct(),
        );

        addTearDown(updates.cancel);

        expect(await updates.next, 1);

        await savePage(const [
          CatalogEntry(
            id: 6,
            name: 'charizard',
            imageUrl: '',
            typeNames: ['fire', 'flying'],
          ),
        ]);

        expect(await updates.next, 2);
      });

      test('el conteo disminuye cuando un Pokémon deja de coincidir', () async {
        final updates = StreamQueue(
          catalogDao
              .watchFilteredCatalogCount(const CatalogQuery(type: 'grass'))
              .distinct(),
        );

        addTearDown(updates.cancel);

        expect(await updates.next, 2);

        await catalogDao.saveRevalidated(const [
          CatalogEntry(
            id: 1,
            name: 'bulbasaur',
            imageUrl: '',
            typeNames: ['poison'],
          ),
        ], savedAt: savedAt.add(const Duration(minutes: 1)));

        expect(await updates.next, 1);
      });

      test('el ranking se actualiza cuando cambian las estadísticas', () async {
        final updates = StreamQueue(
          catalogDao
              .watchFilteredCatalogPage(
                limit: 50,
                offset: 0,
                query: const CatalogQuery(
                  sort: CatalogSort.baseStatTotalDescending,
                ),
              )
              .map(idsOf),
        );

        addTearDown(updates.cancel);

        expect(await updates.next, [26, 2, 1, 4, 7, 25]);

        await catalogDao.saveRevalidated(const [
          CatalogEntry(
            id: 25,
            name: 'pikachu',
            imageUrl: '',
            typeNames: ['electric'],
            baseStats: {
              'hp': 100,
              'attack': 100,
              'defense': 100,
              'special-attack': 100,
              'special-defense': 100,
              'speed': 100,
            },
          ),
        ], savedAt: savedAt.add(const Duration(minutes: 1)));

        expect(await updates.next, [25, 26, 2, 1, 4, 7]);
      });
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
