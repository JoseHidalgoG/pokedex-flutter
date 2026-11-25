import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/core/database/app_database_provider.dart';
import 'package:pokedex_flutter/core/images/pokemon_image_cache_providers.dart';
import 'package:pokedex_flutter/core/network/pokeapi_graphql_client_provider.dart';
import 'package:pokedex_flutter/core/sync/sync_providers.dart';
import 'package:pokedex_flutter/features/catalog/data/cached_pokemon_image_repository.dart';
import 'package:pokedex_flutter/features/catalog/data/offline_first_catalog_repository.dart';
import 'package:pokedex_flutter/features/catalog/data/offline_first_pokemon_detail_repository.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_remote_data_source.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/catalog_restoration_service.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/catalog_sync_constants.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/catalog_sync_service.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/pokemon_detail_sync_service.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/pokemon_detail_repository.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/pokemon_image_repository.dart';

final catalogRemoteDataSourceProvider = Provider<CatalogRemoteDataSource>(
  (ref) => CatalogRemoteDataSource(ref.watch(pokeApiGraphQLClientProvider)),
);

final catalogSyncServiceProvider = Provider<CatalogSyncService>(
  (ref) => CatalogSyncService(
    remoteDataSource: ref.watch(catalogRemoteDataSourceProvider),
    catalogDao: ref.watch(appDatabaseProvider).catalogDao,
  ),
);

final catalogRestorationServiceProvider = Provider<CatalogRestorationService>(
  (ref) => CatalogRestorationService(
    remoteDataSource: ref.watch(catalogRemoteDataSourceProvider),
    catalogDao: ref.watch(appDatabaseProvider).catalogDao,
  ),
);

final pokemonDetailSyncServiceProvider = Provider<PokemonDetailSyncService>(
  (ref) => PokemonDetailSyncService(
    remoteDataSource: ref.watch(catalogRemoteDataSourceProvider),
    detailDao: ref.watch(appDatabaseProvider).pokemonDetailDao,
    catalogDao: ref.watch(appDatabaseProvider).catalogDao,
  ),
);

final catalogSyncTriggersProvider = Provider<void>((ref) {
  final scheduler = ref.watch(syncSchedulerProvider);
  final fullPass = ref.watch(catalogSyncServiceProvider).fullPassJob();
  final restoration = ref
      .watch(catalogRestorationServiceProvider)
      .restorationJob();
  final typeEfficacy = ref
      .watch(pokemonDetailSyncServiceProvider)
      .typeEfficacyJob();
  scheduler
    ..runOnEachReconnect(fullPass)
    ..runOnEachReconnect(restoration)
    ..runOnEachReconnect(typeEfficacy)
    ..runEveryWhileOnline(fullPass, catalogFullPassFreshness)
    ..runEveryWhileOnline(restoration, fingerprintVerificationInterval);
  unawaited(scheduler.run(fullPass));
  unawaited(scheduler.run(restoration));
  unawaited(scheduler.run(typeEfficacy));
});

final offlineFirstCatalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => OfflineFirstCatalogRepository(
    catalogDao: ref.watch(appDatabaseProvider).catalogDao,
    syncService: ref.watch(catalogSyncServiceProvider),
    scheduler: ref.watch(syncSchedulerProvider),
  ),
);

final cachedPokemonImageRepositoryProvider = Provider<PokemonImageRepository>(
  (ref) => CachedPokemonImageRepository(
    catalogDao: ref.watch(appDatabaseProvider).catalogDao,
    images: ref.watch(pokemonImageCacheProvider),
  ),
);

final offlineFirstPokemonDetailRepositoryProvider =
    Provider<PokemonDetailRepository>(
      (ref) => OfflineFirstPokemonDetailRepository(
        detailDao: ref.watch(appDatabaseProvider).pokemonDetailDao,
        syncService: ref.watch(pokemonDetailSyncServiceProvider),
        scheduler: ref.watch(syncSchedulerProvider),
      ),
    );
