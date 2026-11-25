import 'package:pokedex_flutter/features/catalog/domain/repositories/pokemon_detail_repository.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/pokemon_image_repository.dart';

class KeepPokemonOffline {
  const KeepPokemonOffline({required this._images, required this._details});

  final PokemonImageRepository _images;
  final PokemonDetailRepository _details;

  Future<void> call(int pokemonId) async {
    await Future.wait([
      _images.saveArtworkOf(pokemonId),
      _details.saveDetailForOffline(pokemonId),
    ]);
  }
}
