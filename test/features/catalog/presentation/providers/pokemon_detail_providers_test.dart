import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/detail_freshness.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_detail.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/type_matchups.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/pokemon_detail_repository.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/pokemon_detail_providers.dart';

const pikachu = PokemonDetail(
  pokemon: Pokemon(
    id: 25,
    name: 'pikachu',
    imageUrl: 'https://example.com/25.png',
    typeNames: ['electric'],
  ),
);

class RecordingPokemonDetailRepository implements PokemonDetailRepository {
  final detailUpdates = StreamController<PokemonDetail?>.broadcast();
  final revalidations = <({int id, bool force})>[];
  final stoppedIds = <int>[];

  @override
  Stream<PokemonDetail?> watchPokemonDetail(int pokemonId) {
    return detailUpdates.stream;
  }

  @override
  Stream<DetailFreshness> watchPokemonDetailFreshness(int pokemonId) {
    return Stream.value(const LocalData());
  }

  @override
  Stream<List<TypeEfficacy>> watchTypeEfficacy() {
    return Stream.value(const [
      TypeEfficacy(
        attackingType: 'ground',
        defendingType: 'electric',
        damageFactor: 200,
      ),
    ]);
  }

  @override
  Future<void> revalidatePokemonDetail(
    int pokemonId, {
    bool force = false,
  }) async {
    revalidations.add((id: pokemonId, force: force));
  }

  @override
  void stopRevalidatingPokemonDetail(int pokemonId) {
    stoppedIds.add(pokemonId);
  }

  @override
  Future<void> saveDetailForOffline(int pokemonId) async {}
}

void main() {
  late RecordingPokemonDetailRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = RecordingPokemonDetailRepository();
    addTearDown(repository.detailUpdates.close);
    container = ProviderContainer.test(
      overrides: [
        pokemonDetailRepositoryProvider.overrideWithValue(repository),
      ],
    );
  });

  List<int> revalidatedIds() => [
    for (final revalidation in repository.revalidations) revalidation.id,
  ];

  test(
    'revalida en la primera emisión aunque el Pokémon no esté guardado',
    () async {
      container.listen(pokemonDetailProvider(25), (_, _) {});
      await pumpEventQueue();

      repository.detailUpdates.add(null);
      await pumpEventQueue();

      expect(revalidatedIds(), [25]);
      expect(repository.revalidations.single.force, isFalse);
    },
  );

  test('no vuelve a revalidar cuando el detalle se emite otra vez', () async {
    container.listen(pokemonDetailProvider(25), (_, _) {});
    await pumpEventQueue();

    repository.detailUpdates
      ..add(null)
      ..add(pikachu)
      ..add(pikachu);
    await pumpEventQueue();

    expect(revalidatedIds(), [25]);
    expect(container.read(pokemonDetailProvider(25)).value, same(pikachu));
  });

  test('vuelve a revalidar cuando el detalle se muestra de nuevo', () async {
    final firstShow = container.listen(pokemonDetailProvider(25), (_, _) {});
    await pumpEventQueue();
    repository.detailUpdates.add(pikachu);
    await pumpEventQueue();
    firstShow.close();
    await pumpEventQueue();

    container.listen(pokemonDetailProvider(25), (_, _) {});
    await pumpEventQueue();
    repository.detailUpdates.add(pikachu);
    await pumpEventQueue();

    expect(revalidatedIds(), [25, 25]);
  });

  test(
    'al cerrar el detalle deja de revalidarlo en las reconexiones',
    () async {
      final shown = container.listen(pokemonDetailProvider(25), (_, _) {});
      await pumpEventQueue();
      repository.detailUpdates.add(pikachu);
      await pumpEventQueue();
      expect(repository.stoppedIds, isEmpty);

      shown.close();
      await pumpEventQueue();

      expect(repository.stoppedIds, [25]);
    },
  );

  test('cada Pokémon abierto se revalida por su id', () async {
    container
      ..listen(pokemonDetailProvider(25), (_, _) {})
      ..listen(pokemonDetailProvider(133), (_, _) {});
    await pumpEventQueue();

    repository.detailUpdates.add(pikachu);
    await pumpEventQueue();

    expect(revalidatedIds(), unorderedEquals([25, 133]));
  });

  test(
    'revalidatePokemonDetailProvider pasa el id y force al repositorio',
    () async {
      await container.read(revalidatePokemonDetailProvider)(25, force: true);

      expect(repository.revalidations.single, (id: 25, force: true));
    },
  );

  test('la vigencia y la tabla de tipos salen del repositorio', () async {
    container
      ..listen(pokemonDetailFreshnessProvider(25), (_, _) {})
      ..listen(typeEfficacyProvider, (_, _) {});

    expect(
      await container.read(pokemonDetailFreshnessProvider(25).future),
      const LocalData(),
    );
    expect(await container.read(typeEfficacyProvider.future), hasLength(1));
  });
}
