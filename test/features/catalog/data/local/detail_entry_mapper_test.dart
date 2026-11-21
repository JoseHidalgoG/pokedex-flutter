import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';
import 'package:pokedex_flutter/features/catalog/data/local/detail_entry.dart';
import 'package:pokedex_flutter/features/catalog/data/local/detail_entry_mapper.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_detail_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_detail_dto_mapper.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/evolution_tree.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/localized_text.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_detail.dart';

import '../../../../fixtures/pokemon_detail_fixture.dart';

DetailEntry savedDetailOf(String pokemonName) {
  return PokemonDetailDto.fromJson(savedPokemonDetailJson(pokemonName))
      .toDetailEntry();
}

EvolutionTrigger triggerOf(EvolutionEntry evolution) {
  return evolution.toEvolutionTrigger();
}

EvolutionEntry evolutionWith({
  required String? trigger,
  int? minLevel,
  String? item,
  int? minHappiness,
  String? timeOfDay,
}) {
  return EvolutionEntry(
    id: 1,
    chainId: 1,
    toSpeciesId: 2,
    fromSpeciesId: 1,
    trigger: trigger,
    minLevel: minLevel,
    item: item,
    minHappiness: minHappiness,
    timeOfDay: timeOfDay,
  );
}

void main() {
  group('Pikachu guardado', () {
    final pikachu = savedDetailOf('pikachu').toPokemonDetail();

    test('lleva los campos del catálogo, la altura en m y el peso en kg', () {
      expect(pikachu.pokemon.id, 25);
      expect(pikachu.pokemon.name, 'pikachu');
      expect(pikachu.pokemon.typeNames, ['electric']);
      expect(pikachu.heightInMeters, 0.4);
      expect(pikachu.weightInKilograms, 6);
    });

    test('ordena las estadísticas de HP a velocidad con su total', () {
      expect(
        [for (final baseStat in pikachu.baseStats) baseStat.stat],
        [
          PokemonStat.hp,
          PokemonStat.attack,
          PokemonStat.defense,
          PokemonStat.specialAttack,
          PokemonStat.specialDefense,
          PokemonStat.speed,
        ],
      );
      expect(
        [for (final baseStat in pikachu.baseStats) baseStat.value],
        [35, 55, 40, 50, 50, 90],
      );
      expect(pikachu.baseStatTotal, 320);
      expect(pikachu.baseStats.last.fractionOfMaximum, 90 / 255);
    });

    test('las habilidades traen el nombre en los dos idiomas y la oculta', () {
      final lightningRod = pikachu.abilities.singleWhere(
        (ability) => ability.isHidden,
      );

      expect(
        lightningRod.name,
        const LocalizedText(english: 'Lightning Rod', spanish: 'Pararrayos'),
      );
      expect(lightningRod.name.inLanguage('es'), 'Pararrayos');
      expect(lightningRod.name.inLanguage('en'), 'Lightning Rod');
      expect(lightningRod.effect.english, isNotNull);
    });

    test('los movimientos son de Scarlet/Violet con su método de dominio', () {
      final thunderShock = pikachu.moves.singleWhere(
        (move) => move.name.english == 'Thunder Shock',
      );

      expect(pikachu.moveVersionGroup, 'scarlet-violet');
      expect(
        {for (final move in pikachu.moves) move.method},
        {MoveLearnMethod.levelUp, MoveLearnMethod.machine},
      );
      expect(thunderShock.name.inLanguage('es'), 'Impactrueno');
      expect(thunderShock.method, MoveLearnMethod.levelUp);
      expect(thunderShock.level, 1);
    });

    test('las formas son Pokémon de dominio de la misma especie', () {
      expect(pikachu.forms, hasLength(17));
      expect(pikachu.forms.first.name, 'pikachu');
      expect([
        for (final form in pikachu.forms) form.name,
      ], contains('pikachu-gmax'));
    });

    test('el árbol va de Pichu por amistad a Raichu con piedra trueno', () {
      final pichu = pikachu.evolutionTree!;
      final pikachuNode = pichu.evolutions.single;
      final raichu = pikachuNode.evolutions.single;

      expect(pichu.speciesName, 'pichu');
      expect(pikachuNode.trigger, const FriendshipTrigger());
      expect(raichu.speciesName, 'raichu');
      expect(raichu.trigger, const ItemTrigger('thunder-stone'));
    });

    test('un detalle recién descargado aún no tiene fecha de guardado', () {
      expect(pikachu.detailSyncedAt, isNull);
      expect(pikachu.hasStoredDetail, isFalse);
    });
  });

  test('el árbol de Eevee tiene ocho ramas con su trigger principal', () {
    final eevee = savedDetailOf('eevee').toPokemonDetail().evolutionTree!;
    final triggersBySpecies = {
      for (final branch in eevee.evolutions) branch.speciesName: branch.trigger,
    };

    expect(eevee.speciesName, 'eevee');
    expect(eevee.evolutions, hasLength(8));
    expect(triggersBySpecies['leafeon'], const ItemTrigger('leaf-stone'));
    expect(
      triggersBySpecies['espeon'],
      const FriendshipTrigger(timeOfDay: EvolutionTimeOfDay.day),
    );
    expect(
      triggersBySpecies['umbreon'],
      const FriendshipTrigger(timeOfDay: EvolutionTimeOfDay.night),
    );
    expect(
      triggersBySpecies['sylveon'],
      const FriendshipTrigger(knownMoveType: 'fairy'),
    );
    expect(eevee.evolutions.every((branch) => !branch.evolves), isTrue);
  });

  test('sin cadena guardada no hay árbol de evoluciones', () {
    const onlyCatalog = DetailEntry(
      pokemon: CatalogEntry(
        id: 25,
        name: 'pikachu',
        imageUrl: 'https://example.com/25.png',
        typeNames: ['electric'],
      ),
    );

    final detail = onlyCatalog.toPokemonDetail();

    expect(detail.evolutionTree, isNull);
    expect(detail.baseStats, isEmpty);
    expect(detail.baseStatTotal, isNull);
    expect(detail.heightInMeters, isNull);
  });

  test('conserva la fecha en que se guardó el detalle', () {
    final savedAt = DateTime(2026, 11, 24, 10);
    final detail = DetailEntry(
      pokemon: const CatalogEntry(
        id: 25,
        name: 'pikachu',
        imageUrl: 'https://example.com/25.png',
        typeNames: ['electric'],
      ),
      detailSyncedAt: savedAt,
    ).toPokemonDetail();

    expect(detail.detailSyncedAt, savedAt);
    expect(detail.hasStoredDetail, isTrue);
  });

  test('un método de aprendizaje desconocido no llega al dominio', () {
    const move = MoveEntry(
      id: 1,
      name: 'Pound',
      learnMethod: 'stadium-surfing-pikachu',
      level: 0,
    );

    expect(move.toPokemonMove(), isNull);
  });

  group('trigger principal de una evolución', () {
    test('intercambio con objeto equipado', () {
      expect(
        triggerOf(evolutionWith(trigger: 'trade', item: 'metal-coat')),
        const TradeTrigger(heldItem: 'metal-coat'),
      );
    });

    test('nivel con momento del día', () {
      expect(
        triggerOf(
          evolutionWith(trigger: 'level-up', minLevel: 25, timeOfDay: 'dusk'),
        ),
        const LevelTrigger(25, timeOfDay: EvolutionTimeOfDay.dusk),
      );
    });

    test('subir de nivel de noche con un objeto equipado', () {
      expect(
        triggerOf(
          evolutionWith(
            trigger: 'level-up',
            item: 'razor-fang',
            timeOfDay: 'night',
          ),
        ),
        const TimeOfDayTrigger(
          EvolutionTimeOfDay.night,
          heldItem: 'razor-fang',
        ),
      );
    });

    test('la amistad gana al momento del día', () {
      expect(
        triggerOf(
          evolutionWith(
            trigger: 'level-up',
            minHappiness: 160,
            timeOfDay: 'night',
          ),
        ),
        const FriendshipTrigger(timeOfDay: EvolutionTimeOfDay.night),
      );
    });

    test('lo que no encaja queda como otro método con su identificador', () {
      expect(
        triggerOf(evolutionWith(trigger: 'shed')),
        const OtherTrigger('shed'),
      );
      expect(
        triggerOf(evolutionWith(trigger: 'use-item')),
        const OtherTrigger('use-item'),
      );
      expect(
        triggerOf(evolutionWith(trigger: 'level-up')),
        const OtherTrigger('level-up'),
      );
    });
  });
}
