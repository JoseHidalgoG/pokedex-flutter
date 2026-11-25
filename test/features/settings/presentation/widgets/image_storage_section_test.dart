import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/images/pokemon_image_cache_providers.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/artwork_save_progress.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/pokemon_image_providers.dart';
import 'package:pokedex_flutter/features/connectivity/connectivity_providers.dart';
import 'package:pokedex_flutter/features/connectivity/domain/connectivity_status.dart';
import 'package:pokedex_flutter/features/settings/presentation/widgets/image_storage_section.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

import '../../../catalog/fakes/fake_pokemon_image_repository.dart';

const saveAllLabel = 'Guardar imágenes para usar sin conexión';
const deleteLabel = 'Borrar imágenes';

void main() {
  late FakePokemonImageRepository images;
  late int decodedImageClears;

  setUp(() {
    images = FakePokemonImageRepository(savedBytes: 84300000);
    decodedImageClears = 0;
  });

  Future<void> pumpSection(
    WidgetTester tester, {
    ConnectivityStatus connectivity = ConnectivityStatus.online,
    Locale locale = const Locale('es'),
    bool hasImageRepository = true,
    Widget body = const SingleChildScrollView(child: ImageStorageSection()),
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (hasImageRepository)
            pokemonImageRepositoryProvider.overrideWithValue(images),
          if (hasImageRepository)
            connectivityStatusProvider.overrideWith(
              (ref) => Stream.value(connectivity),
            ),
          clearDecodedImagesProvider.overrideWithValue(
            () => decodedImageClears++,
          ),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: body),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  ButtonStyleButton buttonLabeled(WidgetTester tester, String label) {
    return tester.widget<ButtonStyleButton>(
      find.ancestor(
        of: find.text(label),
        matching: find.bySubtype<ButtonStyleButton>(),
      ),
    );
  }

  group('espacio usado', () {
    testWidgets('muestra el espacio de las imágenes guardadas', (tester) async {
      await pumpSection(tester);

      expect(find.text('Imágenes'), findsOneWidget);
      expect(find.text('Imágenes guardadas: 84,3 MB'), findsOneWidget);
    });

    testWidgets('en inglés usa punto decimal', (tester) async {
      await pumpSection(tester, locale: const Locale('en'));

      expect(find.text('Saved images: 84.3 MB'), findsOneWidget);
      expect(find.text('Save images for offline use'), findsOneWidget);
    });

    testWidgets(
      'sin el repositorio de imágenes muestra una raya y desactiva los botones',
      (tester) async {
        await pumpSection(tester, hasImageRepository: false);

        expect(find.text('Imágenes guardadas: —'), findsOneWidget);
        expect(buttonLabeled(tester, saveAllLabel).enabled, isFalse);
        expect(buttonLabeled(tester, deleteLabel).enabled, isFalse);
      },
    );

    testWidgets('oculto no mide el espacio hasta que se muestra', (
      tester,
    ) async {
      final tab = ValueNotifier(0);
      addTearDown(tab.dispose);
      await pumpSection(tester, body: tabsShowing(tab));

      expect(images.sizeReads, 0);

      tab.value = 1;
      await tester.pump();
      await tester.pump();

      expect(images.sizeReads, 1);
      expect(find.text('Imágenes guardadas: 84,3 MB'), findsOneWidget);
    });

    testWidgets('al volver a mostrarse mide otra vez el espacio', (
      tester,
    ) async {
      final tab = ValueNotifier(1);
      addTearDown(tab.dispose);
      await pumpSection(tester, body: tabsShowing(tab));
      expect(images.sizeReads, 1);

      tab.value = 0;
      await tester.pump();
      images.savedBytes = 5000000;
      tab.value = 1;
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(images.sizeReads, 2);
      expect(find.text('Imágenes guardadas: 5,0 MB'), findsOneWidget);
    });
  });

  group('guardar imágenes', () {
    testWidgets(
      'muestra cuántas van con una barra y al terminar el espacio nuevo',
      (tester) async {
        await pumpSection(tester);

        await tester.tap(find.text(saveAllLabel));
        await tester.pump();
        images.reportProgress(
          const ArtworkSaveProgress(saved: 412, failed: 0, total: 1025),
        );
        await tester.pump();

        expect(find.text('412 de 1025 guardadas'), findsOneWidget);
        final bar = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(bar.value, closeTo(412 / 1025, 1e-9));
        expect(buttonLabeled(tester, saveAllLabel).enabled, isFalse);
        expect(buttonLabeled(tester, deleteLabel).enabled, isFalse);

        images
          ..savedBytes = 164000000
          ..reportProgress(
            const ArtworkSaveProgress(saved: 1025, failed: 0, total: 1025),
          )
          ..finishSaving();
        await tester.pump();
        await tester.pump();

        expect(find.text('1025 de 1025 guardadas'), findsOneWidget);
        expect(find.text('Imágenes guardadas: 164,0 MB'), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsNothing);
        expect(buttonLabeled(tester, saveAllLabel).enabled, isTrue);
      },
    );

    testWidgets('sin conexión no se puede guardar y lo explica', (
      tester,
    ) async {
      await pumpSection(tester, connectivity: ConnectivityStatus.offline);

      expect(buttonLabeled(tester, saveAllLabel).enabled, isFalse);
      expect(
        find.text('Sin conexión: conéctate para descargarlas'),
        findsOneWidget,
      );
      expect(buttonLabeled(tester, deleteLabel).enabled, isTrue);
    });

    testWidgets(
      'con PokeAPI caída se puede guardar porque las imágenes vienen de GitHub',
      (tester) async {
        await pumpSection(
          tester,
          connectivity: ConnectivityStatus.serviceUnavailable,
        );

        expect(buttonLabeled(tester, saveAllLabel).enabled, isTrue);
      },
    );
  });

  group('borrar imágenes', () {
    testWidgets('pide confirmación y al aceptar vacía la caché', (
      tester,
    ) async {
      await pumpSection(tester);

      await tester.tap(find.text(deleteLabel));
      await tester.pumpAndSettle();
      expect(find.text('¿Borrar las imágenes guardadas?'), findsOneWidget);

      await tester.tap(find.text('Borrar'));
      await tester.pumpAndSettle();

      expect(images.deletions, 1);
      expect(decodedImageClears, 1);
      expect(find.text('Imágenes guardadas: 0,0 MB'), findsOneWidget);
    });

    testWidgets('cancelar no borra nada', (tester) async {
      await pumpSection(tester);

      await tester.tap(find.text(deleteLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(images.deletions, 0);
      expect(find.text('Imágenes guardadas: 84,3 MB'), findsOneWidget);
    });

    testWidgets('si falla lo dice debajo de los botones', (tester) async {
      images.deletionFails = true;
      await pumpSection(tester);

      await tester.tap(find.text(deleteLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Borrar'));
      await tester.pumpAndSettle();

      expect(find.text('No se pudieron borrar las imágenes'), findsOneWidget);
    });
  });
}

Widget tabsShowing(ValueNotifier<int> tab) {
  return ValueListenableBuilder<int>(
    valueListenable: tab,
    builder: (context, index, _) => IndexedStack(
      index: index,
      children: const [
        Text('Catálogo'),
        SingleChildScrollView(child: ImageStorageSection()),
      ],
    ),
  );
}
