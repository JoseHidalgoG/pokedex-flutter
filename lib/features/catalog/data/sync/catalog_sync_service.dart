import 'dart:async';

import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/core/sync/data/sync_failure_translator.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_dao.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_remote_data_source.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto_mapper.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_pagination.dart';

const catalogFreshnessWindow = Duration(hours: 24);

typedef InternetAccessCheck = Future<bool> Function();

class CatalogSyncService {
  CatalogSyncService({
    required this._remoteDataSource,
    required this._catalogDao,
    required this._hasInternetAccess,
    this._now = DateTime.now,
  });

  final CatalogRemoteDataSource _remoteDataSource;
  final CatalogDao _catalogDao;
  final InternetAccessCheck _hasInternetAccess;
  final DateTime Function() _now;

  final _statusChanges = StreamController<SyncStatus>.broadcast();
  SyncStatus _status = const SyncIdle();
  Future<void>? _runningSync;

  SyncStatus get currentStatus => _status;

  Stream<SyncStatus> watchStatus() {
    return Stream.multi((listener) {
      listener.add(_status);
      final subscription = _statusChanges.stream.listen(
        listener.add,
        onDone: listener.close,
      );
      listener.onCancel = subscription.cancel;
    });
  }

  Future<void> syncCatalog({bool force = false}) {
    return _runningSync ??= _synchronize(force: force)
        .whenComplete(() => _runningSync = null);
  }

  Future<void> dispose() => _statusChanges.close();

  Future<void> _synchronize({required bool force}) async {
    _emit(const SyncFullPassInProgress());

    try {
      final progress = await _catalogDao.readCatalogSyncProgress();

      if (!force && _isFreshAndComplete(progress)) {
        _emit(const SyncIdle());
        return;
      }

      final hasInternet = await _hasInternetAccess();

      if (!hasInternet) {
        _emit(const SyncFailed(NoConnection()));
        return;
      }

      await _downloadPagesFrom(_startOffsetFor(progress));

      _emit(SyncRevalidated(_now()));
    } on SyncFailure catch (failure) {
      final reportedFailure = await _confirmConnectionBehind(failure);

      _emit(SyncFailed(reportedFailure));

      try {
        await _catalogDao.recordCatalogSyncFailure(reportedFailure.toString());
      } catch (_) {}
    } catch (error) {
      _emit(SyncFailed(syncFailureFrom(error)));
      rethrow;
    }
  }

  bool _isFreshAndComplete(SyncMetadataRow? progress) {
    if (progress case SyncMetadataRow(
      isComplete: true,
      lastSyncedAt: final DateTime lastSyncedAt,
    )) {
      return _now().difference(lastSyncedAt) < catalogFreshnessWindow;
    }
    return false;
  }

  int _startOffsetFor(SyncMetadataRow? progress) {
    if (progress == null || progress.isComplete) {
      return 0;
    }
    return progress.nextOffset;
  }

  Future<void> _downloadPagesFrom(int startOffset) async {
    var nextOffset = startOffset;
    var reachedEnd = false;
    while (!reachedEnd) {
      final page = await _remoteDataSource.fetchCatalogPage(
        limit: catalogPageSize,
        offset: nextOffset,
      );
      nextOffset += page.length;
      reachedEnd = page.length < catalogPageSize;
      await _catalogDao.saveCatalogPage(
        entries: [for (final pokemon in page) pokemon.toCatalogEntry()],
        nextOffset: nextOffset,
        isComplete: reachedEnd,
        savedAt: _now(),
      );
    }
  }

  Future<SyncFailure> _confirmConnectionBehind(SyncFailure failure) async {
    if (failure is NoConnection) {
      return failure;
    }
    try {
      return await _hasInternetAccess() ? failure : const NoConnection();
    } catch (_) {
      return failure;
    }
  }

  void _emit(SyncStatus status) {
    _status = status;
    if (!_statusChanges.isClosed) {
      _statusChanges.add(status);
    }
  }
}
