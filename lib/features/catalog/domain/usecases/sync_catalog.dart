import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_repository.dart';

class SyncCatalog {
  const SyncCatalog(this._repository);

  final CatalogRepository _repository;

  Future<void> call() => _repository.syncCatalog();
}
