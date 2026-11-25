import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_artwork.dart';

extension PokemonDtoToCatalogEntry on PokemonDto {
  CatalogEntry toCatalogEntry() {
    return CatalogEntry(
      id: id,
      name: name,
      imageUrl: officialArtworkUrl ?? officialArtworkUrlFor(id),
      typeNames: typeNames,
      speciesId: speciesId,
      generationId: generationId,
      isDefault: isDefault,
      heightDm: heightDm,
      weightHg: weightHg,
      baseStats: baseStats,
    );
  }
}
