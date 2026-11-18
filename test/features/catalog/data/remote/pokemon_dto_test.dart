import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto.dart';

import '../../../../fixtures/catalog_batch_fixture.dart';

void main() {
  Map<String, Object?> bulbasaurJsonWith(Map<String, Object?> changes) {
    return {...savedPokemonJson(name: 'bulbasaur'), ...changes};
  }

  test('lee todos los campos del catálogo de la respuesta guardada', () {
    final bulbasaur = PokemonDto.fromJson(savedPokemonJson(name: 'bulbasaur'));

    expect(bulbasaur.id, 1);
    expect(bulbasaur.name, 'bulbasaur');
    expect(bulbasaur.typeNames, ['grass', 'poison']);
    expect(bulbasaur.speciesId, 1);
    expect(bulbasaur.generationId, 1);
    expect(bulbasaur.isDefault, isTrue);
    expect(bulbasaur.heightDm, 7);
    expect(bulbasaur.weightHg, 69);
    expect(bulbasaur.baseStats, {
      'hp': 45,
      'attack': 49,
      'defense': 49,
      'special-attack': 65,
      'special-defense': 65,
      'speed': 45,
    });
    expect(
      bulbasaur.officialArtworkUrl,
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png',
    );
  });

  test('ordena los tipos por slot aunque lleguen desordenados', () {
    final dto = PokemonDto.fromJson(
      bulbasaurJsonWith({
        'pokemontypes': [
          {
            'slot': 2,
            'type': {'name': 'poison'},
          },
          {
            'slot': 1,
            'type': {'name': 'grass'},
          },
        ],
      }),
    );

    expect(dto.typeNames, ['grass', 'poison']);
  });

  test('acepta la altura, el peso y la especie nulos que PokeAPI permite', () {
    final dto = PokemonDto.fromJson(
      bulbasaurJsonWith({'height': null, 'weight': null, 'pokemonspecy': null}),
    );

    expect(dto.heightDm, isNull);
    expect(dto.weightHg, isNull);
    expect(dto.speciesId, isNull);
    expect(dto.generationId, isNull);
  });

  test('no tiene URL del arte oficial cuando PokeAPI no la trae', () {
    final withNullSprite = PokemonDto.fromJson(
      bulbasaurJsonWith({
        'pokemonsprites': [
          {'sprites': null},
        ],
      }),
    );
    final withoutSprites = PokemonDto.fromJson(
      bulbasaurJsonWith({'pokemonsprites': <Object?>[]}),
    );

    expect(withNullSprite.officialArtworkUrl, isNull);
    expect(withoutSprites.officialArtworkUrl, isNull);
  });

  test('rechaza un Pokémon al que le falta un campo pedido', () {
    const requestedFields = [
      'id',
      'name',
      'height',
      'weight',
      'is_default',
      'pokemonspecy',
      'pokemontypes',
      'pokemonstats',
      'pokemonsprites',
    ];

    for (final field in requestedFields) {
      final incompleteJson = savedPokemonJson(name: 'bulbasaur')..remove(field);

      expect(
        () => PokemonDto.fromJson(incompleteJson),
        throwsFormatException,
        reason: 'sin $field',
      );
    }
  });

  test('rechaza un tipo sin nombre', () {
    expect(
      () => PokemonDto.fromJson(
        bulbasaurJsonWith({
          'pokemontypes': [
            {'slot': 1, 'type': <String, Object?>{}},
          ],
        }),
      ),
      throwsFormatException,
    );
  });

  test('rechaza una estadística sin valor', () {
    expect(
      () => PokemonDto.fromJson(
        bulbasaurJsonWith({
          'pokemonstats': [
            {
              'stat': {'name': 'hp'},
            },
          ],
        }),
      ),
      throwsFormatException,
    );
  });
}
