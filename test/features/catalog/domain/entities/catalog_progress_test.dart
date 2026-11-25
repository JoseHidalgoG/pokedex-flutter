import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_progress.dart';

void main() {
  group('CatalogProgress', () {
    test('está completo cuando los metadatos lo indican', () {
      const progress = CatalogProgress(
        savedCount: 1025,
        totalCount: 1025,
        isComplete: true,
      );

      expect(progress.isComplete, isTrue);
    });

    test('está incompleto mientras faltan Pokémon por guardar', () {
      const progress = CatalogProgress(
        savedCount: 200,
        totalCount: 1025,
        isComplete: false,
      );

      expect(progress.isComplete, isFalse);
    });

    test('está incompleto cuando todavía no conoce el total', () {
      const progress = CatalogProgress(savedCount: 0, isComplete: false);

      expect(progress.totalCount, isNull);
      expect(progress.isComplete, isFalse);
    });

    test('dos progresos con los mismos atributos son iguales', () {
      expect(
        const CatalogProgress(savedCount: 2, totalCount: 3, isComplete: false),
        const CatalogProgress(savedCount: 2, totalCount: 3, isComplete: false),
      );
    });

    test('no deduce completitud cuando las cantidades coinciden', () {
      const progress = CatalogProgress(
        savedCount: 1025,
        totalCount: 1025,
        isComplete: false,
      );

      expect(progress.isComplete, isFalse);
    });

    test('no deduce completitud cuando supera el total esperado', () {
      const progress = CatalogProgress(
        savedCount: 1030,
        totalCount: 1025,
        isComplete: false,
      );

      expect(progress.isComplete, isFalse);
    });

    test('respeta la completitud explícita con total desconocido', () {
      const progress = CatalogProgress(savedCount: 1025, isComplete: true);

      expect(progress.totalCount, isNull);
      expect(progress.isComplete, isTrue);
    });

    test('distinto estado de completitud produce entidades diferentes', () {
      const incomplete = CatalogProgress(
        savedCount: 1025,
        totalCount: 1025,
        isComplete: false,
      );

      const complete = CatalogProgress(
        savedCount: 1025,
        totalCount: 1025,
        isComplete: true,
      );

      expect(incomplete, isNot(complete));
    });

    test('distinta cantidad guardada produce entidades diferentes', () {
      const first = CatalogProgress(
        savedCount: 200,
        totalCount: 1025,
        isComplete: false,
      );

      const second = CatalogProgress(
        savedCount: 300,
        totalCount: 1025,
        isComplete: false,
      );

      expect(first, isNot(second));
    });

    test('distinto total esperado produce entidades diferentes', () {
      const first = CatalogProgress(
        savedCount: 200,
        totalCount: 1025,
        isComplete: false,
      );

      const second = CatalogProgress(
        savedCount: 200,
        totalCount: 1100,
        isComplete: false,
      );

      expect(first, isNot(second));
    });

    test('entidades iguales tienen el mismo hashCode', () {
      const first = CatalogProgress(
        savedCount: 200,
        totalCount: 1025,
        isComplete: false,
      );

      const second = CatalogProgress(
        savedCount: 200,
        totalCount: 1025,
        isComplete: false,
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('toString incluye todos los atributos del progreso', () {
      const progress = CatalogProgress(
        savedCount: 200,
        totalCount: 1025,
        isComplete: false,
      );

      expect(
        progress.toString(),
        'CatalogProgress(savedCount: 200, '
        'totalCount: 1025, isComplete: false)',
      );
    });
  });
}
