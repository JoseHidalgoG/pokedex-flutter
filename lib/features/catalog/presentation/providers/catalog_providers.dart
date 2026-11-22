import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/revalidate_pokemon.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/sync_catalog.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/watch_catalog.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/watch_catalog_sync_status.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/watch_catalog_page.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/watch_catalog_count.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/watch_pokemon_by_ids.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_pagination.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_page_request.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/watch_filtered_catalog_page.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/watch_filtered_catalog_count.dart';

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

final catalogSyncStatusProvider = StreamProvider<SyncStatus>(
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

final watchFilteredCatalogPageProvider = Provider<WatchFilteredCatalogPage>(
  (ref) => WatchFilteredCatalogPage(ref.watch(catalogRepositoryProvider)),
);

final watchFilteredCatalogCountProvider = Provider<WatchFilteredCatalogCount>(
  (ref) => WatchFilteredCatalogCount(ref.watch(catalogRepositoryProvider)),
);

final revalidatePokemonProvider = Provider<RevalidatePokemon>(
  (ref) => RevalidatePokemon(ref.watch(catalogRepositoryProvider)),
);

final catalogPageProvider = StreamProvider.family<List<Pokemon>, int>((
  ref,
  page,
) {
  final revalidatePokemon = ref.watch(revalidatePokemonProvider);
  var shownIds = const <int>[];

  void revalidateShownPokemon() {
    if (shownIds.isNotEmpty) {
      unawaited(revalidatePokemon(shownIds));
    }
  }

  ref.onResume(revalidateShownPokemon);

  return ref
      .watch(watchCatalogPageProvider)(page: page, pageSize: catalogPageSize)
      .map((pagePokemon) {
        final isFirstShown = shownIds.isEmpty && pagePokemon.isNotEmpty;
        shownIds = [for (final pokemon in pagePokemon) pokemon.id];
        if (isFirstShown) {
          revalidateShownPokemon();
        }
        return pagePokemon;
      });
});

final catalogCountProvider = StreamProvider<int>(
  (ref) => ref.watch(watchCatalogCountProvider)(),
);

final watchPokemonByIdsProvider = Provider<WatchPokemonByIds>(
  (ref) => WatchPokemonByIds(ref.watch(catalogRepositoryProvider)),
);

final filteredCatalogPageProvider =
    StreamProvider.family<List<Pokemon>, CatalogPageRequest>((ref, request) {
      final revalidatePokemon = ref.watch(revalidatePokemonProvider);
      var shownIds = const <int>[];

      void revalidateShownPokemon() {
        if (shownIds.isNotEmpty) {
          unawaited(revalidatePokemon(shownIds));
        }
      }

      ref.onResume(revalidateShownPokemon);

      return ref
          .watch(watchFilteredCatalogPageProvider)(
            page: request.page,
            pageSize: request.pageSize,
            query: request.query,
          )
          .map((pagePokemon) {
            final isFirstShown = shownIds.isEmpty && pagePokemon.isNotEmpty;

            shownIds = [for (final pokemon in pagePokemon) pokemon.id];

            if (isFirstShown) {
              revalidateShownPokemon();
            }

            return pagePokemon;
          });
    });

final filteredCatalogCountProvider = StreamProvider.family<int, CatalogQuery>(
  (ref, query) => ref.watch(watchFilteredCatalogCountProvider)(query),
);