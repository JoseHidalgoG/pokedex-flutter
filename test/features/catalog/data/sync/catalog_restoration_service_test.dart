import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/core/sync/domain/call_budget.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_job.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';
import 'package:pokedex_flutter/features/catalog/data/catalog_fingerprint.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_dao.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_batch.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_remote_data_source.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto_mapper.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/catalog_restoration_service.dart';

typedef PokemonByIdsRequest = ({List<int> ids, CallPriority priority});

class PokeApiTruth implements CatalogRemoteDataSource {
  PokeApiTruth(List<PokemonDto> pokemon, {this.failsRequests = false})
    : _pokemonById = {for (final dto in pokemon) dto.id: dto};

  final Map<int, PokemonDto> _pokemonById;
  final bool failsRequests;
  final requests = <PokemonByIdsRequest>[];

  @override
  Future<CatalogBatch> fetchCatalogPage({
    required int limit,
    required int offset,
    bool withTotal = false,
  }) {
    throw UnimplementedError('la restauración no pide páginas');
  }

  @override
  Future<List<PokemonDto>> fetchPokemonByIds(
    List<int> ids, {
    CallPriority priority = CallPriority.user,
  }) async {
    requests.add((ids: ids, priority: priority));
    if (failsRequests) {
      throw const ServerError(503);
    }
    return [for (final id in ids) ?_pokemonById[id]];
  }
}

const bulbasaur = PokemonDto(
  id: 1,
  name: 'bulbasaur',
  typeNames: ['grass', 'poison'],
  speciesId: 1,
  generationId: 1,
  heightDm: 7,
  weightHg: 69,
  baseStats: {'hp': 45, 'attack': 49, 'speed': 45},
);

const pikachu = PokemonDto(
  id: 25,
  name: 'pikachu',
  typeNames: ['electric'],
  speciesId: 25,
  generationId: 1,
  heightDm: 4,
  weightHg: 60,
  baseStats: {'hp': 35, 'attack': 55, 'speed': 90},
);

PokemonDto numberedPokemon(int id) {
  return PokemonDto(
    id: id,
    name: 'pokemon-$id',
    typeNames: const ['normal'],
    speciesId: id,
    generationId: 1,
    heightDm: 10,
    weightHg: 100,
    baseStats: const {'hp': 50, 'speed': 50},
  );
}

void main() {
  late AppDatabase database;
  late CatalogDao catalogDao;
  final now = DateTime(2026, 11, 21, 10);

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    catalogDao = database.catalogDao;
  });

  tearDown(() => database.close());

  Future<void> saveDownloaded(List<PokemonDto> pokemon) {
    return catalogDao.saveCatalogPage(
      entries: [for (final dto in pokemon) dto.toCatalogEntry()],
      nextOffset: pokemon.length,
      isComplete: true,
      savedAt: now.subtract(const Duration(minutes: 10)),
    );
  }

  CatalogRestorationService restorationOver(PokeApiTruth pokeApi) {
    return CatalogRestorationService(
      remoteDataSource: pokeApi,
      catalogDao: catalogDao,
      now: () => now,
    );
  }

  Future<CatalogEntry> storedEntry(int id) async {
    final stored = await catalogDao.readEntriesWithFingerprint();
    return stored.singleWhere((candidate) => candidate.entry.id == id).entry;
  }

  List<List<int>> requestedIdsOf(PokeApiTruth pokeApi) => [
    for (final request in pokeApi.requests) request.ids,
  ];

  test('sin datos alterados no llama a PokeAPI', () async {
    final pokeApi = PokeApiTruth([bulbasaur, pikachu]);
    await saveDownloaded([bulbasaur, pikachu]);

    final outcome = await restorationOver(pokeApi).restoreAlteredPokemon();

    expect(outcome, SyncOutcome.upToDate);
    expect(pokeApi.requests, isEmpty);
  });

  test('un nombre alterado se pide a PokeAPI con prioridad de restauración y vuelve al remoto', () async {
    final pokeApi = PokeApiTruth([bulbasaur, pikachu]);
    await saveDownloaded([bulbasaur, pikachu]);
    await database.customStatement(
      "UPDATE pokemon SET name = 'pikachux' WHERE id = 25",
    );

    final outcome = await restorationOver(pokeApi).restoreAlteredPokemon();

    expect(outcome, SyncOutcome.revalidated);
    expect(requestedIdsOf(pokeApi), [
      [25],
    ]);
    expect(pokeApi.requests.single.priority, CallPriority.restoration);
    expect((await storedEntry(25)).name, 'pikachu');
  });

  test('dos tipos que cambiaron de orden se detectan y se restauran', () async {
    final pokeApi = PokeApiTruth([bulbasaur, pikachu]);
    await saveDownloaded([bulbasaur, pikachu]);
    await database.customStatement(
      'UPDATE pokemon_types SET type_name = CASE slot '
      "WHEN 1 THEN 'poison' ELSE 'grass' END WHERE pokemon_id = 1",
    );

    await restorationOver(pokeApi).restoreAlteredPokemon();

    expect(requestedIdsOf(pokeApi), [
      [1],
    ]);
    expect((await storedEntry(1)).typeNames, ['grass', 'poison']);
  });

  test('una estadística alterada se detecta y se restaura', () async {
    final pokeApi = PokeApiTruth([bulbasaur, pikachu]);
    await saveDownloaded([bulbasaur, pikachu]);
    await database.customStatement(
      'UPDATE pokemon_stats SET base_stat = 1 '
      "WHERE pokemon_id = 25 AND stat_name = 'speed'",
    );

    await restorationOver(pokeApi).restoreAlteredPokemon();

    expect(requestedIdsOf(pokeApi), [
      [25],
    ]);
    expect((await storedEntry(25)).baseStats['speed'], 90);
  });

  test('una huella alterada a mano también se restaura', () async {
    final pokeApi = PokeApiTruth([pikachu]);
    await saveDownloaded([pikachu]);
    await database.customStatement(
      "UPDATE pokemon SET remote_fingerprint = 'alterada' WHERE id = 25",
    );

    await restorationOver(pokeApi).restoreAlteredPokemon();
    final stored = await catalogDao.readEntriesWithFingerprint();

    expect(requestedIdsOf(pokeApi), [
      [25],
    ]);
    expect(
      stored.single.storedFingerprint,
      catalogFingerprintOf(pikachu.toCatalogEntry()),
    );
  });

  test(
    'una fila con la huella nula se salta porque la llena la pasada completa',
    () async {
      final pokeApi = PokeApiTruth([pikachu]);
      await saveDownloaded([pikachu]);
      await database.customStatement(
        "UPDATE pokemon SET name = 'pikachux', remote_fingerprint = NULL "
        'WHERE id = 25',
      );

      final outcome = await restorationOver(pokeApi).restoreAlteredPokemon();

      expect(outcome, SyncOutcome.upToDate);
      expect(pokeApi.requests, isEmpty);
      expect((await storedEntry(25)).name, 'pikachux');
    },
  );

  test(
    '150 Pokémon alterados se restauran en 2 llamadas de restauración',
    () async {
      final downloaded = [
        for (var id = 1; id <= 150; id++) numberedPokemon(id),
      ];
      final pokeApi = PokeApiTruth(downloaded);
      await saveDownloaded(downloaded);
      await database.customStatement(
        "UPDATE pokemon SET name = name || '-alterado'",
      );

      await restorationOver(pokeApi).restoreAlteredPokemon();

      expect(
        [for (final ids in requestedIdsOf(pokeApi)) ids.length],
        [100, 50],
      );
      expect([
        for (final request in pokeApi.requests) request.priority,
      ], everyElement(CallPriority.restoration));
    },
  );

  test('las filas restauradas quedan iguales a las de PokeAPI y una segunda verificación no pide nada', () async {
    final downloaded = [bulbasaur, pikachu, numberedPokemon(133)];
    final pokeApi = PokeApiTruth(downloaded);
    await saveDownloaded(downloaded);
    await database.customStatement(
      "UPDATE pokemon SET name = 'otro', height_dm = 99 WHERE id IN (1, 133)",
    );
    await database.customStatement(
      "UPDATE pokemon_types SET type_name = 'fire' WHERE pokemon_id = 25",
    );
    final restoration = restorationOver(pokeApi);

    await restoration.restoreAlteredPokemon();
    final stored = await catalogDao.readEntriesWithFingerprint();

    for (final (:entry, :storedFingerprint) in stored) {
      final remote = downloaded
          .singleWhere((dto) => dto.id == entry.id)
          .toCatalogEntry();
      expect(entry.name, remote.name);
      expect(entry.typeNames, remote.typeNames);
      expect(entry.baseStats, remote.baseStats);
      expect(entry.heightDm, remote.heightDm);
      expect(entry.weightHg, remote.weightHg);
      expect(entry.imageUrl, remote.imageUrl);
      expect(storedFingerprint, catalogFingerprintOf(remote));
    }
    expect(requestedIdsOf(pokeApi), [
      [1, 25, 133],
    ]);

    expect(await restoration.restoreAlteredPokemon(), SyncOutcome.upToDate);
    expect(pokeApi.requests, hasLength(1));
  });

  test(
    'un id que PokeAPI no devuelve se deja como está y no se vuelve a pedir',
    () async {
      final pokeApi = PokeApiTruth([pikachu]);
      await saveDownloaded([pikachu, numberedPokemon(99999)]);
      await database.customStatement(
        "UPDATE pokemon SET name = name || 'x' WHERE id IN (25, 99999)",
      );
      final restoration = restorationOver(pokeApi);

      await restoration.restoreAlteredPokemon();
      final secondOutcome = await restoration.restoreAlteredPokemon();

      expect(requestedIdsOf(pokeApi), [
        [25, 99999],
      ]);
      expect((await storedEntry(25)).name, 'pikachu');
      expect((await storedEntry(99999)).name, 'pokemon-99999x');
      expect(secondOutcome, SyncOutcome.upToDate);
    },
  );

  test('anota la hora de cada verificación en sync_metadata', () async {
    final pokeApi = PokeApiTruth([pikachu]);
    await saveDownloaded([pikachu]);

    await restorationOver(pokeApi).restoreAlteredPokemon();
    final metadata = await database.syncMetadataDao.readByKey(
      'catalog:restore',
    );

    expect(metadata?.lastVerifiedAt, now);
  });

  test('ante un fallo de PokeAPI lo lanza y conserva el dato local', () async {
    final pokeApi = PokeApiTruth([pikachu], failsRequests: true);
    await saveDownloaded([pikachu]);
    await database.customStatement(
      "UPDATE pokemon SET name = 'pikachux' WHERE id = 25",
    );

    await expectLater(
      restorationOver(pokeApi).restoreAlteredPokemon(),
      throwsA(const ServerError(503)),
    );
    expect((await storedEntry(25)).name, 'pikachux');
  });

  test('la tarea usa la clave catalog:restore, la prioridad de restauración y el estado de revalidación', () async {
    final pokeApi = PokeApiTruth([pikachu]);
    await saveDownloaded([pikachu]);

    final job = restorationOver(pokeApi).restorationJob();
    final outcome = await job.perform();

    expect(job.key, 'catalog:restore');
    expect(job.priority, CallPriority.restoration);
    expect(job.runningStatus, isA<SyncRevalidating>());
    expect(job.force, isFalse);
    expect(outcome, SyncOutcome.upToDate);
  });

  test('restaurar deja favoritos, trivia, logros y preferencias idénticos fila a fila', () async {
    final pokeApi = PokeApiTruth([bulbasaur, pikachu]);
    await saveDownloaded([bulbasaur, pikachu]);
    await database
        .into(database.favoritesTable)
        .insert(
          FavoritesTableCompanion.insert(
            pokemonId: const Value(25),
            createdAt: now.subtract(const Duration(days: 1)),
          ),
        );
    final resultId = await database
        .into(database.triviaResultsTable)
        .insert(
          TriviaResultsTableCompanion.insert(
            score: 800,
            correctAnswers: 8,
            totalQuestions: 10,
            durationMs: 45000,
            playedAt: now.subtract(const Duration(hours: 2)),
          ),
        );
    await database
        .into(database.triviaAnswersTable)
        .insert(
          TriviaAnswersTableCompanion.insert(
            resultId: resultId,
            pokemonId: 25,
            correct: true,
            responseMs: 2100,
          ),
        );
    await database
        .into(database.achievementsTable)
        .insert(
          AchievementsTableCompanion.insert(
            key: 'primer-favorito',
            unlockedAt: now.subtract(const Duration(days: 1)),
          ),
        );
    await database
        .into(database.userPreferencesTable)
        .insert(
          UserPreferencesTableCompanion.insert(key: 'tema', value: 'oscuro'),
        );
    Future<List<List<Object?>>> userTables() async => [
      await database.select(database.favoritesTable).get(),
      await database.select(database.triviaResultsTable).get(),
      await database.select(database.triviaAnswersTable).get(),
      await database.select(database.achievementsTable).get(),
      await database.select(database.userPreferencesTable).get(),
    ];
    final before = await userTables();
    await database.customStatement(
      "UPDATE pokemon SET name = 'pikachux' WHERE id = 25",
    );

    await restorationOver(pokeApi).restoreAlteredPokemon();

    expect(pokeApi.requests, hasLength(1));
    expect(await userTables(), before);
  });
}
