import 'package:drift/drift.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/core/sync/data/sync_metadata_table.dart';
import 'package:pokedex_flutter/features/catalog/data/catalog_fingerprint.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_tables.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/catalog_sync_constants.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query.dart';

part 'catalog_dao.g.dart';

typedef StoredCatalogEntry = ({CatalogEntry entry, String? storedFingerprint});

@DriftAccessor(
  tables: [
    PokemonTable,
    PokemonTypesTable,
    PokemonStatsTable,
    SyncMetadataTable,
  ],
)
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
    return transaction(() async {
      await upsertEntries(entries, savedAt: savedAt);
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

  Future<void> saveRevalidated(
    List<CatalogEntry> entries, {
    required DateTime savedAt,
  }) async {
    if (entries.isEmpty) {
      return;
    }
    await transaction(() => upsertEntries(entries, savedAt: savedAt));
  }

  Future<List<int>> staleIdsAmong(
    List<int> ids, {
    required DateTime olderThan,
  }) {
    final staleIds = selectOnly(pokemonTable)
      ..addColumns([pokemonTable.id])
      ..where(
        pokemonTable.id.isIn(ids) &
            pokemonTable.updatedAt.isSmallerThanValue(olderThan),
      )
      ..orderBy([OrderingTerm.asc(pokemonTable.id)]);
    return staleIds.map((row) => row.read(pokemonTable.id)!).get();
  }

  Stream<List<CatalogEntry>> watchCatalog() {
    final query = _pokemonWithTypes()..where(_isDefaultPokemon);
    return query.watch().map(_groupTypesByPokemon);
  }

  Stream<List<CatalogEntry>> watchCatalogPage({
    required int limit,
    required int offset,
  }) {
    final pageIds = selectOnly(pokemonTable)
      ..addColumns([pokemonTable.id])
      ..where(_isDefaultPokemon)
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

    final defaultPokemonCount = selectOnly(pokemonTable)
      ..addColumns([countExpression])
      ..where(_isDefaultPokemon);
    return defaultPokemonCount.watchSingle().map(
      (row) => row.read(countExpression) ?? 0,
    );
  }

  Stream<List<CatalogEntry>> watchFilteredCatalogPage({
    required int limit,
    required int offset,
    required CatalogQuery query,
  }) {
    final condition = _catalogCondition(query);
    final ordering = _catalogOrdering(query.sort);

    final pageIds = selectOnly(pokemonTable)
      ..addColumns([pokemonTable.id])
      ..where(condition)
      ..orderBy(ordering)
      ..limit(limit, offset: offset);

    final selectedPokemon = _pokemonWithTypes()
      ..where(pokemonTable.id.isInQuery(pageIds));

    return selectedPokemon.watch().map((rows) {
      final entries = _groupTypesByPokemon(rows);
      return _orderFilteredEntries(entries, query.sort, rows);
    });
  }

  Stream<int> watchFilteredCatalogCount(CatalogQuery query) {
    final countExpression = pokemonTable.id.count();

    final countQuery = selectOnly(pokemonTable)
      ..addColumns([countExpression])
      ..where(_catalogCondition(query));

    return countQuery.watchSingle().map(
      (row) => row.read(countExpression) ?? 0,
    );
  }

  Stream<({int savedCount, int? totalCount, bool isComplete})>
  watchCatalogProgress() {
    final progress = customSelect(
      'SELECT '
      '(SELECT COUNT(*) FROM pokemon WHERE is_default = 1) AS saved_count, '
      '(SELECT total_count FROM sync_metadata WHERE key = ?) AS total_count, '
      'COALESCE('
      '(SELECT is_complete FROM sync_metadata WHERE key = ?), '
      '0'
      ') AS is_complete',
      variables: [
        Variable.withString(catalogSyncKey),
        Variable.withString(catalogSyncKey),
      ],
      readsFrom: {pokemonTable, syncMetadataTable},
    );

    return progress
        .watchSingle()
        .map(
          (row) => (
            savedCount: row.read<int>('saved_count'),
            totalCount: row.read<int?>('total_count'),
            isComplete: row.read<int>('is_complete') != 0,
          ),
        )
        .distinct();
  }

  Future<SyncMetadataRow?> readCatalogSyncProgress() {
    final catalogProgress = select(syncMetadataTable)
      ..where((metadata) => metadata.key.equals(catalogSyncKey));
    return catalogProgress.getSingleOrNull();
  }

  Future<List<StoredCatalogEntry>> readEntriesWithFingerprint() {
    return transaction(() => _readStoredEntriesWhere(const Constant(true)));
  }

  Future<StoredCatalogEntry?> readStoredEntry(int pokemonId) {
    return transaction(() async {
      final stored = await _readStoredEntriesWhere(
        pokemonTable.id.equals(pokemonId),
      );
      return stored.firstOrNull;
    });
  }

  Future<CatalogEntry?> readEntry(int pokemonId) async {
    final stored = await _readStoredEntriesWhere(
      pokemonTable.id.equals(pokemonId),
    );
    return stored.firstOrNull?.entry;
  }

  Future<List<CatalogEntry>> readEntriesOfSpecies(int speciesId) async {
    final stored = await _readStoredEntriesWhere(
      pokemonTable.speciesId.equals(speciesId),
    );
    return [for (final (:entry, storedFingerprint: _) in stored) entry];
  }

  Future<Map<int, String>> readArtworkUrls() async {
    final rows =
        await (selectOnly(pokemonTable)
              ..addColumns([pokemonTable.id, pokemonTable.imageUrl])
              ..where(_isDefaultPokemon)
              ..orderBy([OrderingTerm.asc(pokemonTable.id)]))
            .get();
    return {
      for (final row in rows)
        row.read(pokemonTable.id)!: row.read(pokemonTable.imageUrl)!,
    };
  }

  Future<String?> readImageUrlOf(int pokemonId) {
    final imageUrl = selectOnly(pokemonTable)
      ..addColumns([pokemonTable.imageUrl])
      ..where(pokemonTable.id.equals(pokemonId));
    return imageUrl
        .map((row) => row.read(pokemonTable.imageUrl))
        .getSingleOrNull();
  }

  Future<Map<int, String?>> storedFingerprintsOf(List<int> ids) async {
    final rows =
        await (selectOnly(pokemonTable)
              ..addColumns([pokemonTable.id, pokemonTable.remoteFingerprint])
              ..where(pokemonTable.id.isIn(ids)))
            .get();
    return {
      for (final row in rows)
        row.read(pokemonTable.id)!: row.read(pokemonTable.remoteFingerprint),
    };
  }

  Future<void> recordFingerprintsVerified({required DateTime at}) {
    return into(syncMetadataTable).insertOnConflictUpdate(
      SyncMetadataTableCompanion(
        key: const Value(restorationSyncKey),
        lastVerifiedAt: Value(at),
      ),
    );
  }

  Future<List<StoredCatalogEntry>> _readStoredEntriesWhere(
    Expression<bool> condition,
  ) async {
    final selectedIds = selectOnly(pokemonTable)
      ..addColumns([pokemonTable.id])
      ..where(condition);
    final pokemonRows =
        await (select(pokemonTable)
              ..where((_) => condition)
              ..orderBy([(pokemon) => OrderingTerm.asc(pokemon.id)]))
            .get();
    final typeRows =
        await (select(pokemonTypesTable)
              ..where((type) => type.pokemonId.isInQuery(selectedIds))
              ..orderBy([
                (type) => OrderingTerm.asc(type.pokemonId),
                (type) => OrderingTerm.asc(type.slot),
              ]))
            .get();
    final statRows = await (select(
      pokemonStatsTable,
    )..where((stat) => stat.pokemonId.isInQuery(selectedIds))).get();

    final typeNamesById = <int, List<String>>{};
    for (final type in typeRows) {
      typeNamesById.putIfAbsent(type.pokemonId, () => []).add(type.typeName);
    }
    final statsById = <int, Map<String, int>>{};
    for (final stat in statRows) {
      statsById.putIfAbsent(stat.pokemonId, () => {})[stat.statName] =
          stat.baseStat;
    }

    return [
      for (final pokemon in pokemonRows)
        (
          entry: CatalogEntry(
            id: pokemon.id,
            name: pokemon.name,
            imageUrl: pokemon.imageUrl,
            typeNames: typeNamesById[pokemon.id] ?? const [],
            speciesId: pokemon.speciesId,
            generationId: pokemon.generationId,
            isDefault: pokemon.isDefault,
            heightDm: pokemon.heightDm,
            weightHg: pokemon.weightHg,
            baseStats: statsById[pokemon.id] ?? const {},
          ),
          storedFingerprint: pokemon.remoteFingerprint,
        ),
    ];
  }

  Future<void> upsertEntries(
    List<CatalogEntry> entries, {
    required DateTime savedAt,
  }) async {
    final pokemonIds = [for (final entry in entries) entry.id];
    await (delete(
      pokemonTypesTable,
    )..where((type) => type.pokemonId.isIn(pokemonIds))).go();
    await (delete(
      pokemonStatsTable,
    )..where((stat) => stat.pokemonId.isIn(pokemonIds))).go();
    await batch((batch) {
      batch
        ..insertAllOnConflictUpdate(pokemonTable, [
          for (final entry in entries) _pokemonRowOf(entry, savedAt),
        ])
        ..insertAll(pokemonTypesTable, [
          for (final entry in entries) ..._typeRowsOf(entry),
        ])
        ..insertAll(pokemonStatsTable, [
          for (final entry in entries) ..._statRowsOf(entry),
        ]);
    });
  }

  PokemonTableCompanion _pokemonRowOf(CatalogEntry entry, DateTime savedAt) {
    return PokemonTableCompanion.insert(
      id: Value(entry.id),
      name: entry.name,
      imageUrl: entry.imageUrl,
      updatedAt: savedAt,
      speciesId: Value(entry.speciesId),
      generationId: Value(entry.generationId),
      isDefault: Value(entry.isDefault),
      heightDm: Value(entry.heightDm),
      weightHg: Value(entry.weightHg),
      baseStatTotal: Value(entry.baseStatTotal),
      remoteFingerprint: Value(catalogFingerprintOf(entry)),
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

  Iterable<PokemonStatsTableCompanion> _statRowsOf(CatalogEntry entry) sync* {
    for (final MapEntry(key: statName, value: baseStat)
        in entry.baseStats.entries) {
      yield PokemonStatsTableCompanion.insert(
        pokemonId: entry.id,
        statName: statName,
        baseStat: baseStat,
      );
    }
  }

  Expression<bool> get _isDefaultPokemon => pokemonTable.isDefault.equals(true);

  Expression<bool> _catalogCondition(CatalogQuery query) {
    Expression<bool> condition = _isDefaultPokemon;

    final search = query.search.trim();

    if (search.isNotEmpty) {
      final pokemonId = int.tryParse(search);

      if (pokemonId != null) {
        condition = condition & pokemonTable.id.equals(pokemonId);
      } else {
        final escapedSearch = search
            .replaceAll(r'\', r'\\')
            .replaceAll('%', r'\%')
            .replaceAll('_', r'\_');

        condition =
            condition &
            pokemonTable.name.like('$escapedSearch%', escapeChar: r'\');
      }
    }

    final types = query.types;

    if (types.isNotEmpty) {
      final matchingTypes = selectOnly(pokemonTypesTable)
        ..addColumns([pokemonTypesTable.pokemonId])
        ..where(pokemonTypesTable.typeName.isIn(types));

      condition = condition & pokemonTable.id.isInQuery(matchingTypes);
    }

    final generations = query.generations;

    if (generations.isNotEmpty) {
      condition = condition & pokemonTable.generationId.isIn(generations);
    }

    return condition;
  }

  List<OrderingTerm> _catalogOrdering(CatalogSort sort) {
    return switch (sort) {
      CatalogSort.numberAscending => [OrderingTerm.asc(pokemonTable.id)],
      CatalogSort.numberDescending => [OrderingTerm.desc(pokemonTable.id)],
      CatalogSort.nameAscending => [
        OrderingTerm.asc(pokemonTable.name.collate(Collate.noCase)),
        OrderingTerm.asc(pokemonTable.id),
      ],
      CatalogSort.nameDescending => [
        OrderingTerm.desc(pokemonTable.name.collate(Collate.noCase)),
        OrderingTerm.asc(pokemonTable.id),
      ],
      CatalogSort.baseStatTotalAscending => [
        OrderingTerm.asc(pokemonTable.baseStatTotal, nulls: NullsOrder.last),
        OrderingTerm.asc(pokemonTable.id),
      ],
      CatalogSort.baseStatTotalDescending => [
        OrderingTerm.desc(pokemonTable.baseStatTotal, nulls: NullsOrder.last),
        OrderingTerm.asc(pokemonTable.id),
      ],
    };
  }

  List<CatalogEntry> _orderFilteredEntries(
    List<CatalogEntry> entries,
    CatalogSort sort,
    List<TypedResult> rows,
  ) {
    final pokemonRows = <int, PokemonRow>{};

    for (final row in rows) {
      final pokemon = row.readTable(pokemonTable);
      pokemonRows[pokemon.id] = pokemon;
    }

    final sorted = [...entries];

    sorted.sort((a, b) {
      final first = pokemonRows[a.id]!;
      final second = pokemonRows[b.id]!;

      int comparison;

      switch (sort) {
        case CatalogSort.numberAscending:
          comparison = first.id.compareTo(second.id);
        case CatalogSort.numberDescending:
          comparison = second.id.compareTo(first.id);
        case CatalogSort.nameAscending:
          comparison = first.name.toLowerCase().compareTo(
            second.name.toLowerCase(),
          );
        case CatalogSort.nameDescending:
          comparison = second.name.toLowerCase().compareTo(
            first.name.toLowerCase(),
          );
        case CatalogSort.baseStatTotalAscending:
          comparison = _compareNullableStats(
            first.baseStatTotal,
            second.baseStatTotal,
          );
        case CatalogSort.baseStatTotalDescending:
          comparison = _compareNullableStats(
            first.baseStatTotal,
            second.baseStatTotal,
            descending: true,
          );
      }

      return comparison != 0 ? comparison : first.id.compareTo(second.id);
    });

    return sorted;
  }

  int _compareNullableStats(
    int? first,
    int? second, {
    bool descending = false,
  }) {
    if (first == null && second == null) return 0;
    if (first == null) return 1;
    if (second == null) return -1;

    return descending ? second.compareTo(first) : first.compareTo(second);
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
