import 'package:async/async.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/features/catalog/data/catalog_fingerprint.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';
import 'package:pokedex_flutter/features/catalog/data/local/detail_entry.dart';
import 'package:pokedex_flutter/features/catalog/data/local/pokemon_detail_dao.dart';
import 'package:pokedex_flutter/features/catalog/data/local/type_efficacy_entry.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_detail_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_detail_dto_mapper.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/type_efficacy_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/type_efficacy_dto_mapper.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/catalog_sync_constants.dart';

import '../../../../fixtures/pokemon_detail_fixture.dart';

class RecordedSelects extends QueryInterceptor {
  final statements = <({String sql, List<Object?> arguments})>[];

  @override
  Future<List<Map<String, Object?>>> runSelect(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    statements.add((sql: statement, arguments: args));
    return super.runSelect(executor, statement, args);
  }
}

DetailEntry savedDetail(String pokemonName) {
  return PokemonDetailDto.fromJson(savedPokemonDetailJson(pokemonName))
      .toDetailEntry();
}

List<TypeEfficacyEntry> savedTypeEfficacyEntries() {
  return [
    for (final row in savedTypeEfficacyRows())
      TypeEfficacyDto.fromJson(row).toTypeEfficacyEntry(),
  ];
}

void main() {
  late AppDatabase database;
  late PokemonDetailDao detailDao;
  final savedAt = DateTime(2026, 11, 23, 9, 15);

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    detailDao = database.pokemonDetailDao;
  });

  tearDown(() => database.close());

  Future<int> rowCountOf(ResultSetImplementation<HasResultSet, Object?> table) {
    final rows = countAll();
    return (database.selectOnly(
      table,
    )..addColumns([rows])).map((row) => row.read(rows)!).getSingle();
  }

  Future<Map<String, int>> detailRowCounts() async {
    return {
      'pokemon': await rowCountOf(database.pokemonTable),
      'pokemon_types': await rowCountOf(database.pokemonTypesTable),
      'pokemon_stats': await rowCountOf(database.pokemonStatsTable),
      'species': await rowCountOf(database.speciesTable),
      'species_egg_groups': await rowCountOf(database.speciesEggGroupsTable),
      'abilities': await rowCountOf(database.abilitiesTable),
      'pokemon_abilities': await rowCountOf(database.pokemonAbilitiesTable),
      'moves': await rowCountOf(database.movesTable),
      'pokemon_moves': await rowCountOf(database.pokemonMovesTable),
      'evolutions': await rowCountOf(database.evolutionsTable),
      'pokemon_games': await rowCountOf(database.pokemonGamesTable),
      'sync_metadata': await rowCountOf(database.syncMetadataTable),
    };
  }

  Future<void> saveInCatalog(List<CatalogEntry> entries) {
    return database.catalogDao.saveCatalogPage(
      entries: entries,
      nextOffset: entries.length,
      isComplete: false,
      savedAt: savedAt,
    );
  }

  group('guardar y leer el detalle', () {
    test('lee completo el detalle de Pikachu que guardó', () async {
      await detailDao.saveDetail(savedDetail('pikachu'), savedAt: savedAt);

      final pikachu = (await detailDao.readDetail(25))!;

      expect(pikachu.pokemon.name, 'pikachu');
      expect(pikachu.pokemon.typeNames, ['electric']);
      expect(pikachu.pokemon.baseStats, hasLength(6));
      expect(pikachu.species?.name, 'pikachu');
      expect(pikachu.species?.evolutionChainId, 10);
      expect(pikachu.forms, hasLength(17));
      expect(pikachu.forms.last.name, 'pikachu-gmax');
      expect(pikachu.eggGroups, unorderedEquals(['ground', 'fairy']));
      expect(
        [for (final species in pikachu.evolutionChain) species.name],
        ['pikachu', 'raichu', 'pichu'],
      );
      expect(
        [for (final evolution in pikachu.evolutions) evolution.id],
        [16, 17],
      );
      expect(
        [for (final ability in pikachu.abilities) ability.name],
        ['Static', 'Lightning Rod'],
      );
      expect(pikachu.abilities.last.nameEs, 'Pararrayos');
      expect(pikachu.abilities.last.isHidden, isTrue);
      expect(
        pikachu.abilities.first.shortEffectEs,
        startsWith('La electricidad'),
      );
      expect(pikachu.moveVersionGroup, 'scarlet-violet');
      expect(pikachu.moves, hasLength(67));
      expect(pikachu.gameVersions, hasLength(46));
      expect(pikachu.detailSyncedAt, savedAt);
    });

    test('lee los movimientos con su método, su nivel y su nombre', () async {
      await detailDao.saveDetail(savedDetail('pikachu'), savedAt: savedAt);

      final moves = (await detailDao.readDetail(25))!.moves;
      final thunderbolt = moves.firstWhere(
        (move) => move.id == 85 && move.learnMethod == 'level-up',
      );

      expect(thunderbolt.name, 'Thunderbolt');
      expect(thunderbolt.nameEs, 'Rayo');
      expect(thunderbolt.typeName, 'electric');
      expect(thunderbolt.level, 36);
    });

    test('guardar el mismo detalle dos veces no duplica filas', () async {
      await detailDao.saveDetail(savedDetail('pikachu'), savedAt: savedAt);
      final countsAfterFirstSave = await detailRowCounts();

      await detailDao.saveDetail(savedDetail('pikachu'), savedAt: savedAt);

      expect(await detailRowCounts(), countsAfterFirstSave);
      expect(countsAfterFirstSave['pokemon'], 17);
      expect(countsAfterFirstSave['pokemon_moves'], 67);
    });

    test('el segundo guardado reemplaza las habilidades, los movimientos y los juegos', () async {
      final pikachu = savedDetail('pikachu');
      await detailDao.saveDetail(pikachu, savedAt: savedAt);

      await detailDao.saveDetail(
        DetailEntry(
          pokemon: pikachu.pokemon,
          species: pikachu.species,
          forms: pikachu.forms,
          eggGroups: pikachu.eggGroups,
          evolutionChain: pikachu.evolutionChain,
          evolutions: pikachu.evolutions,
          abilities: [pikachu.abilities.first],
          moveVersionGroup: 'sword-shield',
          moves: [pikachu.moves.first],
          gameVersions: const ['red'],
        ),
        savedAt: savedAt,
      );
      final replaced = (await detailDao.readDetail(25))!;

      expect(
        [for (final ability in replaced.abilities) ability.name],
        ['Static'],
      );
      expect(replaced.moveVersionGroup, 'sword-shield');
      expect(replaced.moves, hasLength(1));
      expect(replaced.gameVersions, ['red']);
    });

    test('reemplaza las evoluciones de toda la cadena', () async {
      final pikachu = savedDetail('pikachu');
      await detailDao.saveDetail(pikachu, savedAt: savedAt);

      await detailDao.saveDetail(
        DetailEntry(
          pokemon: pikachu.pokemon,
          species: pikachu.species,
          evolutionChain: pikachu.evolutionChain,
          evolutions: [pikachu.evolutions.last],
        ),
        savedAt: savedAt,
      );

      final evolutions = (await detailDao.readDetail(25))!.evolutions;
      expect([for (final evolution in evolutions) evolution.id], [17]);
    });

    test(
      'guardar otra especie de la cadena conserva sus grupos huevo',
      () async {
        final pikachu = savedDetail('pikachu');
        await detailDao.saveDetail(pikachu, savedAt: savedAt);

        await detailDao.saveDetail(
          DetailEntry(
            pokemon: const CatalogEntry(
              id: 26,
              name: 'raichu',
              imageUrl: 'https://example.com/26.png',
              typeNames: ['electric'],
              speciesId: 26,
            ),
            species: const SpeciesEntry(
              id: 26,
              name: 'raichu',
              generationId: 1,
              evolutionChainId: 10,
            ),
            eggGroups: const ['ground', 'fairy'],
            evolutionChain: pikachu.evolutionChain,
            evolutions: pikachu.evolutions,
          ),
          savedAt: savedAt,
        );

        expect(
          (await detailDao.readDetail(25))!.eggGroups,
          unorderedEquals(['ground', 'fairy']),
        );
      },
    );

    test(
      'abrir el detalle restaura los campos del catálogo del Pokémon',
      () async {
        final pikachu = savedDetail('pikachu');
        await detailDao.saveDetail(pikachu, savedAt: savedAt);
        await database.customStatement(
          "UPDATE pokemon SET name = 'pikachux' WHERE id = 25",
        );

        await detailDao.saveDetail(pikachu, savedAt: savedAt);
        final row = await (database.select(
          database.pokemonTable,
        )..where((pokemon) => pokemon.id.equals(25))).getSingle();

        expect(row.name, 'pikachu');
        expect(row.remoteFingerprint, catalogFingerprintOf(pikachu.pokemon));
      },
    );

    test(
      'anota la fecha de la descarga en la fila detail del Pokémon',
      () async {
        await detailDao.saveDetail(savedDetail('eevee'), savedAt: savedAt);

        final metadata = await database.syncMetadataDao.readByKey(
          detailSyncKey(133),
        );

        expect(metadata?.lastSyncedAt, savedAt);
      },
    );

    test('guardar un detalle no toca los favoritos', () async {
      await detailDao.saveDetail(savedDetail('pikachu'), savedAt: savedAt);
      await database
          .into(database.favoritesTable)
          .insert(
            FavoritesTableCompanion.insert(
              pokemonId: const Value(25),
              createdAt: savedAt,
            ),
          );

      await detailDao.saveDetail(savedDetail('pikachu'), savedAt: savedAt);
      final favorites = await database.select(database.favoritesTable).get();

      expect([for (final favorite in favorites) favorite.pokemonId], [25]);
    });
  });

  group('detalle observado', () {
    test('emite los campos del catálogo sin fecha cuando el detalle nunca se descargó', () async {
      await saveInCatalog([savedDetail('pikachu').pokemon]);

      final pikachu = (await detailDao.watchDetail(25).first)!;

      expect(pikachu.pokemon.name, 'pikachu');
      expect(pikachu.species, isNull);
      expect(pikachu.abilities, isEmpty);
      expect(pikachu.moves, isEmpty);
      expect(pikachu.moveVersionGroup, isNull);
      expect(pikachu.detailSyncedAt, isNull);
    });

    test('emite null para un Pokémon que no está guardado', () async {
      expect(await detailDao.watchDetail(9999).first, isNull);
    });

    test('vuelve a emitir cuando se guarda el detalle', () async {
      final pikachu = savedDetail('pikachu');
      await saveInCatalog([pikachu.pokemon]);
      final detailUpdates = StreamQueue(detailDao.watchDetail(25));
      addTearDown(detailUpdates.cancel);

      expect((await detailUpdates.next)?.detailSyncedAt, isNull);

      await detailDao.saveDetail(pikachu, savedAt: savedAt);
      final downloaded = await detailUpdates.next;

      expect(downloaded?.detailSyncedAt, savedAt);
      expect(downloaded?.moves, hasLength(67));
    });

    test(
      'no vuelve a leer el detalle por un cambio de estado de sincronización',
      () async {
        final pikachu = savedDetail('pikachu');
        await saveInCatalog([pikachu.pokemon]);
        final detailUpdates = StreamQueue(detailDao.watchDetail(25));
        addTearDown(detailUpdates.cancel);
        await detailUpdates.next;

        await database.syncMetadataDao.recordStarted(restorationSyncKey);
        await detailDao.saveDetail(pikachu, savedAt: savedAt);

        expect((await detailUpdates.next)?.detailSyncedAt, savedAt);
      },
    );
  });

  group('formas en el catálogo', () {
    test('las formas guardadas no cambian el conteo ni las páginas', () async {
      final pikachu = savedDetail('pikachu');
      await saveInCatalog([pikachu.pokemon]);

      await detailDao.saveDetail(pikachu, savedAt: savedAt);
      final catalogDao = database.catalogDao;
      final page = await catalogDao
          .watchCatalogPage(limit: 50, offset: 0)
          .first;
      final catalog = await catalogDao.watchCatalog().first;

      expect(await catalogDao.watchCatalogCount().first, 1);
      expect([for (final entry in page) entry.id], [25]);
      expect([for (final entry in catalog) entry.id], [25]);
    });
  });

  group('índices', () {
    late RecordedSelects recordedSelects;

    setUp(() async {
      await database.close();
      recordedSelects = RecordedSelects();
      database = AppDatabase(
        NativeDatabase.memory().interceptWith(recordedSelects),
      );
      detailDao = database.pokemonDetailDao;
      await detailDao.saveDetail(savedDetail('pikachu'), savedAt: savedAt);
      recordedSelects.statements.clear();
      await detailDao.readDetail(25);
    });

    Future<List<String>> queryPlanOf(
      ({String sql, List<Object?> arguments}) statement,
    ) {
      return database
          .customSelect(
            'EXPLAIN QUERY PLAN ${statement.sql}',
            variables: [
              for (final argument in statement.arguments)
                Variable<Object>(argument),
            ],
          )
          .map((row) => row.read<String>('detail'))
          .get();
    }

    ({String sql, List<Object?> arguments}) recordedSelectWhere(
      bool Function(String sql) matches,
    ) {
      return recordedSelects.statements.firstWhere(
        (statement) => matches(statement.sql),
      );
    }

    test('las formas de la especie se leen con pokemon_species_id', () async {
      final formsQuery = recordedSelectWhere(
        (sql) =>
            sql.startsWith('SELECT * FROM "pokemon"') &&
            sql.contains('"species_id" = ?'),
      );

      expect(
        await queryPlanOf(formsQuery),
        contains(contains('pokemon_species_id')),
      );
    });

    test(
      'los movimientos se leen con pokemon_moves_by_version_and_method',
      () async {
        final movesQuery = recordedSelectWhere(
          (sql) =>
              sql.contains('"moves"') && sql.contains('"version_group" = ?'),
        );

        expect(
          await queryPlanOf(movesQuery),
          contains(contains('pokemon_moves_by_version_and_method')),
        );
      },
    );
  });

  group('tabla de tipos', () {
    test('está vacía antes de la primera descarga', () async {
      expect(await detailDao.isTypeEfficacyEmpty(), isTrue);
      expect(await detailDao.watchTypeEfficacy().first, isEmpty);
    });

    test('guarda las 324 filas y anota la fecha de la descarga', () async {
      await detailDao.replaceTypeEfficacy(
        savedTypeEfficacyEntries(),
        savedAt: savedAt,
      );

      final rows = await detailDao.watchTypeEfficacy().first;
      final metadata = await database.syncMetadataDao.readByKey(
        typeEfficacySyncKey,
      );
      final fireAgainstGrass = rows.firstWhere(
        (row) => row.attackingType == 'fire' && row.defendingType == 'grass',
      );

      expect(await detailDao.isTypeEfficacyEmpty(), isFalse);
      expect(rows, hasLength(324));
      expect(fireAgainstGrass.damageFactor, 200);
      expect(metadata?.lastSyncedAt, savedAt);
    });

    test('reemplazarla deja solo las filas nuevas', () async {
      await detailDao.replaceTypeEfficacy(
        savedTypeEfficacyEntries(),
        savedAt: savedAt,
      );

      await detailDao.replaceTypeEfficacy(const [
        TypeEfficacyEntry(
          attackingType: 'fire',
          defendingType: 'grass',
          damageFactor: 100,
        ),
      ], savedAt: savedAt);
      final rows = await detailDao.watchTypeEfficacy().first;

      expect(rows, hasLength(1));
      expect(rows.single.damageFactor, 100);
    });

    test('vuelve a emitir cuando se guarda la tabla', () async {
      final tableUpdates = StreamQueue(detailDao.watchTypeEfficacy());
      addTearDown(tableUpdates.cancel);

      expect(await tableUpdates.next, isEmpty);

      await detailDao.replaceTypeEfficacy(
        savedTypeEfficacyEntries(),
        savedAt: savedAt,
      );
      expect(await tableUpdates.next, hasLength(324));
    });
  });
}
