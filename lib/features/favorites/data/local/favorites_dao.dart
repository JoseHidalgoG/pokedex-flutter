import 'package:drift/drift.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/features/favorites/data/local/favorites_table.dart';

part 'favorites_dao.g.dart';

@DriftAccessor(tables: [FavoritesTable])
class FavoritesDao extends DatabaseAccessor<AppDatabase>
    with _$FavoritesDaoMixin {
  FavoritesDao(super.db);

  Stream<List<int>> watchFavoriteIds() {
    final query = select(favoritesTable)
      ..orderBy([
        (table) =>
            OrderingTerm(expression: table.createdAt, mode: OrderingMode.desc),
      ]);

    return query.watch().map(
      (rows) => rows.map((row) => row.pokemonId).toList(),
    );
  }

  Stream<bool> watchIsFavorite(int pokemonId) {
    final query = select(favoritesTable)
      ..where((table) => table.pokemonId.equals(pokemonId));

    return query.watchSingleOrNull().map((row) => row != null);
  }

  Future<void> addFavorite(int pokemonId) async {
    await into(favoritesTable).insert(
      FavoritesTableCompanion.insert(
        pokemonId: Value(pokemonId),
        createdAt: DateTime.now(),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> removeFavorite(int pokemonId) async {
    await (delete(
      favoritesTable,
    )..where((table) => table.pokemonId.equals(pokemonId))).go();
  }

  Future<bool> isFavorite(int pokemonId) async {
    final query = select(favoritesTable)
      ..where((table) => table.pokemonId.equals(pokemonId));

    final result = await query.getSingleOrNull();
    return result != null;
  }
}
