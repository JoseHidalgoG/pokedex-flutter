import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/core/database/app_database_provider.dart';
import 'package:pokedex_flutter/core/sync/domain/call_budget.dart';
import 'package:pokedex_flutter/core/sync/domain/retry_policy.dart';
import 'package:pokedex_flutter/core/sync/sync_scheduler.dart';
import 'package:pokedex_flutter/features/connectivity/connectivity_providers.dart';
import 'package:pokedex_flutter/features/connectivity/domain/connectivity_status.dart';

final callBudgetProvider = Provider<CallBudget>((ref) => CallBudget());

final retryPolicyProvider = Provider<RetryPolicy>((ref) => RetryPolicy());

final syncSchedulerProvider = Provider<SyncScheduler>((ref) {
  final scheduler = SyncScheduler(
    budget: ref.watch(callBudgetProvider),
    retryPolicy: ref.watch(retryPolicyProvider),
    store: ref.watch(appDatabaseProvider).syncMetadataDao,
  );
  ref.listen(connectivityStatusProvider, (_, next) {
    if (next.asData?.value case final status?) {
      scheduler.connectivityChanged(
        isOnline: status == ConnectivityStatus.online,
      );
    }
  }, fireImmediately: true);
  ref.onDispose(scheduler.dispose);
  return scheduler;
});
