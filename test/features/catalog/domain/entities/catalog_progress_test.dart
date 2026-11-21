import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_progress.dart';

void main() {
  test('está completo cuando guardó todos los Pokémon que hay en PokeAPI', () {
    expect(
      const CatalogProgress(savedCount: 1025, totalCount: 1025).isComplete,
      isTrue,
    );
  });

  test('está incompleto mientras faltan Pokémon por guardar', () {
    expect(
      const CatalogProgress(savedCount: 200, totalCount: 1025).isComplete,
      isFalse,
    );
  });

  test('está incompleto cuando todavía no conoce el total', () {
    expect(const CatalogProgress(savedCount: 0).isComplete, isFalse);
  });

  test('dos progresos con los mismos números son iguales', () {
    expect(
      const CatalogProgress(savedCount: 2, totalCount: 3),
      const CatalogProgress(savedCount: 2, totalCount: 3),
    );
  });
}
