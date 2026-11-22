import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/type_efficacy_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/type_efficacy_dto_mapper.dart';

import '../../../../fixtures/pokemon_detail_fixture.dart';

void main() {
  List<TypeEfficacyDto> savedTypeEfficacy() {
    return [
      for (final row in savedTypeEfficacyRows()) TypeEfficacyDto.fromJson(row),
    ];
  }

  int damageFactorOf(String attackingType, String defendingType) {
    return savedTypeEfficacy()
        .firstWhere(
          (row) =>
              row.attackingType == attackingType &&
              row.defendingType == defendingType,
        )
        .damageFactor;
  }

  test('lee las 324 filas de los 18 tipos', () {
    final rows = savedTypeEfficacy();

    expect(rows, hasLength(324));
    expect({for (final row in rows) row.attackingType}, hasLength(18));
    expect({for (final row in rows) row.defendingType}, hasLength(18));
  });

  test('guarda el factor de daño en porcentaje', () {
    final rowsByFactor = <int, int>{};
    for (final row in savedTypeEfficacy()) {
      rowsByFactor.update(
        row.damageFactor,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    expect(rowsByFactor, {0: 8, 50: 61, 100: 204, 200: 51});
  });

  test('el fuego hace el doble de daño a la planta', () {
    expect(damageFactorOf('fire', 'grass'), 200);
  });

  test('lo normal no afecta a lo fantasma', () {
    expect(damageFactorOf('normal', 'ghost'), 0);
  });

  test('convierte cada fila en una entrada local con los mismos datos', () {
    const fireAgainstGrass = TypeEfficacyDto(
      attackingType: 'fire',
      defendingType: 'grass',
      damageFactor: 200,
    );

    final entry = fireAgainstGrass.toTypeEfficacyEntry();

    expect(entry.attackingType, 'fire');
    expect(entry.defendingType, 'grass');
    expect(entry.damageFactor, 200);
  });

  test('rechaza una fila sin el factor de daño', () {
    expect(
      () => TypeEfficacyDto.fromJson({
        'type': {'name': 'fire'},
        'TypeByTargetTypeId': {'name': 'grass'},
      }),
      throwsFormatException,
    );
  });

  test('rechaza una fila sin el tipo defensor', () {
    expect(
      () => TypeEfficacyDto.fromJson({
        'damage_factor': 200,
        'type': {'name': 'fire'},
        'TypeByTargetTypeId': null,
      }),
      throwsFormatException,
    );
  });
}
