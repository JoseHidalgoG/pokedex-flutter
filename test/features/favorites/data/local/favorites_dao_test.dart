import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/features/favorites/data/local/favorites_dao.dart';

void main() {
  late AppDatabase database;
  late FavoritesDao dao;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    dao = database.favoritesDao;
  });

  tearDown(() async {
    await database.close();
  });

  test('agrega un Pokémon a favoritos', () async {
    await dao.addFavorite(25);

    final isFavorite = await dao.isFavorite(25);

    expect(isFavorite, isTrue);
  });

  test('un Pokémon no guardado no es favorito', () async {
    final isFavorite = await dao.isFavorite(25);

    expect(isFavorite, isFalse);
  });

  test('elimina un Pokémon de favoritos', () async {
    await dao.addFavorite(25);
    await dao.removeFavorite(25);

    final isFavorite = await dao.isFavorite(25);

    expect(isFavorite, isFalse);
  });

  test('no duplica favoritos', () async {
    await dao.addFavorite(25);
    await dao.addFavorite(25);

    final favorites = await dao.watchFavoriteIds().first;

    expect(favorites, [25]);
  });

  test('observa cambios al agregar favoritos', () async {
    final emissions = dao.watchFavoriteIds().take(3).toList();

    await Future<void>.delayed(Duration.zero);

    await dao.addFavorite(25);
    await dao.addFavorite(1);

    final result = await emissions;

    expect(result, [
      <int>[],
      [25],
      [1, 25],
    ]);
  });

  test('observa cambios al eliminar favoritos', () async {
    await dao.addFavorite(25);

    final emissions = dao.watchIsFavorite(25).take(2).toList();

    await Future<void>.delayed(Duration.zero);

    await dao.removeFavorite(25);

    expect(await emissions, [true, false]);
  });
}
