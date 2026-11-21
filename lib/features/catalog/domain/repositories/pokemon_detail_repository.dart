import 'package:pokedex_flutter/features/catalog/domain/entities/detail_freshness.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_detail.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/type_matchups.dart';

abstract interface class PokemonDetailRepository {
  Stream<PokemonDetail?> watchPokemonDetail(int pokemonId);

  Stream<DetailFreshness> watchPokemonDetailFreshness(int pokemonId);

  Stream<List<TypeEfficacy>> watchTypeEfficacy();

  Future<void> revalidatePokemonDetail(int pokemonId, {bool force = false});

  void stopRevalidatingPokemonDetail(int pokemonId);
}
