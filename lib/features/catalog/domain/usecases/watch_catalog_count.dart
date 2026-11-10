import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_repository.dart';

class WatchCatalogCount {
  const WatchCatalogCount(this._repository);

  final CatalogRepository _repository;

  Stream<int> call() => _repository.watchCatalogCount();
}