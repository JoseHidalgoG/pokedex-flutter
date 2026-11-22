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
import 'package:flutter_riverpod/misc.dart' show Override;
import '../../../favorites/fakes/fake_favorites_repository.dart';

void main() {
  const pikachu = Pokemon(
    id: 25,
    name: 'pikachu',
    imageUrl: '',
    typeNames: ['electric'],
  );

  List<Override> catalogOverrides(
      List<Pokemon> pokemon, {
        required Stream<SyncStatus> syncStatuses,
        Stream<int>? counts,
      }) {
    return [
      filteredCatalogPageProvider.overrideWith((ref, request) {
        final offset = request.page * request.pageSize;
        final pagePokemon = pokemon.skip(offset).take(request.pageSize).toList();

        return Stream.value(pagePokemon);
      }),
      filteredCatalogCountProvider.overrideWith(
            (ref, query) => counts ?? Stream.value(pokemon.length),
      ),
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
      }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: catalogOverrides(
          pokemon,
          syncStatuses: Stream.value(syncStatus),
        ),
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
        overrides: catalogOverrides(
          [pikachu],
          syncStatuses: Stream.value(const SyncIdle()),
        ),
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

    final previousButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.chevron_left),
    );

    expect(previousButton.onPressed, isNull);

    await tester.tap(find.byTooltip('Página siguiente'));
    await tester.pump();
    await tester.pump();

    expect(find.text('#0051'), findsOneWidget);
    expect(find.text('Pokemon51'), findsOneWidget);

    final nextButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.chevron_right),
    );

    expect(nextButton.onPressed, isNull);

    await tester.tap(find.byTooltip('Página anterior'));
    await tester.pump();
    await tester.pump();

    expect(find.text('#0001'), findsOneWidget);
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

      final nextPageButton = tester.getRect(find.byTooltip('Página siguiente'));
      expect(nextPageButton.right, lessThanOrEqualTo(narrowPhoneWidth));
      expect(find.text('1'), findsOneWidget);
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
          overrides: catalogOverrides(
            [pikachu],
            syncStatuses: syncStatusController.stream,
          ),
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

    await tester.tap(find.widgetWithIcon(IconButton, Icons.chevron_right));
    await tester.pump();
    await tester.pump();

    expect(find.text('#0051'), findsOneWidget);

    countController.add(25);
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text('#0001'), findsOneWidget);
    expect(find.text('#0051'), findsNothing);
  });
}