import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_repository.dart';

class WatchPokemonByIds {
  const WatchPokemonByIds(this._repository);

  final CatalogRepository _repository;

  Stream<List<Pokemon>> call(List<int> ids) =>
      _repository.watchPokemonByIds(ids);
}
