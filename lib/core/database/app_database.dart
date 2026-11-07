import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_dao.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_tables.dart';
import 'package:pokedex_flutter/features/favorites/data/local/favorites_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [PokemonTable, PokemonTypesTable, SyncMetadataTable, FavoritesTable],
  daos: [CatalogDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.onDevice() : super(driftDatabase(name: 'pokedex'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
  );
}
