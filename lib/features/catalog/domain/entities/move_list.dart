import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_detail.dart';

enum MoveOrder { level, name }

Map<MoveLearnMethod, int> moveCountsByMethod(List<PokemonMove> moves) {
  final counts = {for (final method in MoveLearnMethod.values) method: 0};
  for (final move in moves) {
    counts[move.method] = counts[move.method]! + 1;
  }
  return counts;
}

MoveLearnMethod? firstMethodWithMoves(List<PokemonMove> moves) {
  final counts = moveCountsByMethod(moves);
  for (final method in MoveLearnMethod.values) {
    if (counts[method]! > 0) {
      return method;
    }
  }
  return null;
}

List<PokemonMove> movesLearnedBy(
  List<PokemonMove> moves,
  MoveLearnMethod method, {
  required MoveOrder order,
  required String languageCode,
}) {
  String nameOf(PokemonMove move) =>
      _foldedForSorting(move.name.inLanguage(languageCode) ?? '');

  int byName(PokemonMove first, PokemonMove second) =>
      nameOf(first).compareTo(nameOf(second));

  int byLevel(PokemonMove first, PokemonMove second) {
    final byLevel = first.level.compareTo(second.level);
    return byLevel != 0 ? byLevel : byName(first, second);
  }

  return [
    for (final move in moves)
      if (move.method == method) move,
  ]..sort(switch (order) {
    MoveOrder.level => byLevel,
    MoveOrder.name => byName,
  });
}

const _unaccentedLetters = {
  'á': 'a',
  'é': 'e',
  'í': 'i',
  'ó': 'o',
  'ú': 'u',
  'ü': 'u',
};

String _foldedForSorting(String name) {
  return name
      .toLowerCase()
      .split('')
      .map((letter) => _unaccentedLetters[letter] ?? letter)
      .join();
}
