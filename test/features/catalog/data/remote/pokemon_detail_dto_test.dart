import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_detail_dto.dart';

import '../../../../fixtures/pokemon_detail_fixture.dart';

void main() {
  PokemonDetailDto savedDetail(String pokemonName) {
    return PokemonDetailDto.fromJson(savedPokemonDetailJson(pokemonName));
  }

  Map<String, Object?> speciesJsonOf(Map<String, Object?> pokemonJson) {
    return pokemonJson['pokemonspecy']! as Map<String, Object?>;
  }

  Map<String, Object?> firstEntryOf(
    Map<String, Object?> json,
    String listField,
  ) {
    return (json[listField]! as List<Object?>).first! as Map<String, Object?>;
  }

  test('lee el Pokémon, su especie y sus listas del detalle de Pikachu', () {
    final pikachu = savedDetail('pikachu');

    expect(pikachu.pokemon.id, 25);
    expect(pikachu.pokemon.name, 'pikachu');
    expect(pikachu.pokemon.typeNames, ['electric']);
    expect(pikachu.species.id, 25);
    expect(pikachu.species.name, 'pikachu');
    expect(pikachu.species.generationId, 1);
    expect(pikachu.species.eggGroupNames, ['ground', 'fairy']);
    expect(pikachu.abilities, hasLength(2));
    expect(pikachu.moves, hasLength(1124));
    expect(pikachu.gameVersionNames, hasLength(46));
    expect(pikachu.gameVersionNames.first, 'red');
  });

  test('lee las formas de la especie con los campos del catálogo', () {
    final forms = savedDetail('pikachu').species.forms;

    expect(forms, hasLength(17));
    expect(forms.first.id, 25);
    expect(forms.first.isDefault, isTrue);
    expect(forms.last.id, 10199);
    expect(forms.last.name, 'pikachu-gmax');
    expect(forms.last.isDefault, isFalse);
    expect(forms.last.speciesId, 25);
    expect(forms.last.baseStats, hasLength(6));
  });

  test('lee una habilidad con sus nombres, su efecto y su descripción', () {
    final lightningRod = savedDetail('pikachu').abilities.last;

    expect(lightningRod.id, 31);
    expect(lightningRod.identifier, 'lightning-rod');
    expect(lightningRod.slot, 3);
    expect(lightningRod.isHidden, isTrue);
    expect(lightningRod.namesByLanguage, {
      'es': 'Pararrayos',
      'en': 'Lightning Rod',
    });
    expect(lightningRod.shortEffectEn, startsWith('Redirects'));
    expect(lightningRod.flavorTextEs, startsWith('Atrae'));
  });

  test('lee un movimiento con su método, su nivel y su version group', () {
    final growl = savedDetail('pikachu').moves.first;

    expect(growl.id, 45);
    expect(growl.identifier, 'growl');
    expect(growl.learnMethod, 'level-up');
    expect(growl.level, 1);
    expect(growl.versionGroup, 'red-blue');
    expect(growl.versionGroupOrder, 3);
    expect(growl.typeName, 'normal');
    expect(growl.namesByLanguage, {'es': 'Gruñido', 'en': 'Growl'});
  });

  test('lee la cadena evolutiva completa de Eevee', () {
    final chain = savedDetail('eevee').species.evolutionChain!;
    final eevee = chain.species.first;
    final sylveon = chain.species.last;

    expect(chain.id, 67);
    expect(
      [for (final member in chain.species) member.name],
      [
        'eevee',
        'vaporeon',
        'jolteon',
        'flareon',
        'espeon',
        'umbreon',
        'leafeon',
        'glaceon',
        'sylveon',
      ],
    );
    expect(eevee.evolvesFromSpeciesId, isNull);
    expect(eevee.evolutions, isEmpty);
    expect(sylveon.generationId, 6);
    expect(sylveon.evolvesFromSpeciesId, 133);
    expect(sylveon.evolutions.single.id, 409);
    expect(sylveon.evolutions.single.evolvedSpeciesId, 700);
    expect(sylveon.evolutions.single.triggerName, 'level-up');
    expect(sylveon.evolutions.single.minHappiness, 160);
    expect(sylveon.evolutions.single.knownMoveTypeName, 'fairy');
    expect(sylveon.evolutions.single.timeOfDay, '');
  });

  test('conserva todas las filas por defecto de una especie, como Raichu', () {
    final raichu = savedDetail('pikachu').species.evolutionChain!.species.last;

    expect(
      [for (final evolution in raichu.evolutions) evolution.id],
      [17, 517],
    );
    expect(raichu.evolutions.first.itemName, 'thunder-stone');
  });

  test('acepta una especie sin cadena evolutiva', () {
    final pikachuJson = savedPokemonDetailJson('pikachu');
    speciesJsonOf(pikachuJson)['evolutionchain'] = null;

    final pikachu = PokemonDetailDto.fromJson(pikachuJson);

    expect(pikachu.species.evolutionChain, isNull);
  });

  test('acepta una habilidad sin efecto ni descripción', () {
    final pikachuJson = savedPokemonDetailJson('pikachu');
    final ability =
        firstEntryOf(pikachuJson, 'pokemonabilities')['ability']!
            as Map<String, Object?>;
    ability['abilityeffecttexts'] = <Object?>[];
    ability['abilityflavortexts'] = <Object?>[];

    final staticAbility = PokemonDetailDto.fromJson(pikachuJson)
        .abilities
        .first;

    expect(staticAbility.shortEffectEn, isNull);
    expect(staticAbility.flavorTextEs, isNull);
  });

  test('rechaza un detalle al que le falta un campo pedido', () {
    const requestedFields = [
      'pokemonspecy',
      'pokemonabilities',
      'pokemonmoves',
      'pokemongameindices',
      'pokemontypes',
    ];

    for (final field in requestedFields) {
      final incompleteJson = savedPokemonDetailJson('pikachu')..remove(field);

      expect(
        () => PokemonDetailDto.fromJson(incompleteJson),
        throwsFormatException,
        reason: 'sin $field',
      );
    }
  });

  test('rechaza un detalle sin especie', () {
    final pikachuJson = savedPokemonDetailJson('pikachu')
      ..['pokemonspecy'] = null;

    expect(() => PokemonDetailDto.fromJson(pikachuJson), throwsFormatException);
  });

  test('rechaza un movimiento sin el orden de su version group', () {
    final pikachuJson = savedPokemonDetailJson('pikachu');
    firstEntryOf(pikachuJson, 'pokemonmoves')['versiongroup'] = {
      'name': 'red-blue',
    };

    expect(() => PokemonDetailDto.fromJson(pikachuJson), throwsFormatException);
  });

  test('rechaza una habilidad sin slot', () {
    final pikachuJson = savedPokemonDetailJson('pikachu');
    firstEntryOf(pikachuJson, 'pokemonabilities').remove('slot');

    expect(() => PokemonDetailDto.fromJson(pikachuJson), throwsFormatException);
  });

  test('rechaza un nombre traducido sin idioma', () {
    final pikachuJson = savedPokemonDetailJson('pikachu');
    final move =
        firstEntryOf(pikachuJson, 'pokemonmoves')['move']!
            as Map<String, Object?>;
    move['movenames'] = [
      {'name': 'Gruñido'},
    ];

    expect(() => PokemonDetailDto.fromJson(pikachuJson), throwsFormatException);
  });

  test('rechaza una evolución sin la especie a la que evoluciona', () {
    final eeveeJson = savedPokemonDetailJson('eevee');
    final chain =
        speciesJsonOf(eeveeJson)['evolutionchain']! as Map<String, Object?>;
    final vaporeon =
        (chain['pokemonspecies']! as List<Object?>)[1]! as Map<String, Object?>;
    firstEntryOf(vaporeon, 'pokemonevolutions').remove('evolved_species_id');

    expect(() => PokemonDetailDto.fromJson(eeveeJson), throwsFormatException);
  });
}
