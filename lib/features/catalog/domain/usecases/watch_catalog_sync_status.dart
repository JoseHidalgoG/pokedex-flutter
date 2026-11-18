import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_repository.dart';

class WatchCatalogSyncStatus {
  const WatchCatalogSyncStatus(this._repository);

  final CatalogRepository _repository;

  Stream<SyncStatus> call() => _repository.watchSyncStatus();
}
