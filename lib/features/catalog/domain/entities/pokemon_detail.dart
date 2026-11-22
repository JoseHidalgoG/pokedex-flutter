import 'package:pokedex_flutter/features/catalog/domain/entities/evolution_tree.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/localized_text.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';

enum PokemonStat { hp, attack, defense, specialAttack, specialDefense, speed }

class BaseStat {
  const BaseStat(this.stat, this.value);

  static const maximum = 255;

  final PokemonStat stat;
  final int value;

  double get fractionOfMaximum => value / maximum;
}

enum MoveLearnMethod { levelUp, machine, tutor, egg }

class PokemonAbility {
  const PokemonAbility({
    required this.id,
    required this.name,
    required this.slot,
    required this.isHidden,
    this.effect = const LocalizedText(),
  });

  final int id;
  final LocalizedText name;
  final int slot;
  final bool isHidden;
  final LocalizedText effect;
}

class PokemonMove {
  const PokemonMove({
    required this.id,
    required this.name,
    required this.method,
    required this.level,
    this.typeName,
  });

  final int id;
  final LocalizedText name;
  final MoveLearnMethod method;
  final int level;
  final String? typeName;
}

class PokemonDetail {
  const PokemonDetail({
    required this.pokemon,
    this.heightInMeters,
    this.weightInKilograms,
    this.baseStats = const [],
    this.eggGroups = const [],
    this.abilities = const [],
    this.moveVersionGroup,
    this.moves = const [],
    this.forms = const [],
    this.games = const [],
    this.evolutionTree,
    this.detailSyncedAt,
  });

  final Pokemon pokemon;
  final double? heightInMeters;
  final double? weightInKilograms;
  final List<BaseStat> baseStats;
  final List<String> eggGroups;
  final List<PokemonAbility> abilities;
  final String? moveVersionGroup;
  final List<PokemonMove> moves;
  final List<Pokemon> forms;
  final List<String> games;
  final EvolutionNode? evolutionTree;
  final DateTime? detailSyncedAt;

  bool get hasStoredDetail => detailSyncedAt != null;

  int? get baseStatTotal {
    if (baseStats.isEmpty) {
      return null;
    }
    return baseStats.fold<int>(0, (total, baseStat) => total + baseStat.value);
  }
}
