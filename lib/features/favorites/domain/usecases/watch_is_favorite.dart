import 'package:pokedex_flutter/features/favorites/domain/repositories/favorites_repository.dart';

class WatchIsFavorite {
  const WatchIsFavorite(this._repository);

  final FavoritesRepository _repository;

  Stream<bool> call(int pokemonId) {
    return _repository.watchIsFavorite(pokemonId);
  }
}
