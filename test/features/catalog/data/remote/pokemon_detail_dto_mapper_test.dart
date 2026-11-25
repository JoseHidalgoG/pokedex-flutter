import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/data/local/detail_entry.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/ability_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/evolution_chain_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/move_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_detail_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_detail_dto_mapper.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/species_dto.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_artwork.dart';

import '../../../../fixtures/pokemon_detail_fixture.dart';

void main() {
  DetailEntry savedDetailEntry(String pokemonName) {
    return PokemonDetailDto.fromJson(savedPokemonDetailJson(pokemonName))
        .toDetailEntry();
  }

  PokemonDetailDto pikachuDetailWith({
    List<MoveDto> moves = const [],
    List<String> gameVersionNames = const [],
    EvolutionChainDto? evolutionChain,
  }) {
    return PokemonDetailDto(
      pokemon: const PokemonDto(
        id: 25,
        name: 'pikachu',
        typeNames: ['electric'],
      ),
      species: SpeciesDto(
        id: 25,
        name: 'pikachu',
        evolutionChain: evolutionChain,
      ),
      moves: moves,
      gameVersionNames: gameVersionNames,
    );
  }

  MoveDto moveIn(
    String versionGroup,
    int versionGroupOrder, {
    int id = 1,
    String learnMethod = levelUpLearnMethod,
    int level = 1,
  }) {
    return MoveDto(
      id: id,
      identifier: 'move-$id',
      learnMethod: learnMethod,
      level: level,
      versionGroup: versionGroup,
      versionGroupOrder: versionGroupOrder,
    );
  }

  int movesLearnedBy(DetailEntry detail, String learnMethod) {
    return detail.moves.where((move) => move.learnMethod == learnMethod).length;
  }

  group('movimientos', () {
    test(
      'Pikachu guarda Scarlet/Violet aunque Legends Z-A sea más reciente',
      () {
        final pikachu = savedDetailEntry('pikachu');

        expect(pikachu.moveVersionGroup, 'scarlet-violet');
        expect(pikachu.moves, hasLength(67));
        expect(movesLearnedBy(pikachu, 'level-up'), 20);
        expect(movesLearnedBy(pikachu, 'machine'), 47);
      },
    );

    test('Eevee guarda también sus movimientos por huevo', () {
      final eevee = savedDetailEntry('eevee');

      expect(eevee.moveVersionGroup, 'scarlet-violet');
      expect(eevee.moves, hasLength(52));
      expect(movesLearnedBy(eevee, 'egg'), 8);
    });

    test('guarda el nombre en inglés y en español de cada movimiento', () {
      final thunderbolt = savedDetailEntry('pikachu').moves
          .firstWhere((move) => move.id == 85);

      expect(thunderbolt.name, 'Thunderbolt');
      expect(thunderbolt.nameEs, 'Rayo');
      expect(thunderbolt.typeName, 'electric');
    });

    test('elige el version group más reciente con movimientos por nivel', () {
      final versionGroup = newestMoveVersionGroupIn([
        moveIn('sun-moon', 19),
        moveIn('sword-shield', 22),
        moveIn('scarlet-violet', 27, learnMethod: 'machine'),
      ]);

      expect(versionGroup, 'sword-shield');
    });

    test(
      'usa un juego Legends cuando es el único con movimientos por nivel',
      () {
        final versionGroup = newestMoveVersionGroupIn([
          moveIn('legends-arceus', 26),
          moveIn('sword-shield', 22, learnMethod: 'machine'),
        ]);

        expect(versionGroup, 'legends-arceus');
      },
    );

    test('elige el Legends más reciente cuando solo hay juegos Legends', () {
      final versionGroup = newestMoveVersionGroupIn([
        moveIn('legends-arceus', 26),
        moveIn('legends-za', 30),
      ]);

      expect(versionGroup, 'legends-za');
    });

    test('deja sin movimientos la forma que PokeAPI trae sin ninguno', () {
      final pikachuGmax = pikachuDetailWith().toDetailEntry();

      expect(pikachuGmax.moveVersionGroup, isNull);
      expect(pikachuGmax.moves, isEmpty);
    });

    test(
      'guarda una sola vez un movimiento repetido, con su nivel más bajo',
      () {
        final pikachu = pikachuDetailWith(
          moves: [
            moveIn('scarlet-violet', 27, id: 85, level: 36),
            moveIn('scarlet-violet', 27, id: 85, level: 1),
            moveIn(
              'scarlet-violet',
              27,
              id: 85,
              learnMethod: 'machine',
              level: 0,
            ),
          ],
        ).toDetailEntry();

        expect(pikachu.moves, hasLength(2));
        expect(pikachu.moves.first.learnMethod, 'level-up');
        expect(pikachu.moves.first.level, 1);
        expect(pikachu.moves.last.learnMethod, 'machine');
      },
    );
  });

  group('habilidades', () {
    test('guarda los nombres en inglés y en español y marca la oculta', () {
      final [staticAbility, lightningRod] = savedDetailEntry('pikachu')
          .abilities;

      expect(staticAbility.name, 'Static');
      expect(staticAbility.nameEs, 'Electricidad Estática');
      expect(staticAbility.slot, 1);
      expect(staticAbility.isHidden, isFalse);
      expect(lightningRod.name, 'Lightning Rod');
      expect(lightningRod.nameEs, 'Pararrayos');
      expect(lightningRod.slot, 3);
      expect(lightningRod.isHidden, isTrue);
    });

    test('el efecto en español es la descripción más reciente y en inglés el short_effect', () {
      final staticAbility = savedDetailEntry('pikachu').abilities.first;

      expect(
        staticAbility.shortEffectEs,
        'La electricidad estática que lo envuelve puede paralizar al '
        'Pokémon que lo ataque con un movimiento de contacto.',
      );
      expect(
        staticAbility.shortEffectEn,
        'Has a 30% chance of paralyzing attacking Pokémon on contact.',
      );
    });

    test('junta los espacios dobles del efecto en inglés', () {
      final lightningRod = savedDetailEntry('pikachu').abilities.last;

      expect(lightningRod.shortEffectEn, contains('possible. Absorbs'));
    });

    test('usa el identificador cuando falta el nombre en inglés', () {
      const stench = AbilityDto(
        id: 1,
        identifier: 'stench',
        slot: 1,
        isHidden: false,
      );

      final entry = stench.toAbilityEntry();

      expect(entry.name, 'stench');
      expect(entry.nameEs, isNull);
      expect(entry.shortEffectEs, isNull);
      expect(entry.shortEffectEn, isNull);
    });

    test('deja sin efecto la habilidad cuyo texto solo tiene espacios', () {
      const blank = AbilityDto(
        id: 1,
        identifier: 'stench',
        slot: 1,
        isHidden: false,
        flavorTextEs: ' \n\f ',
      );

      expect(blank.toAbilityEntry().shortEffectEs, isNull);
    });
  });

  group('textos de PokeAPI', () {
    test('une la palabra partida con guion suave al final de la línea', () {
      expect(
        normalizedPokeApiText('Atrae los movi­\nmientos de tipo Eléctrico.'),
        'Atrae los movimientos de tipo Eléctrico.',
      );
    });

    test('cambia los saltos de línea y de página por espacios', () {
      expect(
        normalizedPokeApiText('Puede escapar\nde cualquier\fPokémon.'),
        'Puede escapar de cualquier Pokémon.',
      );
    });

    test('junta los espacios repetidos y recorta los extremos', () {
      expect(
        normalizedPokeApiText('  Redirects moves.  Absorbs them. '),
        'Redirects moves. Absorbs them.',
      );
    });
  });

  group('evoluciones', () {
    test('Eevee tiene ocho evoluciones desde la misma especie', () {
      final evolutions = savedDetailEntry('eevee').evolutions;

      expect(evolutions, hasLength(8));
      expect(
        {for (final evolution in evolutions) evolution.fromSpeciesId},
        {133},
      );
      expect({for (final evolution in evolutions) evolution.chainId}, {67});
    });

    test('Leafeon evoluciona con piedra hoja', () {
      final leafeon = savedDetailEntry('eevee').evolutions
          .firstWhere((evolution) => evolution.toSpeciesId == 470);

      expect(leafeon.trigger, 'use-item');
      expect(leafeon.item, 'leaf-stone');
      expect(leafeon.timeOfDay, isNull);
    });

    test('Espeon y Umbreon dependen de la amistad y de la hora', () {
      final evolutions = savedDetailEntry('eevee').evolutions;
      final espeon = evolutions.firstWhere(
        (evolution) => evolution.toSpeciesId == 196,
      );
      final umbreon = evolutions.firstWhere(
        (evolution) => evolution.toSpeciesId == 197,
      );

      expect(espeon.minHappiness, 160);
      expect(espeon.timeOfDay, 'day');
      expect(umbreon.minHappiness, 160);
      expect(umbreon.timeOfDay, 'night');
    });

    test('Sylveon necesita conocer un movimiento de tipo hada', () {
      final sylveon = savedDetailEntry('eevee').evolutions
          .firstWhere((evolution) => evolution.toSpeciesId == 700);

      expect(sylveon.knownMoveType, 'fairy');
      expect(sylveon.minHappiness, 160);
    });

    test('guarda solo la primera fila de cada especie, como en Raichu', () {
      final evolutions = savedDetailEntry('pikachu').evolutions;

      expect([for (final evolution in evolutions) evolution.id], [16, 17]);
      expect(evolutions.first.toSpeciesId, 25);
      expect(evolutions.first.fromSpeciesId, 172);
      expect(evolutions.first.minHappiness, 220);
      expect(evolutions.last.toSpeciesId, 26);
      expect(evolutions.last.item, 'thunder-stone');
    });

    test('guarda el objeto equipado de un intercambio como su objeto', () {
      final onix = pikachuDetailWith(
        evolutionChain: const EvolutionChainDto(
          id: 46,
          species: [
            ChainSpeciesDto(id: 95, name: 'onix'),
            ChainSpeciesDto(
              id: 208,
              name: 'steelix',
              evolvesFromSpeciesId: 95,
              evolutions: [
                EvolutionDto(
                  id: 114,
                  evolvedSpeciesId: 208,
                  triggerName: 'trade',
                  heldItemName: 'metal-coat',
                  timeOfDay: '',
                ),
              ],
            ),
          ],
        ),
      ).toDetailEntry();

      expect(onix.evolutions.single.trigger, 'trade');
      expect(onix.evolutions.single.item, 'metal-coat');
    });

    test(
      'sin cadena evolutiva no guarda especies de la cadena ni evoluciones',
      () {
        final detail = pikachuDetailWith().toDetailEntry();

        expect(detail.species!.evolutionChainId, isNull);
        expect(detail.evolutionChain, isEmpty);
        expect(detail.evolutions, isEmpty);
      },
    );
  });

  group('especie, formas y juegos', () {
    test('el Pokémon conserva los campos del catálogo', () {
      final pikachu = savedDetailEntry('pikachu').pokemon;

      expect(pikachu.id, 25);
      expect(pikachu.typeNames, ['electric']);
      expect(pikachu.heightDm, 4);
      expect(pikachu.weightHg, 60);
      expect(pikachu.baseStats, hasLength(6));
    });

    test('guarda la especie y las de su cadena con el número de la cadena', () {
      final pikachu = savedDetailEntry('pikachu');
      final species = pikachu.species!;

      expect(species.id, 25);
      expect(species.name, 'pikachu');
      expect(species.generationId, 1);
      expect(species.evolutionChainId, 10);
      expect(
        [for (final species in pikachu.evolutionChain) species.name],
        ['pichu', 'pikachu', 'raichu'],
      );
      expect(pikachu.evolutionChain.first.generationId, 2);
      expect(
        {
          for (final species in pikachu.evolutionChain)
            species.evolutionChainId,
        },
        {10},
      );
    });

    test(
      'convierte las formas en entradas del catálogo de la misma especie',
      () {
        final forms = savedDetailEntry('pikachu').forms;
        final pikachuGmax = forms.last;

        expect(forms, hasLength(17));
        expect({for (final form in forms) form.speciesId}, {25});
        expect(pikachuGmax.id, 10199);
        expect(pikachuGmax.isDefault, isFalse);
        expect(pikachuGmax.imageUrl, officialArtworkUrlFor(10199));
      },
    );

    test('guarda los grupos huevo y los juegos de PokeAPI', () {
      final pikachu = savedDetailEntry('pikachu');

      expect(pikachu.eggGroups, ['ground', 'fairy']);
      expect(pikachu.gameVersions, hasLength(46));
      expect(pikachu.gameVersions, contains('scarlet'));
    });

    test('no repite un juego que PokeAPI trae dos veces', () {
      final detail = pikachuDetailWith(gameVersionNames: ['red', 'blue', 'red'])
          .toDetailEntry();

      expect(detail.gameVersions, ['red', 'blue']);
    });
  });
}
