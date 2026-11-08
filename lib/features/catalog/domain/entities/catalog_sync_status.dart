sealed class CatalogSyncStatus {
  const CatalogSyncStatus();
}

final class CatalogSyncIdle extends CatalogSyncStatus {
  const CatalogSyncIdle();
}

final class CatalogSyncInProgress extends CatalogSyncStatus {
  const CatalogSyncInProgress();
}

final class CatalogSyncSucceeded extends CatalogSyncStatus {
  const CatalogSyncSucceeded();
}

final class CatalogSyncFailed extends CatalogSyncStatus {
  const CatalogSyncFailed(this.reason);

  final CatalogSyncFailureReason reason;
}

enum CatalogSyncFailureReason { noConnection, requestFailed }
