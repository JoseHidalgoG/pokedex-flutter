import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/core/database/app_database_provider.dart';
import 'package:pokedex_flutter/core/network/pokeapi_graphql_client_provider.dart';
import 'package:pokedex_flutter/features/catalog/data/offline_first_catalog_repository.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_remote_data_source.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/catalog_sync_service.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:pokedex_flutter/features/connectivity/connectivity_providers.dart';
import 'package:pokedex_flutter/features/connectivity/domain/connectivity_status.dart';

final catalogInternetAccessCheckProvider = Provider<InternetAccessCheck>((ref) {
  final connectivityRepository = ref.watch(connectivityRepositoryProvider);
  return () async =>
      await connectivityRepository.checkStatus() != ConnectivityStatus.offline;
});

final catalogSyncServiceProvider = Provider<CatalogSyncService>((ref) {
  final syncService = CatalogSyncService(
    remoteDataSource: CatalogRemoteDataSource(
      ref.watch(pokeApiGraphQLClientProvider),
    ),
    catalogDao: ref.watch(appDatabaseProvider).catalogDao,
    hasInternetAccess: ref.watch(catalogInternetAccessCheckProvider),
  );
  ref.onDispose(syncService.dispose);
  return syncService;
});

final offlineFirstCatalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => OfflineFirstCatalogRepository(
    catalogDao: ref.watch(appDatabaseProvider).catalogDao,
    syncService: ref.watch(catalogSyncServiceProvider),
  ),
);
