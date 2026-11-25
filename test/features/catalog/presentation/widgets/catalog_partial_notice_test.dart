import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_progress.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/catalog_partial_notice.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

void main() {
  const noticeKey = ValueKey('catalog-partial-notice');

  const partialProgress = CatalogProgress(
    savedCount: 412,
    totalCount: 1025,
    isComplete: false,
  );

  const completeProgress = CatalogProgress(
    savedCount: 1025,
    totalCount: 1025,
    isComplete: true,
  );

  const unknownTotalProgress = CatalogProgress(
    savedCount: 200,
    isComplete: false,
  );

  Future<void> pumpNotice(
    WidgetTester tester, {
    required Stream<CatalogProgress> progressUpdates,
    Locale locale = const Locale('es'),
    Brightness brightness = Brightness.light,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogProgressProvider.overrideWith((ref) => progressUpdates),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.red,
              brightness: brightness,
            ),
          ),
          home: const Scaffold(body: CatalogPartialNotice()),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();
  }

  Finder notice() => find.byKey(noticeKey);

  AppLocalizations noticeL10n(WidgetTester tester) {
    return AppLocalizations.of(
      tester.element(find.byType(CatalogPartialNotice)),
    )!;
  }

  group('visibilidad del aviso', () {
    testWidgets('oculta el aviso cuando el catálogo está completo', (
      tester,
    ) async {
      await pumpNotice(tester, progressUpdates: Stream.value(completeProgress));

      expect(notice(), findsNothing);
    });

    testWidgets('muestra el aviso cuando el catálogo está incompleto', (
      tester,
    ) async {
      await pumpNotice(tester, progressUpdates: Stream.value(partialProgress));

      expect(notice(), findsOneWidget);
    });

    testWidgets('muestra el aviso con total desconocido', (tester) async {
      await pumpNotice(
        tester,
        progressUpdates: Stream.value(unknownTotalProgress),
      );

      expect(notice(), findsOneWidget);
    });

    testWidgets('muestra el aviso cuando no hay Pokémon almacenados', (
      tester,
    ) async {
      await pumpNotice(
        tester,
        progressUpdates: Stream.value(
          const CatalogProgress(
            savedCount: 0,
            totalCount: 1025,
            isComplete: false,
          ),
        ),
      );

      expect(notice(), findsOneWidget);

      expect(
        find.text(noticeL10n(tester).catalogPartialNotice(0, 1025)),
        findsOneWidget,
      );
    });

    testWidgets('muestra el aviso con catálogo vacío y total desconocido', (
      tester,
    ) async {
      await pumpNotice(
        tester,
        progressUpdates: Stream.value(
          const CatalogProgress(savedCount: 0, isComplete: false),
        ),
      );

      expect(notice(), findsOneWidget);

      expect(
        find.text(noticeL10n(tester).catalogPartialNoticeUnknownTotal(0)),
        findsOneWidget,
      );
    });

    testWidgets('respeta isComplete aunque las cantidades sean iguales', (
      tester,
    ) async {
      await pumpNotice(
        tester,
        progressUpdates: Stream.value(
          const CatalogProgress(
            savedCount: 1025,
            totalCount: 1025,
            isComplete: false,
          ),
        ),
      );

      expect(notice(), findsOneWidget);
    });

    testWidgets('oculta el aviso con catálogo completo y total desconocido', (
      tester,
    ) async {
      await pumpNotice(
        tester,
        progressUpdates: Stream.value(
          const CatalogProgress(savedCount: 1025, isComplete: true),
        ),
      );

      expect(notice(), findsNothing);
    });

    testWidgets('oculta el aviso durante la carga inicial', (tester) async {
      final controller = StreamController<CatalogProgress>.broadcast();

      addTearDown(controller.close);

      await pumpNotice(tester, progressUpdates: controller.stream);

      expect(notice(), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('oculta el aviso ante un error de lectura', (tester) async {
      final controller = StreamController<CatalogProgress>.broadcast();

      addTearDown(controller.close);

      await pumpNotice(tester, progressUpdates: controller.stream);

      controller.addError(StateError('Error leyendo el progreso'));

      await tester.pump();
      await tester.pump();

      expect(notice(), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  group('localización del aviso', () {
    testWidgets('muestra el mensaje en español con total conocido', (
      tester,
    ) async {
      await pumpNotice(tester, progressUpdates: Stream.value(partialProgress));

      expect(
        find.text(
          'Catálogo local: 412 de 1025 Pokémon; '
          'los resultados pueden estar incompletos.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('muestra el mensaje en español con total desconocido', (
      tester,
    ) async {
      await pumpNotice(
        tester,
        progressUpdates: Stream.value(unknownTotalProgress),
      );

      expect(
        find.text(
          'Catálogo local: 200 Pokémon guardados; '
          'los resultados pueden estar incompletos.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('muestra el mensaje en inglés con total conocido', (
      tester,
    ) async {
      await pumpNotice(
        tester,
        locale: const Locale('en'),
        progressUpdates: Stream.value(partialProgress),
      );

      expect(
        find.text(
          'Local catalog: 412 of 1025 Pokémon; '
          'results may be incomplete.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('muestra el mensaje en inglés con total desconocido', (
      tester,
    ) async {
      await pumpNotice(
        tester,
        locale: const Locale('en'),
        progressUpdates: Stream.value(unknownTotalProgress),
      );

      expect(
        find.text(
          'Local catalog: 200 Pokémon saved; '
          'results may be incomplete.',
        ),
        findsOneWidget,
      );
    });
  });

  group('actualizaciones reactivas del aviso', () {
    late StreamController<CatalogProgress> controller;

    setUp(() {
      controller = StreamController<CatalogProgress>.broadcast();
    });

    tearDown(() async {
      await controller.close();
    });

    testWidgets('aparece cuando se recibe el progreso inicial', (tester) async {
      await pumpNotice(tester, progressUpdates: controller.stream);

      expect(notice(), findsNothing);

      controller.add(partialProgress);

      await tester.pump();
      await tester.pump();

      expect(notice(), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('actualiza la cantidad de Pokémon almacenados', (tester) async {
      await pumpNotice(tester, progressUpdates: controller.stream);

      controller.add(partialProgress);

      await tester.pump();
      await tester.pump();

      final l10n = noticeL10n(tester);

      expect(find.text(l10n.catalogPartialNotice(412, 1025)), findsOneWidget);

      controller.add(
        const CatalogProgress(
          savedCount: 700,
          totalCount: 1025,
          isComplete: false,
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.text(l10n.catalogPartialNotice(412, 1025)), findsNothing);

      expect(find.text(l10n.catalogPartialNotice(700, 1025)), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('actualiza el mensaje cuando se conoce el total', (
      tester,
    ) async {
      await pumpNotice(tester, progressUpdates: controller.stream);

      controller.add(unknownTotalProgress);

      await tester.pump();
      await tester.pump();

      final l10n = noticeL10n(tester);

      expect(
        find.text(l10n.catalogPartialNoticeUnknownTotal(200)),
        findsOneWidget,
      );

      controller.add(
        const CatalogProgress(
          savedCount: 200,
          totalCount: 1025,
          isComplete: false,
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(
        find.text(l10n.catalogPartialNoticeUnknownTotal(200)),
        findsNothing,
      );

      expect(find.text(l10n.catalogPartialNotice(200, 1025)), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('desaparece cuando se completa la sincronización', (
      tester,
    ) async {
      await pumpNotice(tester, progressUpdates: controller.stream);

      controller.add(partialProgress);

      await tester.pump();
      await tester.pump();

      expect(notice(), findsOneWidget);

      controller.add(completeProgress);

      await tester.pump();
      await tester.pump();

      expect(notice(), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('desaparece al cambiar únicamente isComplete', (tester) async {
      await pumpNotice(tester, progressUpdates: controller.stream);

      controller.add(
        const CatalogProgress(
          savedCount: 1025,
          totalCount: 1025,
          isComplete: false,
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(notice(), findsOneWidget);

      controller.add(completeProgress);

      await tester.pump();
      await tester.pump();

      expect(notice(), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('vuelve a aparecer si el catálogo deja de estar completo', (
      tester,
    ) async {
      await pumpNotice(tester, progressUpdates: controller.stream);

      controller.add(completeProgress);

      await tester.pump();
      await tester.pump();

      expect(notice(), findsNothing);

      controller.add(
        const CatalogProgress(
          savedCount: 1025,
          totalCount: 1100,
          isComplete: false,
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(notice(), findsOneWidget);

      expect(
        find.text(noticeL10n(tester).catalogPartialNotice(1025, 1100)),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  group('apariencia del aviso', () {
    testWidgets('muestra el icono informativo', (tester) async {
      await pumpNotice(tester, progressUpdates: Stream.value(partialProgress));

      expect(
        find.descendant(
          of: notice(),
          matching: find.byIcon(Icons.info_outline),
        ),
        findsOneWidget,
      );
    });

    for (final brightness in Brightness.values) {
      testWidgets('utiliza los colores del tema ${brightness.name}', (
        tester,
      ) async {
        await pumpNotice(
          tester,
          brightness: brightness,
          progressUpdates: Stream.value(partialProgress),
        );

        final context = tester.element(notice());
        final colorScheme = Theme.of(context).colorScheme;

        final container = tester.widget<Container>(notice());

        final decoration = container.decoration! as BoxDecoration;

        final text = tester.widget<Text>(
          find.descendant(of: notice(), matching: find.byType(Text)),
        );

        final icon = tester.widget<Icon>(
          find.descendant(
            of: notice(),
            matching: find.byIcon(Icons.info_outline),
          ),
        );

        expect(colorScheme.brightness, brightness);

        expect(decoration.color, colorScheme.tertiaryContainer);

        expect(text.style?.color, colorScheme.onTertiaryContainer);

        expect(icon.color, colorScheme.onTertiaryContainer);
      });
    }

    testWidgets('el texto se adapta a una pantalla estrecha', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpNotice(tester, progressUpdates: Stream.value(partialProgress));

      expect(notice(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
