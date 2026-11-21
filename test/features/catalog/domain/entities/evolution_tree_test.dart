import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/evolution_tree.dart';

void main() {
  const bulbasaurLine = <ChainSpecies>[
    (id: 1, name: 'bulbasaur'),
    (id: 2, name: 'ivysaur'),
    (id: 3, name: 'venusaur'),
  ];

  List<String> namesOf(List<EvolutionNode> nodes) => [
    for (final node in nodes) node.speciesName,
  ];

  test('arma la cadena desde la especie base con el trigger de cada paso', () {
    final tree = evolutionTreeOf(
      species: bulbasaurLine,
      steps: const [
        (fromSpeciesId: 2, toSpeciesId: 3, trigger: LevelTrigger(32)),
        (fromSpeciesId: 1, toSpeciesId: 2, trigger: LevelTrigger(16)),
      ],
    )!;

    expect(tree.speciesName, 'bulbasaur');
    expect(tree.trigger, isNull);
    final ivysaur = tree.evolutions.single;
    expect(ivysaur.speciesName, 'ivysaur');
    expect(ivysaur.trigger, const LevelTrigger(16));
    final venusaur = ivysaur.evolutions.single;
    expect(venusaur.trigger, const LevelTrigger(32));
    expect(venusaur.evolves, isFalse);
  });

  test('las ramas salen ordenadas por especie', () {
    final tree = evolutionTreeOf(
      species: const [
        (id: 133, name: 'eevee'),
        (id: 700, name: 'sylveon'),
        (id: 134, name: 'vaporeon'),
        (id: 196, name: 'espeon'),
      ],
      steps: const [
        (
          fromSpeciesId: 133,
          toSpeciesId: 700,
          trigger: FriendshipTrigger(knownMoveType: 'fairy'),
        ),
        (
          fromSpeciesId: 133,
          toSpeciesId: 196,
          trigger: FriendshipTrigger(timeOfDay: EvolutionTimeOfDay.day),
        ),
        (
          fromSpeciesId: 133,
          toSpeciesId: 134,
          trigger: ItemTrigger('water-stone'),
        ),
      ],
    )!;

    expect(namesOf(tree.evolutions), ['vaporeon', 'espeon', 'sylveon']);
  });

  test('una especie sin evoluciones es un árbol de un solo nodo', () {
    final tree = evolutionTreeOf(
      species: const [(id: 128, name: 'tauros')],
      steps: const [],
    )!;

    expect(tree.speciesName, 'tauros');
    expect(tree.evolves, isFalse);
  });

  test('sin especies guardadas no hay árbol', () {
    expect(evolutionTreeOf(species: const [], steps: const []), isNull);
  });

  test('ignora pasos hacia especies que no están en la cadena y repetidos', () {
    final tree = evolutionTreeOf(
      species: bulbasaurLine.sublist(0, 2),
      steps: const [
        (fromSpeciesId: 1, toSpeciesId: 2, trigger: LevelTrigger(16)),
        (fromSpeciesId: 1, toSpeciesId: 2, trigger: OtherTrigger('shed')),
        (fromSpeciesId: 2, toSpeciesId: 3, trigger: LevelTrigger(32)),
      ],
    )!;

    expect(tree.evolutions.single.trigger, const LevelTrigger(16));
    expect(tree.evolutions.single.evolves, isFalse);
  });

  test('un ciclo en los datos no cuelga la construcción', () {
    final tree = evolutionTreeOf(
      species: bulbasaurLine,
      steps: const [
        (fromSpeciesId: 1, toSpeciesId: 2, trigger: LevelTrigger(16)),
        (fromSpeciesId: 2, toSpeciesId: 3, trigger: LevelTrigger(32)),
        (fromSpeciesId: 3, toSpeciesId: 2, trigger: LevelTrigger(50)),
      ],
    )!;

    expect(tree.speciesName, 'bulbasaur');
    expect(namesOf(tree.evolutions.single.evolutions), ['venusaur']);
  });

  test('si todas las especies evolucionan de otra no hay base ni árbol', () {
    final tree = evolutionTreeOf(
      species: bulbasaurLine.sublist(0, 2),
      steps: const [
        (fromSpeciesId: 1, toSpeciesId: 2, trigger: LevelTrigger(16)),
        (fromSpeciesId: 2, toSpeciesId: 1, trigger: LevelTrigger(16)),
      ],
    );

    expect(tree, isNull);
  });
}
