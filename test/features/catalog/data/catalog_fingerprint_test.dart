import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/data/catalog_fingerprint.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';

const bulbasaurStats = {
  'hp': 45,
  'attack': 49,
  'defense': 49,
  'special-attack': 65,
  'special-defense': 65,
  'speed': 45,
};

CatalogEntry bulbasaurWith({
  List<String> typeNames = const ['grass', 'poison'],
  Map<String, int> baseStats = bulbasaurStats,
}) {
  return CatalogEntry(
    id: 1,
    name: 'bulbasaur',
    imageUrl: 'https://example.com/1.png',
    typeNames: typeNames,
    speciesId: 1,
    generationId: 1,
    heightDm: 7,
    weightHg: 69,
    baseStats: baseStats,
  );
}

void main() {
  test('es el SHA-256 del texto canónico y no cambia entre ejecuciones', () {
    const sha256OfBulbasaurCanonicalText =
        'e3a93d042c649e124c3c335c77e64b3d268f071ab4e1bf56c86d3d7c4a58a1eb';

    expect(
      catalogFingerprintOf(bulbasaurWith()),
      sha256OfBulbasaurCanonicalText,
    );
    expect(
      catalogFingerprintOf(bulbasaurWith()),
      catalogFingerprintOf(bulbasaurWith()),
    );
  });

  test('cambia cuando cambia una estadística', () {
    final strongerBulbasaur = bulbasaurWith(
      baseStats: {...bulbasaurStats, 'attack': 50},
    );

    expect(
      catalogFingerprintOf(strongerBulbasaur),
      isNot(catalogFingerprintOf(bulbasaurWith())),
    );
  });

  test('cambia cuando los tipos cambian de orden', () {
    final swappedTypes = bulbasaurWith(typeNames: ['poison', 'grass']);

    expect(
      catalogFingerprintOf(swappedTypes),
      isNot(catalogFingerprintOf(bulbasaurWith())),
    );
  });

  test('no depende del orden en que llegan las estadísticas', () {
    final reversedStats = Map.fromEntries(
      bulbasaurStats.entries.toList().reversed,
    );

    expect(
      catalogFingerprintOf(bulbasaurWith(baseStats: reversedStats)),
      catalogFingerprintOf(bulbasaurWith()),
    );
  });

  group('comparar con la huella guardada', () {
    test('una huella nula no cuenta como diferencia', () {
      expect(
        differsFromStoredFingerprint(bulbasaurWith(), stored: null),
        isFalse,
      );
    });

    test('la huella del mismo dato no es una diferencia', () {
      final stored = catalogFingerprintOf(bulbasaurWith());

      expect(
        differsFromStoredFingerprint(bulbasaurWith(), stored: stored),
        isFalse,
      );
    });

    test('un tipo cambiado sí es una diferencia', () {
      final stored = catalogFingerprintOf(bulbasaurWith());

      expect(
        differsFromStoredFingerprint(
          bulbasaurWith(typeNames: ['fire']),
          stored: stored,
        ),
        isTrue,
      );
    });

    test('idsWithDifferentStoredFingerprint devuelve solo los ids con una huella guardada distinta', () {
      const ivysaur = CatalogEntry(
        id: 2,
        name: 'ivysaur',
        imageUrl: 'https://example.com/2.png',
        typeNames: ['grass', 'poison'],
      );
      const venusaur = CatalogEntry(
        id: 3,
        name: 'venusaur',
        imageUrl: 'https://example.com/3.png',
        typeNames: ['grass', 'poison'],
      );

      final ids = idsWithDifferentStoredFingerprint(
        [bulbasaurWith(), ivysaur, venusaur],
        storedFingerprints: {
          1: catalogFingerprintOf(bulbasaurWith()),
          2: 'huella-alterada',
          3: null,
        },
      );

      expect(ids, [2]);
    });
  });
}
