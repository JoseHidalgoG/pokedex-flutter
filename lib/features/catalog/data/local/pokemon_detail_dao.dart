import 'package:drift/drift.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/core/sync/data/sync_metadata_table.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_detail_tables.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_tables.dart';
import 'package:pokedex_flutter/features/catalog/data/local/detail_entry.dart';
import 'package:pokedex_flutter/features/catalog/data/local/type_efficacy_entry.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/catalog_sync_constants.dart';

part 'pokemon_detail_dao.g.dart';

@DriftAccessor(
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
    SyncMetadataTable,
  ],
)
class PokemonDetailDao extends DatabaseAccessor<AppDatabase>
    with _$PokemonDetailDaoMixin {
  PokemonDetailDao(super.attachedDatabase);

  Future<void> saveDetail(DetailEntry detail, {required DateTime savedAt}) {
    return transaction(() async {
      await attachedDatabase.catalogDao.upsertEntries(
        _catalogEntriesOf(detail),
        savedAt: savedAt,
      );
      await _deleteRowsReplacedBy(detail);
      await batch((batch) {
        final pokemonId = detail.pokemon.id;
        final species = detail.species;
        final moveVersionGroup = detail.moveVersionGroup;
        batch
          ..insertAllOnConflictUpdate(speciesTable, [
            if (species != null)
              for (final member in [...detail.evolutionChain, species])
                _speciesRowOf(member),
          ])
          ..insertAllOnConflictUpdate(speciesEggGroupsTable, [
            if (species != null)
              for (final eggGroup in detail.eggGroups)
                SpeciesEggGroupsTableCompanion.insert(
                  speciesId: species.id,
                  eggGroup: eggGroup,
                ),
          ])
          ..insertAllOnConflictUpdate(evolutionsTable, [
            for (final evolution in detail.evolutions)
              _evolutionRowOf(evolution),
          ])
          ..insertAllOnConflictUpdate(abilitiesTable, [
            for (final ability in detail.abilities) _abilityRowOf(ability),
          ])
          ..insertAllOnConflictUpdate(pokemonAbilitiesTable, [
            for (final ability in detail.abilities)
              PokemonAbilitiesTableCompanion.insert(
                pokemonId: pokemonId,
                abilityId: ability.id,
                slot: ability.slot,
                isHidden: ability.isHidden,
              ),
          ])
          ..insertAllOnConflictUpdate(movesTable, [
            for (final move in detail.moves) _moveRowOf(move),
          ])
          ..insertAllOnConflictUpdate(pokemonMovesTable, [
            if (moveVersionGroup != null)
              for (final move in detail.moves)
                PokemonMovesTableCompanion.insert(
                  pokemonId: pokemonId,
                  moveId: move.id,
                  versionGroup: moveVersionGroup,
                  learnMethod: move.learnMethod,
                  level: move.level,
                ),
          ])
          ..insertAllOnConflictUpdate(pokemonGamesTable, [
            for (final versionName in detail.gameVersions)
              PokemonGamesTableCompanion.insert(
                pokemonId: pokemonId,
                versionName: versionName,
              ),
          ])
          ..insertAllOnConflictUpdate(syncMetadataTable, [
            SyncMetadataTableCompanion(
              key: Value(detailSyncKey(pokemonId)),
              lastSyncedAt: Value(savedAt),
            ),
          ]);
      });
    });
  }

  Stream<DetailEntry?> watchDetail(int pokemonId) {
    final pokemonRow = customSelect(
      'SELECT id FROM pokemon WHERE id = ?',
      variables: [Variable.withInt(pokemonId)],
      readsFrom: {
        pokemonTable,
        pokemonTypesTable,
        pokemonStatsTable,
        speciesTable,
        speciesEggGroupsTable,
        abilitiesTable,
        pokemonAbilitiesTable,
        movesTable,
        pokemonMovesTable,
        evolutionsTable,
        pokemonGamesTable,
      },
    );
    return pokemonRow.watch().asyncMap((_) => readDetail(pokemonId));
  }

  Future<DetailEntry?> readDetail(int pokemonId) {
    return transaction(() async {
      final catalogDao = attachedDatabase.catalogDao;
      final pokemon = await catalogDao.readEntry(pokemonId);
      if (pokemon == null) {
        return null;
      }
      final speciesId = pokemon.speciesId;
      final species = speciesId == null ? null : await _speciesOf(speciesId);
      final chainId = species?.evolutionChainId;
      final moveVersionGroup = await _moveVersionGroupOf(pokemonId);
      return DetailEntry(
        pokemon: pokemon,
        species: species,
        forms: speciesId == null
            ? const []
            : await catalogDao.readEntriesOfSpecies(speciesId),
        eggGroups: speciesId == null ? const [] : await _eggGroupsOf(speciesId),
        evolutionChain: chainId == null
            ? const []
            : await _speciesOfChain(chainId),
        evolutions: chainId == null
            ? const []
            : await _evolutionsOfChain(chainId),
        abilities: await _abilitiesOf(pokemonId),
        moveVersionGroup: moveVersionGroup,
        moves: moveVersionGroup == null
            ? const []
            : await _movesOf(pokemonId, versionGroup: moveVersionGroup),
        gameVersions: await _gameVersionsOf(pokemonId),
        detailSyncedAt: await _detailSyncedAt(pokemonId),
      );
    });
  }

  Future<void> replaceTypeEfficacy(
    List<TypeEfficacyEntry> rows, {
    required DateTime savedAt,
  }) {
    return transaction(() async {
      await delete(typeEfficacyTable).go();
      await batch((batch) {
        batch
          ..insertAllOnConflictUpdate(typeEfficacyTable, [
            for (final row in rows)
              TypeEfficacyTableCompanion.insert(
                attackingType: row.attackingType,
                defendingType: row.defendingType,
                damageFactor: row.damageFactor,
              ),
          ])
          ..insertAllOnConflictUpdate(syncMetadataTable, [
            SyncMetadataTableCompanion(
              key: const Value(typeEfficacySyncKey),
              lastSyncedAt: Value(savedAt),
            ),
          ]);
      });
    });
  }

  Stream<List<TypeEfficacyEntry>> watchTypeEfficacy() {
    final rows = select(typeEfficacyTable)
      ..orderBy([
        (row) => OrderingTerm.asc(row.attackingType),
        (row) => OrderingTerm.asc(row.defendingType),
      ]);
    return rows
        .map(
          (row) => TypeEfficacyEntry(
            attackingType: row.attackingType,
            defendingType: row.defendingType,
            damageFactor: row.damageFactor,
          ),
        )
        .watch();
  }

  Future<bool> isTypeEfficacyEmpty() async {
    final firstRow = await (select(
      typeEfficacyTable,
    )..limit(1)).getSingleOrNull();
    return firstRow == null;
  }

  List<CatalogEntry> _catalogEntriesOf(DetailEntry detail) {
    final entriesById = {
      for (final entry in [...detail.forms, detail.pokemon]) entry.id: entry,
    };
    return entriesById.values.toList();
  }

  Future<void> _deleteRowsReplacedBy(DetailEntry detail) async {
    final pokemonId = detail.pokemon.id;
    final species = detail.species;
    if (species != null) {
      await (delete(
        speciesEggGroupsTable,
      )..where((eggGroup) => eggGroup.speciesId.equals(species.id))).go();
    }
    final chainId = species?.evolutionChainId;
    if (chainId != null) {
      await (delete(
        evolutionsTable,
      )..where((evolution) => evolution.chainId.equals(chainId))).go();
    }
    await (delete(
      pokemonAbilitiesTable,
    )..where((ability) => ability.pokemonId.equals(pokemonId))).go();
    await (delete(
      pokemonMovesTable,
    )..where((move) => move.pokemonId.equals(pokemonId))).go();
    await (delete(
      pokemonGamesTable,
    )..where((game) => game.pokemonId.equals(pokemonId))).go();
  }

  Future<SpeciesEntry?> _speciesOf(int speciesId) {
    final species = select(speciesTable)
      ..where((species) => species.id.equals(speciesId));
    return species.map(_speciesEntryOf).getSingleOrNull();
  }

  Future<List<String>> _eggGroupsOf(int speciesId) {
    final eggGroups = select(speciesEggGroupsTable)
      ..where((eggGroup) => eggGroup.speciesId.equals(speciesId));
    return eggGroups.map((row) => row.eggGroup).get();
  }

  Future<List<SpeciesEntry>> _speciesOfChain(int chainId) {
    final chainSpecies = select(speciesTable)
      ..where((species) => species.evolutionChainId.equals(chainId))
      ..orderBy([(species) => OrderingTerm.asc(species.id)]);
    return chainSpecies.map(_speciesEntryOf).get();
  }

  Future<List<EvolutionEntry>> _evolutionsOfChain(int chainId) {
    final evolutions = select(evolutionsTable)
      ..where((evolution) => evolution.chainId.equals(chainId))
      ..orderBy([(evolution) => OrderingTerm.asc(evolution.id)]);
    return evolutions.map(_evolutionEntryOf).get();
  }

  Future<List<AbilityEntry>> _abilitiesOf(int pokemonId) {
    final abilities =
        select(pokemonAbilitiesTable).join([
            innerJoin(
              abilitiesTable,
              abilitiesTable.id.equalsExp(pokemonAbilitiesTable.abilityId),
            ),
          ])
          ..where(pokemonAbilitiesTable.pokemonId.equals(pokemonId))
          ..orderBy([OrderingTerm.asc(pokemonAbilitiesTable.slot)]);
    return abilities.map((joinedRow) {
      final pokemonAbility = joinedRow.readTable(pokemonAbilitiesTable);
      final ability = joinedRow.readTable(abilitiesTable);
      return AbilityEntry(
        id: ability.id,
        name: ability.name,
        nameEs: ability.nameEs,
        slot: pokemonAbility.slot,
        isHidden: pokemonAbility.isHidden,
        shortEffectEs: ability.shortEffectEs,
        shortEffectEn: ability.shortEffectEn,
      );
    }).get();
  }

  Future<String?> _moveVersionGroupOf(int pokemonId) async {
    final storedVersionGroup = selectOnly(pokemonMovesTable)
      ..addColumns([pokemonMovesTable.versionGroup])
      ..where(pokemonMovesTable.pokemonId.equals(pokemonId))
      ..limit(1);
    final row = await storedVersionGroup.getSingleOrNull();
    return row?.read(pokemonMovesTable.versionGroup);
  }

  Future<List<MoveEntry>> _movesOf(
    int pokemonId, {
    required String versionGroup,
  }) {
    final moves =
        select(pokemonMovesTable).join([
            innerJoin(
              movesTable,
              movesTable.id.equalsExp(pokemonMovesTable.moveId),
            ),
          ])
          ..where(
            pokemonMovesTable.pokemonId.equals(pokemonId) &
                pokemonMovesTable.versionGroup.equals(versionGroup),
          )
          ..orderBy([
            OrderingTerm.asc(pokemonMovesTable.level),
            OrderingTerm.asc(movesTable.name),
          ]);
    return moves.map((joinedRow) {
      final pokemonMove = joinedRow.readTable(pokemonMovesTable);
      final move = joinedRow.readTable(movesTable);
      return MoveEntry(
        id: move.id,
        name: move.name,
        nameEs: move.nameEs,
        typeName: move.typeName,
        learnMethod: pokemonMove.learnMethod,
        level: pokemonMove.level,
      );
    }).get();
  }

  Future<List<String>> _gameVersionsOf(int pokemonId) {
    final games = select(pokemonGamesTable)
      ..where((game) => game.pokemonId.equals(pokemonId));
    return games.map((row) => row.versionName).get();
  }

  Future<DateTime?> _detailSyncedAt(int pokemonId) async {
    final metadata =
        await (select(syncMetadataTable)
              ..where((row) => row.key.equals(detailSyncKey(pokemonId))))
            .getSingleOrNull();
    return metadata?.lastSyncedAt;
  }

  static SpeciesEntry _speciesEntryOf(SpeciesRow row) {
    return SpeciesEntry(
      id: row.id,
      name: row.name,
      generationId: row.generationId,
      evolutionChainId: row.evolutionChainId,
    );
  }

  static EvolutionEntry _evolutionEntryOf(EvolutionRow row) {
    return EvolutionEntry(
      id: row.id,
      chainId: row.chainId,
      toSpeciesId: row.toSpeciesId,
      fromSpeciesId: row.fromSpeciesId,
      trigger: row.trigger,
      minLevel: row.minLevel,
      item: row.item,
      minHappiness: row.minHappiness,
      timeOfDay: row.timeOfDay,
      location: row.location,
      knownMoveType: row.knownMoveType,
    );
  }

  static SpeciesTableCompanion _speciesRowOf(SpeciesEntry species) {
    return SpeciesTableCompanion.insert(
      id: Value(species.id),
      name: species.name,
      generationId: Value(species.generationId),
      evolutionChainId: Value(species.evolutionChainId),
    );
  }

  static EvolutionsTableCompanion _evolutionRowOf(EvolutionEntry evolution) {
    return EvolutionsTableCompanion.insert(
      id: Value(evolution.id),
      toSpeciesId: evolution.toSpeciesId,
      fromSpeciesId: Value(evolution.fromSpeciesId),
      chainId: evolution.chainId,
      trigger: Value(evolution.trigger),
      minLevel: Value(evolution.minLevel),
      item: Value(evolution.item),
      minHappiness: Value(evolution.minHappiness),
      timeOfDay: Value(evolution.timeOfDay),
      location: Value(evolution.location),
      knownMoveType: Value(evolution.knownMoveType),
    );
  }

  static AbilitiesTableCompanion _abilityRowOf(AbilityEntry ability) {
    return AbilitiesTableCompanion.insert(
      id: Value(ability.id),
      name: ability.name,
      nameEs: Value(ability.nameEs),
      shortEffectEs: Value(ability.shortEffectEs),
      shortEffectEn: Value(ability.shortEffectEn),
    );
  }

  static MovesTableCompanion _moveRowOf(MoveEntry move) {
    return MovesTableCompanion.insert(
      id: Value(move.id),
      name: move.name,
      nameEs: Value(move.nameEs),
      typeName: Value(move.typeName),
    );
  }
}
