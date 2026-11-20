import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/core/sync/data/sync_failure_translator.dart';
import 'package:pokedex_flutter/core/sync/domain/call_budget.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_job.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_dao.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_batch.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_remote_data_source.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto_mapper.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/catalog_sync_constants.dart';

class CatalogSyncService {
  CatalogSyncService({
    required this._remoteDataSource,
    required this._catalogDao,
    this._now = DateTime.now,
  });

  final CatalogRemoteDataSource _remoteDataSource;
  final CatalogDao _catalogDao;
  final DateTime Function() _now;

  SyncJob fullPassJob({bool force = false}) {
    return SyncJob(
      key: CatalogDao.catalogSyncKey,
      priority: CallPriority.background,
      runningStatus: const SyncFullPassInProgress(),
      force: force,
      perform: () => syncCatalog(force: force),
    );
  }

  Future<SyncOutcome> syncCatalog({bool force = false}) async {
    try {
      final progress = await _catalogDao.readCatalogSyncProgress();
      if (!force && _isFreshAndComplete(progress)) {
        return SyncOutcome.upToDate;
      }
      await _downloadBatchesAfter(progress);
      return SyncOutcome.revalidated;
    } on SyncFailure {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(syncFailureFrom(error), stackTrace);
    }
  }

  bool _isFreshAndComplete(SyncMetadataRow? progress) {
    if (progress case SyncMetadataRow(
      isComplete: true,
      lastSyncedAt: final DateTime lastSyncedAt,
    )) {
      return _now().difference(lastSyncedAt) < catalogFullPassFreshness;
    }
    return false;
  }

  int _startOffsetFor(SyncMetadataRow? progress) {
    if (progress == null || progress.isComplete) {
      return 0;
    }
    return progress.nextOffset;
  }

  Future<void> _downloadBatchesAfter(SyncMetadataRow? progress) async {
    var nextOffset = _startOffsetFor(progress);
    var totalCount = nextOffset == 0 ? null : progress?.totalCount;
    var isComplete = false;
    while (!isComplete) {
      final batch = await _remoteDataSource.fetchCatalogPage(
        limit: catalogRemoteBatchSize,
        offset: nextOffset,
        withTotal: totalCount == null,
      );
      totalCount = batch.totalCount ?? totalCount;
      nextOffset += batch.pokemon.length;
      isComplete = _isLastBatch(
        batch,
        nextOffset: nextOffset,
        totalCount: totalCount,
      );
      await _catalogDao.saveCatalogPage(
        entries: [
          for (final pokemon in batch.pokemon) pokemon.toCatalogEntry(),
        ],
        nextOffset: nextOffset,
        isComplete: isComplete,
        savedAt: _now(),
        totalCount: batch.totalCount,
      );
    }
  }

  bool _isLastBatch(
    CatalogBatch batch, {
    required int nextOffset,
    required int? totalCount,
  }) {
    final cameBackShort = batch.pokemon.length < catalogRemoteBatchSize;
    final reachedTotal = totalCount != null && nextOffset >= totalCount;
    return cameBackShort || reachedTotal;
  }
}
