import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_detail.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/pokemon_detail_repository.dart';

class WatchPokemonDetail {
  const WatchPokemonDetail(this._repository);

  final PokemonDetailRepository _repository;

  Stream<PokemonDetail?> call(int pokemonId) =>
      _repository.watchPokemonDetail(pokemonId);
}
