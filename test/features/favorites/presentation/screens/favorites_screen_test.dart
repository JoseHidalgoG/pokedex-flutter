import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:pokedex_flutter/features/catalog/presentation/screens/pokemon_detail_screen.dart';
import 'package:pokedex_flutter/features/favorites/presentation/providers/favorites_providers.dart';
import 'package:pokedex_flutter/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/pokemon_list_item.dart';

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

  const raichu = Pokemon(
    id: 26,
    name: 'raichu',
    imageUrl: '',
    typeNames: ['electric'],
  );

  const charmander = Pokemon(
    id: 4,
    name: 'charmander',
    imageUrl: '',
    typeNames: ['fire'],
  );

  const squirtle = Pokemon(
    id: 7,
    name: 'squirtle',
    imageUrl: '',
    typeNames: ['water'],
  );

  const testCatalog = [pikachu, bulbasaur, raichu, charmander, squirtle];

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
    Locale locale = const Locale('es'),
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesRepositoryProvider.overrideWith((ref) => repository),
          catalogProvider.overrideWith((ref) => Stream.value(pokemon)),
        ],
        child: MaterialApp(
          home: const FavoritesScreen(),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    await tester.pump();
    await tester.pump();
  }

  AppLocalizations favoritesL10n(WidgetTester tester) {
    return AppLocalizations.of(tester.element(find.byType(FavoritesScreen)))!;
  }

  Future<void> addFavorites(List<int> ids) async {
    for (final id in ids) {
      await repository.addFavorite(id);
    }
  }

  Future<void> pumpSearchableFavorites(
    WidgetTester tester, {
    List<int> favoriteIds = const [25, 1, 26, 4],
    Locale locale = const Locale('es'),
  }) async {
    await addFavorites(favoriteIds);

    await pumpFavoritesScreen(tester, pokemon: testCatalog, locale: locale);
  }

  Future<void> showSearch(WidgetTester tester) async {
    await tester.tap(find.byTooltip(favoritesL10n(tester).catalogShowSearch));

    await tester.pumpAndSettle();
  }

  Future<void> hideSearch(WidgetTester tester) async {
    await tester.tap(find.byTooltip(favoritesL10n(tester).catalogHideSearch));

    await tester.pumpAndSettle();
  }

  Future<void> searchFor(WidgetTester tester, String value) async {
    await tester.enterText(find.byType(TextField), value);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  }

  List<int> visiblePokemonIds(WidgetTester tester) {
    return tester
        .widgetList<PokemonListItem>(find.byType(PokemonListItem))
        .map((item) => item.pokemon.id)
        .toList();
  }

  String searchText(WidgetTester tester) {
    return tester.widget<TextField>(find.byType(TextField)).controller!.text;
  }

  Finder clearSearchButton() {
    return find.widgetWithIcon(IconButton, Icons.close);
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

  testWidgets('conserva los favoritos al regresar del detalle', (tester) async {
    await repository.addFavorite(25);

    await pumpFavoritesScreen(tester);

    await tester.tap(find.text('Pikachu'));
    await tester.pumpAndSettle();

    expect(find.byType(PokemonDetailScreen), findsOneWidget);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));

    navigator.pop();
    await tester.pumpAndSettle();

    expect(find.byType(PokemonDetailScreen), findsNothing);

    expect(find.byType(FavoritesScreen), findsOneWidget);

    expect(
      find.descendant(
        of: find.byType(FavoritesScreen),
        matching: find.text('Pikachu'),
      ),
      findsOneWidget,
    );

    expect(await repository.isFavorite(25), isTrue);
  });

  testWidgets('muestra el estado vacío en inglés', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesRepositoryProvider.overrideWith((ref) => repository),
          catalogProvider.overrideWith(
            (ref) => Stream.value([pikachu, bulbasaur]),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FavoritesScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text("You don't have any favorites yet"), findsOneWidget);
    expect(
      find.text('Tap the heart on a Pokémon to add it here.'),
      findsOneWidget,
    );
  });

  group('visibilidad de la búsqueda en favoritos', () {
    testWidgets('la búsqueda está oculta inicialmente', (tester) async {
      await pumpSearchableFavorites(tester);

      expect(find.byType(TextField), findsNothing);

      expect(
        find.byTooltip(favoritesL10n(tester).catalogShowSearch),
        findsOneWidget,
      );
    });

    testWidgets('muestra la búsqueda al presionar la lupa', (tester) async {
      await pumpSearchableFavorites(tester);
      await showSearch(tester);

      expect(find.byType(TextField), findsOneWidget);

      expect(
        find.byTooltip(favoritesL10n(tester).catalogHideSearch),
        findsOneWidget,
      );
    });

    testWidgets('permite ocultar nuevamente la búsqueda', (tester) async {
      await pumpSearchableFavorites(tester);

      await showSearch(tester);
      await hideSearch(tester);

      expect(find.byType(TextField), findsNothing);
      expect(find.text('Pikachu'), findsOneWidget);
    });

    testWidgets('la búsqueda comienza vacía y sin botón de limpieza', (
      tester,
    ) async {
      await pumpSearchableFavorites(tester);
      await showSearch(tester);

      expect(searchText(tester), isEmpty);
      expect(clearSearchButton(), findsNothing);
    });
  });

  group('búsqueda de Pokémon favoritos', () {
    testWidgets('busca un favorito por su nombre completo', (tester) async {
      await pumpSearchableFavorites(tester);
      await showSearch(tester);
      await searchFor(tester, 'pikachu');

      expect(visiblePokemonIds(tester), [25]);
      expect(find.text('Pikachu'), findsOneWidget);
      expect(find.text('Bulbasaur'), findsNothing);
    });

    testWidgets('busca favoritos por una parte del nombre', (tester) async {
      await pumpSearchableFavorites(tester);
      await showSearch(tester);
      await searchFor(tester, 'chu');

      expect(visiblePokemonIds(tester), [25, 26]);
    });

    testWidgets('busca un favorito por su número', (tester) async {
      await pumpSearchableFavorites(tester);
      await showSearch(tester);
      await searchFor(tester, '25');

      expect(visiblePokemonIds(tester), [25]);
      expect(find.text('#0025'), findsOneWidget);
    });

    testWidgets('acepta números con ceros iniciales', (tester) async {
      await pumpSearchableFavorites(tester);
      await showSearch(tester);
      await searchFor(tester, '0025');

      expect(visiblePokemonIds(tester), [25]);
    });

    testWidgets('la búsqueda numérica requiere una coincidencia exacta', (
      tester,
    ) async {
      await pumpSearchableFavorites(tester);
      await showSearch(tester);
      await searchFor(tester, '2');

      expect(find.byType(PokemonListItem), findsNothing);

      expect(find.text(favoritesL10n(tester).catalogNoResults), findsOneWidget);
    });

    testWidgets('ignora diferencias entre mayúsculas y minúsculas', (
      tester,
    ) async {
      await pumpSearchableFavorites(tester);
      await showSearch(tester);
      await searchFor(tester, 'PiKaChU');

      expect(visiblePokemonIds(tester), [25]);
    });

    testWidgets('ignora espacios al principio y al final', (tester) async {
      await pumpSearchableFavorites(tester);
      await showSearch(tester);
      await searchFor(tester, '  Raichu  ');

      expect(visiblePokemonIds(tester), [26]);
    });

    testWidgets('no incluye Pokémon que no son favoritos', (tester) async {
      await pumpSearchableFavorites(tester);
      await showSearch(tester);
      await searchFor(tester, 'squirtle');

      expect(find.text('Squirtle'), findsNothing);
      expect(find.byType(PokemonListItem), findsNothing);

      expect(find.text(favoritesL10n(tester).catalogNoResults), findsOneWidget);
    });
  });

  group('debounce de búsqueda en favoritos', () {
    testWidgets('no aplica la búsqueda antes de 300 milisegundos', (
      tester,
    ) async {
      await pumpSearchableFavorites(tester);
      await showSearch(tester);

      await tester.enterText(find.byType(TextField), 'pikachu');

      await tester.pump(const Duration(milliseconds: 299));

      expect(find.text('Pikachu'), findsOneWidget);
      expect(find.text('Bulbasaur'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();

      expect(visiblePokemonIds(tester), [25]);
    });

    testWidgets('reinicia el temporizador cuando cambia el texto', (
      tester,
    ) async {
      await pumpSearchableFavorites(tester);
      await showSearch(tester);

      await tester.enterText(find.byType(TextField), 'p');
      await tester.pump(const Duration(milliseconds: 200));

      await tester.enterText(find.byType(TextField), 'pi');
      await tester.pump(const Duration(milliseconds: 200));

      await tester.enterText(find.byType(TextField), 'pikachu');
      await tester.pump(const Duration(milliseconds: 299));

      expect(find.text('Bulbasaur'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();

      expect(visiblePokemonIds(tester), [25]);
    });

    testWidgets('solamente aplica el último texto introducido', (tester) async {
      await pumpSearchableFavorites(tester);
      await showSearch(tester);

      for (final text in ['pika', 'bulba', 'raichu']) {
        await tester.enterText(find.byType(TextField), text);
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.text('Pikachu'), findsOneWidget);
        expect(find.text('Bulbasaur'), findsOneWidget);
      }

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(visiblePokemonIds(tester), [26]);
    });

    testWidgets('cancela el temporizador al destruir la pantalla', (
      tester,
    ) async {
      await pumpSearchableFavorites(tester);
      await showSearch(tester);

      await tester.enterText(find.byType(TextField), 'pikachu');

      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 400));

      expect(tester.takeException(), isNull);
    });
  });

  group('estado sin resultados y limpieza en favoritos', () {
    testWidgets(
      'muestra el estado sin resultados cuando no hay coincidencias',
      (tester) async {
        await pumpSearchableFavorites(tester);
        await showSearch(tester);
        await searchFor(tester, 'inexistente');

        final l10n = favoritesL10n(tester);

        expect(find.text(l10n.catalogNoResults), findsOneWidget);
        expect(find.text(l10n.catalogNoResultsMessage), findsOneWidget);
        expect(find.text(l10n.catalogClearFilters), findsOneWidget);

        expect(find.text(l10n.noFavoritesTitle), findsNothing);
        expect(find.byType(PokemonListItem), findsNothing);
      },
    );

    testWidgets('borrar manualmente la búsqueda restaura los favoritos', (
      tester,
    ) async {
      await pumpSearchableFavorites(tester);
      await showSearch(tester);
      await searchFor(tester, 'pikachu');

      expect(visiblePokemonIds(tester), [25]);

      await searchFor(tester, '');

      expect(find.text('Pikachu'), findsOneWidget);
      expect(find.text('Bulbasaur'), findsOneWidget);
      expect(find.text('Raichu'), findsOneWidget);
      expect(clearSearchButton(), findsNothing);
    });

    testWidgets('el botón del campo de búsqueda restaura los favoritos', (
      tester,
    ) async {
      await pumpSearchableFavorites(tester);
      await showSearch(tester);
      await searchFor(tester, 'pikachu');

      expect(clearSearchButton(), findsOneWidget);

      await tester.tap(clearSearchButton());
      await tester.pumpAndSettle();

      expect(searchText(tester), isEmpty);
      expect(clearSearchButton(), findsNothing);
      expect(find.text('Bulbasaur'), findsOneWidget);
      expect(find.text('Raichu'), findsOneWidget);
    });

    testWidgets('limpiar desde el estado sin resultados restaura la lista', (
      tester,
    ) async {
      await pumpSearchableFavorites(tester);
      await showSearch(tester);
      await searchFor(tester, 'inexistente');

      await tester.tap(
        find.widgetWithText(
          OutlinedButton,
          favoritesL10n(tester).catalogClearFilters,
        ),
      );

      await tester.pumpAndSettle();

      expect(searchText(tester), isEmpty);
      expect(find.text('Pikachu'), findsOneWidget);
      expect(find.text('Bulbasaur'), findsOneWidget);

      expect(find.text(favoritesL10n(tester).catalogNoResults), findsNothing);
    });

    testWidgets('limpiar la búsqueda cancela un temporizador pendiente', (
      tester,
    ) async {
      await pumpSearchableFavorites(tester);
      await showSearch(tester);
      await searchFor(tester, 'pikachu');

      await tester.enterText(find.byType(TextField), 'raichu');

      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(clearSearchButton());

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(searchText(tester), isEmpty);
      expect(find.text('Pikachu'), findsOneWidget);
      expect(find.text('Bulbasaur'), findsOneWidget);
    });

    testWidgets('buscar sin tener favoritos conserva el estado vacío', (
      tester,
    ) async {
      await pumpFavoritesScreen(tester);
      await showSearch(tester);
      await searchFor(tester, 'pikachu');

      final l10n = favoritesL10n(tester);

      expect(find.text(l10n.noFavoritesTitle), findsOneWidget);
      expect(find.text(l10n.noFavoritesMessage), findsOneWidget);
      expect(find.text(l10n.catalogNoResults), findsNothing);
    });

    testWidgets('distingue favoritos ausentes del catálogo', (tester) async {
      await repository.addFavorite(9999);

      await pumpFavoritesScreen(tester, pokemon: testCatalog);

      await showSearch(tester);
      await searchFor(tester, 'pikachu');

      final l10n = favoritesL10n(tester);

      expect(find.text(l10n.favoritePokemonNotFound), findsOneWidget);

      expect(find.text(l10n.catalogNoResults), findsNothing);
      expect(find.text(l10n.noFavoritesTitle), findsNothing);
    });
  });

  group('persistencia de búsqueda en favoritos', () {
    testWidgets('ocultar la búsqueda conserva los resultados filtrados', (
      tester,
    ) async {
      await pumpSearchableFavorites(tester);
      await showSearch(tester);
      await searchFor(tester, 'pikachu');

      await hideSearch(tester);

      expect(find.byType(TextField), findsNothing);
      expect(visiblePokemonIds(tester), [25]);
    });

    testWidgets('mostrar nuevamente la búsqueda conserva el texto', (
      tester,
    ) async {
      await pumpSearchableFavorites(tester);
      await showSearch(tester);
      await searchFor(tester, 'chu');

      await hideSearch(tester);
      await showSearch(tester);

      expect(searchText(tester), 'chu');
      expect(visiblePokemonIds(tester), [25, 26]);
      expect(clearSearchButton(), findsOneWidget);
    });

    testWidgets('permite limpiar la búsqueda aunque el campo esté oculto', (
      tester,
    ) async {
      await pumpSearchableFavorites(tester);
      await showSearch(tester);
      await searchFor(tester, 'inexistente');

      await hideSearch(tester);

      await tester.tap(
        find.widgetWithText(
          OutlinedButton,
          favoritesL10n(tester).catalogClearFilters,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
      expect(find.text('Pikachu'), findsOneWidget);
      expect(find.text('Bulbasaur'), findsOneWidget);

      await showSearch(tester);

      expect(searchText(tester), isEmpty);
    });
  });

  group('actualización reactiva de favoritos con búsqueda', () {
    testWidgets('agregar un favorito coincidente actualiza los resultados', (
      tester,
    ) async {
      await pumpSearchableFavorites(tester, favoriteIds: [25, 1]);

      await showSearch(tester);
      await searchFor(tester, 'chu');

      expect(visiblePokemonIds(tester), [25]);

      await repository.addFavorite(26);
      await tester.pumpAndSettle();

      expect(visiblePokemonIds(tester), [25, 26]);
      expect(searchText(tester), 'chu');
    });

    testWidgets('agregar un favorito no coincidente conserva los resultados', (
      tester,
    ) async {
      await pumpSearchableFavorites(tester, favoriteIds: [25]);

      await showSearch(tester);
      await searchFor(tester, 'pikachu');

      await repository.addFavorite(1);
      await tester.pumpAndSettle();

      expect(visiblePokemonIds(tester), [25]);
      expect(find.text('Bulbasaur'), findsNothing);
      expect(await repository.isFavorite(1), isTrue);
    });

    testWidgets('eliminar un favorito visible actualiza la búsqueda', (
      tester,
    ) async {
      await pumpSearchableFavorites(tester);
      await showSearch(tester);
      await searchFor(tester, 'chu');

      expect(visiblePokemonIds(tester), [25, 26]);

      await tester.tap(
        find.descendant(
          of: find.byWidgetPredicate(
            (widget) => widget is PokemonListItem && widget.pokemon.id == 25,
          ),
          matching: find.byTooltip('Quitar de favoritos'),
        ),
      );

      await tester.pumpAndSettle();

      expect(await repository.isFavorite(25), isFalse);
      expect(visiblePokemonIds(tester), [26]);
      expect(searchText(tester), 'chu');
    });

    testWidgets(
      'eliminar la última coincidencia muestra el estado sin resultados',
      (tester) async {
        await pumpSearchableFavorites(tester, favoriteIds: [25, 1]);

        await showSearch(tester);
        await searchFor(tester, 'pikachu');

        await tester.tap(find.byTooltip('Quitar de favoritos'));

        await tester.pumpAndSettle();

        final l10n = favoritesL10n(tester);

        expect(find.text(l10n.catalogNoResults), findsOneWidget);
        expect(find.text(l10n.noFavoritesTitle), findsNothing);
        expect(await repository.isFavorite(1), isTrue);
        expect(await repository.isFavorite(25), isFalse);
      },
    );

    testWidgets(
      'eliminar el último favorito muestra el estado vacío original',
      (tester) async {
        await pumpSearchableFavorites(tester, favoriteIds: [25]);

        await showSearch(tester);
        await searchFor(tester, 'pikachu');

        await tester.tap(find.byTooltip('Quitar de favoritos'));

        await tester.pumpAndSettle();

        final l10n = favoritesL10n(tester);

        expect(find.text(l10n.noFavoritesTitle), findsOneWidget);
        expect(find.text(l10n.catalogNoResults), findsNothing);
        expect(find.byType(PokemonListItem), findsNothing);
      },
    );
  });

  group('localización de búsqueda en favoritos', () {
    for (final language in ['es', 'en']) {
      testWidgets('muestra los controles de búsqueda en $language', (
        tester,
      ) async {
        await pumpSearchableFavorites(tester, locale: Locale(language));

        final l10n = favoritesL10n(tester);

        expect(find.text(l10n.favoritesTitle), findsOneWidget);

        expect(find.byTooltip(l10n.catalogShowSearch), findsOneWidget);

        await showSearch(tester);

        final field = tester.widget<TextField>(find.byType(TextField));

        expect(field.decoration!.hintText, l10n.catalogSearchHint);

        expect(find.byTooltip(l10n.catalogHideSearch), findsOneWidget);

        await searchFor(tester, 'pikachu');

        final clearButton = tester.widget<IconButton>(clearSearchButton());

        expect(clearButton.tooltip, l10n.catalogClearFilters);
        expect(visiblePokemonIds(tester), [25]);
      });

      testWidgets('muestra el estado sin resultados en $language', (
        tester,
      ) async {
        await pumpSearchableFavorites(tester, locale: Locale(language));

        await showSearch(tester);
        await searchFor(tester, 'inexistente');

        final l10n = favoritesL10n(tester);

        expect(find.text(l10n.catalogNoResults), findsOneWidget);

        expect(find.text(l10n.catalogNoResultsMessage), findsOneWidget);

        expect(find.text(l10n.catalogClearFilters), findsOneWidget);
      });
    }
  });

  testWidgets('la búsqueda de favoritos cabe en un teléfono estrecho', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(360 * 3, 740 * 3);

    addTearDown(tester.view.reset);

    await pumpSearchableFavorites(tester);
    await showSearch(tester);

    expect(find.byType(TextField), findsOneWidget);

    final searchRect = tester.getRect(find.byType(TextField));

    expect(searchRect.left, greaterThanOrEqualTo(0));
    expect(searchRect.right, lessThanOrEqualTo(360));

    await searchFor(tester, 'pikachu');

    expect(clearSearchButton(), findsOneWidget);
    expect(visiblePokemonIds(tester), [25]);
    expect(tester.takeException(), isNull);
  });
}
