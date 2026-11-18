import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';

sealed class SyncStatus {
  const SyncStatus();
}

final class SyncIdle extends SyncStatus {
  const SyncIdle();
}

final class SyncFullPassInProgress extends SyncStatus {
  const SyncFullPassInProgress();
}

final class SyncRevalidating extends SyncStatus {
  const SyncRevalidating();
}

final class SyncRevalidated extends SyncStatus {
  const SyncRevalidated(this.at);

  final DateTime at;
}

final class SyncWaitingRetry extends SyncStatus {
  const SyncWaitingRetry({
    required this.attempt,
    required this.maxAttempts,
    required this.retryAt,
    required this.failure,
  });

  final int attempt;
  final int maxAttempts;
  final DateTime retryAt;
  final SyncFailure failure;
}

final class SyncPaused extends SyncStatus {
  const SyncPaused(this.until);

  final DateTime until;
}

final class SyncFailed extends SyncStatus {
  const SyncFailed(this.failure);

  final SyncFailure failure;
}
