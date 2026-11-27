import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokedex_flutter/core/images/pokemon_image_cache_providers.dart';
import 'package:pokedex_flutter/core/share/share_text_provider.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/detail_freshness.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_detail.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/type_matchups.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/pokemon_detail_providers.dart';
import 'package:pokedex_flutter/features/catalog/presentation/screens/pokemon_detail_screen.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/detail/detail_header.dart';
import 'package:pokedex_flutter/features/favorites/presentation/providers/favorites_providers.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

import '../../../favorites/fakes/fake_favorites_repository.dart';
import '../../fakes/fake_pokemon_detail_repository.dart';
import '../../fakes/pikachu_detail.dart';

class _SilentCacheManager extends Mock implements BaseCacheManager {}

void main() {
  late FakePokemonDetailRepository detailRepository;
  late FakeFavoritesRepository favoritesRepository;
  late _SilentCacheManager cacheManager;

  const electricEfficacy = [
    TypeEfficacy(
      attackingType: 'ground',
      defendingType: 'electric',
      damageFactor: 200,
    ),
    TypeEfficacy(
      attackingType: 'steel',
      defendingType: 'electric',
      damageFactor: 50,
    ),
  ];

  setUp(() {
    detailRepository = FakePokemonDetailRepository();
    favoritesRepository = FakeFavoritesRepository();
    cacheManager = _SilentCacheManager();
    when(
      () => cacheManager.getFileStream(
        any(),
        key: any(named: 'key'),
        headers: any(named: 'headers'),
        withProgress: any(named: 'withProgress'),
      ),
    ).thenAnswer((_) => StreamController<FileResponse>().stream);
  });

  tearDown(() async {
    await detailRepository.dispose();
    await favoritesRepository.dispose();
  });

  void useScreen(WidgetTester tester, Size size) {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> pumpDetail(
    WidgetTester tester, {
    Locale locale = const Locale('es'),
    Brightness brightness = Brightness.light,
    double textScale = 1,
  }) async {
    detailRepository
      ..emitDetail(25, pikachuDetail)
      ..emitFreshness(25, LocalData(savedAt: pikachuSavedAt))
      ..emitTypeEfficacy(electricEfficacy);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pokemonDetailRepositoryProvider.overrideWithValue(detailRepository),
          favoritesRepositoryProvider.overrideWith(
            (ref) => favoritesRepository,
          ),
          pokemonImageCacheManagerProvider.overrideWithValue(cacheManager),
          shareTextProvider.overrideWithValue(
            (text, {required subject, origin}) async {},
          ),
        ],
        child: MaterialApp(
          locale: locale,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.red,
              brightness: brightness,
            ),
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: const PokemonDetailScreen(pokemon: pikachu),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  AppLocalizations l10nOf(WidgetTester tester) {
    return AppLocalizations.of(tester.element(find.byType(TabBar)))!;
  }

  List<String> tabNamesOf(WidgetTester tester) {
    final l10n = l10nOf(tester);
    return [
      l10n.detailTabInfo,
      l10n.detailTabStats,
      l10n.detailTabEvolutions,
      l10n.detailTabMoves,
      l10n.detailTabMatchups,
    ];
  }

  Future<void> openTab(WidgetTester tester, String tabName) async {
    final tab = find.widgetWithText(Tab, tabName);
    await tester.ensureVisible(tab);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(tab);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  group('texto al 200 %', () {
    for (final locale in const [Locale('es'), Locale('en')]) {
      for (final brightness in Brightness.values) {
        testWidgets('ninguna pestaña se desborda en ${locale.languageCode} '
            'con tema ${brightness.name}', (tester) async {
          useScreen(tester, const Size(360, 740));
          await pumpDetail(
            tester,
            locale: locale,
            brightness: brightness,
            textScale: 2,
          );
          expect(tester.takeException(), isNull);

          for (final tabName in tabNamesOf(tester)) {
            await openTab(tester, tabName);
            expect(tester.takeException(), isNull, reason: tabName);
          }
        });
      }
    }

    for (final size in const [Size(800, 360), Size(640, 330)]) {
      testWidgets(
        'en una pantalla baja de ${size.width.round()}×${size.height.round()} '
        'el encabezado alto no desborda las pestañas',
        (tester) async {
          useScreen(tester, size);
          await pumpDetail(tester, textScale: 2);
          expect(tester.takeException(), isNull);

          for (final tabName in tabNamesOf(tester)) {
            await openTab(tester, tabName);
            expect(tester.takeException(), isNull, reason: tabName);
          }
        },
      );
    }

    testWidgets('las estadísticas pasan a dos líneas con texto grande', (
      tester,
    ) async {
      useScreen(tester, const Size(360, 740));
      await pumpDetail(tester, textScale: 2);
      await openTab(tester, 'Estadísticas');

      final name = tester.getRect(find.text('Ataque'));
      final value = tester.getRect(find.text('55'));
      final attackBar = tester.getRect(find.byType(FractionallySizedBox).at(1));

      expect(value.left, greaterThan(name.right));
      expect(value.center.dy, closeTo(name.center.dy, 4));
      expect(attackBar.top, greaterThanOrEqualTo(name.bottom));
    });
  });

  group('guías de accesibilidad', () {
    for (final brightness in Brightness.values) {
      testWidgets('cada pestaña cumple tamaño táctil, etiquetas y contraste '
          'con tema ${brightness.name}', (tester) async {
        final semantics = tester.ensureSemantics();
        useScreen(tester, const Size(800, 600));
        await pumpDetail(tester, brightness: brightness);

        for (final tabName in tabNamesOf(tester)) {
          await openTab(tester, tabName);
          await expectLater(
            tester,
            meetsGuideline(androidTapTargetGuideline),
            reason: tabName,
          );
          await expectLater(
            tester,
            meetsGuideline(labeledTapTargetGuideline),
            reason: tabName,
          );
          await expectLater(
            tester,
            meetsGuideline(textContrastGuideline),
            reason: tabName,
          );
        }
        semantics.dispose();
      });
    }
  });

  group('lector de pantalla', () {
    testWidgets('anuncia la imagen, el número y el nombre como encabezado', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      useScreen(tester, const Size(800, 600));
      await pumpDetail(tester);

      expect(find.bySemanticsLabel('Imagen de Pikachu'), findsOneWidget);
      expect(find.bySemanticsLabel('Número 25'), findsOneWidget);
      expect(
        tester.getSemantics(
          find.descendant(
            of: find.byType(DetailIdentity),
            matching: find.text('Pikachu'),
          ),
        ),
        isSemantics(label: 'Pikachu', isHeader: true, namesRoute: true),
      );

      await tester.tap(find.byTooltip('Ver versión shiny'));
      await tester.pump();

      expect(find.bySemanticsLabel('Imagen shiny de Pikachu'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('lee cada estadística y el total como una sola frase', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      useScreen(tester, const Size(800, 600));
      await pumpDetail(tester);
      await openTab(tester, 'Estadísticas');

      expect(
        find.bySemanticsLabel(RegExp(r'^Ataque: 55 de 255, 22\s?%$')),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Total: 320'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets(
      'marca el Pokémon actual en la evolución sin depender del color',
      (tester) async {
        final semantics = tester.ensureSemantics();
        useScreen(tester, const Size(800, 600));
        await pumpDetail(tester);
        await openTab(tester, 'Evoluciones');

        expect(find.text('Actual'), findsOneWidget);
        expect(find.bySemanticsLabel('Pikachu, actual'), findsOneWidget);
        expect(find.bySemanticsLabel('Raichu'), findsOneWidget);
        semantics.dispose();
      },
    );

    testWidgets('lee cada movimiento con su nivel, nombre y tipo', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      useScreen(tester, const Size(800, 600));
      await pumpDetail(tester);
      await openTab(tester, 'Movimientos');

      expect(
        find.bySemanticsLabel('Nivel 1, Impactrueno, tipo Eléctrico'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Nivel 6, Ataque Rápido, tipo Normal'),
        findsOneWidget,
      );
      semantics.dispose();
    });

    testWidgets('en inglés usa los textos en inglés', (tester) async {
      final semantics = tester.ensureSemantics();
      useScreen(tester, const Size(800, 600));
      await pumpDetail(tester, locale: const Locale('en'));

      expect(find.bySemanticsLabel('Image of Pikachu'), findsOneWidget);
      expect(find.bySemanticsLabel('Number 25'), findsOneWidget);

      await openTab(tester, 'Stats');
      expect(
        find.bySemanticsLabel(RegExp(r'^Attack: 55 of 255, 22\s?%$')),
        findsOneWidget,
      );
      semantics.dispose();
    });
  });

  group('diseño adaptable', () {
    void expectTwoPanes(WidgetTester tester) {
      expect(find.byType(DetailSidePanel), findsOneWidget);
      expect(find.byType(DetailHeader), findsNothing);
      expect(
        tester.getTopLeft(find.byType(TabBar)).dx,
        greaterThanOrEqualTo(
          tester.getTopRight(find.byType(DetailSidePanel)).dx,
        ),
      );
    }

    testWidgets('un teléfono en horizontal muestra dos paneles', (
      tester,
    ) async {
      useScreen(tester, const Size(914, 411));
      await pumpDetail(tester);

      expectTwoPanes(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('una tableta muestra dos paneles', (tester) async {
      useScreen(tester, const Size(1280, 800));
      await pumpDetail(tester);

      expectTwoPanes(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('por debajo de 840 dp hay una sola columna', (tester) async {
      useScreen(tester, const Size(800, 600));
      await pumpDetail(tester);

      expect(find.byType(DetailHeader), findsOneWidget);
      expect(find.byType(DetailSidePanel), findsNothing);
    });

    testWidgets(
      'girar el teléfono ida y vuelta conserva pestaña, forma y shiny',
      (tester) async {
        useScreen(tester, const Size(411, 914));
        detailRepository.emitDetail(
          10080,
          PokemonDetail(
            pokemon: pikachuRockStar,
            moveVersionGroup: 'scarlet-violet',
            moves: pikachuDetail.moves,
            detailSyncedAt: pikachuSavedAt,
          ),
        );
        await pumpDetail(tester);

        await tester.tap(find.text('Rock Star'));
        await tester.pump();
        await tester.tap(find.byTooltip('Ver versión shiny'));
        await tester.pump();
        await openTab(tester, 'Movimientos');

        void expectStateKept() {
          expect(
            DefaultTabController.of(tester.element(find.byType(TabBar))).index,
            3,
          );
          expect(find.text('Pikachu Rock Star'), findsOneWidget);
          expect(find.byTooltip('Ver versión normal'), findsOneWidget);
          expect(find.text('Impactrueno'), findsOneWidget);
          expect(tester.takeException(), isNull);
        }

        for (final size in const [Size(914, 411), Size(411, 914)]) {
          tester.view.physicalSize = size;
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          expect(
            find.byType(DetailSidePanel),
            size.width > size.height ? findsOneWidget : findsNothing,
          );
          expectStateKept();
        }
      },
    );
  });
}
