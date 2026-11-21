import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry_mapper.dart';
import 'package:pokedex_flutter/features/catalog/data/local/detail_entry.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/evolution_tree.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/localized_text.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_detail.dart';

const _statsByPokeApiName = {
  'hp': PokemonStat.hp,
  'attack': PokemonStat.attack,
  'defense': PokemonStat.defense,
  'special-attack': PokemonStat.specialAttack,
  'special-defense': PokemonStat.specialDefense,
  'speed': PokemonStat.speed,
};

const _learnMethodsByPokeApiName = {
  'level-up': MoveLearnMethod.levelUp,
  'machine': MoveLearnMethod.machine,
  'tutor': MoveLearnMethod.tutor,
  'egg': MoveLearnMethod.egg,
};

const _timesOfDayByPokeApiName = {
  'day': EvolutionTimeOfDay.day,
  'night': EvolutionTimeOfDay.night,
  'dusk': EvolutionTimeOfDay.dusk,
};

extension DetailEntryToPokemonDetail on DetailEntry {
  PokemonDetail toPokemonDetail() {
    return PokemonDetail(
      pokemon: pokemon.toPokemon(),
      heightInMeters: _tenthsOf(pokemon.heightDm),
      weightInKilograms: _tenthsOf(pokemon.weightHg),
      baseStats: _baseStatsOf(pokemon.baseStats),
      eggGroups: List.unmodifiable(eggGroups),
      abilities: [for (final ability in abilities) ability.toPokemonAbility()],
      moveVersionGroup: moveVersionGroup,
      moves: [for (final move in moves) ?move.toPokemonMove()],
      forms: [for (final form in forms) form.toPokemon()],
      games: List.unmodifiable(gameVersions),
      evolutionTree: evolutionTreeOf(
        species: [
          for (final member in evolutionChain)
            (id: member.id, name: member.name),
        ],
        steps: [
          for (final evolution in evolutions)
            if (evolution.fromSpeciesId case final fromSpeciesId?)
              (
                fromSpeciesId: fromSpeciesId,
                toSpeciesId: evolution.toSpeciesId,
                trigger: evolution.toEvolutionTrigger(),
              ),
        ],
      ),
      detailSyncedAt: detailSyncedAt,
    );
  }

  static double? _tenthsOf(int? value) => value == null ? null : value / 10;

  static List<BaseStat> _baseStatsOf(Map<String, int> baseStats) {
    return [
      for (final MapEntry(key: statName, value: baseStat) in baseStats.entries)
        if (_statsByPokeApiName[statName] case final stat?)
          BaseStat(stat, baseStat),
    ]..sort((first, second) => first.stat.index.compareTo(second.stat.index));
  }
}

extension AbilityEntryToPokemonAbility on AbilityEntry {
  PokemonAbility toPokemonAbility() {
    return PokemonAbility(
      id: id,
      name: LocalizedText(english: name, spanish: nameEs),
      slot: slot,
      isHidden: isHidden,
      effect: LocalizedText(english: shortEffectEn, spanish: shortEffectEs),
    );
  }
}

extension MoveEntryToPokemonMove on MoveEntry {
  PokemonMove? toPokemonMove() {
    final method = _learnMethodsByPokeApiName[learnMethod];
    if (method == null) {
      return null;
    }
    return PokemonMove(
      id: id,
      name: LocalizedText(english: name, spanish: nameEs),
      method: method,
      level: level,
      typeName: typeName,
    );
  }
}

extension EvolutionEntryToTrigger on EvolutionEntry {
  EvolutionTrigger toEvolutionTrigger() {
    final evolutionTime = _timesOfDayByPokeApiName[timeOfDay];
    return switch (this) {
      EvolutionEntry(trigger: 'use-item', item: final String item) =>
        ItemTrigger(item),
      EvolutionEntry(trigger: 'trade', :final item) => TradeTrigger(
        heldItem: item,
      ),
      EvolutionEntry(
        trigger: 'level-up',
        minHappiness: _?,
        :final knownMoveType,
      ) =>
        FriendshipTrigger(
          timeOfDay: evolutionTime,
          knownMoveType: knownMoveType,
        ),
      EvolutionEntry(trigger: 'level-up', minLevel: final int level) =>
        LevelTrigger(level, timeOfDay: evolutionTime),
      EvolutionEntry(trigger: 'level-up', :final item)
          when evolutionTime != null =>
        TimeOfDayTrigger(evolutionTime, heldItem: item),
      EvolutionEntry(:final trigger) => OtherTrigger(trigger),
    };
  }
}
