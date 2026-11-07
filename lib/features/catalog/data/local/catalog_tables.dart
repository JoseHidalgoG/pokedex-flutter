import 'package:drift/drift.dart';

@DataClassName('PokemonRow')
class PokemonTable extends Table {
  @override
  String get tableName => 'pokemon';

  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get imageUrl => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PokemonTypeRow')
class PokemonTypesTable extends Table {
  @override
  String get tableName => 'pokemon_types';

  IntColumn get pokemonId =>
      integer().references(PokemonTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get slot => integer()();
  TextColumn get typeName => text()();

  @override
  Set<Column<Object>> get primaryKey => {pokemonId, slot};
}

@DataClassName('SyncMetadataRow')
class SyncMetadataTable extends Table {
  @override
  String get tableName => 'sync_metadata';

  TextColumn get key => text()();
  IntColumn get nextOffset => integer().withDefault(const Constant(0))();
  IntColumn get totalCount => integer().nullable()();
  BoolColumn get isComplete => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
