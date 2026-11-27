import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:pokedex_flutter/core/theme/color_contrast.dart';

void main() {
  const black = Color(0xFF000000);
  const white = Color(0xFFFFFFFF);

  group('contrastRatioBetween', () {
    test('negro sobre blanco da 21:1 en cualquier orden', () {
      expect(contrastRatioBetween(black, white), closeTo(21, 0.01));
      expect(contrastRatioBetween(white, black), closeTo(21, 0.01));
    });

    test('un color contra sí mismo da 1:1', () {
      const fire = Color(0xFFEE8130);

      expect(contrastRatioBetween(fire, fire), closeTo(1, 0.0001));
    });

    test(
      'el gris medio de Material queda por debajo de AA con texto blanco',
      () {
        const grey = Color(0xFF9E9E9E);

        expect(contrastRatioBetween(white, grey), lessThan(4.5));
      },
    );
  });

  group('readableTextColorOn', () {
    test('elige blanco sobre el color del tipo siniestro', () {
      expect(readableTextColorOn(const Color(0xFF705746)), white);
    });

    test('elige negro sobre el color del tipo eléctrico', () {
      expect(readableTextColorOn(const Color(0xFFF7D02C)), black);
    });

    test('cualquier fondo opaco consigue al menos 4,5:1', () {
      for (var red = 0; red <= 255; red += 15) {
        for (var green = 0; green <= 255; green += 15) {
          for (var blue = 0; blue <= 255; blue += 15) {
            final background = Color.fromARGB(255, red, green, blue);
            final text = readableTextColorOn(background);

            expect(
              contrastRatioBetween(text, background),
              greaterThanOrEqualTo(4.5),
              reason: 'fondo $background',
            );
          }
        }
      }
    });
  });
}
