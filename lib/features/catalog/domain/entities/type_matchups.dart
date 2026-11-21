class TypeEfficacy {
  const TypeEfficacy({
    required this.attackingType,
    required this.defendingType,
    required this.damageFactor,
  });

  final String attackingType;
  final String defendingType;
  final int damageFactor;

  double get multiplier => damageFactor / 100;
}

enum DefensiveMatchup {
  quadrupleWeakness(4),
  weakness(2),
  resistance(0.5),
  doubleResistance(0.25),
  immunity(0);

  const DefensiveMatchup(this.multiplier);

  final double multiplier;
}

Map<DefensiveMatchup, List<String>> defensiveMatchupsFor(
  List<String> defendingTypes,
  List<TypeEfficacy> efficacy,
) {
  final multiplierByAttackingType = <String, double>{};
  for (final row in efficacy) {
    final multiplier = multiplierByAttackingType[row.attackingType] ?? 1;
    multiplierByAttackingType[row.attackingType] =
        defendingTypes.contains(row.defendingType)
        ? multiplier * row.multiplier
        : multiplier;
  }
  final attackingTypesByMatchup = {
    for (final matchup in DefensiveMatchup.values) matchup: <String>[],
  };
  for (final MapEntry(key: attackingType, value: multiplier)
      in multiplierByAttackingType.entries) {
    final matchup = _matchupWith(multiplier);
    if (matchup != null) {
      attackingTypesByMatchup[matchup]!.add(attackingType);
    }
  }
  return {
    for (final MapEntry(key: matchup, value: attackingTypes)
        in attackingTypesByMatchup.entries)
      if (attackingTypes.isNotEmpty) matchup: attackingTypes,
  };
}

DefensiveMatchup? _matchupWith(double multiplier) {
  for (final matchup in DefensiveMatchup.values) {
    if (matchup.multiplier == multiplier) {
      return matchup;
    }
  }
  return null;
}
