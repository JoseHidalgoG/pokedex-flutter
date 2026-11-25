import 'package:pokedex_flutter/features/catalog/domain/repositories/pokemon_image_repository.dart';

class SaveArtworkOf {
  const SaveArtworkOf(this._repository);

  final PokemonImageRepository _repository;

  Future<bool> call(int pokemonId) => _repository.saveArtworkOf(pokemonId);
}
