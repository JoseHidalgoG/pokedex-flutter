import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_progress.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_repository.dart';

class WatchCatalogProgress {
  const WatchCatalogProgress(this._repository);

  final CatalogRepository _repository;

  Stream<CatalogProgress> call() => _repository.watchCatalogProgress();
}
