import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_repository.dart';

class WatchCatalog {
  const WatchCatalog(this._repository);

  final CatalogRepository _repository;

  Stream<List<Pokemon>> call() => _repository.watchCatalog();
}
