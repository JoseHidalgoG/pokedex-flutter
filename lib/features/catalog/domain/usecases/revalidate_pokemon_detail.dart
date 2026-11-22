import 'package:pokedex_flutter/features/catalog/domain/repositories/pokemon_detail_repository.dart';

class RevalidatePokemonDetail {
  const RevalidatePokemonDetail(this._repository);

  final PokemonDetailRepository _repository;

  Future<void> call(int pokemonId, {bool force = false}) =>
      _repository.revalidatePokemonDetail(pokemonId, force: force);
}
