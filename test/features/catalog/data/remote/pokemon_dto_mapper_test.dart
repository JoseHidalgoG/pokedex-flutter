import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto_mapper.dart';

void main() {
  const charizard = PokemonDto(
    id: 6,
    name: 'charizard',
    typeNames: ['fire', 'flying'],
    speciesId: 6,
    generationId: 1,
    heightDm: 17,
    weightHg: 905,
    baseStats: {
      'hp': 78,
      'attack': 84,
      'defense': 78,
      'special-attack': 109,
      'special-defense': 85,
      'speed': 100,
    },
    officialArtworkUrl: 'https://example.com/6.png',
  );

  test('construye la URL del arte oficial a partir del número', () {
    expect(
      officialArtworkUrlFor(25),
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png',
    );
  });

  test('conserva todos los campos al convertir a CatalogEntry', () {
    final entry = charizard.toCatalogEntry();

    expect(entry.id, 6);
    expect(entry.name, 'charizard');
    expect(entry.typeNames, ['fire', 'flying']);
    expect(entry.speciesId, 6);
    expect(entry.generationId, 1);
    expect(entry.isDefault, isTrue);
    expect(entry.heightDm, 17);
    expect(entry.weightHg, 905);
    expect(entry.baseStats, charizard.baseStats);
  });

  test('suma las estadísticas base en el total', () {
    expect(charizard.toCatalogEntry().baseStatTotal, 534);
  });

  test('deja el total desconocido cuando no llegan estadísticas', () {
    const withoutStats = PokemonDto(
      id: 6,
      name: 'charizard',
      typeNames: ['fire', 'flying'],
    );

    expect(withoutStats.toCatalogEntry().baseStatTotal, isNull);
  });

  test('usa la URL del arte oficial que trae PokeAPI', () {
    expect(charizard.toCatalogEntry().imageUrl, 'https://example.com/6.png');
  });

  test('construye la URL del arte oficial cuando PokeAPI no la trae', () {
    const withoutArtwork = PokemonDto(
      id: 6,
      name: 'charizard',
      typeNames: ['fire', 'flying'],
    );

    expect(withoutArtwork.toCatalogEntry().imageUrl, officialArtworkUrlFor(6));
  });
}
