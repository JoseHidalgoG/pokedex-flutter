import 'package:drift/drift.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/core/sync/data/sync_metadata_table.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_state_store.dart';

part 'sync_metadata_dao.g.dart';

enum StoredSyncStatus {
  idle('idle'),
  inProgress('in_progress'),
  waitingRetry('waiting_retry'),
  paused('paused'),
  pending('pending'),
  failed('failed');

  const StoredSyncStatus(this.columnValue);

  final String columnValue;
}

@DriftAccessor(tables: [SyncMetadataTable])
class SyncMetadataDao extends DatabaseAccessor<AppDatabase>
    with _$SyncMetadataDaoMixin
    implements SyncStateStore {
  SyncMetadataDao(super.attachedDatabase);

  Future<SyncMetadataRow?> readByKey(String key) {
    final row = select(syncMetadataTable)
      ..where((metadata) => metadata.key.equals(key));
    return row.getSingleOrNull();
  }

  @override
  Future<void> recordStarted(String key) {
    return _upsert(
      SyncMetadataTableCompanion(
        key: Value(key),
        status: Value(StoredSyncStatus.inProgress.columnValue),
      ),
    );
  }

  @override
  Future<void> recordSucceeded(String key) {
    return _upsert(
      SyncMetadataTableCompanion(
        key: Value(key),
        status: Value(StoredSyncStatus.idle.columnValue),
        attempt: const Value(0),
        nextRetryAt: const Value(null),
        lastErrorKind: const Value(null),
        lastError: const Value(null),
      ),
    );
  }

  @override
  Future<void> recordWaitingRetry(
    String key, {
    required int attempt,
    required DateTime retryAt,
    required SyncFailure failure,
  }) {
    return _upsert(
      SyncMetadataTableCompanion(
        key: Value(key),
        status: Value(StoredSyncStatus.waitingRetry.columnValue),
        attempt: Value(attempt),
        nextRetryAt: Value(retryAt),
        lastErrorKind: Value(_kindOf(failure)),
        lastError: Value('$failure'),
      ),
    );
  }

  @override
  Future<void> recordPaused(String key, {required DateTime until}) {
    return _upsert(
      SyncMetadataTableCompanion(
        key: Value(key),
        status: Value(StoredSyncStatus.paused.columnValue),
        nextRetryAt: Value(until),
      ),
    );
  }

  @override
  Future<void> recordPending(String key, {required SyncFailure failure}) {
    return _upsert(
      SyncMetadataTableCompanion(
        key: Value(key),
        status: Value(StoredSyncStatus.pending.columnValue),
        nextRetryAt: const Value(null),
        lastErrorKind: Value(_kindOf(failure)),
        lastError: Value('$failure'),
      ),
    );
  }

  @override
  Future<void> recordFailed(
    String key, {
    required int attempt,
    required SyncFailure failure,
  }) {
    return _upsert(
      SyncMetadataTableCompanion(
        key: Value(key),
        status: Value(StoredSyncStatus.failed.columnValue),
        attempt: Value(attempt),
        nextRetryAt: const Value(null),
        lastErrorKind: Value(_kindOf(failure)),
        lastError: Value('$failure'),
      ),
    );
  }

  Future<void> _upsert(SyncMetadataTableCompanion changes) {
    return into(syncMetadataTable).insertOnConflictUpdate(changes);
  }

  static String _kindOf(SyncFailure failure) {
    return switch (failure) {
      NoConnection() => 'no_connection',
      RequestTimeout() => 'request_timeout',
      RateLimited() => 'rate_limited',
      ServerError() => 'server_error',
      PartialResponse() => 'partial_response',
      QueryError() => 'query_error',
      InvalidResponse() => 'invalid_response',
      CallBudgetExhausted() => 'call_budget_exhausted',
    };
  }
}
