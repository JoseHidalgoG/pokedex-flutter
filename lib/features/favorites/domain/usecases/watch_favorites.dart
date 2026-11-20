import 'package:pokedex_flutter/features/favorites/domain/repositories/favorites_repository.dart';

class WatchFavorites {
  const WatchFavorites(this._repository);

  final FavoritesRepository _repository;

  Stream<List<int>> call() {
    return _repository.watchFavoriteIds();
  }
}
