import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';

extension CatalogEntryToPokemon on CatalogEntry {
  Pokemon toPokemon() {
    return Pokemon(
      id: id,
      name: name,
      imageUrl: imageUrl,
      typeNames: List.unmodifiable(typeNames),
    );
  }
}
