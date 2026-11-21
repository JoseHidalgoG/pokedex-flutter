// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pokemon_detail_dao.dart';

// ignore_for_file: type=lint
mixin _$PokemonDetailDaoMixin on DatabaseAccessor<AppDatabase> {
  $PokemonTableTable get pokemonTable => attachedDatabase.pokemonTable;
  $PokemonTypesTableTable get pokemonTypesTable =>
      attachedDatabase.pokemonTypesTable;
  $PokemonStatsTableTable get pokemonStatsTable =>
      attachedDatabase.pokemonStatsTable;
  $SpeciesTableTable get speciesTable => attachedDatabase.speciesTable;
  $SpeciesEggGroupsTableTable get speciesEggGroupsTable =>
      attachedDatabase.speciesEggGroupsTable;
  $AbilitiesTableTable get abilitiesTable => attachedDatabase.abilitiesTable;
  $PokemonAbilitiesTableTable get pokemonAbilitiesTable =>
      attachedDatabase.pokemonAbilitiesTable;
  $MovesTableTable get movesTable => attachedDatabase.movesTable;
  $PokemonMovesTableTable get pokemonMovesTable =>
      attachedDatabase.pokemonMovesTable;
  $EvolutionsTableTable get evolutionsTable => attachedDatabase.evolutionsTable;
  $PokemonGamesTableTable get pokemonGamesTable =>
      attachedDatabase.pokemonGamesTable;
  $TypeEfficacyTableTable get typeEfficacyTable =>
      attachedDatabase.typeEfficacyTable;
  $SyncMetadataTableTable get syncMetadataTable =>
      attachedDatabase.syncMetadataTable;
  PokemonDetailDaoManager get managers => PokemonDetailDaoManager(this);
}

class PokemonDetailDaoManager {
  final _$PokemonDetailDaoMixin _db;
  PokemonDetailDaoManager(this._db);
  $$PokemonTableTableTableManager get pokemonTable =>
      $$PokemonTableTableTableManager(_db.attachedDatabase, _db.pokemonTable);
  $$PokemonTypesTableTableTableManager get pokemonTypesTable =>
      $$PokemonTypesTableTableTableManager(
        _db.attachedDatabase,
        _db.pokemonTypesTable,
      );
  $$PokemonStatsTableTableTableManager get pokemonStatsTable =>
      $$PokemonStatsTableTableTableManager(
        _db.attachedDatabase,
        _db.pokemonStatsTable,
      );
  $$SpeciesTableTableTableManager get speciesTable =>
      $$SpeciesTableTableTableManager(_db.attachedDatabase, _db.speciesTable);
  $$SpeciesEggGroupsTableTableTableManager get speciesEggGroupsTable =>
      $$SpeciesEggGroupsTableTableTableManager(
        _db.attachedDatabase,
        _db.speciesEggGroupsTable,
      );
  $$AbilitiesTableTableTableManager get abilitiesTable =>
      $$AbilitiesTableTableTableManager(
        _db.attachedDatabase,
        _db.abilitiesTable,
      );
  $$PokemonAbilitiesTableTableTableManager get pokemonAbilitiesTable =>
      $$PokemonAbilitiesTableTableTableManager(
        _db.attachedDatabase,
        _db.pokemonAbilitiesTable,
      );
  $$MovesTableTableTableManager get movesTable =>
      $$MovesTableTableTableManager(_db.attachedDatabase, _db.movesTable);
  $$PokemonMovesTableTableTableManager get pokemonMovesTable =>
      $$PokemonMovesTableTableTableManager(
        _db.attachedDatabase,
        _db.pokemonMovesTable,
      );
  $$EvolutionsTableTableTableManager get evolutionsTable =>
      $$EvolutionsTableTableTableManager(
        _db.attachedDatabase,
        _db.evolutionsTable,
      );
  $$PokemonGamesTableTableTableManager get pokemonGamesTable =>
      $$PokemonGamesTableTableTableManager(
        _db.attachedDatabase,
        _db.pokemonGamesTable,
      );
  $$TypeEfficacyTableTableTableManager get typeEfficacyTable =>
      $$TypeEfficacyTableTableTableManager(
        _db.attachedDatabase,
        _db.typeEfficacyTable,
      );
  $$SyncMetadataTableTableTableManager get syncMetadataTable =>
      $$SyncMetadataTableTableTableManager(
        _db.attachedDatabase,
        _db.syncMetadataTable,
      );
}
