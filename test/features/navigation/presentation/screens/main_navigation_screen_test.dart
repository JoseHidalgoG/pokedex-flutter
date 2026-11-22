import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:pokedex_flutter/features/navigation/presentation/screens/main_navigation_screen.dart';
import 'package:pokedex_flutter/features/favorites/presentation/providers/favorites_providers.dart';
import 'package:pokedex_flutter/features/settings/presentation/providers/settings_providers.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import '../../../favorites/fakes/fake_favorites_repository.dart';

void main() {
  const pikachu = Pokemon(
    id: 25,
    name: 'pikachu',
    imageUrl: '',
    typeNames: ['electric'],
  );

  List<Override> navigationOverrides(
      List<Pokemon> pokemon, {
        required Locale locale,
      }) {
    return [
      filteredCatalogPageProvider.overrideWith((ref, request) {
        final offset = request.page * request.pageSize;

        return Stream.value(
          pokemon.skip(offset).take(request.pageSize).toList(),
        );
      }),
      filteredCatalogCountProvider.overrideWith(
            (ref, query) => Stream.value(pokemon.length),
      ),
      catalogSyncStatusProvider.overrideWith(
            (ref) => Stream.value(const SyncIdle()),
      ),
      favoritesRepositoryProvider.overrideWith(
            (ref) => FakeFavoritesRepository(),
      ),
      languageProvider.overrideWith(
            (ref) => Stream.value(locale.languageCode),
      ),
      themeProvider.overrideWith((ref) => Stream.value('system')),
    ];
  }

  Future<void> pumpNavigation(
      WidgetTester tester, {
        Locale locale = const Locale('es'),
      }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: navigationOverrides([pikachu], locale: locale),
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MainNavigationScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();
  }

  testWidgets('muestra los cuatro destinos de navegación', (tester) async {
    await pumpNavigation(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(4));

    expect(find.text('Catálogo'), findsOneWidget);
    expect(find.text('Favoritos'), findsOneWidget);
    expect(find.text('Trivia'), findsOneWidget);
    expect(find.text('Ajustes'), findsOneWidget);
  });

  testWidgets('inicia en la pestaña de catálogo', (tester) async {
    await pumpNavigation(tester);

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );

    expect(navigationBar.selectedIndex, 0);
    expect(find.text('Pikachu'), findsOneWidget);
  });

  testWidgets('permite navegar a Trivia', (tester) async {
    await pumpNavigation(tester);

    await tester.tap(find.text('Trivia').first);
    await tester.pump();

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );

    expect(navigationBar.selectedIndex, 2);
    expect(find.text('Próximamente'), findsOneWidget);
  });

  testWidgets('permite navegar a Ajustes', (tester) async {
    await pumpNavigation(tester);

    await tester.tap(find.text('Ajustes'));
    await tester.pump();

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );

    expect(navigationBar.selectedIndex, 3);
    expect(find.text('Idioma'), findsOneWidget);
  });

  testWidgets('muestra las etiquetas de navegación en inglés', (tester) async {
    await pumpNavigation(tester, locale: const Locale('en'));

    expect(find.text('Catalog'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Trivia'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    expect(find.text('Catálogo'), findsNothing);
    expect(find.text('Favoritos'), findsNothing);
    expect(find.text('Ajustes'), findsNothing);
  });

  testWidgets('conserva la página del catálogo al cambiar de pestaña', (
      tester,
      ) async {
    final pokemon = List.generate(
      51,
          (index) => Pokemon(
        id: index + 1,
        name: 'pokemon${index + 1}',
        imageUrl: '',
        typeNames: const ['normal'],
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: navigationOverrides(
          pokemon,
          locale: const Locale('es'),
        ),
        child: const MaterialApp(
          locale: Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MainNavigationScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('#0001'), findsOneWidget);

    await tester.tap(find.byTooltip('Página siguiente'));
    await tester.pump();
    await tester.pump();

    expect(find.text('#0051'), findsOneWidget);

    await tester.tap(find.text('Trivia').first);
    await tester.pump();

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );

    expect(navigationBar.selectedIndex, 2);

    await tester.tap(find.text('Catálogo'));
    await tester.pump();

    expect(find.text('#0051'), findsOneWidget);
    expect(find.text('#0001'), findsNothing);
  });

  testWidgets('el botón Atrás regresa a Catálogo desde Trivia', (tester) async {
    await pumpNavigation(tester);

    await tester.tap(find.text('Trivia').first);
    await tester.pump();

    var navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );

    expect(navigationBar.selectedIndex, 2);
    expect(find.text('Próximamente'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pump();

    navigationBar = tester.widget<NavigationBar>(find.byType(NavigationBar));

    expect(navigationBar.selectedIndex, 0);
    expect(find.text('Pikachu'), findsOneWidget);
  });
}
