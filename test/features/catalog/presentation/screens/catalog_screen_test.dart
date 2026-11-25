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

import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_query_providers.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query_state.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_progress.dart';

import '../../fakes/fake_catalog_query_repository.dart';
import '../../../favorites/fakes/fake_favorites_repository.dart';
import '../../fakes/fake_sync_catalog.dart';

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

  const cyndaquil = Pokemon(
    id: 155,
    name: 'cyndaquil',
    imageUrl: '',
    typeNames: ['fire'],
  );

  const totodile = Pokemon(
    id: 158,
    name: 'totodile',
    imageUrl: '',
    typeNames: ['water'],
  );

  const torchic = Pokemon(
    id: 255,
    name: 'torchic',
    imageUrl: '',
    typeNames: ['fire'],
  );

  const multiGenerationCatalog = [...testCatalog, cyndaquil, totodile, torchic];

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
              : item.name.toLowerCase().startsWith(search));

      final matchesType =
          query.types.isEmpty || item.typeNames.any(query.types.contains);

      final generation = switch (item.id) {
        <= 151 => 1,
        <= 251 => 2,
        <= 386 => 3,
        <= 493 => 4,
        <= 649 => 5,
        <= 721 => 6,
        <= 809 => 7,
        <= 905 => 8,
        <= 1025 => 9,
        _ => 0,
      };

      final matchesGeneration =
          query.generations.isEmpty || query.generations.contains(generation);

      return matchesSearch && matchesType && matchesGeneration;
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
    Stream<CatalogProgress>? progressUpdates,
    List<CatalogPageRequest>? pageRequests,
    List<CatalogQuery>? countRequests,
    FakeCatalogQueryRepository? queryRepository,
    FakeSyncCatalog? syncCatalog,
    Stream<List<Pokemon>>? pokemonUpdates,
  }) {
    return [
      catalogQueryRepositoryProvider.overrideWithValue(
        queryRepository ?? FakeCatalogQueryRepository(),
      ),

      syncCatalogProvider.overrideWithValue(syncCatalog ?? FakeSyncCatalog()),

      catalogProgressProvider.overrideWith(
        (ref) =>
            progressUpdates ??
            Stream.value(
              CatalogProgress(
                savedCount: pokemon.length,
                totalCount: pokemon.length,
                isComplete: true,
              ),
            ),
      ),

      filteredCatalogPageProvider.overrideWith((ref, request) {
        pageRequests?.add(request);

        List<Pokemon> pageOf(List<Pokemon> items) {
          final filtered = applyQuery(items, request.query);
          final offset = request.page * request.pageSize;

          return filtered.skip(offset).take(request.pageSize).toList();
        }

        if (pokemonUpdates != null) {
          return pokemonUpdates.map(pageOf);
        }

        return Stream.value(pageOf(pokemon));
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
    Stream<CatalogProgress>? progressUpdates,
    List<CatalogPageRequest>? pageRequests,
    List<CatalogQuery>? countRequests,
    FakeCatalogQueryRepository? queryRepository,
    FakeSyncCatalog? syncCatalog,
    Stream<SyncStatus>? syncStatuses,
    Stream<List<Pokemon>>? pokemonUpdates,
    Stream<int>? counts,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: catalogOverrides(
          pokemon,
          syncStatuses: syncStatuses ?? Stream.value(syncStatus),
          progressUpdates: progressUpdates,
          pageRequests: pageRequests,
          countRequests: countRequests,
          queryRepository: queryRepository,
          syncCatalog: syncCatalog,
          pokemonUpdates: pokemonUpdates,
          counts: counts,
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
    await tester.pump();
  }

  AppLocalizations catalogL10n(WidgetTester tester) {
    return AppLocalizations.of(tester.element(find.byType(CatalogScreen)))!;
  }

  Future<void> scrollToPagination(WidgetTester tester) async {
    final paginationFinder = find.byTooltip(catalogL10n(tester).nextPage);

    final catalogList = find.byKey(const ValueKey('catalog-pokemon-list'));

    final catalogScrollable = find.descendant(
      of: catalogList,
      matching: find.byType(Scrollable),
    );

    await tester.scrollUntilVisible(
      paginationFinder,
      400,
      scrollable: catalogScrollable,
      maxScrolls: 100,
    );

    await tester.ensureVisible(paginationFinder);
    await tester.pumpAndSettle();
  }

  Finder typeDropdown() {
    return find.byKey(const ValueKey('catalog-types-selector'));
  }

  Finder generationSelector() {
    return find.byKey(const ValueKey('catalog-generations-selector'));
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
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
  }

  Future<void> selectType(WidgetTester tester, String label) async {
    final l10n = catalogL10n(tester);

    await tester.tap(typeDropdown());
    await tester.pumpAndSettle();

    final clearButton = find.byKey(const ValueKey('catalog-selection-clear'));

    final clearWidget = tester.widget<TextButton>(clearButton);

    if (clearWidget.onPressed != null) {
      await tester.tap(clearButton);
      await tester.pumpAndSettle();
    }

    if (label != l10n.catalogAllTypes) {
      final option = find.widgetWithText(CheckboxListTile, label);

      await tester.ensureVisible(option);
      await tester.tap(option);
      await tester.pumpAndSettle();
    }

    await tester.tap(find.byKey(const ValueKey('catalog-selection-apply')));

    await tester.pumpAndSettle();
  }

  Future<void> selectMultiple<T>(
    WidgetTester tester, {
    required Finder selector,
    required Set<T> values,
  }) async {
    await tester.tap(selector);
    await tester.pumpAndSettle();

    final clearButton = find.byKey(const ValueKey('catalog-selection-clear'));

    if (tester.widget<TextButton>(clearButton).onPressed != null) {
      await tester.tap(clearButton);
      await tester.pumpAndSettle();
    }

    for (final value in values) {
      final option = find.byKey(ValueKey('catalog-option-$value'));

      await tester.ensureVisible(option);
      await tester.tap(option);
      await tester.pumpAndSettle();
    }

    await tester.tap(find.byKey(const ValueKey('catalog-selection-apply')));

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

  Finder refreshIndicator() {
    return find.byKey(const ValueKey('catalog-refresh-indicator'));
  }

  Finder refreshProgressIndicator() {
    return find.descendant(
      of: refreshIndicator(),
      matching: find.byType(RefreshProgressIndicator),
    );
  }

  Finder catalogList() {
    return find.byKey(const ValueKey('catalog-pokemon-list'));
  }

  Finder catalogScrollableState() {
    return find.byKey(const ValueKey('catalog-scrollable-state'));
  }

  Future<void> pullToRefresh(WidgetTester tester, {Finder? target}) async {
    final scrollTarget = target ?? catalogList();

    expect(scrollTarget, findsOneWidget);

    await tester.drag(scrollTarget, const Offset(0, 500));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
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

      await tester.pump();
      await tester.pump();
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

    await tester.pump();
    await tester.pump();
    countController.add(51);

    await tester.pump();
    await tester.pump();
    await tester.pump();

    await scrollToPagination(tester);

    await tester.tap(find.byTooltip('Página siguiente'));
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text('#0051'), findsOneWidget);

    countController.add(25);

    await tester.pump();
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
      expect(requests.single.query, CatalogQuery());
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
      expect(filterBar.selectedTypes, isEmpty);
      expect(filterBar.selectedGenerations, isEmpty);
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

    testWidgets('permite buscar por el prefijo del nombre', (tester) async {
      await pumpCatalog(tester, pokemon: testCatalog);
      await showFilters(tester);

      await searchFor(tester, 'pika');

      expect(visiblePokemonIds(tester), [25]);
    });

    testWidgets('no muestra coincidencias internas del nombre', (tester) async {
      await pumpCatalog(tester, pokemon: testCatalog);
      await showFilters(tester);
      await searchFor(tester, 'chu');
      expect(visiblePokemonIds(tester), isEmpty);
      expect(find.text(catalogL10n(tester).catalogNoResults), findsOneWidget);
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
      await searchFor(tester, 'pika');

      expect(pageRequests.last.query, countRequests.last);
      expect(countRequests.last.search, 'pika');
      expect(pageRequests.last.page, 0);
      expect(pageRequests.last.pageSize, 50);
    });
  });

  group('debounce de búsqueda del catálogo', () {
    testWidgets('no aplica la búsqueda antes de 400 milisegundos', (
      tester,
    ) async {
      final requests = <CatalogPageRequest>[];

      await pumpCatalog(tester, pokemon: testCatalog, pageRequests: requests);

      await showFilters(tester);

      await tester.enterText(find.byType(TextField), 'pikachu');
      await tester.pump(const Duration(milliseconds: 399));

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
      await tester.pump(const Duration(milliseconds: 399));

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

      await tester.pump(const Duration(milliseconds: 400));
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
      expect(requests.last.query.types, {'electric'});
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

      expect(requests.last.query.types, isEmpty);
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

    testWidgets(
      'el selector contiene los 18 tipos y permite limpiar la selección',
      (tester) async {
        await pumpCatalog(tester, pokemon: testCatalog);
        await showFilters(tester);

        await tester.tap(typeDropdown());
        await tester.pumpAndSettle();

        expect(find.byType(CheckboxListTile), findsNWidgets(18));

        for (final type in CatalogFilterBar.types) {
          expect(find.byKey(ValueKey('catalog-option-$type')), findsOneWidget);
        }

        expect(
          find.byKey(const ValueKey('catalog-selection-clear')),
          findsOneWidget,
        );

        await tester.tap(
          find.byKey(const ValueKey('catalog-selection-cancel')),
        );

        await tester.pumpAndSettle();
      },
    );
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
      await searchFor(tester, 'pika');

      await selectType(tester, catalogL10n(tester).pokemonTypeElectric);

      expect(visiblePokemonIds(tester), [25]);

      expect(
        requests.last.query,
        CatalogQuery(search: 'pika', types: {'electric'}),
      );
    });

    testWidgets('combina búsqueda, tipo y ordenamiento', (tester) async {
      final requests = <CatalogPageRequest>[];

      await pumpCatalog(tester, pokemon: testCatalog, pageRequests: requests);

      await showFilters(tester);
      await searchFor(tester, 'pika');

      await selectType(tester, catalogL10n(tester).pokemonTypeElectric);

      await selectSort(tester, catalogL10n(tester).catalogSortNumberDesc);

      expect(visiblePokemonIds(tester), [25]);

      expect(
        requests.last.query,
        CatalogQuery(
          search: 'pika',
          types: {'electric'},
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
      await searchFor(tester, 'pika');

      await selectType(tester, catalogL10n(tester).pokemonTypeElectric);

      await selectType(tester, catalogL10n(tester).catalogAllTypes);

      expect(requests.last.query.search, 'pika');
      expect(requests.last.query.types, isEmpty);
      expect(visiblePokemonIds(tester), [25]);
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
      await searchFor(tester, 'pika');

      await selectType(tester, catalogL10n(tester).pokemonTypeElectric);

      await selectSort(tester, catalogL10n(tester).catalogSortNumberDesc);

      await hideFilters(tester);
      await showFilters(tester);

      final filterBar = tester.widget<CatalogFilterBar>(
        find.byType(CatalogFilterBar),
      );

      expect(filterBar.searchController.text, 'pika');
      expect(filterBar.selectedTypes, {'electric'});
      expect(filterBar.selectedSort, CatalogSort.numberDescending);

      expect(visiblePokemonIds(tester), [25]);
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

      expect(requests.last.query, CatalogQuery());
      expect(requests.last.page, 0);

      final filterBar = tester.widget<CatalogFilterBar>(
        find.byType(CatalogFilterBar),
      );

      expect(filterBar.searchController.text, isEmpty);
      expect(filterBar.selectedTypes, isEmpty);
      expect(filterBar.selectedGenerations, isEmpty);
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

      expect(requests.last.query, CatalogQuery());

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

      expect(requests.last.query, CatalogQuery());
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
      expect(requests.last.query.types, {'electric'});
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
      expect(requests.last.query.types, {'electric'});

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
        CatalogQuery(
          search: 'pokemon',
          types: {'electric'},
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

        expect(requests.last.query.types, {'electric'});
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
    expect(generationSelector(), findsOneWidget);

    final generationRect = tester.getRect(generationSelector());

    expect(generationRect.right, lessThanOrEqualTo(360));

    expect(generationRect.left, greaterThanOrEqualTo(0));
  });
  group('selección múltiple de filtros', () {
    testWidgets('permite seleccionar múltiples tipos', (tester) async {
      final requests = <CatalogPageRequest>[];

      await pumpCatalog(tester, pokemon: testCatalog, pageRequests: requests);

      await showFilters(tester);

      await selectMultiple<String>(
        tester,
        selector: typeDropdown(),
        values: {'fire', 'water'},
      );

      expect(visiblePokemonIds(tester), [4, 7, 37]);

      expect(requests.last.query.types, {'fire', 'water'});
    });

    testWidgets('no duplica Pokémon con dos tipos seleccionados', (
      tester,
    ) async {
      await pumpCatalog(tester, pokemon: testCatalog);
      await showFilters(tester);

      await selectMultiple<String>(
        tester,
        selector: typeDropdown(),
        values: {'grass', 'poison'},
      );

      expect(visiblePokemonIds(tester), [1]);
    });

    testWidgets('permite seleccionar una generación', (tester) async {
      await pumpCatalog(tester, pokemon: multiGenerationCatalog);

      await showFilters(tester);

      await selectMultiple<int>(
        tester,
        selector: generationSelector(),
        values: {2},
      );

      expect(visiblePokemonIds(tester), [155, 158]);
    });

    testWidgets('permite seleccionar múltiples generaciones', (tester) async {
      final requests = <CatalogPageRequest>[];

      await pumpCatalog(
        tester,
        pokemon: multiGenerationCatalog,
        pageRequests: requests,
      );

      await showFilters(tester);

      await selectMultiple<int>(
        tester,
        selector: generationSelector(),
        values: {2, 3},
      );

      expect(visiblePokemonIds(tester), [155, 158, 255]);
      expect(requests.last.query.generations, {2, 3});
    });

    testWidgets('combina múltiples tipos y generaciones', (tester) async {
      final requests = <CatalogPageRequest>[];

      await pumpCatalog(
        tester,
        pokemon: multiGenerationCatalog,
        pageRequests: requests,
      );

      await showFilters(tester);

      await selectMultiple<String>(
        tester,
        selector: typeDropdown(),
        values: {'fire', 'water'},
      );

      await selectMultiple<int>(
        tester,
        selector: generationSelector(),
        values: {2, 3},
      );

      expect(visiblePokemonIds(tester), [155, 158, 255]);

      expect(requests.last.query.types, {'fire', 'water'});
      expect(requests.last.query.generations, {2, 3});
    });

    testWidgets('cancelar el diálogo no modifica la consulta', (tester) async {
      final requests = <CatalogPageRequest>[];

      await pumpCatalog(tester, pokemon: testCatalog, pageRequests: requests);

      await showFilters(tester);

      await tester.tap(typeDropdown());
      await tester.pumpAndSettle();

      final option = find.byKey(const ValueKey('catalog-option-fire'));

      await tester.ensureVisible(option);
      await tester.tap(option);
      await tester.pumpAndSettle();

      expect(requests, hasLength(1));

      await tester.tap(find.byKey(const ValueKey('catalog-selection-cancel')));

      await tester.pumpAndSettle();

      expect(requests, hasLength(1));
      expect(requests.last.query.types, isEmpty);
    });

    testWidgets('aplicar sin cambios no genera otra consulta', (tester) async {
      final requests = <CatalogPageRequest>[];

      await pumpCatalog(tester, pokemon: testCatalog, pageRequests: requests);

      await showFilters(tester);

      await tester.tap(typeDropdown());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('catalog-selection-apply')));

      await tester.pumpAndSettle();

      expect(requests, hasLength(1));
    });

    testWidgets('el selector contiene las nueve generaciones', (tester) async {
      await pumpCatalog(tester, pokemon: testCatalog);
      await showFilters(tester);

      await tester.tap(generationSelector());
      await tester.pumpAndSettle();

      expect(find.byType(CheckboxListTile), findsNWidgets(9));

      for (var generation = 1; generation <= 9; generation++) {
        expect(
          find.byKey(ValueKey('catalog-option-$generation')),
          findsOneWidget,
        );
      }

      await tester.tap(find.byKey(const ValueKey('catalog-selection-cancel')));

      await tester.pumpAndSettle();
    });

    testWidgets('una generación sin coincidencias muestra el estado vacío', (
      tester,
    ) async {
      await pumpCatalog(tester, pokemon: multiGenerationCatalog);

      await showFilters(tester);

      await selectMultiple<int>(
        tester,
        selector: generationSelector(),
        values: {9},
      );

      expect(find.byType(PokemonListItem), findsNothing);

      expect(find.text(catalogL10n(tester).catalogNoResults), findsOneWidget);
    });

    testWidgets('limpiar filtros elimina tipos y generaciones', (tester) async {
      final requests = <CatalogPageRequest>[];

      await pumpCatalog(
        tester,
        pokemon: multiGenerationCatalog,
        pageRequests: requests,
      );

      await showFilters(tester);

      await selectMultiple<String>(
        tester,
        selector: typeDropdown(),
        values: {'electric'},
      );

      await selectMultiple<int>(
        tester,
        selector: generationSelector(),
        values: {3},
      );

      await tester.tap(find.text(catalogL10n(tester).catalogClearFilters));

      await tester.pumpAndSettle();

      expect(requests.last.query, CatalogQuery());
      expect(requests.last.page, 0);

      final filterBar = tester.widget<CatalogFilterBar>(
        find.byType(CatalogFilterBar),
      );

      expect(filterBar.selectedTypes, isEmpty);
      expect(filterBar.selectedGenerations, isEmpty);
      expect(filterBar.selectedSort, CatalogSort.numberAscending);
    });
  });
  group('comportamiento avanzado de filtros múltiples', () {
    Finder option(Object value) =>
        find.byKey(ValueKey('catalog-option-$value'));
    Finder action(String name) =>
        find.byKey(ValueKey('catalog-selection-$name'));

    Future<void> open(WidgetTester tester, Finder selector) async {
      await tester.tap(selector);
      await tester.pumpAndSettle();
    }

    Future<void> toggle(WidgetTester tester, Object value) async {
      await tester.ensureVisible(option(value));
      await tester.tap(option(value));
      await tester.pumpAndSettle();
    }

    Future<void> finish(WidgetTester tester, String name) async {
      await tester.tap(action(name));
      await tester.pumpAndSettle();
    }

    for (final category in ['types', 'generations']) {
      final isType = category == 'types';
      Finder selector() => isType ? typeDropdown() : generationSelector();
      final Object first = isType ? 'fire' : 1;
      final Object second = isType ? 'water' : 2;

      testWidgets('$category: contador y selección provisional', (
        tester,
      ) async {
        final requests = <CatalogPageRequest>[];
        await pumpCatalog(
          tester,
          pokemon: multiGenerationCatalog,
          pageRequests: requests,
        );
        await showFilters(tester);
        await open(tester, selector());
        final l10n = catalogL10n(tester);
        expect(find.text(l10n.catalogSelectedCount(0)), findsOneWidget);
        await toggle(tester, first);
        await toggle(tester, second);
        expect(find.text(l10n.catalogSelectedCount(2)), findsOneWidget);
        expect(requests, hasLength(1));
        await toggle(tester, first);
        expect(find.text(l10n.catalogSelectedCount(1)), findsOneWidget);
        await finish(tester, 'apply');
        expect(
          isType ? requests.last.query.types : requests.last.query.generations,
          {second},
        );
      });

      testWidgets(
        '$category: reabrir conserva las casillas y cancelar conserva la consulta',
        (tester) async {
          final requests = <CatalogPageRequest>[];
          await pumpCatalog(
            tester,
            pokemon: multiGenerationCatalog,
            pageRequests: requests,
          );
          await showFilters(tester);
          await open(tester, selector());
          await toggle(tester, first);
          await finish(tester, 'apply');
          final previous = requests.last;
          final count = requests.length;
          await open(tester, selector());
          expect(tester.widget<CheckboxListTile>(option(first)).value, isTrue);
          expect(
            tester.widget<CheckboxListTile>(option(second)).value,
            isFalse,
          );
          await toggle(tester, first);
          await toggle(tester, second);
          await finish(tester, 'cancel');
          expect(requests.length, count);
          expect(requests.last, previous);
        },
      );

      testWidgets('$category: limpiar es provisional hasta aplicar', (
        tester,
      ) async {
        final requests = <CatalogPageRequest>[];
        await pumpCatalog(
          tester,
          pokemon: multiGenerationCatalog,
          pageRequests: requests,
        );
        await showFilters(tester);
        await open(tester, selector());
        expect(tester.widget<TextButton>(action('clear')).onPressed, isNull);
        await toggle(tester, first);
        await toggle(tester, second);
        await finish(tester, 'apply');
        final previous = requests.last;
        await open(tester, selector());
        await finish(tester, 'clear');
        expect(tester.widget<CheckboxListTile>(option(first)).value, isFalse);
        expect(tester.widget<CheckboxListTile>(option(second)).value, isFalse);
        expect(requests.last, previous);
        await finish(tester, 'apply');
        expect(
          isType ? requests.last.query.types : requests.last.query.generations,
          isEmpty,
        );
      });
    }

    testWidgets('eliminar un chip de tipo conserva los demás filtros', (
      tester,
    ) async {
      final requests = <CatalogPageRequest>[];
      await pumpCatalog(
        tester,
        pokemon: multiGenerationCatalog,
        pageRequests: requests,
      );
      await showFilters(tester);
      await selectMultiple<String>(
        tester,
        selector: typeDropdown(),
        values: {'fire', 'water'},
      );
      await selectMultiple<int>(
        tester,
        selector: generationSelector(),
        values: {2},
      );
      final chip = find.widgetWithText(
        InputChip,
        catalogL10n(tester).pokemonTypeFire,
      );
      expect(chip, findsOneWidget);
      await tester.tap(
        find.descendant(
          of: chip,
          matching: find.byTooltip(
            MaterialLocalizations.of(tester.element(chip)).deleteButtonTooltip,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(requests.last.query.types, {'water'});
      expect(requests.last.query.generations, {2});
      expect(visiblePokemonIds(tester), [158]);
    });

    testWidgets('eliminar un chip de generación conserva los tipos', (
      tester,
    ) async {
      final requests = <CatalogPageRequest>[];
      await pumpCatalog(
        tester,
        pokemon: multiGenerationCatalog,
        pageRequests: requests,
      );
      await showFilters(tester);
      await selectMultiple<String>(
        tester,
        selector: typeDropdown(),
        values: {'fire'},
      );
      await selectMultiple<int>(
        tester,
        selector: generationSelector(),
        values: {2, 3},
      );
      final chip = find.widgetWithText(
        InputChip,
        catalogL10n(tester).catalogGenerationLabel('II'),
      );
      await tester.ensureVisible(chip);
      await tester.tap(
        find.descendant(
          of: chip,
          matching: find.byTooltip(
            MaterialLocalizations.of(tester.element(chip)).deleteButtonTooltip,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(requests.last.query.types, {'fire'});
      expect(requests.last.query.generations, {3});
      expect(visiblePokemonIds(tester), [255]);
    });

    testWidgets('ocultar y mostrar conserva ambos conjuntos', (tester) async {
      await pumpCatalog(tester, pokemon: multiGenerationCatalog);
      await showFilters(tester);
      await selectMultiple<String>(
        tester,
        selector: typeDropdown(),
        values: {'fire', 'water'},
      );
      await selectMultiple<int>(
        tester,
        selector: generationSelector(),
        values: {2, 3},
      );
      await hideFilters(tester);
      await showFilters(tester);
      final bar = tester.widget<CatalogFilterBar>(
        find.byType(CatalogFilterBar),
      );
      expect(bar.selectedTypes, {'fire', 'water'});
      expect(bar.selectedGenerations, {2, 3});
      expect(visiblePokemonIds(tester), [155, 158, 255]);
    });

    testWidgets('combina búsqueda, tipos, generaciones y orden', (
      tester,
    ) async {
      final requests = <CatalogPageRequest>[];
      await pumpCatalog(
        tester,
        pokemon: multiGenerationCatalog,
        pageRequests: requests,
      );
      await showFilters(tester);
      await selectMultiple<String>(
        tester,
        selector: typeDropdown(),
        values: {'fire', 'water'},
      );
      await selectMultiple<int>(
        tester,
        selector: generationSelector(),
        values: {2, 3},
      );
      await searchFor(tester, 't');
      await selectSort(tester, catalogL10n(tester).catalogSortNumberDesc);
      expect(
        requests.last.query,
        CatalogQuery(
          search: 't',
          types: {'fire', 'water'},
          generations: {2, 3},
          sort: CatalogSort.numberDescending,
        ),
      );
      expect(visiblePokemonIds(tester), [255, 158]);
    });

    testWidgets('cambiar generaciones restablece la página inicial', (
      tester,
    ) async {
      final requests = <CatalogPageRequest>[];
      final pokemon = List.generate(
        160,
        (i) => Pokemon(
          id: i + 1,
          name: 'pokemon${i + 1}',
          imageUrl: '',
          typeNames: const ['fire'],
        ),
      );
      await pumpCatalog(tester, pokemon: pokemon, pageRequests: requests);
      await scrollToPagination(tester);
      await tester.tap(find.byTooltip(catalogL10n(tester).nextPage));
      await tester.pumpAndSettle();
      expect(requests.last.page, 1);
      await showFilters(tester);
      await selectMultiple<int>(
        tester,
        selector: generationSelector(),
        values: {2},
      );
      expect(requests.last.page, 0);
      expect(requests.last.query.generations, {2});
      expect(visiblePokemonIds(tester).first, 152);
    });

    for (final language in ['es', 'en']) {
      testWidgets('diálogos de selección localizados en $language', (
        tester,
      ) async {
        await pumpCatalog(
          tester,
          pokemon: multiGenerationCatalog,
          locale: Locale(language),
        );
        await showFilters(tester);
        final l10n = catalogL10n(tester);
        expect(find.text(l10n.catalogGenerationFilter), findsOneWidget);
        await open(tester, generationSelector());
        expect(find.text(l10n.catalogSelectGenerations), findsOneWidget);
        expect(find.text(l10n.catalogGenerationLabel('IX')), findsOneWidget);
        expect(find.text(l10n.catalogApplySelection), findsOneWidget);
        expect(find.text(l10n.catalogCancelSelection), findsOneWidget);
        expect(find.text(l10n.catalogClearSelection), findsOneWidget);
        await finish(tester, 'cancel');
        await open(tester, typeDropdown());
        expect(find.text(l10n.catalogSelectTypes), findsOneWidget);
        expect(
          find.widgetWithText(CheckboxListTile, l10n.pokemonTypeFire),
          findsOneWidget,
        );
        await finish(tester, 'cancel');
      });
    }

    testWidgets('muchos filtros activos caben en teléfono estrecho', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = const Size(360 * 3, 740 * 3);
      addTearDown(tester.view.reset);
      await pumpCatalog(tester, pokemon: multiGenerationCatalog);
      await showFilters(tester);
      await selectMultiple<String>(
        tester,
        selector: typeDropdown(),
        values: CatalogFilterBar.types.toSet(),
      );
      await selectMultiple<int>(
        tester,
        selector: generationSelector(),
        values: CatalogFilterBar.generations.toSet(),
      );
      final bar = tester.widget<CatalogFilterBar>(
        find.byType(CatalogFilterBar),
      );
      expect(bar.selectedTypes, hasLength(18));
      expect(bar.selectedGenerations, hasLength(9));
      expect(tester.takeException(), isNull);
    });
  });

  group('persistencia de consulta', () {
    testWidgets('restaura todos los criterios antes de consultar', (
      tester,
    ) async {
      final initial = CatalogQueryState(
        query: CatalogQuery(
          search: 'pika',
          types: {'electric'},
          generations: {1},
          sort: CatalogSort.numberDescending,
        ),
      );
      final repository = FakeCatalogQueryRepository(initialState: initial);
      final requests = <CatalogPageRequest>[];
      await pumpCatalog(
        tester,
        pokemon: testCatalog,
        queryRepository: repository,
        pageRequests: requests,
      );
      await tester.pumpAndSettle();
      expect(requests.single.query, initial.query);
      expect(visiblePokemonIds(tester), [25]);
      await showFilters(tester);
      final bar = tester.widget<CatalogFilterBar>(
        find.byType(CatalogFilterBar),
      );
      expect(bar.searchController.text, 'pika');
      expect(bar.selectedTypes, {'electric'});
      expect(bar.selectedGenerations, {1});
      expect(bar.selectedSort, CatalogSort.numberDescending);
      expect(repository.saveCalls, 0);
    });
    testWidgets('guarda criterios y los restaura en un nuevo scope', (
      tester,
    ) async {
      final repository = FakeCatalogQueryRepository();
      await pumpCatalog(
        tester,
        pokemon: testCatalog,
        queryRepository: repository,
      );
      await showFilters(tester);
      await searchFor(tester, 'pika');
      await selectType(tester, catalogL10n(tester).pokemonTypeElectric);
      await selectMultiple<int>(
        tester,
        selector: generationSelector(),
        values: {1},
      );
      await selectSort(tester, catalogL10n(tester).catalogSortNumberDesc);
      final saved = repository.storedState!;
      expect(
        saved.query,
        CatalogQuery(
          search: 'pika',
          types: {'electric'},
          generations: {1},
          sort: CatalogSort.numberDescending,
        ),
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await pumpCatalog(
        tester,
        pokemon: testCatalog,
        queryRepository: repository,
      );
      await tester.pumpAndSettle();
      expect(visiblePokemonIds(tester), [25]);
      expect(repository.loadCalls, 2);
    });
    testWidgets('restaura una segunda pagina', (tester) async {
      final repository = FakeCatalogQueryRepository(
        initialState: CatalogQueryState(query: CatalogQuery(), page: 1),
      );
      final pokemon = List.generate(
        51,
        (i) => Pokemon(
          id: i + 1,
          name: 'pokemon${i + 1}',
          imageUrl: '',
          typeNames: const ['normal'],
        ),
      );
      await pumpCatalog(tester, pokemon: pokemon, queryRepository: repository);
      await tester.pumpAndSettle();
      expect(visiblePokemonIds(tester), [51]);
      expect(repository.saveCalls, 0);
    });
    testWidgets('corrige y guarda una pagina inexistente', (tester) async {
      final repository = FakeCatalogQueryRepository(
        initialState: CatalogQueryState(query: CatalogQuery(), page: 9),
      );
      await pumpCatalog(
        tester,
        pokemon: testCatalog,
        queryRepository: repository,
      );
      await tester.pumpAndSettle();
      expect(repository.storedState!.page, 0);
      expect(find.text('Bulbasaur'), findsOneWidget);
    });
    testWidgets('limpiar filtros guarda estado inicial', (tester) async {
      final repository = FakeCatalogQueryRepository(
        initialState: CatalogQueryState(
          query: CatalogQuery(search: 'inexistente'),
        ),
      );
      await pumpCatalog(
        tester,
        pokemon: testCatalog,
        queryRepository: repository,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(catalogL10n(tester).catalogClearFilters));
      await tester.pumpAndSettle();
      expect(repository.storedState, CatalogQueryState.initial());
    });
  });
  group('aviso de catálogo parcial', () {
    const noticeKey = ValueKey('catalog-partial-notice');

    const partialProgress = CatalogProgress(
      savedCount: 6,
      totalCount: 1025,
      isComplete: false,
    );

    Finder partialNotice() => find.byKey(noticeKey);

    testWidgets('muestra el aviso junto al catálogo local', (tester) async {
      await pumpCatalog(
        tester,
        pokemon: testCatalog,
        progressUpdates: Stream.value(partialProgress),
      );

      expect(partialNotice(), findsOneWidget);
      expect(find.byType(PokemonListItem), findsWidgets);

      expect(
        find.text(catalogL10n(tester).catalogPartialNotice(6, 1025)),
        findsOneWidget,
      );
    });

    testWidgets('no muestra el aviso si el catálogo está completo', (
      tester,
    ) async {
      await pumpCatalog(
        tester,
        pokemon: testCatalog,
        progressUpdates: Stream.value(
          const CatalogProgress(savedCount: 6, totalCount: 6, isComplete: true),
        ),
      );

      expect(partialNotice(), findsNothing);
      expect(find.byType(PokemonListItem), findsWidgets);
    });

    testWidgets('muestra el aviso con total desconocido', (tester) async {
      await pumpCatalog(
        tester,
        pokemon: testCatalog,
        progressUpdates: Stream.value(
          const CatalogProgress(savedCount: 6, isComplete: false),
        ),
      );

      expect(
        find.text(catalogL10n(tester).catalogPartialNoticeUnknownTotal(6)),
        findsOneWidget,
      );
    });

    testWidgets('muestra el aviso cuando el catálogo local está vacío', (
      tester,
    ) async {
      await pumpCatalog(
        tester,
        pokemon: const [],
        progressUpdates: Stream.value(
          const CatalogProgress(
            savedCount: 0,
            totalCount: 1025,
            isComplete: false,
          ),
        ),
      );

      expect(partialNotice(), findsOneWidget);
      expect(find.byType(PokemonListItem), findsNothing);

      expect(
        find.text(catalogL10n(tester).catalogPartialNotice(0, 1025)),
        findsOneWidget,
      );
    });

    testWidgets('conserva el aviso al mostrar y ocultar los filtros', (
      tester,
    ) async {
      await pumpCatalog(
        tester,
        pokemon: testCatalog,
        progressUpdates: Stream.value(partialProgress),
      );

      expect(partialNotice(), findsOneWidget);
      expect(find.byType(CatalogFilterBar), findsNothing);

      await showFilters(tester);

      expect(partialNotice(), findsOneWidget);
      expect(find.byType(CatalogFilterBar), findsOneWidget);

      await hideFilters(tester);

      expect(partialNotice(), findsOneWidget);
      expect(find.byType(CatalogFilterBar), findsNothing);
    });

    testWidgets('el aviso se encuentra antes de los filtros', (tester) async {
      await pumpCatalog(
        tester,
        pokemon: testCatalog,
        progressUpdates: Stream.value(partialProgress),
      );

      await showFilters(tester);

      final noticeRect = tester.getRect(partialNotice());

      final filtersRect = tester.getRect(find.byType(CatalogFilterBar));

      expect(noticeRect.bottom, lessThanOrEqualTo(filtersRect.top));
    });

    testWidgets('la búsqueda no modifica el progreso global', (tester) async {
      await pumpCatalog(
        tester,
        pokemon: testCatalog,
        progressUpdates: Stream.value(partialProgress),
      );

      await showFilters(tester);
      await searchFor(tester, 'pikachu');

      expect(find.byType(PokemonListItem), findsOneWidget);
      expect(find.text('Pikachu'), findsOneWidget);

      expect(
        find.text(catalogL10n(tester).catalogPartialNotice(6, 1025)),
        findsOneWidget,
      );
    });

    testWidgets('conserva el aviso cuando la búsqueda no tiene resultados', (
      tester,
    ) async {
      await pumpCatalog(
        tester,
        pokemon: testCatalog,
        progressUpdates: Stream.value(partialProgress),
      );

      await showFilters(tester);
      await searchFor(tester, 'pokemon-inexistente');

      expect(find.byType(PokemonListItem), findsNothing);

      expect(find.text(catalogL10n(tester).catalogNoResults), findsOneWidget);

      expect(
        find.text(catalogL10n(tester).catalogPartialNotice(6, 1025)),
        findsOneWidget,
      );
    });

    testWidgets('el filtro por tipo no modifica el progreso global', (
      tester,
    ) async {
      await pumpCatalog(
        tester,
        pokemon: testCatalog,
        progressUpdates: Stream.value(partialProgress),
      );

      await showFilters(tester);

      await tester.tap(typeDropdown());
      await tester.pumpAndSettle();

      final electricOption = find.byKey(
        const ValueKey('catalog-option-electric'),
      );

      await tester.ensureVisible(electricOption);
      await tester.tap(electricOption);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('catalog-selection-apply')));

      await tester.pumpAndSettle();

      expect(find.text('Pikachu'), findsOneWidget);
      expect(find.text('Raichu'), findsOneWidget);
      expect(find.byType(PokemonListItem), findsNWidgets(2));

      expect(
        find.text(catalogL10n(tester).catalogPartialNotice(6, 1025)),
        findsOneWidget,
      );
    });

    testWidgets('el filtro por generación no modifica el progreso global', (
      tester,
    ) async {
      await pumpCatalog(
        tester,
        pokemon: multiGenerationCatalog,
        progressUpdates: Stream.value(
          const CatalogProgress(
            savedCount: 9,
            totalCount: 1025,
            isComplete: false,
          ),
        ),
      );

      await showFilters(tester);

      await tester.tap(generationSelector());
      await tester.pumpAndSettle();

      final generationOption = find.byKey(const ValueKey('catalog-option-2'));

      await tester.ensureVisible(generationOption);
      await tester.tap(generationOption);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('catalog-selection-apply')));

      await tester.pumpAndSettle();

      expect(find.text('Cyndaquil'), findsOneWidget);
      expect(find.text('Totodile'), findsOneWidget);
      expect(find.byType(PokemonListItem), findsNWidgets(2));

      expect(
        find.text(catalogL10n(tester).catalogPartialNotice(9, 1025)),
        findsOneWidget,
      );
    });

    testWidgets('la paginación no modifica el progreso global', (tester) async {
      final pokemon = List.generate(
        51,
        (index) => Pokemon(
          id: index + 1,
          name: 'pokemon${index + 1}',
          imageUrl: '',
          typeNames: const ['normal'],
        ),
      );

      await pumpCatalog(
        tester,
        pokemon: pokemon,
        progressUpdates: Stream.value(
          const CatalogProgress(
            savedCount: 51,
            totalCount: 1025,
            isComplete: false,
          ),
        ),
      );

      final message = catalogL10n(tester).catalogPartialNotice(51, 1025);

      expect(find.text(message), findsOneWidget);

      await scrollToPagination(tester);

      expect(find.text(message), findsOneWidget);

      await tester.tap(find.widgetWithIcon(IconButton, Icons.chevron_right));

      await tester.pumpAndSettle();

      expect(find.text('#0051'), findsOneWidget);
      expect(find.byType(PokemonListItem), findsOneWidget);
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('mantiene el aviso cuando falla la sincronización', (
      tester,
    ) async {
      await pumpCatalog(
        tester,
        pokemon: testCatalog,
        syncStatus: const SyncFailed(NoConnection()),
        progressUpdates: Stream.value(partialProgress),
      );

      expect(partialNotice(), findsOneWidget);
      expect(find.byType(PokemonListItem), findsWidgets);

      expect(
        find.text(catalogL10n(tester).catalogPartialNotice(6, 1025)),
        findsOneWidget,
      );
    });

    testWidgets('actualiza el aviso durante la sincronización', (tester) async {
      final controller = StreamController<CatalogProgress>.broadcast();

      addTearDown(controller.close);

      await pumpCatalog(
        tester,
        pokemon: testCatalog,
        syncStatus: const SyncFullPassInProgress(),
        progressUpdates: controller.stream,
      );

      controller.add(partialProgress);

      await tester.pump();
      await tester.pump();

      final l10n = catalogL10n(tester);

      expect(find.text(l10n.catalogPartialNotice(6, 1025)), findsOneWidget);

      controller.add(
        const CatalogProgress(
          savedCount: 100,
          totalCount: 1025,
          isComplete: false,
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.text(l10n.catalogPartialNotice(6, 1025)), findsNothing);

      expect(find.text(l10n.catalogPartialNotice(100, 1025)), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('el aviso desaparece sin abandonar la pantalla', (
      tester,
    ) async {
      final controller = StreamController<CatalogProgress>.broadcast();

      addTearDown(controller.close);

      await pumpCatalog(
        tester,
        pokemon: testCatalog,
        progressUpdates: controller.stream,
      );

      controller.add(partialProgress);

      await tester.pump();
      await tester.pump();

      expect(partialNotice(), findsOneWidget);

      controller.add(
        const CatalogProgress(
          savedCount: 1025,
          totalCount: 1025,
          isComplete: true,
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(partialNotice(), findsNothing);
      expect(find.byType(CatalogScreen), findsOneWidget);
      expect(find.byType(PokemonListItem), findsWidgets);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('actualizar el progreso no vuelve a consultar los filtros', (
      tester,
    ) async {
      final controller = StreamController<CatalogProgress>.broadcast();

      addTearDown(controller.close);

      final pageRequests = <CatalogPageRequest>[];
      final countRequests = <CatalogQuery>[];

      await pumpCatalog(
        tester,
        pokemon: testCatalog,
        progressUpdates: controller.stream,
        pageRequests: pageRequests,
        countRequests: countRequests,
      );

      final initialPageRequests = List.of(pageRequests);
      final initialCountRequests = List.of(countRequests);

      expect(initialPageRequests, isNotEmpty);
      expect(initialCountRequests, isNotEmpty);

      controller.add(partialProgress);

      await tester.pump();
      await tester.pump();

      controller.add(
        const CatalogProgress(
          savedCount: 200,
          totalCount: 1025,
          isComplete: false,
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(partialNotice(), findsOneWidget);

      expect(pageRequests, initialPageRequests);
      expect(countRequests, initialCountRequests);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('muestra el aviso en inglés dentro del catálogo', (
      tester,
    ) async {
      await pumpCatalog(
        tester,
        pokemon: testCatalog,
        locale: const Locale('en'),
        progressUpdates: Stream.value(partialProgress),
      );

      expect(
        find.text(
          'Local catalog: 6 of 1025 Pokémon; '
          'results may be incomplete.',
        ),
        findsOneWidget,
      );
    });
  });
  group('pull-to-refresh: disponibilidad', () {
    testWidgets('existe una unica instancia de RefreshIndicator', (
      tester,
    ) async {
      await pumpCatalog(tester, pokemon: testCatalog);

      expect(find.byType(RefreshIndicator), findsOneWidget);

      expect(refreshIndicator(), findsOneWidget);

      expect(
        find.descendant(of: refreshIndicator(), matching: catalogList()),
        findsOneWidget,
      );
    });

    testWidgets('el listado siempre permite desplazamiento', (tester) async {
      await pumpCatalog(tester, pokemon: [pikachu]);

      final list = tester.widget<ListView>(catalogList());

      expect(list.physics, isA<AlwaysScrollableScrollPhysics>());
    });

    testWidgets('permite actualizar un listado largo', (tester) async {
      final sync = FakeSyncCatalog();

      final pokemon = List.generate(
        50,
        (index) => Pokemon(
          id: index + 1,
          name: 'pokemon${index + 1}',
          imageUrl: '',
          typeNames: const ['normal'],
        ),
      );

      await pumpCatalog(tester, pokemon: pokemon, syncCatalog: sync);

      expect(sync.calls, 0);

      await pullToRefresh(tester);
      await tester.pumpAndSettle();

      expect(sync.calls, 1);
      expect(sync.requests, [true]);

      expect(find.text('#0001'), findsOneWidget);
    });

    testWidgets('permite actualizar cuando solo hay un Pokemon', (
      tester,
    ) async {
      final sync = FakeSyncCatalog();

      await pumpCatalog(tester, pokemon: [pikachu], syncCatalog: sync);

      expect(find.byType(PokemonListItem), findsOneWidget);

      await pullToRefresh(tester);
      await tester.pumpAndSettle();

      expect(sync.requests, [true]);

      expect(find.text('Pikachu'), findsOneWidget);
    });

    testWidgets('permite actualizar el catalogo vacio', (tester) async {
      final sync = FakeSyncCatalog();

      await pumpCatalog(tester, pokemon: [], syncCatalog: sync);

      final l10n = catalogL10n(tester);

      expect(find.text(l10n.catalogEmpty), findsOneWidget);

      expect(catalogScrollableState(), findsOneWidget);

      await pullToRefresh(tester, target: catalogScrollableState());

      await tester.pumpAndSettle();

      expect(sync.requests, [true]);

      expect(find.text(l10n.catalogEmpty), findsOneWidget);
    });

    testWidgets('permite actualizar desde el estado de error', (tester) async {
      final sync = FakeSyncCatalog();

      await pumpCatalog(
        tester,
        pokemon: [],
        syncStatus: const SyncFailed(NoConnection()),
        syncCatalog: sync,
      );

      final l10n = catalogL10n(tester);

      expect(find.text(l10n.catalogLoadError), findsOneWidget);

      await pullToRefresh(tester, target: catalogScrollableState());

      await tester.pumpAndSettle();

      expect(sync.requests, [true]);

      expect(find.text(l10n.retry), findsOneWidget);
    });

    testWidgets('permite actualizar una busqueda sin resultados', (
      tester,
    ) async {
      final sync = FakeSyncCatalog();

      await pumpCatalog(tester, pokemon: testCatalog, syncCatalog: sync);

      await showFilters(tester);
      await searchFor(tester, 'inexistente');

      final l10n = catalogL10n(tester);

      expect(find.text(l10n.catalogNoResults), findsOneWidget);

      await pullToRefresh(tester, target: catalogScrollableState());

      await tester.pumpAndSettle();

      expect(sync.requests, [true]);

      expect(find.text(l10n.catalogNoResults), findsOneWidget);

      final searchField = tester.widget<TextField>(find.byType(TextField));

      expect(searchField.controller?.text, 'inexistente');
    });

    testWidgets('permite actualizar con filtros sin coincidencias', (
      tester,
    ) async {
      final sync = FakeSyncCatalog();

      await pumpCatalog(tester, pokemon: testCatalog, syncCatalog: sync);

      await showFilters(tester);

      await selectMultiple<String>(
        tester,
        selector: typeDropdown(),
        values: {'dragon'},
      );

      final l10n = catalogL10n(tester);

      expect(find.text(l10n.catalogNoResults), findsOneWidget);

      await pullToRefresh(tester, target: catalogScrollableState());

      await tester.pumpAndSettle();

      expect(sync.requests, [true]);

      expect(find.text(l10n.catalogNoResults), findsOneWidget);

      final filterBar = tester.widget<CatalogFilterBar>(
        find.byType(CatalogFilterBar),
      );

      expect(filterBar.selectedTypes, {'dragon'});
    });

    testWidgets('no inicia otra actualizacion durante la carga inicial', (
      tester,
    ) async {
      final sync = FakeSyncCatalog();

      await pumpCatalog(
        tester,
        pokemon: [],
        syncStatus: const SyncFullPassInProgress(),
        syncCatalog: sync,
      );

      final l10n = catalogL10n(tester);

      expect(find.text(l10n.catalogLoading), findsOneWidget);

      expect(catalogList(), findsNothing);

      expect(catalogScrollableState(), findsNothing);

      await tester.drag(refreshIndicator(), const Offset(0, 500));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(sync.calls, 0);

      expect(refreshProgressIndicator(), findsNothing);

      expect(find.text(l10n.catalogLoading), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
  group('pull-to-refresh: ejecucion', () {
    testWidgets('el gesto ejecuta el caso de uso de sincronizacion', (
      tester,
    ) async {
      var executed = false;

      final sync = FakeSyncCatalog(
        onSync: (_) async {
          executed = true;
        },
      );

      await pumpCatalog(tester, pokemon: testCatalog, syncCatalog: sync);

      expect(executed, isFalse);
      expect(sync.calls, 0);

      await pullToRefresh(tester);
      await tester.pumpAndSettle();

      expect(executed, isTrue);
      expect(sync.calls, 1);
    });

    testWidgets('la actualizacion manual utiliza force true', (tester) async {
      final sync = FakeSyncCatalog();

      await pumpCatalog(tester, pokemon: testCatalog, syncCatalog: sync);

      await pullToRefresh(tester);
      await tester.pumpAndSettle();

      expect(sync.requests, [true]);
    });

    testWidgets(
      'el indicador permanece activo mientras la sincronizacion esta pendiente',
      (tester) async {
        final pendingSync = Completer<void>();

        final sync = FakeSyncCatalog(onSync: (_) => pendingSync.future);

        await pumpCatalog(tester, pokemon: testCatalog, syncCatalog: sync);

        expect(refreshProgressIndicator(), findsNothing);

        await pullToRefresh(tester);

        expect(sync.calls, 1);
        expect(pendingSync.isCompleted, isFalse);

        expect(refreshProgressIndicator(), findsOneWidget);

        await tester.pump(const Duration(seconds: 3));

        expect(refreshProgressIndicator(), findsOneWidget);

        expect(pendingSync.isCompleted, isFalse);

        pendingSync.complete();

        await tester.pumpAndSettle();

        expect(refreshProgressIndicator(), findsNothing);
      },
    );

    testWidgets('el indicador desaparece cuando finaliza la sincronizacion', (
      tester,
    ) async {
      final pendingSync = Completer<void>();

      final sync = FakeSyncCatalog(onSync: (_) => pendingSync.future);

      await pumpCatalog(tester, pokemon: testCatalog, syncCatalog: sync);

      await pullToRefresh(tester);

      expect(refreshProgressIndicator(), findsOneWidget);

      pendingSync.complete();

      await tester.pumpAndSettle();

      expect(pendingSync.isCompleted, isTrue);

      expect(refreshProgressIndicator(), findsNothing);

      expect(refreshIndicator(), findsOneWidget);

      expect(sync.calls, 1);
    });

    testWidgets('conserva los Pokemon visibles durante la actualizacion', (
      tester,
    ) async {
      final pendingSync = Completer<void>();

      final sync = FakeSyncCatalog(onSync: (_) => pendingSync.future);

      await pumpCatalog(
        tester,
        pokemon: [bulbasaur, pikachu, raichu],
        syncCatalog: sync,
      );

      final initialIds = visiblePokemonIds(tester);

      expect(initialIds, [1, 25, 26]);

      await pullToRefresh(tester);

      expect(refreshProgressIndicator(), findsOneWidget);

      expect(visiblePokemonIds(tester), initialIds);

      await tester.pump(const Duration(seconds: 2));

      expect(visiblePokemonIds(tester), initialIds);

      expect(catalogList(), findsOneWidget);

      pendingSync.complete();

      await tester.pumpAndSettle();

      expect(visiblePokemonIds(tester), initialIds);
    });

    testWidgets(
      'un segundo gesto no inicia otra solicitud mientras se actualiza',
      (tester) async {
        final pendingSync = Completer<void>();

        final sync = FakeSyncCatalog(onSync: (_) => pendingSync.future);

        await pumpCatalog(tester, pokemon: testCatalog, syncCatalog: sync);

        await pullToRefresh(tester);

        expect(sync.calls, 1);

        expect(refreshProgressIndicator(), findsOneWidget);

        await pullToRefresh(tester);

        expect(sync.calls, 1);
        expect(sync.requests, [true]);

        expect(refreshProgressIndicator(), findsOneWidget);

        pendingSync.complete();

        await tester.pumpAndSettle();

        expect(sync.calls, 1);

        expect(refreshProgressIndicator(), findsNothing);
      },
    );

    testWidgets('permite volver a actualizar despues de finalizar', (
      tester,
    ) async {
      final pendingSyncs = <Completer<void>>[];

      final sync = FakeSyncCatalog(
        onSync: (_) {
          final pending = Completer<void>();

          pendingSyncs.add(pending);

          return pending.future;
        },
      );

      await pumpCatalog(tester, pokemon: testCatalog, syncCatalog: sync);

      // Primera actualizacion.
      await pullToRefresh(tester);

      expect(sync.calls, 1);
      expect(pendingSyncs, hasLength(1));

      expect(refreshProgressIndicator(), findsOneWidget);

      pendingSyncs.first.complete();

      await tester.pumpAndSettle();

      expect(refreshProgressIndicator(), findsNothing);

      // Segunda actualizacion.
      await pullToRefresh(tester);

      expect(sync.calls, 2);
      expect(pendingSyncs, hasLength(2));
      expect(sync.requests, [true, true]);

      expect(refreshProgressIndicator(), findsOneWidget);

      pendingSyncs.last.complete();

      await tester.pumpAndSettle();

      expect(refreshProgressIndicator(), findsNothing);

      expect(sync.calls, 2);
    });
  });
  group('pull-to-refresh: errores', () {
    testWidgets('una excepcion no deja el indicador activo', (tester) async {
      final pending = Completer<void>();

      final sync = FakeSyncCatalog(onSync: (_) => pending.future);

      await pumpCatalog(tester, pokemon: testCatalog, syncCatalog: sync);

      await pullToRefresh(tester);

      expect(sync.requests, [true]);
      expect(refreshProgressIndicator(), findsOneWidget);

      pending.completeError(StateError('Error inesperado'));

      await tester.pumpAndSettle();

      expect(refreshProgressIndicator(), findsNothing);
      expect(catalogList(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('un fallo por falta de conexion conserva el listado local', (
      tester,
    ) async {
      final statuses = StreamController<SyncStatus>.broadcast();
      addTearDown(statuses.close);

      final pending = Completer<void>();

      final sync = FakeSyncCatalog(
        onSync: (_) {
          statuses.add(const SyncFullPassInProgress());
          return pending.future;
        },
      );

      await pumpCatalog(
        tester,
        pokemon: [pikachu, raichu],
        syncCatalog: sync,
        syncStatuses: statuses.stream,
      );

      statuses.add(const SyncIdle());
      await tester.pump();
      await tester.pump();

      await pullToRefresh(tester);

      expect(visiblePokemonIds(tester), [25, 26]);
      expect(refreshProgressIndicator(), findsOneWidget);

      statuses.add(const SyncFailed(NoConnection()));
      pending.complete();

      await tester.pumpAndSettle();

      expect(refreshProgressIndicator(), findsNothing);
      expect(visiblePokemonIds(tester), [25, 26]);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('un fallo de sincronizacion muestra un SnackBar', (
      tester,
    ) async {
      final statuses = StreamController<SyncStatus>.broadcast();
      addTearDown(statuses.close);

      final pending = Completer<void>();

      final sync = FakeSyncCatalog(
        onSync: (_) {
          statuses.add(const SyncFullPassInProgress());
          return pending.future;
        },
      );

      await pumpCatalog(
        tester,
        pokemon: [pikachu],
        syncCatalog: sync,
        syncStatuses: statuses.stream,
      );

      statuses.add(const SyncIdle());
      await tester.pump();
      await tester.pump();

      await pullToRefresh(tester);

      statuses.add(const SyncFailed(NoConnection()));
      pending.complete();

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Pikachu'), findsOneWidget);
      expect(refreshProgressIndicator(), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('el indicador desaparece al programarse un reintento', (
      tester,
    ) async {
      final statuses = StreamController<SyncStatus>.broadcast();
      addTearDown(statuses.close);

      final pending = Completer<void>();

      final sync = FakeSyncCatalog(
        onSync: (_) {
          statuses.add(const SyncFullPassInProgress());
          return pending.future;
        },
      );

      await pumpCatalog(
        tester,
        pokemon: [pikachu],
        syncCatalog: sync,
        syncStatuses: statuses.stream,
      );

      statuses.add(const SyncIdle());
      await tester.pump();
      await tester.pump();

      await pullToRefresh(tester);

      expect(refreshProgressIndicator(), findsOneWidget);

      statuses.add(
        SyncWaitingRetry(
          attempt: 1,
          maxAttempts: 5,
          retryAt: DateTime(2026, 11, 25, 10, 0, 2),
          failure: const ServerError(503),
        ),
      );

      pending.complete();

      await tester.pumpAndSettle();

      expect(refreshProgressIndicator(), findsNothing);
      expect(find.text('Pikachu'), findsOneWidget);
      expect(sync.calls, 1);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('el indicador desaparece cuando se agota el presupuesto', (
      tester,
    ) async {
      final statuses = StreamController<SyncStatus>.broadcast();
      addTearDown(statuses.close);

      final pending = Completer<void>();

      final sync = FakeSyncCatalog(
        onSync: (_) {
          statuses.add(const SyncFullPassInProgress());
          return pending.future;
        },
      );

      await pumpCatalog(
        tester,
        pokemon: [pikachu],
        syncCatalog: sync,
        syncStatuses: statuses.stream,
      );

      statuses.add(const SyncIdle());
      await tester.pump();
      await tester.pump();

      await pullToRefresh(tester);

      expect(refreshProgressIndicator(), findsOneWidget);

      statuses.add(SyncPaused(DateTime(2026, 11, 25, 10, 10)));

      pending.complete();

      await tester.pumpAndSettle();

      expect(refreshProgressIndicator(), findsNothing);
      expect(find.text('Pikachu'), findsOneWidget);
      expect(sync.calls, 1);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('permite volver a actualizar despues de una excepcion', (
      tester,
    ) async {
      final attempts = <Completer<void>>[];

      final sync = FakeSyncCatalog(
        onSync: (_) {
          final pending = Completer<void>();
          attempts.add(pending);
          return pending.future;
        },
      );

      await pumpCatalog(tester, pokemon: [pikachu], syncCatalog: sync);

      await pullToRefresh(tester);

      expect(sync.calls, 1);

      attempts.first.completeError(StateError('Primer intento fallido'));

      await tester.pumpAndSettle();

      expect(refreshProgressIndicator(), findsNothing);

      await pullToRefresh(tester);

      expect(sync.calls, 2);
      expect(sync.requests, [true, true]);
      expect(refreshProgressIndicator(), findsOneWidget);

      attempts.last.complete();

      await tester.pumpAndSettle();

      expect(refreshProgressIndicator(), findsNothing);
      expect(find.text('Pikachu'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
  group('pull-to-refresh: conservacion de la consulta', () {
    testWidgets('conserva el texto de busqueda', (tester) async {
      final sync = FakeSyncCatalog();

      await pumpCatalog(tester, pokemon: testCatalog, syncCatalog: sync);

      await showFilters(tester);
      await searchFor(tester, 'pikachu');

      expect(visiblePokemonIds(tester), [25]);

      await pullToRefresh(tester);
      await tester.pumpAndSettle();

      final searchField = tester.widget<TextField>(find.byType(TextField));

      expect(searchField.controller?.text, 'pikachu');
      expect(visiblePokemonIds(tester), [25]);
      expect(sync.requests, [true]);
    });

    testWidgets('conserva los tipos seleccionados', (tester) async {
      final sync = FakeSyncCatalog();

      await pumpCatalog(tester, pokemon: testCatalog, syncCatalog: sync);

      await showFilters(tester);

      await selectMultiple<String>(
        tester,
        selector: typeDropdown(),
        values: {'electric', 'water'},
      );

      expect(visiblePokemonIds(tester), [7, 25, 26]);

      await pullToRefresh(tester);
      await tester.pumpAndSettle();

      final filterBar = tester.widget<CatalogFilterBar>(
        find.byType(CatalogFilterBar),
      );

      expect(filterBar.selectedTypes, {'electric', 'water'});

      expect(visiblePokemonIds(tester), [7, 25, 26]);
      expect(sync.requests, [true]);
    });

    testWidgets('conserva las generaciones seleccionadas', (tester) async {
      final sync = FakeSyncCatalog();

      await pumpCatalog(
        tester,
        pokemon: multiGenerationCatalog,
        syncCatalog: sync,
      );

      await showFilters(tester);

      await selectMultiple<int>(
        tester,
        selector: generationSelector(),
        values: {2, 3},
      );

      expect(visiblePokemonIds(tester), [155, 158, 255]);

      await pullToRefresh(tester);
      await tester.pumpAndSettle();

      final filterBar = tester.widget<CatalogFilterBar>(
        find.byType(CatalogFilterBar),
      );

      expect(filterBar.selectedGenerations, {2, 3});
      expect(visiblePokemonIds(tester), [155, 158, 255]);
      expect(sync.requests, [true]);
    });

    testWidgets('conserva el criterio de ordenamiento', (tester) async {
      final sync = FakeSyncCatalog();

      await pumpCatalog(
        tester,
        pokemon: [bulbasaur, pikachu, raichu],
        syncCatalog: sync,
      );

      await showFilters(tester);

      await selectSort(tester, catalogL10n(tester).catalogSortNumberDesc);

      expect(visiblePokemonIds(tester), [26, 25, 1]);

      await pullToRefresh(tester);
      await tester.pumpAndSettle();

      final filterBar = tester.widget<CatalogFilterBar>(
        find.byType(CatalogFilterBar),
      );

      expect(filterBar.selectedSort, CatalogSort.numberDescending);

      expect(visiblePokemonIds(tester), [26, 25, 1]);
      expect(sync.requests, [true]);
    });

    testWidgets('conserva la pagina actual cuando sigue siendo valida', (
      tester,
    ) async {
      final sync = FakeSyncCatalog();
      final queryRepository = FakeCatalogQueryRepository();
      final pageRequests = <CatalogPageRequest>[];

      final pokemon = List.generate(
        51,
        (index) => Pokemon(
          id: index + 1,
          name: 'pokemon${index + 1}',
          imageUrl: '',
          typeNames: const ['normal'],
        ),
      );

      await pumpCatalog(
        tester,
        pokemon: pokemon,
        syncCatalog: sync,
        queryRepository: queryRepository,
        pageRequests: pageRequests,
      );

      await scrollToPagination(tester);

      await tester.tap(find.byTooltip(catalogL10n(tester).nextPage));

      await tester.pumpAndSettle();

      expect(visiblePokemonIds(tester), [51]);
      expect(pageRequests.last.page, 1);
      expect(queryRepository.storedState?.page, 1);

      await pullToRefresh(tester);
      await tester.pumpAndSettle();

      expect(visiblePokemonIds(tester), [51]);
      expect(pageRequests.last.page, 1);
      expect(queryRepository.storedState?.page, 1);
      expect(sync.requests, [true]);
    });

    testWidgets(
      'actualizar no genera escrituras innecesarias en preferencias',
      (tester) async {
        final sync = FakeSyncCatalog();
        final queryRepository = FakeCatalogQueryRepository();

        final pageRequests = <CatalogPageRequest>[];
        final countRequests = <CatalogQuery>[];

        await pumpCatalog(
          tester,
          pokemon: testCatalog,
          syncCatalog: sync,
          queryRepository: queryRepository,
          pageRequests: pageRequests,
          countRequests: countRequests,
        );

        await showFilters(tester);
        await searchFor(tester, 'pikachu');

        await selectMultiple<String>(
          tester,
          selector: typeDropdown(),
          values: {'electric'},
        );

        await selectMultiple<int>(
          tester,
          selector: generationSelector(),
          values: {1},
        );

        await selectSort(tester, catalogL10n(tester).catalogSortNumberDesc);

        await tester.pumpAndSettle();

        final savedState = queryRepository.storedState;
        final saveCallsBefore = queryRepository.saveCalls;
        final loadCallsBefore = queryRepository.loadCalls;
        final clearCallsBefore = queryRepository.clearCalls;

        final pagesBefore = List<CatalogPageRequest>.of(pageRequests);

        final countsBefore = List<CatalogQuery>.of(countRequests);

        expect(savedState, isNotNull);
        expect(visiblePokemonIds(tester), [25]);

        await pullToRefresh(tester);
        await tester.pumpAndSettle();

        expect(queryRepository.storedState, savedState);
        expect(queryRepository.saveCalls, saveCallsBefore);
        expect(queryRepository.loadCalls, loadCallsBefore);
        expect(queryRepository.clearCalls, clearCallsBefore);

        expect(pageRequests, pagesBefore);
        expect(countRequests, countsBefore);

        expect(visiblePokemonIds(tester), [25]);
        expect(sync.requests, [true]);
      },
    );
  });
  group('pull-to-refresh: integracion reactiva', () {
    const noticeKey = ValueKey('catalog-partial-notice');

    testWidgets('los nuevos Pokemon aparecen durante la actualizacion', (
      tester,
    ) async {
      final updates = StreamController<List<Pokemon>>.broadcast();

      addTearDown(updates.close);

      final pending = Completer<void>();

      final sync = FakeSyncCatalog(onSync: (_) => pending.future);

      await pumpCatalog(
        tester,
        pokemon: [pikachu],
        syncCatalog: sync,
        pokemonUpdates: updates.stream,
      );

      updates.add([pikachu]);

      await tester.pump();
      await tester.pump();

      expect(visiblePokemonIds(tester), [25]);

      await pullToRefresh(tester);

      expect(refreshProgressIndicator(), findsOneWidget);

      updates.add([pikachu, raichu]);

      await tester.pump();
      await tester.pump();

      expect(visiblePokemonIds(tester), [25, 26]);
      expect(refreshProgressIndicator(), findsOneWidget);

      pending.complete();

      await tester.pumpAndSettle();

      expect(visiblePokemonIds(tester), [25, 26]);
      expect(refreshProgressIndicator(), findsNothing);
      expect(sync.requests, [true]);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets(
      'el catalogo pasa de vacio a contener Pokemon durante la actualizacion',
      (tester) async {
        final updates = StreamController<List<Pokemon>>.broadcast();

        final counts = StreamController<int>.broadcast();

        final statuses = StreamController<SyncStatus>.broadcast();

        addTearDown(updates.close);
        addTearDown(counts.close);
        addTearDown(statuses.close);

        final pending = Completer<void>();

        final sync = FakeSyncCatalog(
          onSync: (_) {
            statuses.add(const SyncFullPassInProgress());
            return pending.future;
          },
        );

        await pumpCatalog(
          tester,
          pokemon: [],
          syncCatalog: sync,
          pokemonUpdates: updates.stream,
          counts: counts.stream,
          syncStatuses: statuses.stream,
        );

        updates.add([]);
        counts.add(0);
        statuses.add(const SyncIdle());

        await tester.pump();
        await tester.pump();

        expect(catalogScrollableState(), findsOneWidget);
        expect(catalogList(), findsNothing);

        final indicatorBefore = tester.state<RefreshIndicatorState>(
          refreshIndicator(),
        );

        await pullToRefresh(tester, target: catalogScrollableState());

        expect(sync.calls, 1);
        expect(refreshProgressIndicator(), findsOneWidget);

        updates.add([pikachu]);
        counts.add(1);

        await tester.pump();
        await tester.pump();

        expect(catalogList(), findsOneWidget);
        expect(find.text('Pikachu'), findsOneWidget);
        expect(refreshProgressIndicator(), findsOneWidget);

        final indicatorAfter = tester.state<RefreshIndicatorState>(
          refreshIndicator(),
        );

        expect(identical(indicatorBefore, indicatorAfter), isTrue);

        statuses.add(SyncRevalidated(DateTime(2026, 11, 25, 10)));

        pending.complete();

        await tester.pumpAndSettle();

        expect(refreshProgressIndicator(), findsNothing);
        expect(find.text('Pikachu'), findsOneWidget);
        expect(catalogScrollableState(), findsNothing);

        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    testWidgets('el aviso de catalogo parcial actualiza sus cantidades', (
      tester,
    ) async {
      final progress = StreamController<CatalogProgress>.broadcast();

      addTearDown(progress.close);

      final pending = Completer<void>();

      final sync = FakeSyncCatalog(onSync: (_) => pending.future);

      await pumpCatalog(
        tester,
        pokemon: testCatalog,
        syncCatalog: sync,
        progressUpdates: progress.stream,
      );

      progress.add(
        const CatalogProgress(
          savedCount: 6,
          totalCount: 1025,
          isComplete: false,
        ),
      );

      await tester.pump();
      await tester.pump();

      final l10n = catalogL10n(tester);

      expect(find.byKey(noticeKey), findsOneWidget);

      expect(find.text(l10n.catalogPartialNotice(6, 1025)), findsOneWidget);

      await pullToRefresh(tester);

      expect(refreshProgressIndicator(), findsOneWidget);

      progress.add(
        const CatalogProgress(
          savedCount: 100,
          totalCount: 1025,
          isComplete: false,
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.text(l10n.catalogPartialNotice(6, 1025)), findsNothing);

      expect(find.text(l10n.catalogPartialNotice(100, 1025)), findsOneWidget);

      expect(refreshProgressIndicator(), findsOneWidget);

      pending.complete();

      await tester.pumpAndSettle();

      expect(refreshProgressIndicator(), findsNothing);

      expect(find.text(l10n.catalogPartialNotice(100, 1025)), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('el aviso desaparece cuando se completa el catalogo', (
      tester,
    ) async {
      final progress = StreamController<CatalogProgress>.broadcast();

      addTearDown(progress.close);

      final pending = Completer<void>();

      final sync = FakeSyncCatalog(onSync: (_) => pending.future);

      await pumpCatalog(
        tester,
        pokemon: testCatalog,
        syncCatalog: sync,
        progressUpdates: progress.stream,
      );

      progress.add(
        const CatalogProgress(
          savedCount: 6,
          totalCount: 1025,
          isComplete: false,
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.byKey(noticeKey), findsOneWidget);

      await pullToRefresh(tester);

      progress.add(
        const CatalogProgress(
          savedCount: 1025,
          totalCount: 1025,
          isComplete: true,
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.byKey(noticeKey), findsNothing);
      expect(refreshProgressIndicator(), findsOneWidget);
      expect(catalogList(), findsOneWidget);

      pending.complete();

      await tester.pumpAndSettle();

      expect(refreshProgressIndicator(), findsNothing);
      expect(find.byKey(noticeKey), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets(
      'el aviso y los filtros permanecen fuera del area de actualizacion',
      (tester) async {
        final pending = Completer<void>();

        final sync = FakeSyncCatalog(onSync: (_) => pending.future);

        await pumpCatalog(
          tester,
          pokemon: testCatalog,
          syncCatalog: sync,
          progressUpdates: Stream.value(
            const CatalogProgress(
              savedCount: 6,
              totalCount: 1025,
              isComplete: false,
            ),
          ),
        );

        await showFilters(tester);

        final notice = find.byKey(noticeKey);
        final filters = find.byType(CatalogFilterBar);

        expect(notice, findsOneWidget);
        expect(filters, findsOneWidget);

        expect(
          find.descendant(of: refreshIndicator(), matching: notice),
          findsNothing,
        );

        expect(
          find.descendant(of: refreshIndicator(), matching: filters),
          findsNothing,
        );

        final noticeBefore = tester.getRect(notice);
        final filtersBefore = tester.getRect(filters);

        await pullToRefresh(tester);

        expect(refreshProgressIndicator(), findsOneWidget);

        expect(tester.getRect(notice), noticeBefore);
        expect(tester.getRect(filters), filtersBefore);

        pending.complete();

        await tester.pumpAndSettle();

        expect(tester.getRect(notice), noticeBefore);
        expect(tester.getRect(filters), filtersBefore);
        expect(refreshProgressIndicator(), findsNothing);
      },
    );

    testWidgets('el boton de sincronizacion del AppBar sigue funcionando', (
      tester,
    ) async {
      final sync = FakeSyncCatalog();

      await pumpCatalog(tester, pokemon: testCatalog, syncCatalog: sync);

      final l10n = catalogL10n(tester);

      expect(sync.calls, 0);

      await tester.tap(find.byTooltip(l10n.syncCatalog));

      await tester.pumpAndSettle();

      expect(sync.requests, [true]);
      expect(catalogList(), findsOneWidget);

      await pullToRefresh(tester);
      await tester.pumpAndSettle();

      expect(sync.requests, [true, true]);
      expect(refreshProgressIndicator(), findsNothing);
    });

    testWidgets('el boton de reintentar sigue funcionando en el estado vacio', (
      tester,
    ) async {
      final sync = FakeSyncCatalog();

      await pumpCatalog(tester, pokemon: [], syncCatalog: sync);

      final l10n = catalogL10n(tester);

      expect(find.text(l10n.retry), findsOneWidget);

      await tester.tap(find.text(l10n.retry));
      await tester.pumpAndSettle();

      expect(sync.requests, [true]);

      await pullToRefresh(tester, target: catalogScrollableState());

      await tester.pumpAndSettle();

      expect(sync.requests, [true, true]);
      expect(refreshProgressIndicator(), findsNothing);
      expect(find.text(l10n.retry), findsOneWidget);
    });

    testWidgets('limpiar filtros sigue funcionando despues de actualizar', (
      tester,
    ) async {
      final sync = FakeSyncCatalog();
      final queryRepository = FakeCatalogQueryRepository();

      await pumpCatalog(
        tester,
        pokemon: testCatalog,
        syncCatalog: sync,
        queryRepository: queryRepository,
      );

      await showFilters(tester);
      await searchFor(tester, 'inexistente');

      final l10n = catalogL10n(tester);

      expect(find.text(l10n.catalogNoResults), findsOneWidget);

      await pullToRefresh(tester, target: catalogScrollableState());

      await tester.pumpAndSettle();

      expect(sync.requests, [true]);

      expect(find.text(l10n.catalogNoResults), findsOneWidget);

      await tester.tap(find.text(l10n.catalogClearFilters));

      await tester.pumpAndSettle();

      expect(find.text(l10n.catalogNoResults), findsNothing);

      expect(catalogList(), findsOneWidget);
      expect(find.byType(PokemonListItem), findsWidgets);

      final searchField = tester.widget<TextField>(find.byType(TextField));

      expect(searchField.controller?.text, isEmpty);

      expect(queryRepository.storedState, CatalogQueryState.initial());

      expect(sync.calls, 1);
      expect(refreshProgressIndicator(), findsNothing);
    });
  });
}
