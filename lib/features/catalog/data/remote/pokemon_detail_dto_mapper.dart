import 'package:pokedex_flutter/features/catalog/data/local/detail_entry.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/ability_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/evolution_chain_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/move_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_detail_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto_mapper.dart';

const levelUpLearnMethod = 'level-up';

const legendsVersionGroups = {'legends-arceus', 'legends-za', 'mega-dimension'};

String? newestMoveVersionGroupIn(List<MoveDto> moves) {
  final levelUpGroupOrders = <String, int>{
    for (final move in moves)
      if (move.learnMethod == levelUpLearnMethod)
        move.versionGroup: move.versionGroupOrder,
  };
  final withoutLegends = Map.of(levelUpGroupOrders)
    ..removeWhere(
      (versionGroup, _) => legendsVersionGroups.contains(versionGroup),
    );
  final candidates = withoutLegends.isEmpty
      ? levelUpGroupOrders
      : withoutLegends;
  final newestFirst = candidates.entries.toList()
    ..sort((first, second) => second.value.compareTo(first.value));
  return newestFirst.firstOrNull?.key;
}

String normalizedPokeApiText(String text) {
  return text
      .replaceAll(RegExp(r'­\s*'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

extension PokemonDetailDtoToDetailEntry on PokemonDetailDto {
  DetailEntry toDetailEntry() {
    final chain = species.evolutionChain;
    final moveVersionGroup = newestMoveVersionGroupIn(moves);
    return DetailEntry(
      pokemon: pokemon.toCatalogEntry(),
      species: SpeciesEntry(
        id: species.id,
        name: species.name,
        generationId: species.generationId,
        evolutionChainId: chain?.id,
      ),
      forms: [for (final form in species.forms) form.toCatalogEntry()],
      eggGroups: species.eggGroupNames.toSet().toList(),
      evolutionChain: [
        if (chain != null)
          for (final member in chain.species)
            SpeciesEntry(
              id: member.id,
              name: member.name,
              generationId: member.generationId,
              evolutionChainId: chain.id,
            ),
      ],
      evolutions: chain == null ? const [] : _evolutionsIn(chain),
      abilities: [for (final ability in abilities) ability.toAbilityEntry()],
      moveVersionGroup: moveVersionGroup,
      moves: _movesLearnedIn(moveVersionGroup),
      gameVersions: gameVersionNames.toSet().toList(),
    );
  }

  List<MoveEntry> _movesLearnedIn(String? versionGroup) {
    final lowestLevelMoves = <(int, String), MoveDto>{};
    for (final move in moves) {
      if (move.versionGroup != versionGroup) {
        continue;
      }
      final key = (move.id, move.learnMethod);
      final kept = lowestLevelMoves[key];
      if (kept == null || move.level < kept.level) {
        lowestLevelMoves[key] = move;
      }
    }
    return [for (final move in lowestLevelMoves.values) move.toMoveEntry()];
  }

  static List<EvolutionEntry> _evolutionsIn(EvolutionChainDto chain) {
    return [
      for (final member in chain.species)
        if (member.evolutions.firstOrNull case final evolution?)
          EvolutionEntry(
            id: evolution.id,
            chainId: chain.id,
            toSpeciesId: evolution.evolvedSpeciesId,
            fromSpeciesId: member.evolvesFromSpeciesId,
            trigger: evolution.triggerName,
            minLevel: evolution.minLevel,
            item: evolution.itemName ?? evolution.heldItemName,
            minHappiness: evolution.minHappiness,
            timeOfDay: _nonEmptyOrNull(evolution.timeOfDay),
            location: evolution.locationName,
            knownMoveType: evolution.knownMoveTypeName,
          ),
    ];
  }
}

extension AbilityDtoToAbilityEntry on AbilityDto {
  AbilityEntry toAbilityEntry() {
    return AbilityEntry(
      id: id,
      name: namesByLanguage['en'] ?? identifier,
      nameEs: namesByLanguage['es'],
      slot: slot,
      isHidden: isHidden,
      shortEffectEs: _normalizedOrNull(flavorTextEs),
      shortEffectEn: _normalizedOrNull(shortEffectEn),
    );
  }
}

extension MoveDtoToMoveEntry on MoveDto {
  MoveEntry toMoveEntry() {
    return MoveEntry(
      id: id,
      name: namesByLanguage['en'] ?? identifier,
      nameEs: namesByLanguage['es'],
      typeName: typeName,
      learnMethod: learnMethod,
      level: level,
    );
  }
}

String? _normalizedOrNull(String? text) {
  return _nonEmptyOrNull(text == null ? null : normalizedPokeApiText(text));
}

String? _nonEmptyOrNull(String? text) {
  return text == null || text.isEmpty ? null : text;
}
