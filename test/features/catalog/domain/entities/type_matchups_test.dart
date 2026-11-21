import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/data/local/type_efficacy_entry_mapper.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/type_efficacy_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/type_efficacy_dto_mapper.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/type_matchups.dart';

import '../../../../fixtures/pokemon_detail_fixture.dart';

void main() {
  final typeTable = [
    for (final row in savedTypeEfficacyRows())
      TypeEfficacyDto.fromJson(row).toTypeEfficacyEntry().toTypeEfficacy(),
  ];

  DefensiveMatchup? matchupAgainst(
    String attackingType,
    Map<DefensiveMatchup, List<String>> matchups,
  ) {
    for (final MapEntry(key: matchup, value: attackingTypes)
        in matchups.entries) {
      if (attackingTypes.contains(attackingType)) {
        return matchup;
      }
    }
    return null;
  }

  test('fuego/volador recibe ×4 de roca y ×0 de tierra', () {
    final matchups = defensiveMatchupsFor(['fire', 'flying'], typeTable);

    expect(matchups[DefensiveMatchup.quadrupleWeakness], ['rock']);
    expect(matchups[DefensiveMatchup.immunity], ['ground']);
    expect(matchupAgainst('water', matchups), DefensiveMatchup.weakness);
    expect(matchupAgainst('electric', matchups), DefensiveMatchup.weakness);
    expect(
      matchups[DefensiveMatchup.doubleResistance],
      unorderedEquals(['grass', 'bug']),
    );
    expect(matchupAgainst('normal', matchups), isNull);
  });

  test('un solo tipo reparte la tabla en ×2, ×0,5 y ×0 sin grupos vacíos', () {
    final matchups = defensiveMatchupsFor(['electric'], typeTable);

    expect(matchups.keys, [
      DefensiveMatchup.weakness,
      DefensiveMatchup.resistance,
    ]);
    expect(matchups[DefensiveMatchup.weakness], ['ground']);
    expect(
      matchups[DefensiveMatchup.resistance],
      unorderedEquals(['flying', 'steel', 'electric']),
    );
  });

  test('normal/fantasma es inmune a normal, lucha y fantasma', () {
    final matchups = defensiveMatchupsFor(['normal', 'ghost'], typeTable);

    expect(
      matchups[DefensiveMatchup.immunity],
      unorderedEquals(['normal', 'fighting', 'ghost']),
    );
  });

  test('sin tabla de tipos no hay matchups', () {
    expect(defensiveMatchupsFor(['fire'], const []), isEmpty);
  });

  test('el multiplicador es el porcentaje de PokeAPI entre 100', () {
    const row = TypeEfficacy(
      attackingType: 'fire',
      defendingType: 'grass',
      damageFactor: 200,
    );

    expect(row.multiplier, 2);
  });
}
