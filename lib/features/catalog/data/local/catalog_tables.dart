import 'package:drift/drift.dart';

@DataClassName('PokemonRow')
@TableIndex.sql(
  'CREATE INDEX pokemon_name_nocase ON pokemon (name COLLATE NOCASE)',
)
@TableIndex(name: 'pokemon_generation_id', columns: {#generationId})
@TableIndex(name: 'pokemon_base_stat_total', columns: {#baseStatTotal})
@TableIndex(name: 'pokemon_species_id', columns: {#speciesId})
class PokemonTable extends Table {
  @override
  String get tableName => 'pokemon';

  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get imageUrl => text()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get speciesId => integer().nullable()();
  IntColumn get generationId => integer().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(true))();
  IntColumn get heightDm => integer().nullable()();
  IntColumn get weightHg => integer().nullable()();
  IntColumn get baseStatTotal => integer().nullable()();
  TextColumn get remoteFingerprint => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PokemonTypeRow')
@TableIndex(name: 'pokemon_types_by_type', columns: {#typeName, #pokemonId})
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

@DataClassName('PokemonStatRow')
class PokemonStatsTable extends Table {
  @override
  String get tableName => 'pokemon_stats';

  IntColumn get pokemonId =>
      integer().references(PokemonTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get statName => text()();
  IntColumn get baseStat => integer()();

  @override
  Set<Column<Object>> get primaryKey => {pokemonId, statName};
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
  TextColumn get status => text().withDefault(const Constant('idle'))();
  IntColumn get attempt => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextRetryAt => dateTime().nullable()();
  DateTimeColumn get lastVerifiedAt => dateTime().nullable()();
  TextColumn get lastErrorKind => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
