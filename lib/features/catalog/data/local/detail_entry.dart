import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';

class DetailEntry {
  const DetailEntry({
    required this.pokemon,
    this.species,
    this.forms = const [],
    this.eggGroups = const [],
    this.evolutionChain = const [],
    this.evolutions = const [],
    this.abilities = const [],
    this.moveVersionGroup,
    this.moves = const [],
    this.gameVersions = const [],
    this.detailSyncedAt,
  });

  final CatalogEntry pokemon;
  final SpeciesEntry? species;
  final List<CatalogEntry> forms;
  final List<String> eggGroups;
  final List<SpeciesEntry> evolutionChain;
  final List<EvolutionEntry> evolutions;
  final List<AbilityEntry> abilities;
  final String? moveVersionGroup;
  final List<MoveEntry> moves;
  final List<String> gameVersions;
  final DateTime? detailSyncedAt;
}

class SpeciesEntry {
  const SpeciesEntry({
    required this.id,
    required this.name,
    this.generationId,
    this.evolutionChainId,
  });

  final int id;
  final String name;
  final int? generationId;
  final int? evolutionChainId;
}

class AbilityEntry {
  const AbilityEntry({
    required this.id,
    required this.name,
    required this.slot,
    required this.isHidden,
    this.nameEs,
    this.shortEffectEs,
    this.shortEffectEn,
  });

  final int id;
  final String name;
  final int slot;
  final bool isHidden;
  final String? nameEs;
  final String? shortEffectEs;
  final String? shortEffectEn;
}

class MoveEntry {
  const MoveEntry({
    required this.id,
    required this.name,
    required this.learnMethod,
    required this.level,
    this.nameEs,
    this.typeName,
  });

  final int id;
  final String name;
  final String learnMethod;
  final int level;
  final String? nameEs;
  final String? typeName;
}

class EvolutionEntry {
  const EvolutionEntry({
    required this.id,
    required this.chainId,
    required this.toSpeciesId,
    this.fromSpeciesId,
    this.trigger,
    this.minLevel,
    this.item,
    this.minHappiness,
    this.timeOfDay,
    this.location,
    this.knownMoveType,
  });

  final int id;
  final int chainId;
  final int toSpeciesId;
  final int? fromSpeciesId;
  final String? trigger;
  final int? minLevel;
  final String? item;
  final int? minHappiness;
  final String? timeOfDay;
  final String? location;
  final String? knownMoveType;
}
