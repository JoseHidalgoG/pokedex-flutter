// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_dao.dart';

// ignore_for_file: type=lint
mixin _$CatalogDaoMixin on DatabaseAccessor<AppDatabase> {
  $PokemonTableTable get pokemonTable => attachedDatabase.pokemonTable;
  $PokemonTypesTableTable get pokemonTypesTable =>
      attachedDatabase.pokemonTypesTable;
  $PokemonStatsTableTable get pokemonStatsTable =>
      attachedDatabase.pokemonStatsTable;
  $SyncMetadataTableTable get syncMetadataTable =>
      attachedDatabase.syncMetadataTable;
  CatalogDaoManager get managers => CatalogDaoManager(this);
}

class CatalogDaoManager {
  final _$CatalogDaoMixin _db;
  CatalogDaoManager(this._db);
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
  $$SyncMetadataTableTableTableManager get syncMetadataTable =>
      $$SyncMetadataTableTableTableManager(
        _db.attachedDatabase,
        _db.syncMetadataTable,
      );
}
