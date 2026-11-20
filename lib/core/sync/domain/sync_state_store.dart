import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';

abstract interface class SyncStateStore {
  Future<void> recordStarted(String key);

  Future<void> recordSucceeded(String key);

  Future<void> recordWaitingRetry(
    String key, {
    required int attempt,
    required DateTime retryAt,
    required SyncFailure failure,
  });

  Future<void> recordPaused(String key, {required DateTime until});

  Future<void> recordPending(String key, {required SyncFailure failure});

  Future<void> recordFailed(
    String key, {
    required int attempt,
    required SyncFailure failure,
  });
}
