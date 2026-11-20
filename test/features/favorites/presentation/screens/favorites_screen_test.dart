import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:pokedex_flutter/features/catalog/presentation/screens/pokemon_detail_screen.dart';
import 'package:pokedex_flutter/features/favorites/presentation/providers/favorites_providers.dart';
import 'package:pokedex_flutter/features/favorites/presentation/screens/favorites_screen.dart';

import '../../fakes/fake_favorites_repository.dart';

void main() {
  const pikachu = Pokemon(
    id: 25,
    name: 'pikachu',
    imageUrl: '',
    typeNames: ['electric'],
  );

  const bulbasaur = Pokemon(
    id: 1,
    name: 'bulbasaur',
    imageUrl: '',
    typeNames: ['grass', 'poison'],
  );

  late FakeFavoritesRepository repository;

  setUp(() {
    repository = FakeFavoritesRepository();
  });

  tearDown(() async {
    await repository.dispose();
  });

  Future<void> pumpFavoritesScreen(
    WidgetTester tester, {
    List<Pokemon> pokemon = const [pikachu, bulbasaur],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesRepositoryProvider.overrideWith((ref) => repository),
          catalogProvider.overrideWith((ref) => Stream.value(pokemon)),
        ],
        child: const MaterialApp(home: FavoritesScreen()),
      ),
    );

    await tester.pump();
    await tester.pump();
  }

  testWidgets('muestra el estado vacío cuando no hay favoritos', (
    tester,
  ) async {
    await pumpFavoritesScreen(tester);

    expect(find.text('Todavía no tienes favoritos'), findsOneWidget);

    expect(
      find.text('Marca un Pokémon con el corazón para agregarlo aquí.'),
      findsOneWidget,
    );

    expect(find.text('Pikachu'), findsNothing);
  });

  testWidgets('muestra los Pokémon guardados como favoritos', (tester) async {
    await repository.addFavorite(25);
    await repository.addFavorite(1);

    await pumpFavoritesScreen(tester);

    expect(find.text('Pikachu'), findsOneWidget);
    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.text('#0025'), findsOneWidget);
    expect(find.text('#0001'), findsOneWidget);
  });

  testWidgets('no muestra Pokémon que no son favoritos', (tester) async {
    await repository.addFavorite(25);

    await pumpFavoritesScreen(tester);

    expect(find.text('Pikachu'), findsOneWidget);
    expect(find.text('Bulbasaur'), findsNothing);
  });

  testWidgets('elimina un favorito y actualiza la lista', (tester) async {
    await repository.addFavorite(25);
    await repository.addFavorite(1);

    await pumpFavoritesScreen(tester);

    expect(find.text('Pikachu'), findsOneWidget);
    expect(find.text('Bulbasaur'), findsOneWidget);

    await tester.tap(find.byTooltip('Quitar de favoritos').first);

    await tester.pump();
    await tester.pump();

    expect(await repository.isFavorite(25), isFalse);
    expect(find.text('Pikachu'), findsNothing);
    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('muestra el estado vacío al eliminar el último favorito', (
    tester,
  ) async {
    await repository.addFavorite(25);

    await pumpFavoritesScreen(tester);

    expect(find.text('Pikachu'), findsOneWidget);

    await tester.tap(find.byTooltip('Quitar de favoritos'));

    await tester.pump();
    await tester.pump();

    expect(find.text('Todavía no tienes favoritos'), findsOneWidget);

    expect(find.text('Pikachu'), findsNothing);
  });

  testWidgets('permite abrir el detalle de un Pokémon favorito', (
    tester,
  ) async {
    await repository.addFavorite(25);

    await pumpFavoritesScreen(tester);

    await tester.tap(find.text('Pikachu'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(PokemonDetailScreen), findsOneWidget);
  });

  testWidgets('conserva los favoritos al regresar del detalle', (
      tester,
      ) async {
    await repository.addFavorite(25);

    await pumpFavoritesScreen(tester);

    await tester.tap(find.text('Pikachu'));
    await tester.pumpAndSettle();

    expect(
      find.byType(PokemonDetailScreen),
      findsOneWidget,
    );

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(
      find.byType(PokemonDetailScreen),
      findsNothing,
    );

    expect(
      find.byType(FavoritesScreen),
      findsOneWidget,
    );

    expect(
      find.descendant(
        of: find.byType(FavoritesScreen),
        matching: find.text('Pikachu'),
      ),
      findsOneWidget,
    );

    expect(await repository.isFavorite(25), isTrue);
  });
}
