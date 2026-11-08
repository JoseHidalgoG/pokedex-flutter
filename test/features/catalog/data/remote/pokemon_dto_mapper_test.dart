import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto_mapper.dart';

void main() {
  test('construye la URL del arte oficial a partir del número', () {
    expect(
      officialArtworkUrlFor(25),
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png',
    );
  });

  test('conserva número, nombre y tipos al convertir a CatalogEntry', () {
    const charizard = PokemonDto(
      id: 6,
      name: 'charizard',
      typeNames: ['fire', 'flying'],
    );

    final entry = charizard.toCatalogEntry();

    expect(entry.id, 6);
    expect(entry.name, 'charizard');
    expect(entry.typeNames, ['fire', 'flying']);
    expect(entry.imageUrl, officialArtworkUrlFor(6));
  });

  test('ordena los tipos por slot aunque lleguen desordenados', () {
    final dto = PokemonDto.fromJson({
      'id': 6,
      'name': 'charizard',
      'pokemontypes': [
        {
          'slot': 2,
          'type': {'name': 'flying'},
        },
        {
          'slot': 1,
          'type': {'name': 'fire'},
        },
      ],
    });

    expect(dto.typeNames, ['fire', 'flying']);
  });

  test('rechaza un Pokémon sin nombre', () {
    expect(
      () => PokemonDto.fromJson({'id': 6, 'pokemontypes': <Object?>[]}),
      throwsFormatException,
    );
  });

  test('rechaza un tipo sin nombre', () {
    expect(
      () => PokemonDto.fromJson({
        'id': 6,
        'name': 'charizard',
        'pokemontypes': [
          {'slot': 1, 'type': <String, Object?>{}},
        ],
      }),
      throwsFormatException,
    );
  });
}
