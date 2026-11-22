import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_repository.dart';

class WatchFilteredCatalogCount {
  const WatchFilteredCatalogCount(this._repository);

  final CatalogRepository _repository;

  Stream<int> call(CatalogQuery query) {
    return _repository.watchFilteredCatalogCount(query);
  }
}
