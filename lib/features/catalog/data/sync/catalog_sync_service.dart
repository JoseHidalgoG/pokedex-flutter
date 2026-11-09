import 'dart:async';

import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_dao.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_page_request_failed.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_remote_data_source.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto_mapper.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_sync_status.dart';

const catalogPageSize = 50;
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

  final _statusChanges = StreamController<CatalogSyncStatus>.broadcast();
  CatalogSyncStatus _status = const CatalogSyncIdle();
  Future<void>? _runningSync;

  CatalogSyncStatus get currentStatus => _status;

  Stream<CatalogSyncStatus> watchStatus() {
    return Stream.multi((listener) {
      listener.add(_status);
      final subscription = _statusChanges.stream.listen(
        listener.add,
        onDone: listener.close,
      );
      listener.onCancel = subscription.cancel;
    });
  }

  Future<void> syncCatalog() {
    return _runningSync ??= _synchronize().whenComplete(
      () => _runningSync = null,
    );
  }

  Future<void> dispose() => _statusChanges.close();

  Future<void> _synchronize() async {
    final progress = await _catalogDao.readCatalogSyncProgress();
    if (_isFreshAndComplete(progress)) {
      _emit(const CatalogSyncSucceeded());
      return;
    }
    if (!await _hasInternetAccess()) {
      _emit(const CatalogSyncFailed(CatalogSyncFailureReason.noConnection));
      return;
    }
    _emit(const CatalogSyncInProgress());
    try {
      await _downloadPagesFrom(_startOffsetFor(progress));
      _emit(const CatalogSyncSucceeded());
    } on CatalogPageRequestFailed catch (failure) {
      _emit(CatalogSyncFailed(await _reasonForFailedRequest()));
      await _catalogDao.recordCatalogSyncFailure(failure.toString());
    } on Object {
      _emit(const CatalogSyncFailed(CatalogSyncFailureReason.requestFailed));
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

  Future<CatalogSyncFailureReason> _reasonForFailedRequest() async {
    return await _hasInternetAccess()
        ? CatalogSyncFailureReason.requestFailed
        : CatalogSyncFailureReason.noConnection;
  }

  void _emit(CatalogSyncStatus status) {
    _status = status;
    if (!_statusChanges.isClosed) {
      _statusChanges.add(status);
    }
  }
}
