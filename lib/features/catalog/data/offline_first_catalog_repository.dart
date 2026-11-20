import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';
import 'package:pokedex_flutter/core/sync/sync_scheduler.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_dao.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry_mapper.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/catalog_sync_service.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_repository.dart';

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
  Stream<List<Pokemon>> watchPokemonByIds(List<int> ids) {
    return _catalogDao.watchPokemonByIds(ids).map(_pokemonOf);
  }

  @override
  Stream<SyncStatus> watchSyncStatus() =>
      _scheduler.watchStatus(CatalogDao.catalogSyncKey);

  @override
  Future<void> syncCatalog({bool force = false}) =>
      _scheduler.run(_syncService.fullPassJob(force: force));

  @override
  Future<DateTime?> getLastSyncedAt() async {
    final progress = await _catalogDao.readCatalogSyncProgress();
    return progress?.lastSyncedAt;
  }

  static List<Pokemon> _pokemonOf(List<CatalogEntry> entries) {
    return [for (final entry in entries) entry.toPokemon()];
  }
}
