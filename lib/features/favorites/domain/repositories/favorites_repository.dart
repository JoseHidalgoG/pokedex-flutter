abstract interface class FavoritesRepository {
  Stream<List<int>> watchFavoriteIds();

  Stream<bool> watchIsFavorite(int pokemonId);

  Future<bool> isFavorite(int pokemonId);

  Future<void> addFavorite(int pokemonId);

  Future<void> removeFavorite(int pokemonId);
}
