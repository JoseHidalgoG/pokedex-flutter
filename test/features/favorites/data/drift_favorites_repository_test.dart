import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/features/favorites/data/drift_favorites_repository.dart';
import 'package:pokedex_flutter/features/favorites/domain/repositories/favorites_repository.dart';

void main() {
  late AppDatabase database;
  late FavoritesRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftFavoritesRepository(database.favoritesDao);
  });

  tearDown(() async {
    await database.close();
  });

  test('guarda un Pokémon como favorito', () async {
    await repository.addFavorite(25);

    expect(await repository.isFavorite(25), isTrue);
  });

  test('elimina un Pokémon favorito', () async {
    await repository.addFavorite(25);
    await repository.removeFavorite(25);

    expect(await repository.isFavorite(25), isFalse);
  });

  test('devuelve los IDs de los favoritos guardados', () async {
    await repository.addFavorite(25);
    await repository.addFavorite(1);

    final ids = await repository.watchFavoriteIds().first;

    expect(ids, containsAll([25, 1]));
    expect(ids, hasLength(2));
  });

  test('observa si un Pokémon es favorito', () async {
    await repository.addFavorite(25);

    final isFavorite = await repository.watchIsFavorite(25).first;

    expect(isFavorite, isTrue);
  });
}
