import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pokedex_flutter/core/theme/color_contrast.dart';
import 'package:pokedex_flutter/features/catalog/presentation/theme/detail_color_scheme.dart';
import 'package:pokedex_flutter/features/catalog/presentation/theme/pokemon_type_palette.dart';

void main() {
  const textContrast = 4.5;
  const graphicContrast = 3.0;

  final rolePairs =
      <
        ({
          String name,
          Color Function(ColorScheme) foreground,
          Color Function(ColorScheme) background,
          double minimum,
        })
      >[
        (
          name: 'texto sobre la superficie',
          foreground: (scheme) => scheme.onSurface,
          background: (scheme) => scheme.surface,
          minimum: textContrast,
        ),
        (
          name: 'número y vigencia sobre la superficie',
          foreground: (scheme) => scheme.onSurfaceVariant,
          background: (scheme) => scheme.surface,
          minimum: textContrast,
        ),
        (
          name: 'pestaña seleccionada sobre la superficie',
          foreground: (scheme) => scheme.primary,
          background: (scheme) => scheme.surface,
          minimum: textContrast,
        ),
        (
          name: 'chip seleccionado',
          foreground: (scheme) => scheme.onSecondaryContainer,
          background: (scheme) => scheme.secondaryContainer,
          minimum: textContrast,
        ),
        (
          name: 'icono sobre el fondo de la imagen',
          foreground: (scheme) => scheme.onPrimaryContainer,
          background: (scheme) => scheme.primaryContainer,
          minimum: textContrast,
        ),
        (
          name: 'barra de estadística sobre su pista',
          foreground: (scheme) => scheme.primary,
          background: (scheme) => scheme.surfaceContainerHighest,
          minimum: graphicContrast,
        ),
      ];

  for (final brightness in Brightness.values) {
    group('tema ${brightness.name}', () {
      for (final typeName in pokemonTypePalette.keys) {
        test('el esquema de $typeName cumple el contraste en cada par', () {
          final scheme = detailColorSchemeOf(typeName, brightness)!;

          expect(scheme.brightness, brightness);
          for (final pair in rolePairs) {
            expect(
              contrastRatioBetween(
                pair.foreground(scheme),
                pair.background(scheme),
              ),
              greaterThanOrEqualTo(pair.minimum),
              reason: pair.name,
            );
          }
        });
      }
    });
  }

  test('sin tipo o con un tipo desconocido no hay esquema propio', () {
    expect(detailColorSchemeOf(null, Brightness.light), isNull);
    expect(detailColorSchemeOf('stellar', Brightness.light), isNull);
  });

  test('reutiliza el esquema calculado para el mismo tipo y brillo', () {
    expect(
      identical(
        detailColorSchemeOf('fire', Brightness.dark),
        detailColorSchemeOf(' Fire ', Brightness.dark),
      ),
      isTrue,
    );
  });

  test('tipos distintos dan colores principales distintos', () {
    final primaries = {
      for (final typeName in pokemonTypePalette.keys)
        detailColorSchemeOf(typeName, Brightness.light)!.primaryContainer,
    };

    expect(primaries, hasLength(pokemonTypePalette.length));
  });

  group('detailThemeOf', () {
    final appTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
    );

    test('usa el primer tipo y pinta el fondo con su superficie', () {
      final theme = detailThemeOf(appTheme, ['fire', 'flying']);
      final fire = detailColorSchemeOf('fire', Brightness.light)!;

      expect(theme.colorScheme, fire);
      expect(theme.scaffoldBackgroundColor, fire.surface);
      expect(theme.canvasColor, fire.surface);
    });

    test('conserva el tema de la app si el tipo no se conoce', () {
      expect(identical(detailThemeOf(appTheme, const []), appTheme), isTrue);
      expect(identical(detailThemeOf(appTheme, ['shadow']), appTheme), isTrue);
    });

    test('sigue el brillo del tema de la app', () {
      final darkAppTheme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
      );

      expect(
        detailThemeOf(darkAppTheme, ['water']).colorScheme,
        detailColorSchemeOf('water', Brightness.dark),
      );
    });
  });
}
