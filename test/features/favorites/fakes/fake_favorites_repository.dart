import 'dart:async';

import 'package:pokedex_flutter/features/favorites/domain/repositories/favorites_repository.dart';

class FakeFavoritesRepository implements FavoritesRepository {
  final Set<int> _favoriteIds = {};
  final StreamController<void> _changes = StreamController<void>.broadcast(
    sync: true,
  );

  Stream<T> _watch<T>(T Function() readValue) async* {
    yield readValue();

    await for (final _ in _changes.stream) {
      yield readValue();
    }
  }

  @override
  Stream<List<int>> watchFavoriteIds() {
    return _watch(() => _favoriteIds.toList());
  }

  @override
  Stream<bool> watchIsFavorite(int pokemonId) {
    return _watch(() => _favoriteIds.contains(pokemonId));
  }

  @override
  Future<bool> isFavorite(int pokemonId) async {
    return _favoriteIds.contains(pokemonId);
  }

  @override
  Future<void> addFavorite(int pokemonId) async {
    if (_favoriteIds.add(pokemonId)) {
      _changes.add(null);
    }
  }

  @override
  Future<void> removeFavorite(int pokemonId) async {
    if (_favoriteIds.remove(pokemonId)) {
      _changes.add(null);
    }
  }

  Future<void> dispose() async {
    await _changes.close();
  }
}
