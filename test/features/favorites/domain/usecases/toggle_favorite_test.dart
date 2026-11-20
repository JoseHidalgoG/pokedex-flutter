import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/favorites/domain/usecases/toggle_favorite.dart';

import '../../fakes/fake_favorites_repository.dart';

void main() {
  late FakeFavoritesRepository repository;
  late ToggleFavorite toggleFavorite;

  setUp(() {
    repository = FakeFavoritesRepository();
    toggleFavorite = ToggleFavorite(repository);
  });

  test('agrega un Pokémon cuando no es favorito', () async {
    await toggleFavorite(25);

    expect(await repository.isFavorite(25), isTrue);
  });

  test('elimina un Pokémon cuando ya es favorito', () async {
    await repository.addFavorite(25);

    await toggleFavorite(25);

    expect(await repository.isFavorite(25), isFalse);
  });

  test('permite alternar varias veces el mismo Pokémon', () async {
    await toggleFavorite(25);
    expect(await repository.isFavorite(25), isTrue);

    await toggleFavorite(25);
    expect(await repository.isFavorite(25), isFalse);

    await toggleFavorite(25);
    expect(await repository.isFavorite(25), isTrue);
  });

  test('no modifica otros Pokémon favoritos', () async {
    await repository.addFavorite(1);

    await toggleFavorite(25);

    expect(await repository.isFavorite(1), isTrue);
    expect(await repository.isFavorite(25), isTrue);
  });
}
