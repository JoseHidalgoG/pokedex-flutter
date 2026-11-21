import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/detail_freshness.dart';

void main() {
  final savedAt = DateTime(2026, 11, 10, 9, 15);
  final revalidatedAt = DateTime(2026, 11, 24, 10, 42);

  test('una revalidación en esta sesión es dato fresco de PokeAPI', () {
    expect(
      detailFreshnessOf(
        revalidatedThisSessionAt: revalidatedAt,
        savedAt: revalidatedAt,
      ),
      FreshFromPokeApi(revalidatedAt),
    );
  });

  test('sin revalidación en esta sesión es dato local con su fecha', () {
    final freshness = detailFreshnessOf(
      revalidatedThisSessionAt: null,
      savedAt: savedAt,
    );

    expect(freshness, LocalData(savedAt: savedAt));
    expect((freshness as LocalData).hasStoredDetail, isTrue);
  });

  test('sin detalle guardado es dato local sin fecha', () {
    final freshness = detailFreshnessOf(
      revalidatedThisSessionAt: null,
      savedAt: null,
    );

    expect(freshness, const LocalData());
    expect((freshness as LocalData).hasStoredDetail, isFalse);
  });
}
