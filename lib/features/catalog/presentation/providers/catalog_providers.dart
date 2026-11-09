import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_sync_status.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/sync_catalog.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/watch_catalog.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/watch_catalog_sync_status.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => throw UnimplementedError(
    'catalogRepositoryProvider debe sobrescribirse en ProviderScope',
  ),
);

final watchCatalogProvider = Provider<WatchCatalog>(
  (ref) => WatchCatalog(ref.watch(catalogRepositoryProvider)),
);

final syncCatalogProvider = Provider<SyncCatalog>(
  (ref) => SyncCatalog(ref.watch(catalogRepositoryProvider)),
);

final watchCatalogSyncStatusProvider = Provider<WatchCatalogSyncStatus>(
  (ref) => WatchCatalogSyncStatus(ref.watch(catalogRepositoryProvider)),
);

final catalogProvider = StreamProvider<List<Pokemon>>(
  (ref) => ref.watch(watchCatalogProvider)(),
);

final catalogSyncStatusProvider = StreamProvider<CatalogSyncStatus>(
  (ref) => ref.watch(watchCatalogSyncStatusProvider)(),
);
