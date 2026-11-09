import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pokedex_flutter/core/database/app_database_provider.dart';
import 'package:pokedex_flutter/core/network/pokeapi_graphql_client_provider.dart';
import 'package:pokedex_flutter/features/catalog/data/offline_first_catalog_repository.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_remote_data_source.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/catalog_sync_service.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_repository.dart';

final catalogInternetAccessCheckProvider = Provider<InternetAccessCheck>(
  (ref) =>
      () => InternetConnection().hasInternetAccess,
);

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
