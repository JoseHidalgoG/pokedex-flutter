import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/share/share_text_provider.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/detail_freshness.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_detail.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/type_matchups.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/pokemon_detail_providers.dart';
import 'package:pokedex_flutter/features/catalog/presentation/screens/pokemon_detail_screen.dart';
import 'package:pokedex_flutter/features/catalog/presentation/theme/detail_color_scheme.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/detail/detail_artwork.dart';
import 'package:pokedex_flutter/features/favorites/presentation/providers/favorites_providers.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

import '../../../favorites/fakes/fake_favorites_repository.dart';
import '../../fakes/fake_pokemon_detail_repository.dart';
import '../../fakes/pikachu_detail.dart';

void main() {
  late FakePokemonDetailRepository detailRepository;
  late FakeFavoritesRepository favoritesRepository;
  late List<String> sharedTexts;

  setUp(() {
    detailRepository = FakePokemonDetailRepository();
    favoritesRepository = FakeFavoritesRepository();
    sharedTexts = [];
  });

  tearDown(() async {
    await detailRepository.dispose();
    await favoritesRepository.dispose();
  });

  Future<void> pumpDetail(
    WidgetTester tester, {
    Pokemon pokemon = pikachu,
    Locale locale = const Locale('es'),
    ThemeData? theme,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pokemonDetailRepositoryProvider.overrideWithValue(detailRepository),
          favoritesRepositoryProvider.overrideWith(
            (ref) => favoritesRepository,
          ),
          shareTextProvider.overrideWithValue((
            text, {
            required subject,
            origin,
          }) async {
            sharedTexts.add(text);
          }),
        ],
        child: MaterialApp(
          locale: locale,
          theme: theme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PokemonDetailScreen(pokemon: pokemon),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> openTab(WidgetTester tester, String tabName) async {
    final tab = find.widgetWithText(Tab, tabName);
    await tester.ensureVisible(tab);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(tab);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  List<int> revalidatedIds() => [
    for (final revalidation in detailRepository.revalidations) revalidation.id,
  ];

  testWidgets(
    'pinta el encabezado del catálogo antes de que llegue el detalle',
    (tester) async {
      await pumpDetail(tester);

      expect(find.text('#0025'), findsOneWidget);
      expect(find.text('Pikachu'), findsOneWidget);
      expect(find.text('Eléctrico'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      detailRepository.emitDetail(25, pikachuDetail);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Electricidad Estática'), findsOneWidget);
    },
  );

  testWidgets(
    'dice «Actualizado desde PokeAPI» solo después de una revalidación',
    (tester) async {
      detailRepository
        ..emitDetail(25, pikachuDetail)
        ..emitFreshness(25, LocalData(savedAt: pikachuSavedAt));

      await pumpDetail(tester);

      expect(find.text('Datos locales del 10/11 · 09:15'), findsOneWidget);
      expect(find.textContaining('Actualizado desde PokeAPI'), findsNothing);

      detailRepository.emitFreshness(25, FreshFromPokeApi(DateTime.now()));
      await tester.pump();

      expect(
        find.text('Actualizado desde PokeAPI hace un momento'),
        findsOneWidget,
      );
      expect(find.textContaining('Datos locales'), findsNothing);
    },
  );

  testWidgets(
    'muestra los datos del catálogo y «Sin detalle guardado» sin descarga',
    (tester) async {
      detailRepository.emitDetail(
        25,
        PokemonDetail(
          pokemon: pikachu,
          heightInMeters: 0.4,
          weightInKilograms: 6,
          baseStats: pikachuDetail.baseStats,
        ),
      );

      await pumpDetail(tester);

      expect(
        find.text('Sin detalle guardado · se descargará con conexión'),
        findsOneWidget,
      );
      expect(find.text('0,4 m'), findsOneWidget);
      expect(find.text('Se descargará con conexión'), findsNWidgets(3));

      await openTab(tester, 'Estadísticas');

      expect(find.text('320'), findsOneWidget);
    },
  );

  testWidgets('el favorito reacciona en el detalle', (tester) async {
    detailRepository.emitDetail(25, pikachuDetail);
    await pumpDetail(tester);

    await tester.tap(find.byTooltip('Agregar a favoritos'));
    await tester.pump();
    await tester.pump();

    expect(await favoritesRepository.isFavorite(25), isTrue);
    expect(find.byTooltip('Quitar de favoritos'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('los chips de movimientos filtran la lista', (tester) async {
    detailRepository.emitDetail(25, pikachuDetail);
    await pumpDetail(tester);

    await openTab(tester, 'Movimientos');

    expect(find.text('Movimientos de Scarlet Violet'), findsOneWidget);
    expect(find.text('Impactrueno'), findsOneWidget);
    expect(find.text('Ataque Rápido'), findsOneWidget);
    expect(find.text('Rayo'), findsNothing);
    expect(
      tester.getTopLeft(find.text('Impactrueno')).dy,
      lessThan(tester.getTopLeft(find.text('Ataque Rápido')).dy),
    );

    await tester.tap(find.text('MT (1)'));
    await tester.pump();

    expect(find.text('Rayo'), findsOneWidget);
    expect(find.text('Impactrueno'), findsNothing);

    await tester.tap(find.text('Tutor (0)'));
    await tester.pump();

    expect(find.text('Rayo'), findsOneWidget);
  });

  testWidgets('ordena los movimientos por nivel o por nombre', (tester) async {
    detailRepository.emitDetail(25, pikachuDetail);
    await pumpDetail(tester);
    await openTab(tester, 'Movimientos');

    await tester.tap(find.text('Por nombre'));
    await tester.pump();

    expect(
      tester.getTopLeft(find.text('Ataque Rápido')).dy,
      lessThan(tester.getTopLeft(find.text('Impactrueno')).dy),
    );
  });

  testWidgets('el selector de formas cambia los datos mostrados', (
    tester,
  ) async {
    detailRepository.emitDetail(25, pikachuDetail);
    await pumpDetail(tester);

    expect(find.text('Rock Star'), findsOneWidget);

    await tester.tap(find.text('Rock Star'));
    await tester.pump();

    expect(find.text('Pikachu Rock Star'), findsOneWidget);
    expect(find.text('#10080'), findsOneWidget);

    detailRepository.emitDetail(
      10080,
      PokemonDetail(
        pokemon: pikachuRockStar,
        heightInMeters: 0.4,
        weightInKilograms: 6,
        abilities: pikachuDetail.abilities.take(1).toList(),
        detailSyncedAt: pikachuSavedAt,
      ),
    );
    await tester.pump();

    expect(find.text('Pararrayos'), findsNothing);
    expect(find.text('Electricidad Estática'), findsOneWidget);
    expect(revalidatedIds(), [25, 10080]);
    expect(find.text('Rock Star'), findsOneWidget);
  });

  testWidgets('deslizar hacia abajo fuerza la descarga del detalle', (
    tester,
  ) async {
    detailRepository.emitDetail(25, pikachuDetail);
    await pumpDetail(tester);

    await tester.fling(
      find.text('Electricidad Estática'),
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();

    expect(detailRepository.revalidations, [
      (id: 25, force: false),
      (id: 25, force: true),
    ]);
  });

  testWidgets(
    'en una pantalla baja el encabezado se desplaza y deja ver la pestaña',
    (tester) async {
      tester.view
        ..physicalSize = const Size(915, 300)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      detailRepository.emitDetail(25, pikachuDetail);
      await pumpDetail(tester);

      final tabBarTop = tester.getTopLeft(find.byType(TabBar)).dy;
      await tester.drag(find.text('#0025'), const Offset(0, -400));
      await tester.pump();

      expect(tester.getTopLeft(find.byType(TabBar)).dy, lessThan(tabBarTop));
      expect(find.text('#0025'), findsNothing);
      expect(find.text('Electricidad Estática'), findsOneWidget);
    },
  );

  testWidgets('muestra habilidades y grupos huevo en el idioma de la app', (
    tester,
  ) async {
    detailRepository.emitDetail(25, pikachuDetail);
    await pumpDetail(tester, locale: const Locale('en'));

    expect(find.text('Static'), findsOneWidget);
    expect(find.text('Lightning Rod'), findsOneWidget);
    expect(find.text('Hidden'), findsOneWidget);
    expect(find.text('Field'), findsOneWidget);
    expect(find.text('0.4 m'), findsOneWidget);
    expect(
      find.text('Has a 30% chance of paralyzing attacking Pokémon on contact.'),
      findsOneWidget,
    );
  });

  testWidgets('muestra las estadísticas con su total', (tester) async {
    detailRepository.emitDetail(25, pikachuDetail);
    await pumpDetail(tester);

    await openTab(tester, 'Estadísticas');

    expect(find.text('PS'), findsOneWidget);
    expect(find.text('90'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('320'), findsOneWidget);
  });

  testWidgets('muestra el árbol de evoluciones con sus triggers', (
    tester,
  ) async {
    detailRepository.emitDetail(25, pikachuDetail);
    await pumpDetail(tester);

    await openTab(tester, 'Evoluciones');

    expect(find.text('Pichu'), findsOneWidget);
    expect(find.text('Raichu'), findsOneWidget);
    expect(find.text('Amistad'), findsOneWidget);
    expect(find.text('Thunder Stone'), findsOneWidget);
  });

  testWidgets('agrupa los matchups cuando la tabla de tipos está guardada', (
    tester,
  ) async {
    detailRepository.emitDetail(25, pikachuDetail);
    await pumpDetail(tester);
    await openTab(tester, 'Matchups');

    expect(find.textContaining('Tabla de tipos pendiente'), findsOneWidget);

    detailRepository.emitTypeEfficacy(const [
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
      TypeEfficacy(
        attackingType: 'fire',
        defendingType: 'electric',
        damageFactor: 100,
      ),
    ]);
    await tester.pump();

    expect(find.textContaining('Tabla de tipos pendiente'), findsNothing);
    expect(find.text('Débil · ×2'), findsOneWidget);
    expect(find.text('Tierra'), findsOneWidget);
    expect(find.text('Resiste · ×0,5'), findsOneWidget);
    expect(find.text('Acero'), findsOneWidget);
    expect(find.text('Fuego'), findsNothing);
  });

  testWidgets('comparte el Pokémon como texto', (tester) async {
    detailRepository.emitDetail(25, pikachuDetail);
    await pumpDetail(tester);

    await tester.tap(find.byTooltip('Compartir'));
    await tester.pump();

    expect(sharedTexts, ['Pikachu #0025\nEléctrico\nTotal base: 320']);
  });

  testWidgets('deja de revalidar el detalle al cerrar la pantalla', (
    tester,
  ) async {
    detailRepository.emitDetail(25, pikachuDetail);
    await pumpDetail(tester);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();

    expect(detailRepository.stoppedIds, contains(25));
  });

  group('color del detalle según el tipo', () {
    const charmander = Pokemon(
      id: 4,
      name: 'charmander',
      imageUrl: '',
      typeNames: ['fire'],
    );
    const marowak = Pokemon(
      id: 105,
      name: 'marowak',
      imageUrl: '',
      typeNames: ['ground'],
    );
    const alolanMarowak = Pokemon(
      id: 10115,
      name: 'marowak-alola',
      imageUrl: '',
      typeNames: ['fire', 'ghost'],
    );
    const shadowOnly = Pokemon(
      id: 9999,
      name: 'missingno',
      imageUrl: '',
      typeNames: ['shadow'],
    );

    ColorScheme detailSchemeIn(WidgetTester tester) {
      return Theme.of(tester.element(find.byType(TabBar))).colorScheme;
    }

    Color backdropColorIn(WidgetTester tester) {
      final backdrop = tester.widget<DecoratedBox>(
        find.byKey(detailArtworkBackdropKey),
      );
      return (backdrop.decoration as BoxDecoration).color!;
    }

    testWidgets('Pikachu toma el esquema del tipo eléctrico', (tester) async {
      await pumpDetail(tester);

      final electric = detailColorSchemeOf('electric', Brightness.light)!;
      expect(detailSchemeIn(tester), electric);
      expect(backdropColorIn(tester), electric.primaryContainer);
    });

    testWidgets('Charmander toma el esquema del fuego', (tester) async {
      await pumpDetail(tester, pokemon: charmander);

      expect(
        detailSchemeIn(tester),
        detailColorSchemeOf('fire', Brightness.light),
      );
    });

    testWidgets('elegir una forma con otro tipo principal cambia el color', (
      tester,
    ) async {
      detailRepository.emitDetail(
        105,
        const PokemonDetail(pokemon: marowak, forms: [marowak, alolanMarowak]),
      );
      await pumpDetail(tester, pokemon: marowak);

      expect(
        detailSchemeIn(tester),
        detailColorSchemeOf('ground', Brightness.light),
      );

      await tester.tap(find.text('Alola'));
      await tester.pump();
      await tester.pump(kThemeAnimationDuration);

      expect(
        detailSchemeIn(tester),
        detailColorSchemeOf('fire', Brightness.light),
      );
    });

    testWidgets('con el tema oscuro de la app usa el esquema oscuro del tipo', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red,
            brightness: Brightness.dark,
          ),
        ),
      );

      expect(
        detailSchemeIn(tester),
        detailColorSchemeOf('electric', Brightness.dark),
      );
    });

    testWidgets('con un tipo desconocido conserva los colores de la app', (
      tester,
    ) async {
      final appTheme = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      );
      await pumpDetail(tester, pokemon: shadowOnly, theme: appTheme);

      expect(detailSchemeIn(tester), appTheme.colorScheme);
    });
  });
}
