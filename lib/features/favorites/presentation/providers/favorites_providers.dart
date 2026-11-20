import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/core/database/app_database_provider.dart';
import 'package:pokedex_flutter/features/favorites/data/drift_favorites_repository.dart';
import 'package:pokedex_flutter/features/favorites/data/local/favorites_dao.dart';
import 'package:pokedex_flutter/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:pokedex_flutter/features/favorites/domain/usecases/toggle_favorite.dart';
import 'package:pokedex_flutter/features/favorites/domain/usecases/watch_favorites.dart';
import 'package:pokedex_flutter/features/favorites/domain/usecases/watch_is_favorite.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_providers.dart';

final favoritesDaoProvider = Provider<FavoritesDao>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return database.favoritesDao;
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  final dao = ref.watch(favoritesDaoProvider);
  return DriftFavoritesRepository(dao);
});

final watchFavoritesProvider = Provider<WatchFavorites>((ref) {
  return WatchFavorites(ref.watch(favoritesRepositoryProvider));
});

final watchIsFavoriteProvider = Provider<WatchIsFavorite>((ref) {
  return WatchIsFavorite(ref.watch(favoritesRepositoryProvider));
});

final toggleFavoriteProvider = Provider<ToggleFavorite>((ref) {
  return ToggleFavorite(ref.watch(favoritesRepositoryProvider));
});

final favoriteIdsProvider = StreamProvider<List<int>>((ref) {
  return ref.watch(watchFavoritesProvider)();
});

final isFavoriteProvider = StreamProvider.family<bool, int>((ref, pokemonId) {
  return ref.watch(watchIsFavoriteProvider)(pokemonId);
});

final favoritePokemonProvider = StreamProvider<List<Pokemon>>((ref) {
  final repository = ref.watch(favoritesRepositoryProvider);
  final watchPokemonByIds = ref.watch(watchPokemonByIdsProvider);

  return repository.watchFavoriteIds().asyncExpand((ids) {
    if (ids.isEmpty) {
      return Stream.value(<Pokemon>[]);
    }

    return watchPokemonByIds(ids);
  });
});

final favoritePokemonByIdsProvider =
    StreamProvider.family<List<Pokemon>, List<int>>((ref, ids) {
      if (ids.isEmpty) {
        return Stream.value(<Pokemon>[]);
      }

      return ref.watch(watchPokemonByIdsProvider)(ids);
    });
