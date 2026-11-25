import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/localized_text.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/move_list.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_detail.dart';

PokemonMove _move(
  String english,
  String spanish, {
  MoveLearnMethod method = MoveLearnMethod.levelUp,
  int level = 0,
}) {
  return PokemonMove(
    id: english.hashCode,
    name: LocalizedText(english: english, spanish: spanish),
    method: method,
    level: level,
  );
}

void main() {
  final growl = _move('Growl', 'Gruñido', level: 1);
  final thunderShock = _move('Thunder Shock', 'Impactrueno', level: 1);
  final quickAttack = _move('Quick Attack', 'Ataque Rápido', level: 6);
  final nuzzle = _move('Nuzzle', 'Moflete Estático', level: 0);
  final acidSpray = _move('Acid Spray', 'Ácido', level: 9);
  final thunderbolt = _move(
    'Thunderbolt',
    'Rayo',
    method: MoveLearnMethod.machine,
  );
  final moves = [
    quickAttack,
    thunderbolt,
    growl,
    acidSpray,
    thunderShock,
    nuzzle,
  ];

  test('cuenta los movimientos de cada método, incluidos los vacíos', () {
    expect(moveCountsByMethod(moves), {
      MoveLearnMethod.levelUp: 5,
      MoveLearnMethod.machine: 1,
      MoveLearnMethod.tutor: 0,
      MoveLearnMethod.egg: 0,
    });
  });

  test('elige el primer método con movimientos', () {
    expect(firstMethodWithMoves(moves), MoveLearnMethod.levelUp);
    expect(firstMethodWithMoves([thunderbolt]), MoveLearnMethod.machine);
    expect(firstMethodWithMoves(const []), isNull);
  });

  test('por nivel ordena por nivel y desempata por nombre', () {
    expect(
      movesLearnedBy(
        moves,
        MoveLearnMethod.levelUp,
        order: MoveOrder.level,
        languageCode: 'es',
      ),
      [nuzzle, growl, thunderShock, quickAttack, acidSpray],
    );
  });

  test('por nombre ordena en el idioma de la app ignorando tildes', () {
    expect(
      movesLearnedBy(
        moves,
        MoveLearnMethod.levelUp,
        order: MoveOrder.name,
        languageCode: 'es',
      ),
      [acidSpray, quickAttack, growl, thunderShock, nuzzle],
    );
    expect(
      movesLearnedBy(
        moves,
        MoveLearnMethod.levelUp,
        order: MoveOrder.name,
        languageCode: 'en',
      ),
      [acidSpray, growl, nuzzle, quickAttack, thunderShock],
    );
  });

  test('deja fuera los movimientos de otros métodos', () {
    expect(
      movesLearnedBy(
        moves,
        MoveLearnMethod.machine,
        order: MoveOrder.name,
        languageCode: 'es',
      ),
      [thunderbolt],
    );
  });
}
