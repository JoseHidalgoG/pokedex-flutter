import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/ability_effect.dart';

void main() {
  test('un efecto de hasta 160 caracteres queda igual', () {
    final effect = 'a' * 160;

    expect(trimmedEffect(effect), effect);
  });

  test('un efecto largo se corta en un límite de palabra con 160 caracteres como máximo', () {
    const effect =
        'Los movimientos de contacto que recibe pueden paralizar al atacante. '
        'Si el Pokémon lleva este objeto, la probabilidad sube un poco más '
        'y además se activa al entrar en combate contra rivales de tipo agua.';

    final trimmed = trimmedEffect(effect);

    expect(effect.length, greaterThan(160));
    expect(trimmed.length, lessThanOrEqualTo(160));
    expect(trimmed, endsWith('…'));
    final kept = trimmed.substring(0, trimmed.length - 1);
    expect(effect, startsWith(kept));
    expect(effect[kept.length], ' ');
  });

  test('no deja una coma ni un punto antes de los puntos suspensivos', () {
    final effect = '${'palabra ' * 18}fin, y sigue mucho más allá del límite';

    final trimmed = trimmedEffect(effect, maxLength: 150);

    expect(trimmed, isNot(contains(',…')));
    expect(trimmed, endsWith('fin…'));
  });

  test('una sola palabra más larga que el límite se corta en seco', () {
    final trimmed = trimmedEffect('x' * 200);

    expect(trimmed, '${'x' * 159}…');
  });

  test('quita los espacios de los extremos', () {
    expect(trimmedEffect('  Aumenta la velocidad.  '), 'Aumenta la velocidad.');
  });
}
