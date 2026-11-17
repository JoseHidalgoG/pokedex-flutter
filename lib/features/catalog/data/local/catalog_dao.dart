import 'package:drift/drift.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_tables.dart';

part 'catalog_dao.g.dart';

@DriftAccessor(tables: [PokemonTable, PokemonTypesTable, SyncMetadataTable])
class CatalogDao extends DatabaseAccessor<AppDatabase> with _$CatalogDaoMixin {
  CatalogDao(super.attachedDatabase);

  static const catalogSyncKey = 'catalog';

  Future<void> saveCatalogPage({
    required List<CatalogEntry> entries,
    required int nextOffset,
    required bool isComplete,
    required DateTime savedAt,
    int? totalCount,
  }) {
    final pokemonIdsInPage = [for (final entry in entries) entry.id];
    return transaction(() async {
      await (delete(
        pokemonTypesTable,
      )..where((type) => type.pokemonId.isIn(pokemonIdsInPage))).go();
      await batch((batch) {
        batch
          ..insertAllOnConflictUpdate(pokemonTable, [
            for (final entry in entries) _pokemonRowOf(entry, savedAt),
          ])
          ..insertAll(pokemonTypesTable, [
            for (final entry in entries) ..._typeRowsOf(entry),
          ]);
      });
      await into(syncMetadataTable).insertOnConflictUpdate(
        SyncMetadataTableCompanion(
          key: const Value(catalogSyncKey),
          nextOffset: Value(nextOffset),
          totalCount: Value.absentIfNull(totalCount),
          isComplete: Value(isComplete),
          lastSyncedAt: Value(savedAt),
          lastError: const Value(null),
        ),
      );
    });
  }

  Stream<List<CatalogEntry>> watchCatalog() {
    return _pokemonWithTypes().watch().map(_groupTypesByPokemon);
  }

  Stream<List<CatalogEntry>> watchCatalogPage({
    required int limit,
    required int offset,
  }) {
    final pageIds = selectOnly(pokemonTable)
      ..addColumns([pokemonTable.id])
      ..orderBy([OrderingTerm.asc(pokemonTable.id)])
      ..limit(limit, offset: offset);

    final query = _pokemonWithTypes()
      ..where(pokemonTable.id.isInQuery(pageIds));

    return query.watch().map(_groupTypesByPokemon);
  }

  Stream<List<CatalogEntry>> watchPokemonByIds(List<int> ids) {
    final query = _pokemonWithTypes()..where(pokemonTable.id.isIn(ids));

    return query
        .watch()
        .map(_groupTypesByPokemon)
        .map((entries) => _inRequestedOrder(entries, ids));
  }

  Stream<int> watchCatalogCount() {
    final countExpression = pokemonTable.id.count();

    return (selectOnly(pokemonTable)..addColumns([countExpression]))
        .watchSingle()
        .map((row) => row.read(countExpression) ?? 0);
  }

  Future<SyncMetadataRow?> readCatalogSyncProgress() {
    final catalogProgress = select(syncMetadataTable)
      ..where((metadata) => metadata.key.equals(catalogSyncKey));
    return catalogProgress.getSingleOrNull();
  }

  Future<void> recordCatalogSyncFailure(String message) {
    return into(syncMetadataTable).insertOnConflictUpdate(
      SyncMetadataTableCompanion(
        key: const Value(catalogSyncKey),
        lastError: Value(message),
      ),
    );
  }

  PokemonTableCompanion _pokemonRowOf(CatalogEntry entry, DateTime savedAt) {
    return PokemonTableCompanion.insert(
      id: Value(entry.id),
      name: entry.name,
      imageUrl: entry.imageUrl,
      updatedAt: savedAt,
    );
  }

  Iterable<PokemonTypesTableCompanion> _typeRowsOf(CatalogEntry entry) sync* {
    for (final (index, typeName) in entry.typeNames.indexed) {
      yield PokemonTypesTableCompanion.insert(
        pokemonId: entry.id,
        slot: index + 1,
        typeName: typeName,
      );
    }
  }

  JoinedSelectStatement<HasResultSet, dynamic> _pokemonWithTypes() {
    return select(pokemonTable).join([
      leftOuterJoin(
        pokemonTypesTable,
        pokemonTypesTable.pokemonId.equalsExp(pokemonTable.id),
      ),
    ])..orderBy([
      OrderingTerm.asc(pokemonTable.id),
      OrderingTerm.asc(pokemonTypesTable.slot),
    ]);
  }

  List<CatalogEntry> _inRequestedOrder(
    List<CatalogEntry> entries,
    List<int> requestedIds,
  ) {
    final entriesById = {for (final entry in entries) entry.id: entry};
    return [for (final id in requestedIds.toSet()) ?entriesById[id]];
  }

  List<CatalogEntry> _groupTypesByPokemon(List<TypedResult> joinedRows) {
    final entriesById = <int, CatalogEntry>{};
    for (final joinedRow in joinedRows) {
      final pokemon = joinedRow.readTable(pokemonTable);
      final entry = entriesById.putIfAbsent(
        pokemon.id,
        () => CatalogEntry(
          id: pokemon.id,
          name: pokemon.name,
          imageUrl: pokemon.imageUrl,
          typeNames: <String>[],
        ),
      );
      final type = joinedRow.readTableOrNull(pokemonTypesTable);
      if (type != null) {
        entry.typeNames.add(type.typeName);
      }
    }
    return entriesById.values.toList();
  }
}
