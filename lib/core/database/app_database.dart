import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:pokedex_flutter/core/database/app_database.steps.dart';
import 'package:pokedex_flutter/core/sync/data/sync_metadata_dao.dart';
import 'package:pokedex_flutter/core/sync/data/sync_metadata_table.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_dao.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_detail_tables.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_tables.dart';
import 'package:pokedex_flutter/features/favorites/data/local/favorites_table.dart';
import 'package:pokedex_flutter/features/settings/data/local/user_preferences_table.dart';
import 'package:pokedex_flutter/features/trivia/data/local/trivia_tables.dart';
import 'package:pokedex_flutter/features/favorites/data/local/favorites_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    PokemonTable,
    PokemonTypesTable,
    PokemonStatsTable,
    SpeciesTable,
    SpeciesEggGroupsTable,
    AbilitiesTable,
    PokemonAbilitiesTable,
    MovesTable,
    PokemonMovesTable,
    EvolutionsTable,
    PokemonGamesTable,
    TypeEfficacyTable,
    FavoritesTable,
    TriviaResultsTable,
    TriviaAnswersTable,
    AchievementsTable,
    UserPreferencesTable,
    SyncMetadataTable,
  ],
  daos: [CatalogDao, SyncMetadataDao, FavoritesDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.onDevice() : super(driftDatabase(name: 'pokedex'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: stepByStep(from1To2: _addDetailUserTablesAndSyncColumns),
    beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
  );

  Future<void> _addDetailUserTablesAndSyncColumns(
    Migrator migrator,
    Schema2 schema,
  ) async {
    final pokemon = schema.pokemon;
    for (final newPokemonColumn in [
      pokemon.speciesId,
      pokemon.generationId,
      pokemon.isDefault,
      pokemon.heightDm,
      pokemon.weightHg,
      pokemon.baseStatTotal,
      pokemon.remoteFingerprint,
    ]) {
      await migrator.addColumn(pokemon, newPokemonColumn);
    }

    final syncMetadata = schema.syncMetadata;
    for (final newSyncMetadataColumn in [
      syncMetadata.status,
      syncMetadata.attempt,
      syncMetadata.nextRetryAt,
      syncMetadata.lastVerifiedAt,
      syncMetadata.lastErrorKind,
    ]) {
      await migrator.addColumn(syncMetadata, newSyncMetadataColumn);
    }

    for (final newTable in [
      schema.pokemonStats,
      schema.species,
      schema.speciesEggGroups,
      schema.abilities,
      schema.pokemonAbilities,
      schema.moves,
      schema.pokemonMoves,
      schema.evolutions,
      schema.pokemonGames,
      schema.typeEfficacy,
      schema.triviaResults,
      schema.triviaAnswers,
      schema.achievements,
      schema.userPreferences,
    ]) {
      await migrator.createTable(newTable);
    }

    for (final newIndex in [
      schema.pokemonNameNocase,
      schema.pokemonGenerationId,
      schema.pokemonBaseStatTotal,
      schema.pokemonSpeciesId,
      schema.pokemonTypesByType,
      schema.pokemonMovesByVersionAndMethod,
      schema.triviaResultsByScore,
    ]) {
      await migrator.createIndex(newIndex);
    }

    await customStatement(
      'UPDATE sync_metadata SET last_synced_at = NULL WHERE key = ?',
      [CatalogDao.catalogSyncKey],
    );
  }
}
