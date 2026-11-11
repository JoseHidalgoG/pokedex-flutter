import 'package:flutter/material.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_sync_status.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:pokedex_flutter/features/catalog/presentation/screens/catalog_screen.dart';
import 'package:pokedex_flutter/features/catalog/presentation/screens/pokemon_detail_screen.dart';

void main() {
  const pikachu = Pokemon(
    id: 25,
    name: 'pikachu',
    imageUrl: '',
    typeNames: ['electric'],
  );

  Future<void> pumpCatalog(
    WidgetTester tester, {
    required List<Pokemon> pokemon,
    CatalogSyncStatus syncStatus = const CatalogSyncSucceeded(),
  }) async {
    final firstPage = pokemon.take(50).toList();
    final secondPage = pokemon.skip(50).take(50).toList();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogPageProvider(0).overrideWith((ref) => Stream.value(firstPage)),
          catalogPageProvider(1)
              .overrideWith((ref) => Stream.value(secondPage)),
          catalogCountProvider.overrideWith(
            (ref) => Stream.value(pokemon.length),
          ),
          catalogSyncStatusProvider.overrideWith(
            (ref) => Stream.value(syncStatus),
          ),
        ],
        child: const MaterialApp(home: CatalogScreen()),
      ),
    );

    await tester.pump();
  }

  testWidgets('muestra el número, nombre y tipo de un Pokémon', (tester) async {
    await pumpCatalog(tester, pokemon: [pikachu]);

    expect(find.text('#0025'), findsOneWidget);
    expect(find.text('Pikachu'), findsOneWidget);
    expect(find.text('Electric'), findsOneWidget);
  });

  testWidgets('muestra un indicador cuando el catálogo está sincronizando', (
    tester,
  ) async {
    await pumpCatalog(
      tester,
      pokemon: [],
      syncStatus: const CatalogSyncInProgress(),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Cargando catálogo'), findsOneWidget);
  });

  testWidgets(
    'muestra un error cuando no hay datos y falla la sincronización',
    (tester) async {
      await pumpCatalog(
        tester,
        pokemon: [],
        syncStatus: const CatalogSyncFailed(
          CatalogSyncFailureReason.noConnection,
        ),
      );

      expect(find.text('No se pudo cargar el catálogo'), findsOneWidget);

      expect(find.text('Reintentar'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    },
  );

  testWidgets('muestra un estado vacío cuando no hay Pokémon', (tester) async {
    await pumpCatalog(
      tester,
      pokemon: [],
      syncStatus: const CatalogSyncSucceeded(),
    );

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
      syncStatus: const CatalogSyncFailed(
        CatalogSyncFailureReason.noConnection,
      ),
    );

    expect(find.text('#0025'), findsOneWidget);
    expect(find.text('Pikachu'), findsOneWidget);
    expect(find.text('Electric'), findsOneWidget);

    expect(find.text('No se pudo cargar el catálogo'), findsNothing);
    expect(
      find.text('Sin conexión: se muestran los Pokémon guardados.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'avisa con un SnackBar cuando falla una sincronización sobre la lista visible',
    (tester) async {
      final syncStatusController = StreamController<CatalogSyncStatus>();
      addTearDown(syncStatusController.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            catalogPageProvider(0)
                .overrideWith((ref) => Stream.value([pikachu])),
            catalogCountProvider.overrideWith((ref) => Stream.value(1)),
            catalogSyncStatusProvider.overrideWith(
              (ref) => syncStatusController.stream,
            ),
          ],
          child: const MaterialApp(home: CatalogScreen()),
        ),
      );

      syncStatusController.add(const CatalogSyncSucceeded());
      await tester.pump();
      await tester.pump();

      expect(find.byType(SnackBar), findsNothing);

      syncStatusController
        ..add(const CatalogSyncInProgress())
        ..add(const CatalogSyncFailed(CatalogSyncFailureReason.requestFailed));
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
        overrides: [
          catalogPageProvider(0)
              .overrideWith((ref) => Stream.value(pokemon.take(50).toList())),
          catalogPageProvider(1)
              .overrideWith((ref) => Stream.value(pokemon.skip(50).toList())),
          catalogCountProvider.overrideWith((ref) => countController.stream),
          catalogSyncStatusProvider.overrideWith(
            (ref) => Stream.value(const CatalogSyncSucceeded()),
          ),
        ],
        child: const MaterialApp(home: CatalogScreen()),
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
