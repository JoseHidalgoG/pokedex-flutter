import 'package:drift/drift.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_tables.dart';

@DataClassName('SpeciesRow')
class SpeciesTable extends Table {
  @override
  String get tableName => 'species';

  IntColumn get id => integer()();
  TextColumn get name => text()();
  IntColumn get generationId => integer().nullable()();
  IntColumn get evolutionChainId => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SpeciesEggGroupRow')
class SpeciesEggGroupsTable extends Table {
  @override
  String get tableName => 'species_egg_groups';

  IntColumn get speciesId =>
      integer().references(SpeciesTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get eggGroup => text()();

  @override
  Set<Column<Object>> get primaryKey => {speciesId, eggGroup};
}

@DataClassName('AbilityRow')
class AbilitiesTable extends Table {
  @override
  String get tableName => 'abilities';

  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get nameEs => text().nullable()();
  TextColumn get shortEffectEs => text().nullable()();
  TextColumn get shortEffectEn => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PokemonAbilityRow')
class PokemonAbilitiesTable extends Table {
  @override
  String get tableName => 'pokemon_abilities';

  IntColumn get pokemonId =>
      integer().references(PokemonTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get abilityId => integer()();
  IntColumn get slot => integer()();
  BoolColumn get isHidden => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {pokemonId, slot};
}

@DataClassName('MoveRow')
class MovesTable extends Table {
  @override
  String get tableName => 'moves';

  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get nameEs => text().nullable()();
  TextColumn get typeName => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PokemonMoveRow')
@TableIndex(
  name: 'pokemon_moves_by_version_and_method',
  columns: {#pokemonId, #versionGroup, #learnMethod},
)
class PokemonMovesTable extends Table {
  @override
  String get tableName => 'pokemon_moves';

  IntColumn get pokemonId =>
      integer().references(PokemonTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get moveId => integer()();
  TextColumn get versionGroup => text()();
  TextColumn get learnMethod => text()();
  IntColumn get level => integer()();

  @override
  Set<Column<Object>> get primaryKey => {
    pokemonId,
    moveId,
    versionGroup,
    learnMethod,
  };
}

@DataClassName('EvolutionRow')
class EvolutionsTable extends Table {
  @override
  String get tableName => 'evolutions';

  IntColumn get id => integer()();
  IntColumn get toSpeciesId => integer()();
  IntColumn get fromSpeciesId => integer().nullable()();
  IntColumn get chainId => integer()();
  TextColumn get trigger => text().nullable()();
  IntColumn get minLevel => integer().nullable()();
  TextColumn get item => text().nullable()();
  IntColumn get minHappiness => integer().nullable()();
  TextColumn get timeOfDay => text().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get knownMoveType => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PokemonGameRow')
class PokemonGamesTable extends Table {
  @override
  String get tableName => 'pokemon_games';

  IntColumn get pokemonId =>
      integer().references(PokemonTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get versionName => text()();

  @override
  Set<Column<Object>> get primaryKey => {pokemonId, versionName};
}

@DataClassName('TypeEfficacyRow')
class TypeEfficacyTable extends Table {
  @override
  String get tableName => 'type_efficacy';

  TextColumn get attackingType => text()();
  TextColumn get defendingType => text()();
  IntColumn get damageFactor => integer()();

  @override
  Set<Column<Object>> get primaryKey => {attackingType, defendingType};
}
