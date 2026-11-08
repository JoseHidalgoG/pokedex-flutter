import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto.dart';

String officialArtworkUrlFor(int pokemonId) {
  return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokemonId.png';
}

extension PokemonDtoToCatalogEntry on PokemonDto {
  CatalogEntry toCatalogEntry() {
    return CatalogEntry(
      id: id,
      name: name,
      imageUrl: officialArtworkUrlFor(id),
      typeNames: typeNames,
    );
  }
}
