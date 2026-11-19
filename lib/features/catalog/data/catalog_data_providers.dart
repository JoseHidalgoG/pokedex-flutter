import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/core/database/app_database_provider.dart';
import 'package:pokedex_flutter/core/network/pokeapi_graphql_client_provider.dart';
import 'package:pokedex_flutter/core/sync/sync_providers.dart';
import 'package:pokedex_flutter/features/catalog/data/offline_first_catalog_repository.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_remote_data_source.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/catalog_sync_service.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_repository.dart';

final catalogSyncServiceProvider = Provider<CatalogSyncService>(
  (ref) => CatalogSyncService(
    remoteDataSource: CatalogRemoteDataSource(
      ref.watch(pokeApiGraphQLClientProvider),
    ),
    catalogDao: ref.watch(appDatabaseProvider).catalogDao,
  ),
);

final catalogFullPassTriggersProvider = Provider<void>((ref) {
  final scheduler = ref.watch(syncSchedulerProvider);
  final fullPass = ref.watch(catalogSyncServiceProvider).fullPassJob();
  scheduler.runOnEachReconnect(fullPass);
  unawaited(scheduler.run(fullPass));
});

final offlineFirstCatalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => OfflineFirstCatalogRepository(
    catalogDao: ref.watch(appDatabaseProvider).catalogDao,
    syncService: ref.watch(catalogSyncServiceProvider),
    scheduler: ref.watch(syncSchedulerProvider),
  ),
);
