import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';
import 'package:pokedex_flutter/core/sync/sync_scheduler.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_dao.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry_mapper.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/catalog_sync_constants.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/catalog_sync_service.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_progress.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query.dart';

class OfflineFirstCatalogRepository implements CatalogRepository {
  OfflineFirstCatalogRepository({
    required this._catalogDao,
    required this._syncService,
    required this._scheduler,
  });

  final CatalogDao _catalogDao;
  final CatalogSyncService _syncService;
  final SyncScheduler _scheduler;

  @override
  Stream<List<Pokemon>> watchCatalog() {
    return _catalogDao.watchCatalog().map(_pokemonOf);
  }

  @override
  Stream<List<Pokemon>> watchCatalogPage({
    required int page,
    required int pageSize,
  }) {
    return _catalogDao
        .watchCatalogPage(limit: pageSize, offset: page * pageSize)
        .map(_pokemonOf);
  }

  @override
  Stream<int> watchCatalogCount() {
    return _catalogDao.watchCatalogCount();
  }

  @override
  Stream<List<Pokemon>> watchFilteredCatalogPage({
    required int page,
    required int pageSize,
    required CatalogQuery query,
  }) {
    return _catalogDao
        .watchFilteredCatalogPage(
          limit: pageSize,
          offset: page * pageSize,
          query: query,
        )
        .map(_pokemonOf);
  }

  @override
  Stream<int> watchFilteredCatalogCount(CatalogQuery query) {
    return _catalogDao.watchFilteredCatalogCount(query);
  }

  @override
  Stream<CatalogProgress> watchCatalogProgress() {
    return _catalogDao.watchCatalogProgress().map(
      (progress) => CatalogProgress(
        savedCount: progress.savedCount,
        totalCount: progress.totalCount,
        isComplete: progress.isComplete,
      ),
    );
  }

  @override
  Stream<List<Pokemon>> watchPokemonByIds(List<int> ids) {
    return _catalogDao.watchPokemonByIds(ids).map(_pokemonOf);
  }

  @override
  Stream<SyncStatus> watchSyncStatus() {
    return _scheduler
        .watchStatuses([CatalogDao.catalogSyncKey, visiblePokemonSyncKey])
        .map(mostRelevantSyncStatus);
  }

  @override
  Future<void> syncCatalog({bool force = false}) =>
      _scheduler.run(_syncService.fullPassJob(force: force));

  @override
  Future<void> revalidatePokemon(List<int> ids, {bool force = false}) async {
    if (ids.isEmpty) {
      return;
    }
    _scheduler.runOnEachReconnect(_syncService.visiblePokemonJob(ids));
    if (!_scheduler.isOnline) {
      return;
    }
    if (!force && !await _syncService.hasStalePokemonAmong(ids)) {
      return;
    }
    await _scheduler.runLatest(
      _syncService.visiblePokemonJob(ids, force: force),
    );
  }

  @override
  Future<DateTime?> getLastSyncedAt() async {
    final progress = await _catalogDao.readCatalogSyncProgress();
    return progress?.lastSyncedAt;
  }

  static List<Pokemon> _pokemonOf(List<CatalogEntry> entries) {
    return [for (final entry in entries) entry.toPokemon()];
  }
}
