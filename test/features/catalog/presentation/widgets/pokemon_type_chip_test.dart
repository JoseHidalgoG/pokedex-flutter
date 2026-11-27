import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pokedex_flutter/core/theme/color_contrast.dart';
import 'package:pokedex_flutter/features/catalog/presentation/theme/pokemon_type_palette.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/pokemon_type_chip.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

void main() {
  final allTypes = pokemonTypePalette.keys.toList();

  Future<void> pumpChips(
    WidgetTester tester,
    List<String> typeNames, {
    Brightness brightness = Brightness.light,
    Locale locale = const Locale('es'),
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red,
            brightness: brightness,
          ),
        ),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final typeName in typeNames)
                  PokemonTypeChip(typeName: typeName),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color chipBackgroundOf(WidgetTester tester, String typeName) {
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byWidgetPredicate(
          (widget) => widget is PokemonTypeChip && widget.typeName == typeName,
        ),
        matching: find.byType(Container),
      ),
    );
    return (container.decoration! as BoxDecoration).color!;
  }

  Color chipTextColorOf(WidgetTester tester, String typeName) {
    final text = tester.widget<Text>(
      find.descendant(
        of: find.byWidgetPredicate(
          (widget) => widget is PokemonTypeChip && widget.typeName == typeName,
        ),
        matching: find.byType(Text),
      ),
    );
    return text.style!.color!;
  }

  test('la paleta tiene los 18 tipos', () {
    expect(allTypes, hasLength(18));
  });

  test('un tipo desconocido usa el gris de respaldo', () {
    expect(pokemonTypeColorOf('stellar'), unknownTypeColor);
    expect(pokemonTypeColorOf(' Fire '), pokemonTypePalette['fire']);
  });

  for (final brightness in Brightness.values) {
    group('tema ${brightness.name}', () {
      testWidgets(
        'el texto de cada tipo y del desconocido llega a 4,5:1 sobre su chip',
        (tester) async {
          final typeNames = [...allTypes, 'stellar'];
          await pumpChips(tester, typeNames, brightness: brightness);

          for (final typeName in typeNames) {
            final background = chipBackgroundOf(tester, typeName);
            final text = chipTextColorOf(tester, typeName);

            expect(background, pokemonTypeColorOf(typeName));
            expect(
              contrastRatioBetween(text, background),
              greaterThanOrEqualTo(4.5),
              reason: typeName,
            );
          }
        },
      );

      testWidgets('los 18 chips cumplen la guía de contraste de texto', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        await pumpChips(tester, allTypes, brightness: brightness);

        await expectLater(tester, meetsGuideline(textContrastGuideline));
        semantics.dispose();
      });
    });
  }

  testWidgets('muestra el nombre del tipo en el idioma de la app', (
    tester,
  ) async {
    await pumpChips(tester, ['dark']);
    expect(find.text('Siniestro'), findsOneWidget);

    await pumpChips(tester, ['dark'], locale: const Locale('en'));
    expect(find.text('Dark'), findsOneWidget);
  });

  testWidgets('usa el estilo labelMedium del tema', (tester) async {
    await pumpChips(tester, ['fire']);

    final text = tester.widget<Text>(find.text('Fuego'));
    final labelMedium = Theme.of(tester.element(find.text('Fuego')))
        .textTheme
        .labelMedium!;

    expect(text.style!.fontSize, labelMedium.fontSize);
    expect(text.style!.fontWeight, FontWeight.w600);
  });
}
