import 'package:pokedex_flutter/features/favorites/domain/repositories/favorites_repository.dart';

class FakeFavoritesRepository implements FavoritesRepository {
  final Set<int> _favoriteIds = {};

  @override
  Stream<List<int>> watchFavoriteIds() {
    return Stream.value(_favoriteIds.toList());
  }

  @override
  Stream<bool> watchIsFavorite(int pokemonId) {
    return Stream.value(_favoriteIds.contains(pokemonId));
  }

  @override
  Future<bool> isFavorite(int pokemonId) async {
    return _favoriteIds.contains(pokemonId);
  }

  @override
  Future<void> addFavorite(int pokemonId) async {
    _favoriteIds.add(pokemonId);
  }

  @override
  Future<void> removeFavorite(int pokemonId) async {
    _favoriteIds.remove(pokemonId);
  }
}