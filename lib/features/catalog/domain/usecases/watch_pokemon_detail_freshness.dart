import 'package:pokedex_flutter/features/catalog/domain/entities/detail_freshness.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/pokemon_detail_repository.dart';

class WatchPokemonDetailFreshness {
  const WatchPokemonDetailFreshness(this._repository);

  final PokemonDetailRepository _repository;

  Stream<DetailFreshness> call(int pokemonId) =>
      _repository.watchPokemonDetailFreshness(pokemonId);
}
