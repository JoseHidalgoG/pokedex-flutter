import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/favorites/presentation/providers/favorites_providers.dart';
import 'package:pokedex_flutter/features/favorites/presentation/widgets/favorite_button.dart';

import '../../fakes/fake_favorites_repository.dart';

import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

void main() {
  late FakeFavoritesRepository repository;

  setUp(() {
    repository = FakeFavoritesRepository();
  });

  tearDown(() async {
    await repository.dispose();
  });

  Future<void> pumpFavoriteButton(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesRepositoryProvider.overrideWith((ref) => repository),
        ],
        child: const MaterialApp(
          home: Scaffold(body: FavoriteButton(pokemonId: 25)),
          locale: Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    await tester.pump();
  }

  testWidgets('muestra un corazón vacío si no es favorito', (tester) async {
    await pumpFavoriteButton(tester);

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byTooltip('Agregar a favoritos'), findsOneWidget);
  });

  testWidgets('muestra un corazón lleno si es favorito', (tester) async {
    await repository.addFavorite(25);

    await pumpFavoriteButton(tester);

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byTooltip('Quitar de favoritos'), findsOneWidget);
  });

  testWidgets('permite agregar un Pokémon a favoritos', (tester) async {
    await pumpFavoriteButton(tester);

    await tester.tap(find.byTooltip('Agregar a favoritos'));
    await tester.pump();
    await tester.pump();

    expect(await repository.isFavorite(25), isTrue);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('permite eliminar un Pokémon de favoritos', (tester) async {
    await repository.addFavorite(25);

    await pumpFavoriteButton(tester);

    await tester.tap(find.byTooltip('Quitar de favoritos'));
    await tester.pump();
    await tester.pump();

    expect(await repository.isFavorite(25), isFalse);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });

  testWidgets('actualiza el icono al alternar favoritos', (tester) async {
    await pumpFavoriteButton(tester);

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    await tester.tap(find.byTooltip('Agregar a favoritos'));
    await tester.pump();
    await tester.pump();

    expect(find.byIcon(Icons.favorite), findsOneWidget);

    await tester.tap(find.byTooltip('Quitar de favoritos'));
    await tester.pump();
    await tester.pump();

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });

  testWidgets('muestra el tooltip en inglés', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesRepositoryProvider.overrideWith((ref) => repository),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: FavoriteButton(pokemonId: 25)),
        ),
      ),
    );

    await tester.pump();

    expect(find.byTooltip('Add to favorites'), findsOneWidget);

    await repository.addFavorite(25);
    await tester.pump();
    await tester.pump();

    expect(find.byTooltip('Remove from favorites'), findsOneWidget);
  });
}
