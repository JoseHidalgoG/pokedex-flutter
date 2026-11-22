import 'dart:developer' as developer;

import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/core/sync/data/sync_failure_translator.dart';
import 'package:pokedex_flutter/core/sync/domain/call_budget.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_job.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';
import 'package:pokedex_flutter/features/catalog/data/catalog_fingerprint.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_dao.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';
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

  SyncJob visiblePokemonJob(List<int> ids, {bool force = false}) {
    return SyncJob(
      key: visiblePokemonSyncKey,
      priority: CallPriority.user,
      runningStatus: const SyncRevalidating(),
      force: force,
      perform: () => revalidatePokemon(ids, force: force),
    );
  }

  Future<SyncOutcome> syncCatalog({bool force = false}) {
    return asSyncFailures(() async {
      final progress = await _catalogDao.readCatalogSyncProgress();
      if (!force && _isFreshAndComplete(progress)) {
        return SyncOutcome.upToDate;
      }
      await _downloadBatchesAfter(progress);
      return SyncOutcome.revalidated;
    });
  }

  Future<bool> hasStalePokemonAmong(List<int> ids) async {
    final staleIds = await _staleIdsAmong(ids);
    return staleIds.isNotEmpty;
  }

  Future<SyncOutcome> revalidatePokemon(List<int> ids, {bool force = false}) {
    return asSyncFailures(() async {
      final idsToDownload = force ? ids : await _staleIdsAmong(ids);
      if (idsToDownload.isEmpty) {
        return SyncOutcome.upToDate;
      }
      final pokemon = await _remoteDataSource.fetchPokemonByIds(idsToDownload);
      await _catalogDao.saveRevalidated([
        for (final dto in pokemon) dto.toCatalogEntry(),
      ], savedAt: _now());
      return SyncOutcome.revalidated;
    });
  }

  Future<List<int>> _staleIdsAmong(List<int> ids) {
    return _catalogDao.staleIdsAmong(
      ids,
      olderThan: _now().subtract(visibleFreshnessWindow),
    );
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
      final freshEntries = [
        for (final pokemon in batch.pokemon) pokemon.toCatalogEntry(),
      ];
      await _logDifferentFingerprints(freshEntries);
      await _catalogDao.saveCatalogPage(
        entries: freshEntries,
        nextOffset: nextOffset,
        isComplete: isComplete,
        savedAt: _now(),
        totalCount: batch.totalCount,
      );
    }
  }

  Future<void> _logDifferentFingerprints(
    List<CatalogEntry> freshEntries,
  ) async {
    final storedFingerprints = await _catalogDao.storedFingerprintsOf([
      for (final entry in freshEntries) entry.id,
    ]);
    final differentIds = idsWithDifferentStoredFingerprint(
      freshEntries,
      storedFingerprints: storedFingerprints,
    );
    if (differentIds.isEmpty) {
      return;
    }
    developer.log(
      'pasada completa: huella distinta en '
      '${[for (final id in differentIds) '#$id'].join(', ')}; '
      'se guarda lo de PokeAPI',
      name: 'sync',
    );
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
