import 'package:pokedex_flutter/features/catalog/domain/repositories/pokemon_image_repository.dart';

class GetPokemonIdsWithSavedArtwork {
  const GetPokemonIdsWithSavedArtwork(this._repository);

  final PokemonImageRepository _repository;

  Future<Set<int>> call() => _repository.pokemonIdsWithSavedArtwork();
}
