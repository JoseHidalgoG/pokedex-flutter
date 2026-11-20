import 'package:pokedex_flutter/features/favorites/domain/repositories/favorites_repository.dart';

class ToggleFavorite {
  const ToggleFavorite(this._repository);

  final FavoritesRepository _repository;

  Future<void> call(int pokemonId) async {
    final isFavorite = await _repository.isFavorite(pokemonId);

    if (isFavorite) {
      await _repository.removeFavorite(pokemonId);
    } else {
      await _repository.addFavorite(pokemonId);
    }
  }
}
