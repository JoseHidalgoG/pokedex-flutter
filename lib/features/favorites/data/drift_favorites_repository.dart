import 'package:pokedex_flutter/features/favorites/data/local/favorites_dao.dart';
import 'package:pokedex_flutter/features/favorites/domain/repositories/favorites_repository.dart';

class DriftFavoritesRepository implements FavoritesRepository {
  const DriftFavoritesRepository(this._dao);

  final FavoritesDao _dao;

  @override
  Stream<List<int>> watchFavoriteIds() {
    return _dao.watchFavoriteIds();
  }

  @override
  Stream<bool> watchIsFavorite(int pokemonId) {
    return _dao.watchIsFavorite(pokemonId);
  }

  @override
  Future<bool> isFavorite(int pokemonId) {
    return _dao.isFavorite(pokemonId);
  }

  @override
  Future<void> addFavorite(int pokemonId) {
    return _dao.addFavorite(pokemonId);
  }

  @override
  Future<void> removeFavorite(int pokemonId) {
    return _dao.removeFavorite(pokemonId);
  }
}
