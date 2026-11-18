import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto.dart';

class CatalogBatch {
  const CatalogBatch({required this.pokemon, this.totalCount});

  final List<PokemonDto> pokemon;
  final int? totalCount;
}
