import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/data/catalog_differences.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';

CatalogEntry pikachuWith({
  String name = 'pikachu',
  List<String> typeNames = const ['electric'],
  Map<String, int> baseStats = const {'hp': 35, 'speed': 90},
  int? heightDm = 4,
  int? weightHg = 60,
  int? generationId = 1,
  int? speciesId = 25,
}) {
  return CatalogEntry(
    id: 25,
    name: name,
    imageUrl: 'https://example.com/25.png',
    typeNames: typeNames,
    speciesId: speciesId,
    generationId: generationId,
    heightDm: heightDm,
    weightHg: weightHg,
    baseStats: baseStats,
  );
}

void main() {
  test('dos entradas iguales no tienen diferencias', () {
    expect(catalogDifferencesBetween(pikachuWith(), pikachuWith()), isEmpty);
  });

  test('describe el nombre local y el remoto', () {
    expect(
      catalogDifferencesBetween(pikachuWith(name: 'pikachux'), pikachuWith()),
      ['name: pikachux → pikachu'],
    );
  });

  test('muestra los tipos en orden de slot', () {
    expect(
      catalogDifferencesBetween(
        pikachuWith(typeNames: ['fire', 'flying']),
        pikachuWith(),
      ),
      ['types: fire,flying → electric'],
    );
  });

  test('detecta dos tipos que solo cambiaron de orden', () {
    expect(
      catalogDifferencesBetween(
        pikachuWith(typeNames: ['poison', 'grass']),
        pikachuWith(typeNames: ['grass', 'poison']),
      ),
      ['types: poison,grass → grass,poison'],
    );
  });

  test('nombra cada estadística distinta', () {
    expect(
      catalogDifferencesBetween(
        pikachuWith(baseStats: {'hp': 35, 'speed': 1}),
        pikachuWith(),
      ),
      ['stats.speed: 1 → 90'],
    );
  });

  test('marca con ∅ lo que falta en un lado', () {
    expect(
      catalogDifferencesBetween(
        pikachuWith(typeNames: [], baseStats: {'hp': 35}),
        pikachuWith(),
      ),
      ['types: ∅ → electric', 'stats.speed: ∅ → 90'],
    );
  });

  test('incluye generación, especie, altura y peso', () {
    expect(
      catalogDifferencesBetween(
        pikachuWith(generationId: 9, speciesId: 1, heightDm: 40, weightHg: 6),
        pikachuWith(),
      ),
      [
        'generation: 9 → 1',
        'species: 1 → 25',
        'height: 40 → 4',
        'weight: 6 → 60',
      ],
    );
  });

  test('lista varias diferencias a la vez en un orden fijo', () {
    expect(
      catalogDifferencesBetween(
        pikachuWith(name: 'pikachux', baseStats: {'hp': 1, 'speed': 1}),
        pikachuWith(),
      ),
      ['name: pikachux → pikachu', 'stats.hp: 1 → 35', 'stats.speed: 1 → 90'],
    );
  });
}
