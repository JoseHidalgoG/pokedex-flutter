import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:pokedex_flutter/features/catalog/presentation/screens/catalog_screen.dart';
import 'package:pokedex_flutter/features/catalog/presentation/screens/pokemon_detail_screen.dart';
import 'package:pokedex_flutter/features/favorites/presentation/providers/favorites_providers.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_page_request.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/catalog_filter_bar.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/pokemon_list_item.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import '../../../favorites/fakes/fake_favorites_repository.dart';

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

  const raichu = Pokemon(
    id: 26,
    name: 'raichu',
    imageUrl: '',
    typeNames: ['electric'],
  );

  const vulpix = Pokemon(
    id: 37,
    name: 'vulpix',
    imageUrl: '',
    typeNames: ['fire'],
  );

  const testCatalog = [
    bulbasaur,
    charmander,
    squirtle,
    pikachu,
    raichu,
    vulpix,
  ];

  const testBaseStats = <int, int>{
    1: 318,
    4: 309,
    7: 314,
    25: 320,
    26: 485,
    37: 299,
  };

  List<Pokemon> applyQuery(List<Pokemon> pokemon, CatalogQuery query) {
    final search = query.search.trim().toLowerCase();
    final searchedId = int.tryParse(search);

    final filtered = pokemon.where((item) {
      final matchesSearch =
          search.isEmpty ||
          (searchedId != null
              ? item.id == searchedId
              : item.name.toLowerCase().contains(search));

      final matchesType =
          query.type == null || item.typeNames.contains(query.type);

      return matchesSearch && matchesType;
    }).toList();

    filtered.sort((a, b) {
      final comparison = switch (query.sort) {
        CatalogSort.numberAscending => a.id.compareTo(b.id),

        CatalogSort.numberDescending => b.id.compareTo(a.id),

        CatalogSort.nameAscending => a.name.toLowerCase().compareTo(
          b.name.toLowerCase(),
        ),

        CatalogSort.nameDescending => b.name.toLowerCase().compareTo(
          a.name.toLowerCase(),
        ),

        CatalogSort.baseStatTotalAscending =>
          (testBaseStats[a.id] ?? 0).compareTo(testBaseStats[b.id] ?? 0),

        CatalogSort.baseStatTotalDescending =>
          (testBaseStats[b.id] ?? 0).compareTo(testBaseStats[a.id] ?? 0),
      };

      return comparison != 0 ? comparison : a.id.compareTo(b.id);
    });

    return filtered;
  }

  List<Override> catalogOverrides(
    List<Pokemon> pokemon, {
    required Stream<SyncStatus> syncStatuses,
    Stream<int>? counts,
    List<CatalogPageRequest>? pageRequests,
    List<CatalogQuery>? countRequests,
  }) {
    return [
      filteredCatalogPageProvider.overrideWith((ref, request) {
        pageRequests?.add(request);

        final filtered = applyQuery(pokemon, request.query);
        final offset = request.page * request.pageSize;

        return Stream.value(
          filtered.skip(offset).take(request.pageSize).toList(),
        );
      }),

      filteredCatalogCountProvider.overrideWith((ref, query) {
        countRequests?.add(query);

        return counts ?? Stream.value(applyQuery(pokemon, query).length);
      }),

      catalogSyncStatusProvider.overrideWith((ref) => syncStatuses),

      favoritesRepositoryProvider.overrideWith(
        (ref) => FakeFavoritesRepository(),
      ),
    ];
  }

  Future<void> pumpCatalog(
    WidgetTester tester, {
    required List<Pokemon> pokemon,
    SyncStatus syncStatus = const SyncIdle(),
    Locale locale = const Locale('es'),
    List<CatalogPageRequest>? pageRequests,
    List<CatalogQuery>? countRequests,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: catalogOverrides(
          pokemon,
          syncStatuses: Stream.value(syncStatus),
          pageRequests: pageRequests,
          countRequests: countRequests,
        ),
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CatalogScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();
  }

  Future<void> scrollToPagination(WidgetTester tester) async {
    final paginationFinder = find.byTooltip('Página siguiente');

    await tester.scrollUntilVisible(
      paginationFinder,
      400,
      scrollable: find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
      maxScrolls: 100,
    );

    await tester.ensureVisible(paginationFinder);
    await tester.pumpAndSettle();
  }

  AppLocalizations catalogL10n(WidgetTester tester) {
    return AppLocalizations.of(tester.element(find.byType(CatalogScreen)))!;
  }

  Finder typeDropdown() {
    return find.byType(DropdownButtonFormField<String>);
  }

  Finder sortDropdown() {
    return find.byType(DropdownButtonFormField<CatalogSort>);
  }

  Future<void> showFilters(WidgetTester tester) async {
    await tester.tap(find.byTooltip(catalogL10n(tester).catalogShowSearch));

    await tester.pumpAndSettle();
  }

  Future<void> hideFilters(WidgetTester tester) async {
    await tester.tap(find.byTooltip(catalogL10n(tester).catalogHideSearch));

    await tester.pumpAndSettle();
  }

  Future<void> searchFor(WidgetTester tester, String value) async {
    await tester.enterText(find.byType(TextField), value);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  }

  Future<void> selectType(WidgetTester tester, String label) async {
    final dropdown = tester.widget<DropdownButton<String>>(
      find.descendant(
        of: typeDropdown(),
        matching: find.byType(DropdownButton<String>),
      ),
    );

    final items = dropdown.items!;

    final targetIndex = items.indexWhere(
      (item) => item.child is Text && (item.child as Text).data == label,
    );

    final currentIndex = items.indexWhere(
      (item) => item.value == dropdown.value,
    );

    expect(targetIndex, greaterThanOrEqualTo(0));

    await tester.tap(typeDropdown());
    await tester.pumpAndSettle();

    final menuScrollable = find.byType(Scrollable).last;

    final option = find.descendant(
      of: menuScrollable,
      matching: find.text(label),
    );

    await tester.scrollUntilVisible(
      option,
      targetIndex < currentIndex ? -48 : 48,
      scrollable: menuScrollable,
      maxScrolls: 25,
    );

    await tester.ensureVisible(option);
    await tester.tap(option);
    await tester.pumpAndSettle();
  }

  Future<void> selectSort(WidgetTester tester, String label) async {
    await tester.tap(sortDropdown());
    await tester.pumpAndSettle();

    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  List<int> visiblePokemonIds(WidgetTester tester) {
    return tester
        .widgetList<PokemonListItem>(find.byType(PokemonListItem))
        .map((item) => item.pokemon.id)
        .toList();
  }

  testWidgets('muestra el número, nombre y tipo de un Pokémon', (tester) async {
    await pumpCatalog(tester, pokemon: [pikachu]);

    expect(find.text('#0025'), findsOneWidget);
    expect(find.text('Pikachu'), findsOneWidget);
    expect(find.text('Eléctrico'), findsOneWidget);
  });

  testWidgets('muestra el tipo de Pokémon en inglés', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: catalogOverrides([
          pikachu,
        ], syncStatuses: Stream.value(const SyncIdle())),
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CatalogScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('Pikachu'), findsOneWidget);
    expect(find.text('Electric'), findsOneWidget);
    expect(find.text('Eléctrico'), findsNothing);
  });

  testWidgets('muestra un indicador cuando el catálogo está sincronizando', (
    tester,
  ) async {
    await pumpCatalog(
      tester,
      pokemon: [],
      syncStatus: const SyncFullPassInProgress(),
    );

    expect(find.byType(CircularProgressIndicator), findsWidgets);
    expect(find.text('Cargando catálogo'), findsOneWidget);
  });

  testWidgets('sigue cargando mientras espera un reintento sin datos', (
    tester,
  ) async {
    await pumpCatalog(
      tester,
      pokemon: [],
      syncStatus: SyncWaitingRetry(
        attempt: 1,
        maxAttempts: 5,
        retryAt: DateTime(2026, 11, 20, 10, 0, 2),
        failure: const ServerError(503),
      ),
    );

    expect(find.text('Cargando catálogo'), findsOneWidget);
    expect(find.text('No hay Pokémon disponibles'), findsNothing);
  });

  testWidgets(
    'muestra un error cuando no hay datos y falla la sincronización',
    (tester) async {
      await pumpCatalog(
        tester,
        pokemon: [],
        syncStatus: const SyncFailed(NoConnection()),
      );

      expect(find.text('No se pudo cargar el catálogo'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    },
  );

  testWidgets('muestra un estado vacío cuando no hay Pokémon', (tester) async {
    await pumpCatalog(tester, pokemon: [], syncStatus: const SyncIdle());

    expect(find.text('No hay Pokémon disponibles'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('permite navegar entre dos páginas del catálogo', (tester) async {
    final pokemon = List.generate(
      51,
      (index) => Pokemon(
        id: index + 1,
        name: 'pokemon${index + 1}',
        imageUrl: '',
        typeNames: const ['normal'],
      ),
    );

    await pumpCatalog(tester, pokemon: pokemon);

    expect(find.text('#0001'), findsOneWidget);
    expect(find.text('Pokemon1'), findsOneWidget);

    expect(find.byTooltip('Página siguiente'), findsNothing);

    await scrollToPagination(tester);

    final previousButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.chevron_left),
    );

    expect(previousButton.onPressed, isNull);

    await tester.tap(find.byTooltip('Página siguiente'));
    await tester.pump();
    await tester.pump();

    expect(find.text('#0051'), findsOneWidget);
    expect(find.text('Pokemon51'), findsOneWidget);

    await scrollToPagination(tester);

    final nextButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.chevron_right),
    );

    expect(nextButton.onPressed, isNull);

    await tester.tap(find.byTooltip('Página anterior'));
    await tester.pump();
    await tester.pump();

    // Al regresar, debe mostrarse el inicio de la primera página.
    expect(find.text('#0001'), findsOneWidget);
    expect(find.text('Pokemon1'), findsOneWidget);
  });

  testWidgets(
    'la paginación cabe en un teléfono estrecho con el catálogo completo',
    (tester) async {
      const narrowPhoneWidth = 360.0;

      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = const Size(narrowPhoneWidth * 3, 740 * 3);

      addTearDown(tester.view.reset);

      final fullCatalog = List.generate(
        1025,
        (index) => Pokemon(
          id: index + 1,
          name: 'pokemon${index + 1}',
          imageUrl: '',
          typeNames: const ['normal'],
        ),
      );

      await pumpCatalog(tester, pokemon: fullCatalog);

      await scrollToPagination(tester);

      final nextPageButton = tester.getRect(find.byTooltip('Página siguiente'));

      final previousPageButton = tester.getRect(
        find.byTooltip('Página anterior'),
      );

      expect(nextPageButton.right, lessThanOrEqualTo(narrowPhoneWidth));

      expect(previousPageButton.left, greaterThanOrEqualTo(0));

      expect(find.text('1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('abre el detalle al seleccionar un Pokémon', (tester) async {
    await pumpCatalog(tester, pokemon: [pikachu]);

    expect(find.text('Pikachu'), findsOneWidget);

    await tester.tap(find.text('Pikachu'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(PokemonDetailScreen), findsOneWidget);
  });

  testWidgets('conserva los Pokémon visibles cuando falla la sincronización', (
    tester,
  ) async {
    await pumpCatalog(
      tester,
      pokemon: [pikachu],
      syncStatus: const SyncFailed(NoConnection()),
    );

    expect(find.text('#0025'), findsOneWidget);
    expect(find.text('Pikachu'), findsOneWidget);
    expect(find.text('Eléctrico'), findsOneWidget);

    expect(find.text('No se pudo cargar el catálogo'), findsNothing);
    expect(
      find.text('Sin conexión: se muestran los Pokémon guardados.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'avisa con un SnackBar cuando falla una sincronización sobre la lista visible',
    (tester) async {
      final syncStatusController = StreamController<SyncStatus>();
      addTearDown(syncStatusController.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: catalogOverrides([
            pikachu,
          ], syncStatuses: syncStatusController.stream),
          child: const MaterialApp(
            locale: Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: CatalogScreen(),
          ),
        ),
      );

      syncStatusController.add(SyncRevalidated(DateTime(2026, 11, 19, 10)));
      await tester.pump();
      await tester.pump();

      expect(find.byType(SnackBar), findsNothing);

      syncStatusController
        ..add(const SyncFullPassInProgress())
        ..add(const SyncFailed(ServerError(503)));

      await tester.pump();
      await tester.pump();

      expect(find.text('Pikachu'), findsOneWidget);
      expect(
        find.text('No se pudo sincronizar el catálogo. Inténtalo nuevamente.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('regresa a una página válida cuando disminuye el catálogo', (
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

    final countController = StreamController<int>.broadcast();
    addTearDown(countController.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: catalogOverrides(
          pokemon,
          syncStatuses: Stream.value(const SyncIdle()),
          counts: countController.stream,
        ),
        child: const MaterialApp(
          home: CatalogScreen(),
          locale: Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    countController.add(51);

    await tester.pump();
    await tester.pump();

    await scrollToPagination(tester);

    await tester.tap(find.byTooltip('Página siguiente'));
    await tester.pump();
    await tester.pump();

    expect(find.text('#0051'), findsOneWidget);

    countController.add(25);

    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text('#0001'), findsOneWidget);
    expect(find.text('#0051'), findsNothing);
    expect(find.byTooltip('Página siguiente'), findsNothing);
  });

  group('visibilidad de los filtros del catálogo', () {
    testWidgets('los filtros están ocultos inicialmente', (tester) async {
      await pumpCatalog(tester, pokemon: testCatalog);

      expect(find.byType(CatalogFilterBar), findsNothing);
      expect(find.byType(TextField), findsNothing);

      expect(
        find.byTooltip(catalogL10n(tester).catalogShowSearch),
        findsOneWidget,
      );
    });

    testWidgets('muestra los filtros al presionar la lupa', (tester) async {
      await pumpCatalog(tester, pokemon: testCatalog);
      await showFilters(tester);

      expect(find.byType(CatalogFilterBar), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(typeDropdown(), findsOneWidget);
      expect(sortDropdown(), findsOneWidget);

      expect(
        find.byTooltip(catalogL10n(tester).catalogHideSearch),
        findsOneWidget,
      );
    });

    testWidgets('permite ocultar nuevamente los filtros', (tester) async {
      await pumpCatalog(tester, pokemon: testCatalog);

      await showFilters(tester);
      await hideFilters(tester);

      expect(find.byType(CatalogFilterBar), findsNothing);
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Bulbasaur'), findsOneWidget);
    });

    testWidgets('mostrar y ocultar no genera nuevas consultas', (tester) async {
      final requests = <CatalogPageRequest>[];

      await pumpCatalog(tester, pokemon: testCatalog, pageRequests: requests);

      await showFilters(tester);
      await hideFilters(tester);
      await showFilters(tester);

      expect(requests, hasLength(1));
      expect(requests.single.query, const CatalogQuery());
    });

    testWidgets('los filtros comienzan con los valores predeterminados', (
      tester,
    ) async {
      await pumpCatalog(tester, pokemon: testCatalog);
      await showFilters(tester);

      final filterBar = tester.widget<CatalogFilterBar>(
        find.byType(CatalogFilterBar),
      );

      expect(filterBar.searchController.text, isEmpty);
      expect(filterBar.selectedType, isNull);
      expect(filterBar.selectedSort, CatalogSort.numberAscending);
    });
  });

  group('búsqueda en el catálogo', () {
    testWidgets('busca un Pokémon por su nombre completo', (tester) async {
      await pumpCatalog(tester, pokemon: testCatalog);
      await showFilters(tester);

      await searchFor(tester, 'pikachu');

      expect(visiblePokemonIds(tester), [25]);
      expect(find.text('Pikachu'), findsOneWidget);
      expect(find.text('Raichu'), findsNothing);
    });

    testWidgets('permite buscar por una parte del nombre', (tester) async {
      await pumpCatalog(tester, pokemon: testCatalog);
      await showFilters(tester);

      await searchFor(tester, 'chu');

      expect(visiblePokemonIds(tester), [25, 26]);
    });

    testWidgets('permite buscar utilizando el número del Pokémon', (
      tester,
    ) async {
      await pumpCatalog(tester, pokemon: testCatalog);
      await showFilters(tester);

      await searchFor(tester, '25');

      expect(visiblePokemonIds(tester), [25]);
      expect(find.text('#0025'), findsOneWidget);
    });

    testWidgets('la búsqueda no distingue mayúsculas y minúsculas', (
      tester,
    ) async {
      await pumpCatalog(tester, pokemon: testCatalog);
      await showFilters(tester);

      await searchFor(tester, 'PiKaChU');

      expect(visiblePokemonIds(tester), [25]);
    });

    testWidgets('elimina espacios al principio y al final de la búsqueda', (
      tester,
    ) async {
      final requests = <CatalogPageRequest>[];

      await pumpCatalog(tester, pokemon: testCatalog, pageRequests: requests);

      await showFilters(tester);
      await searchFor(tester, '  pikachu  ');

      expect(visiblePokemonIds(tester), [25]);
      expect(requests.last.query.search, 'pikachu');
    });

    testWidgets('borrar la búsqueda restablece los resultados', (tester) async {
      await pumpCatalog(tester, pokemon: testCatalog);
      await showFilters(tester);

      await searchFor(tester, 'pikachu');

      expect(visiblePokemonIds(tester), [25]);

      await searchFor(tester, '');

      expect(find.text('Bulbasaur'), findsOneWidget);
      expect(find.text('Charmander'), findsOneWidget);
    });

    testWidgets('la página y el conteo reciben la misma consulta', (
      tester,
    ) async {
      final pageRequests = <CatalogPageRequest>[];
      final countRequests = <CatalogQuery>[];

      await pumpCatalog(
        tester,
        pokemon: testCatalog,
        pageRequests: pageRequests,
        countRequests: countRequests,
      );

      await showFilters(tester);
      await searchFor(tester, 'chu');

      expect(pageRequests.last.query, countRequests.last);
      expect(countRequests.last.search, 'chu');
      expect(pageRequests.last.page, 0);
      expect(pageRequests.last.pageSize, 50);
    });
  });

  group('debounce de búsqueda del catálogo', () {
    testWidgets('no aplica la búsqueda antes de 300 milisegundos', (
      tester,
    ) async {
      final requests = <CatalogPageRequest>[];

      await pumpCatalog(tester, pokemon: testCatalog, pageRequests: requests);

      await showFilters(tester);

      await tester.enterText(find.byType(TextField), 'pikachu');
      await tester.pump(const Duration(milliseconds: 299));

      expect(requests, hasLength(1));
      expect(requests.last.query.search, isEmpty);
      expect(find.text('Bulbasaur'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();

      expect(requests, hasLength(2));
      expect(requests.last.query.search, 'pikachu');
      expect(visiblePokemonIds(tester), [25]);
    });

    testWidgets('reinicia el temporizador cuando cambia el texto', (
      tester,
    ) async {
      final requests = <CatalogPageRequest>[];

      await pumpCatalog(tester, pokemon: testCatalog, pageRequests: requests);

      await showFilters(tester);

      await tester.enterText(find.byType(TextField), 'p');
      await tester.pump(const Duration(milliseconds: 200));

      await tester.enterText(find.byType(TextField), 'pi');
      await tester.pump(const Duration(milliseconds: 200));

      await tester.enterText(find.byType(TextField), 'pikachu');
      await tester.pump(const Duration(milliseconds: 299));

      expect(requests, hasLength(1));

      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();

      expect(requests, hasLength(2));
      expect(requests.last.query.search, 'pikachu');
    });

    testWidgets('no consulta los textos intermedios', (tester) async {
      final requests = <CatalogPageRequest>[];

      await pumpCatalog(tester, pokemon: testCatalog, pageRequests: requests);

      await showFilters(tester);

      for (final text in ['p', 'pi', 'pik', 'pika', 'pikachu']) {
        await tester.enterText(find.byType(TextField), text);
        await tester.pump(const Duration(milliseconds: 50));
      }

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(requests.map((request) => request.query.search).toList(), [
        '',
        'pikachu',
      ]);
    });

    testWidgets('cancela el temporizador al destruir la pantalla', (
      tester,
    ) async {
      final requests = <CatalogPageRequest>[];

      await pumpCatalog(tester, pokemon: testCatalog, pageRequests: requests);

      await showFilters(tester);

      await tester.enterText(find.byType(TextField), 'pikachu');
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 400));

      expect(requests, hasLength(1));
      expect(tester.takeException(), isNull);
    });
  });

  group('filtro por tipo del catálogo', () {
    testWidgets('muestra solamente los Pokémon del tipo seleccionado', (
      tester,
    ) async {
      final requests = <CatalogPageRequest>[];

      await pumpCatalog(tester, pokemon: testCatalog, pageRequests: requests);

      await showFilters(tester);

      await selectType(tester, catalogL10n(tester).pokemonTypeElectric);

      expect(visiblePokemonIds(tester), [25, 26]);
      expect(requests.last.query.type, 'electric');
    });

    testWidgets('incluye Pokémon con más de un tipo', (tester) async {
      await pumpCatalog(tester, pokemon: testCatalog);
      await showFilters(tester);

      await selectType(tester, catalogL10n(tester).pokemonTypePoison);

      expect(visiblePokemonIds(tester), [1]);
    });

    testWidgets('permite cambiar de un tipo a otro', (tester) async {
      await pumpCatalog(tester, pokemon: testCatalog);
      await showFilters(tester);

      await selectType(tester, catalogL10n(tester).pokemonTypeElectric);

      expect(visiblePokemonIds(tester), [25, 26]);

      await selectType(tester, catalogL10n(tester).pokemonTypeFire);

      expect(visiblePokemonIds(tester), [4, 37]);
    });

    testWidgets('seleccionar todos los tipos elimina el filtro', (
      tester,
    ) async {
      final requests = <CatalogPageRequest>[];

      await pumpCatalog(tester, pokemon: testCatalog, pageRequests: requests);

      await showFilters(tester);

      await selectType(tester, catalogL10n(tester).pokemonTypeElectric);

      await selectType(tester, catalogL10n(tester).catalogAllTypes);

      expect(requests.last.query.type, isNull);
      expect(find.text('Bulbasaur'), findsOneWidget);
      expect(find.text('Charmander'), findsOneWidget);
    });

    testWidgets('un tipo sin coincidencias muestra el estado sin resultados', (
      tester,
    ) async {
      await pumpCatalog(tester, pokemon: testCatalog);
      await showFilters(tester);

      await selectType(tester, catalogL10n(tester).pokemonTypeDragon);

      expect(find.byType(PokemonListItem), findsNothing);

      expect(find.text(catalogL10n(tester).catalogNoResults), findsOneWidget);
    });

    testWidgets('el selector contiene los 18 tipos y la opción todos', (
      tester,
    ) async {
      await pumpCatalog(tester, pokemon: testCatalog);
      await showFilters(tester);

      final dropdown = tester.widget<DropdownButton<String>>(
        find.descendant(
          of: typeDropdown(),
          matching: find.byType(DropdownButton<String>),
        ),
      );

      expect(dropdown.items, hasLength(19));

      expect(
        dropdown.items!.map((item) => item.value),
        unorderedEquals(['', ...CatalogFilterBar.types]),
      );
    });
  });

  group('ordenamiento del catálogo', () {
    const expectedOrders = <CatalogSort, List<int>>{
      CatalogSort.numberAscending: [1, 4, 7, 25, 26, 37],
      CatalogSort.numberDescending: [37, 26, 25, 7, 4, 1],
      CatalogSort.nameAscending: [1, 4, 25, 26, 7, 37],
      CatalogSort.nameDescending: [37, 7, 26, 25, 4, 1],
      CatalogSort.baseStatTotalAscending: [37, 4, 7, 1, 25, 26],
      CatalogSort.baseStatTotalDescending: [26, 25, 1, 7, 4, 37],
    };

    String sortLabel(AppLocalizations l10n, CatalogSort sort) {
      return switch (sort) {
        CatalogSort.numberAscending => l10n.catalogSortNumberAsc,
        CatalogSort.numberDescending => l10n.catalogSortNumberDesc,
        CatalogSort.nameAscending => l10n.catalogSortNameAsc,
        CatalogSort.nameDescending => l10n.catalogSortNameDesc,
        CatalogSort.baseStatTotalAscending => l10n.catalogSortStatsAsc,
        CatalogSort.baseStatTotalDescending => l10n.catalogSortStatsDesc,
      };
    }

    for (final entry in expectedOrders.entries) {
      testWidgets('permite ordenar por ${entry.key.name}', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(800, 1400);

        addTearDown(tester.view.reset);

        final requests = <CatalogPageRequest>[];

        await pumpCatalog(tester, pokemon: testCatalog, pageRequests: requests);

        await showFilters(tester);

        // Cambiamos primero el orden para comprobar también
        // que se puede regresar al orden predeterminado.
        await selectSort(tester, catalogL10n(tester).catalogSortNumberDesc);

        await selectSort(tester, sortLabel(catalogL10n(tester), entry.key));

        expect(requests.last.query.sort, entry.key);
        expect(visiblePokemonIds(tester), entry.value);
      });
    }

    testWidgets('el selector contiene los seis ordenamientos', (tester) async {
      await pumpCatalog(tester, pokemon: testCatalog);
      await showFilters(tester);

      final dropdown = tester.widget<DropdownButton<CatalogSort>>(
        find.descendant(
          of: sortDropdown(),
          matching: find.byType(DropdownButton<CatalogSort>),
        ),
      );

      expect(dropdown.items, hasLength(6));

      expect(
        dropdown.items!.map((item) => item.value),
        unorderedEquals(CatalogSort.values),
      );
    });
  });

  group('combinación y persistencia de filtros', () {
    testWidgets('combina búsqueda y filtro por tipo', (tester) async {
      final requests = <CatalogPageRequest>[];

      await pumpCatalog(tester, pokemon: testCatalog, pageRequests: requests);

      await showFilters(tester);
      await searchFor(tester, 'chu');

      await selectType(tester, catalogL10n(tester).pokemonTypeElectric);

      expect(visiblePokemonIds(tester), [25, 26]);

      expect(
        requests.last.query,
        const CatalogQuery(search: 'chu', type: 'electric'),
      );
    });

    testWidgets('combina búsqueda, tipo y ordenamiento', (tester) async {
      final requests = <CatalogPageRequest>[];

      await pumpCatalog(tester, pokemon: testCatalog, pageRequests: requests);

      await showFilters(tester);
      await searchFor(tester, 'chu');

      await selectType(tester, catalogL10n(tester).pokemonTypeElectric);

      await selectSort(tester, catalogL10n(tester).catalogSortNumberDesc);

      expect(visiblePokemonIds(tester), [26, 25]);

      expect(
        requests.last.query,
        const CatalogQuery(
          search: 'chu',
          type: 'electric',
          sort: CatalogSort.numberDescending,
        ),
      );
    });

    testWidgets('borrar la búsqueda conserva el tipo seleccionado', (
      tester,
    ) async {
      await pumpCatalog(tester, pokemon: testCatalog);
      await showFilters(tester);

      await selectType(tester, catalogL10n(tester).pokemonTypeElectric);

      await searchFor(tester, 'pika');
      expect(visiblePokemonIds(tester), [25]);

      await searchFor(tester, '');
      expect(visiblePokemonIds(tester), [25, 26]);
    });

    testWidgets('eliminar el tipo conserva la búsqueda', (tester) async {
      final requests = <CatalogPageRequest>[];

      await pumpCatalog(tester, pokemon: testCatalog, pageRequests: requests);

      await showFilters(tester);
      await searchFor(tester, 'chu');

      await selectType(tester, catalogL10n(tester).pokemonTypeElectric);

      await selectType(tester, catalogL10n(tester).catalogAllTypes);

      expect(requests.last.query.search, 'chu');
      expect(requests.last.query.type, isNull);
      expect(visiblePokemonIds(tester), [25, 26]);
    });

    testWidgets('ocultar los filtros conserva los resultados filtrados', (
      tester,
    ) async {
      await pumpCatalog(tester, pokemon: testCatalog);
      await showFilters(tester);
      await searchFor(tester, 'pikachu');

      await hideFilters(tester);

      expect(find.byType(CatalogFilterBar), findsNothing);
      expect(visiblePokemonIds(tester), [25]);
    });

    testWidgets('al mostrar nuevamente los filtros conserva sus valores', (
      tester,
    ) async {
      await pumpCatalog(tester, pokemon: testCatalog);
      await showFilters(tester);
      await searchFor(tester, 'chu');

      await selectType(tester, catalogL10n(tester).pokemonTypeElectric);

      await selectSort(tester, catalogL10n(tester).catalogSortNumberDesc);

      await hideFilters(tester);
      await showFilters(tester);

      final filterBar = tester.widget<CatalogFilterBar>(
        find.byType(CatalogFilterBar),
      );

      expect(filterBar.searchController.text, 'chu');
      expect(filterBar.selectedType, 'electric');
      expect(filterBar.selectedSort, CatalogSort.numberDescending);

      expect(visiblePokemonIds(tester), [26, 25]);
    });
  });

  group('estado sin resultados del catálogo', () {
    testWidgets(
      'muestra el mensaje cuando la búsqueda no tiene coincidencias',
      (tester) async {
        await pumpCatalog(tester, pokemon: testCatalog);
        await showFilters(tester);

        await searchFor(tester, 'inexistente');

        final l10n = catalogL10n(tester);

        expect(find.text(l10n.catalogNoResults), findsOneWidget);
        expect(find.text(l10n.catalogNoResultsMessage), findsOneWidget);
        expect(find.text(l10n.catalogClearFilters), findsOneWidget);

        expect(find.text(l10n.catalogEmpty), findsNothing);
        expect(find.byType(PokemonListItem), findsNothing);
      },
    );

    testWidgets('limpiar filtros restablece todos los criterios', (
      tester,
    ) async {
      final requests = <CatalogPageRequest>[];

      await pumpCatalog(tester, pokemon: testCatalog, pageRequests: requests);

      await showFilters(tester);

      await selectType(tester, catalogL10n(tester).pokemonTypeElectric);

      await selectSort(tester, catalogL10n(tester).catalogSortNumberDesc);

      await searchFor(tester, 'inexistente');

      await tester.tap(find.text(catalogL10n(tester).catalogClearFilters));

      await tester.pumpAndSettle();

      expect(requests.last.query, const CatalogQuery());
      expect(requests.last.page, 0);

      final filterBar = tester.widget<CatalogFilterBar>(
        find.byType(CatalogFilterBar),
      );

      expect(filterBar.searchController.text, isEmpty);
      expect(filterBar.selectedType, isNull);
      expect(filterBar.selectedSort, CatalogSort.numberAscending);

      expect(find.text('Bulbasaur'), findsOneWidget);
      expect(find.text('Charmander'), findsOneWidget);
    });

    testWidgets('limpiar filtros cancela una búsqueda pendiente', (
      tester,
    ) async {
      final requests = <CatalogPageRequest>[];

      await pumpCatalog(tester, pokemon: testCatalog, pageRequests: requests);

      await showFilters(tester);
      await searchFor(tester, 'inexistente');

      await tester.enterText(find.byType(TextField), 'pikachu');
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text(catalogL10n(tester).catalogClearFilters));

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(requests.last.query, const CatalogQuery());

      expect(
        requests.any((request) => request.query.search == 'pikachu'),
        isFalse,
      );

      expect(find.text('Bulbasaur'), findsOneWidget);
    });

    testWidgets('permite limpiar los filtros aunque estén ocultos', (
      tester,
    ) async {
      final requests = <CatalogPageRequest>[];

      await pumpCatalog(tester, pokemon: testCatalog, pageRequests: requests);

      await showFilters(tester);
      await searchFor(tester, 'inexistente');
      await hideFilters(tester);

      await tester.tap(find.text(catalogL10n(tester).catalogClearFilters));

      await tester.pumpAndSettle();

      expect(requests.last.query, const CatalogQuery());
      expect(find.byType(CatalogFilterBar), findsNothing);
      expect(find.text('Bulbasaur'), findsOneWidget);
    });

    testWidgets('una búsqueda sin resultados no muestra paginación', (
      tester,
    ) async {
      await pumpCatalog(tester, pokemon: testCatalog);
      await showFilters(tester);
      await searchFor(tester, 'inexistente');

      expect(find.byTooltip(catalogL10n(tester).nextPage), findsNothing);

      expect(find.byTooltip(catalogL10n(tester).previousPage), findsNothing);
    });
  });

  group('paginación del catálogo filtrado', () {
    List<Pokemon> largeCatalog() {
      return List.generate(
        120,
        (index) => Pokemon(
          id: index + 1,
          name: 'pokemon${index + 1}',
          imageUrl: '',
          typeNames: [index.isEven ? 'electric' : 'fire'],
        ),
      );
    }

    Future<void> goToSecondPage(WidgetTester tester) async {
      await scrollToPagination(tester);

      await tester.tap(find.byTooltip(catalogL10n(tester).nextPage));

      await tester.pumpAndSettle();
    }

    testWidgets('cambiar la búsqueda restablece la primera página', (
      tester,
    ) async {
      final requests = <CatalogPageRequest>[];

      await pumpCatalog(
        tester,
        pokemon: largeCatalog(),
        pageRequests: requests,
      );

      await goToSecondPage(tester);

      expect(requests.last.page, 1);

      await showFilters(tester);
      await searchFor(tester, '25');

      expect(requests.last.page, 0);
      expect(requests.last.query.search, '25');
      expect(visiblePokemonIds(tester), [25]);
    });

    testWidgets('cambiar el tipo restablece la primera página', (tester) async {
      final requests = <CatalogPageRequest>[];

      await pumpCatalog(
        tester,
        pokemon: largeCatalog(),
        pageRequests: requests,
      );

      await goToSecondPage(tester);
      expect(requests.last.page, 1);

      await showFilters(tester);

      await selectType(tester, catalogL10n(tester).pokemonTypeElectric);

      expect(requests.last.page, 0);
      expect(requests.last.query.type, 'electric');
      expect(visiblePokemonIds(tester).first, 1);
    });

    testWidgets('cambiar el ordenamiento restablece la primera página', (
      tester,
    ) async {
      final requests = <CatalogPageRequest>[];

      await pumpCatalog(
        tester,
        pokemon: largeCatalog(),
        pageRequests: requests,
      );

      await goToSecondPage(tester);
      expect(requests.last.page, 1);

      await showFilters(tester);

      await selectSort(tester, catalogL10n(tester).catalogSortNumberDesc);

      expect(requests.last.page, 0);

      expect(requests.last.query.sort, CatalogSort.numberDescending);

      expect(visiblePokemonIds(tester).first, 120);
    });

    testWidgets('la paginación utiliza el conteo filtrado', (tester) async {
      final requests = <CatalogPageRequest>[];

      await pumpCatalog(
        tester,
        pokemon: largeCatalog(),
        pageRequests: requests,
      );

      await showFilters(tester);

      await selectType(tester, catalogL10n(tester).pokemonTypeElectric);

      await goToSecondPage(tester);

      expect(requests.last.page, 1);
      expect(requests.last.query.type, 'electric');

      expect(visiblePokemonIds(tester).first, 101);

      await scrollToPagination(tester);

      final nextButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_right),
      );

      expect(nextButton.onPressed, isNull);
    });

    testWidgets('cambiar de página conserva los filtros activos', (
      tester,
    ) async {
      final requests = <CatalogPageRequest>[];

      await pumpCatalog(
        tester,
        pokemon: largeCatalog(),
        pageRequests: requests,
      );

      await showFilters(tester);
      await searchFor(tester, 'pokemon');

      await selectType(tester, catalogL10n(tester).pokemonTypeElectric);

      await selectSort(tester, catalogL10n(tester).catalogSortNumberDesc);

      await goToSecondPage(tester);

      expect(requests.last.page, 1);

      expect(
        requests.last.query,
        const CatalogQuery(
          search: 'pokemon',
          type: 'electric',
          sort: CatalogSort.numberDescending,
        ),
      );

      expect(visiblePokemonIds(tester).first, 19);
    });

    testWidgets('la paginación desaparece si el filtro deja una sola página', (
      tester,
    ) async {
      await pumpCatalog(tester, pokemon: largeCatalog());
      await showFilters(tester);

      await searchFor(tester, '25');

      expect(visiblePokemonIds(tester), [25]);

      expect(find.byTooltip(catalogL10n(tester).nextPage), findsNothing);
    });
  });

  group('localización de los filtros del catálogo', () {
    for (final language in ['es', 'en']) {
      testWidgets('muestra los controles de búsqueda en $language', (
        tester,
      ) async {
        await pumpCatalog(
          tester,
          pokemon: testCatalog,
          locale: Locale(language),
        );

        final l10n = catalogL10n(tester);

        expect(find.byTooltip(l10n.catalogShowSearch), findsOneWidget);

        await showFilters(tester);

        final searchField = tester.widget<TextField>(find.byType(TextField));

        expect(searchField.decoration!.hintText, l10n.catalogSearchHint);

        expect(find.text(l10n.catalogTypeFilter), findsOneWidget);
        expect(find.text(l10n.catalogSortBy), findsOneWidget);
        expect(find.text(l10n.catalogAllTypes), findsOneWidget);
        expect(find.text(l10n.catalogSortNumberAsc), findsOneWidget);

        expect(find.byTooltip(l10n.catalogHideSearch), findsOneWidget);
      });

      testWidgets('muestra el estado sin resultados en $language', (
        tester,
      ) async {
        await pumpCatalog(
          tester,
          pokemon: testCatalog,
          locale: Locale(language),
        );

        await showFilters(tester);
        await searchFor(tester, 'inexistente');

        final l10n = catalogL10n(tester);

        expect(find.text(l10n.catalogNoResults), findsOneWidget);
        expect(find.text(l10n.catalogNoResultsMessage), findsOneWidget);
        expect(find.text(l10n.catalogClearFilters), findsOneWidget);
      });

      testWidgets('permite seleccionar un tipo localizado en $language', (
        tester,
      ) async {
        final requests = <CatalogPageRequest>[];

        await pumpCatalog(
          tester,
          pokemon: testCatalog,
          locale: Locale(language),
          pageRequests: requests,
        );

        await showFilters(tester);

        await selectType(tester, catalogL10n(tester).pokemonTypeElectric);

        expect(requests.last.query.type, 'electric');
        expect(visiblePokemonIds(tester), [25, 26]);
      });
    }
  });

  testWidgets('los filtros caben en un teléfono estrecho', (tester) async {
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(360 * 3, 740 * 3);

    addTearDown(tester.view.reset);

    await pumpCatalog(tester, pokemon: testCatalog);
    await showFilters(tester);

    expect(find.byType(TextField), findsOneWidget);
    expect(typeDropdown(), findsOneWidget);
    expect(sortDropdown(), findsOneWidget);

    final typeRect = tester.getRect(typeDropdown());
    final sortRect = tester.getRect(sortDropdown());

    expect(typeRect.left, greaterThanOrEqualTo(0));
    expect(sortRect.right, lessThanOrEqualTo(360));

    expect(tester.takeException(), isNull);
  });
}
