import 'package:pokedex_flutter/core/sync/domain/call_budget.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';

enum SyncOutcome { revalidated, upToDate }

class SyncJob {
  const SyncJob({
    required this.key,
    required this.priority,
    required this.runningStatus,
    required this.perform,
    this.force = false,
  });

  final String key;
  final CallPriority priority;
  final SyncStatus runningStatus;
  final Future<SyncOutcome> Function() perform;
  final bool force;
}
