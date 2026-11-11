import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_sync_status.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/sync_catalog.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/watch_catalog.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/watch_catalog_sync_status.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/watch_catalog_page.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/watch_catalog_count.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_pagination.dart';

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

final lastCatalogSyncProvider = FutureProvider<DateTime?>((ref) async {
  ref.watch(catalogSyncStatusProvider);
  final repository = ref.watch(catalogRepositoryProvider);
  return repository.getLastSyncedAt();
});

final watchCatalogPageProvider = Provider<WatchCatalogPage>(
  (ref) => WatchCatalogPage(ref.watch(catalogRepositoryProvider)),
);

final watchCatalogCountProvider = Provider<WatchCatalogCount>(
  (ref) => WatchCatalogCount(ref.watch(catalogRepositoryProvider)),
);

final catalogPageProvider = StreamProvider.family<List<Pokemon>, int>((
  ref,
  page,
) {
  return ref.watch(watchCatalogPageProvider)(
    page: page,
    pageSize: catalogPageSize,
  );
});

final catalogCountProvider = StreamProvider<int>(
  (ref) => ref.watch(watchCatalogCountProvider)(),
);
