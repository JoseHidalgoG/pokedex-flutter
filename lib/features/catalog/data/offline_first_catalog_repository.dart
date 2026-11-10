import 'package:pokedex_flutter/features/catalog/data/local/catalog_dao.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry_mapper.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/catalog_sync_service.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_sync_status.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_repository.dart';

class OfflineFirstCatalogRepository implements CatalogRepository {
  OfflineFirstCatalogRepository({
    required this._catalogDao,
    required this._syncService,
  });

  final CatalogDao _catalogDao;
  final CatalogSyncService _syncService;

  @override
  Stream<List<Pokemon>> watchCatalog() {
    return _catalogDao.watchCatalog().map(
      (entries) => [for (final entry in entries) entry.toPokemon()],
    );
  }

  @override
  Stream<List<Pokemon>> watchCatalogPage({
    required int page,
    required int pageSize,
  }) {
    return _catalogDao
        .watchCatalogPage(
      limit: pageSize,
      offset: page * pageSize,
    )
        .map(
          (entries) => [
        for (final entry in entries) entry.toPokemon(),
      ],
    );
  }

  @override
  Stream<int> watchCatalogCount() {
    return _catalogDao.watchCatalogCount();
  }

  @override
  Stream<CatalogSyncStatus> watchSyncStatus() => _syncService.watchStatus();

  @override
  Future<void> syncCatalog() => _syncService.syncCatalog();

  @override
  Future<DateTime?> getLastSyncedAt() async {
    final progress = await _catalogDao.readCatalogSyncProgress();
    return progress?.lastSyncedAt;
  }
}
