import 'package:pokedex_flutter/features/catalog/domain/repositories/pokemon_detail_repository.dart';

class StopRevalidatingPokemonDetail {
  const StopRevalidatingPokemonDetail(this._repository);

  final PokemonDetailRepository _repository;

  void call(int pokemonId) =>
      _repository.stopRevalidatingPokemonDetail(pokemonId);
}
