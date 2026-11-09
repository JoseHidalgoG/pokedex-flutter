import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_sync_status.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_repository.dart';

class WatchCatalogSyncStatus {
  const WatchCatalogSyncStatus(this._repository);

  final CatalogRepository _repository;

  Stream<CatalogSyncStatus> call() => _repository.watchSyncStatus();
}
