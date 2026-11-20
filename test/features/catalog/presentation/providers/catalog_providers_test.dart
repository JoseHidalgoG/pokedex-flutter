import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_providers.dart';

class InMemoryCatalogRepository implements CatalogRepository {
  int syncRequests = 0;
  bool? lastForceValue;
  final revalidationRequests = <({List<int> ids, bool force})>[];

  final List<Pokemon> _pokemon = List.generate(
    51,
    (index) => Pokemon(
      id: index + 1,
      name: 'pokemon${index + 1}',
      imageUrl: 'https://example.com/${index + 1}.png',
      typeNames: const ['normal'],
    ),
  );

  @override
  Stream<List<Pokemon>> watchCatalog() {
    return Stream.value(_pokemon);
  }

  @override
  Stream<List<Pokemon>> watchCatalogPage({
    required int page,
    required int pageSize,
  }) {
    final offset = page * pageSize;

    final pagePokemon = _pokemon.skip(offset).take(pageSize).toList();

    return Stream.value(pagePokemon);
  }

  @override
  Stream<int> watchCatalogCount() {
    return Stream.value(_pokemon.length);
  }

  @override
  Stream<List<Pokemon>> watchPokemonByIds(List<int> ids) {
    return Stream.value([
      for (final id in ids) ..._pokemon.where((pokemon) => pokemon.id == id),
    ]);
  }

  @override
  Stream<SyncStatus> watchSyncStatus() {
    return Stream.value(const SyncFullPassInProgress());
  }

  @override
  Future<void> syncCatalog({bool force = false}) async {
    syncRequests++;
    lastForceValue = force;
  }

  @override
  Future<void> revalidatePokemon(List<int> ids, {bool force = false}) async {
    revalidationRequests.add((ids: ids, force: force));
  }

  @override
  Future<DateTime?> getLastSyncedAt() async => null;
}

class ControlledPageCatalogRepository extends InMemoryCatalogRepository {
  final pageUpdates = StreamController<List<Pokemon>>();

  @override
  Stream<List<Pokemon>> watchCatalogPage({
    required int page,
    required int pageSize,
  }) {
    return pageUpdates.stream;
  }
}

void main() {
  late InMemoryCatalogRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = InMemoryCatalogRepository();

    container = ProviderContainer.test(
      overrides: [catalogRepositoryProvider.overrideWithValue(repository)],
    );
  });

  test('catalogProvider emite lo que entrega el repositorio', () async {
    container.listen(catalogProvider, (_, _) {});

    final catalog = await container.read(catalogProvider.future);

    expect(catalog, hasLength(51));
    expect(catalog.first.name, 'pokemon1');
    expect(catalog.last.name, 'pokemon51');
  });

  test(
    'catalogPageProvider devuelve la primera página desde el índice 0',
    () async {
      container.listen(catalogPageProvider(0), (_, _) {});

      final catalog = await container.read(catalogPageProvider(0).future);

      expect(catalog, hasLength(50));
      expect(catalog.first.id, 1);
      expect(catalog.last.id, 50);
    },
  );

  test('catalogCountProvider emite el total de Pokémon', () async {
    container.listen(catalogCountProvider, (_, _) {});

    final count = await container.read(catalogCountProvider.future);

    expect(count, 51);
  });

  test(
    'watchPokemonByIdsProvider entrega los Pokémon que pide la funcionalidad',
    () async {
      final watchPokemonByIds = container.read(watchPokemonByIdsProvider);

      final requested = await watchPokemonByIds([3, 1]).first;

      expect([for (final pokemon in requested) pokemon.id], [3, 1]);
      expect(requested.first.name, 'pokemon3');
    },
  );

  test('catalogSyncStatusProvider emite el estado del repositorio', () async {
    container.listen(catalogSyncStatusProvider, (_, _) {});

    final status = await container.read(catalogSyncStatusProvider.future);

    expect(status, isA<SyncFullPassInProgress>());
  });

  test('syncCatalogProvider llama a syncCatalog del repositorio', () async {
    await container.read(syncCatalogProvider)();

    expect(repository.syncRequests, 1);
  });

  test('la paginación divide 51 Pokémon en páginas de 50 y 1', () async {
    container.listen(catalogPageProvider(0), (_, _) {});
    container.listen(catalogPageProvider(1), (_, _) {});

    final firstPage = await container.read(catalogPageProvider(0).future);

    final secondPage = await container.read(catalogPageProvider(1).future);

    expect(firstPage.length, 50);
    expect(firstPage.first.id, 1);
    expect(firstPage.last.id, 50);

    expect(secondPage.length, 1);
    expect(secondPage.first.id, 51);
  });

  test('syncCatalogProvider utiliza force false por defecto', () async {
    await container.read(syncCatalogProvider)();

    expect(repository.syncRequests, 1);
    expect(repository.lastForceValue, false);
  });

  test('syncCatalogProvider permite forzar la sincronización', () async {
    await container.read(syncCatalogProvider)(force: true);

    expect(repository.syncRequests, 1);
    expect(repository.lastForceValue, true);
  });

  group('revalidación de la página visible', () {
    List<List<int>> requestedIds() => [
      for (final request in repository.revalidationRequests) request.ids,
    ];

    test(
      'pide revalidar los ids de la página la primera vez que se muestra',
      () async {
        container.listen(catalogPageProvider(1), (_, _) {});

        await container.read(catalogPageProvider(1).future);
        await pumpEventQueue();

        expect(requestedIds(), [
          [51],
        ]);
        expect(repository.revalidationRequests.single.force, isFalse);
      },
    );

    test('no vuelve a pedirla cuando la página se emite otra vez', () async {
      final controlledRepository = ControlledPageCatalogRepository();
      addTearDown(controlledRepository.pageUpdates.close);
      final controlledContainer = ProviderContainer.test(
        overrides: [
          catalogRepositoryProvider.overrideWithValue(controlledRepository),
        ],
      );
      const pikachu = Pokemon(
        id: 25,
        name: 'pikachu',
        imageUrl: 'https://example.com/25.png',
        typeNames: ['electric'],
      );
      controlledContainer.listen(catalogPageProvider(0), (_, _) {});

      controlledRepository.pageUpdates
        ..add(const [])
        ..add(const [pikachu])
        ..add(const [pikachu]);
      await pumpEventQueue();

      expect(controlledRepository.revalidationRequests, hasLength(1));
      expect(controlledRepository.revalidationRequests.single.ids, [25]);
    });

    test('vuelve a pedirla cuando la página se muestra de nuevo', () async {
      final firstShow = container.listen(catalogPageProvider(1), (_, _) {});
      await container.read(catalogPageProvider(1).future);
      firstShow.close();
      await pumpEventQueue();

      container.listen(catalogPageProvider(1), (_, _) {});
      await pumpEventQueue();

      expect(requestedIds(), [
        [51],
        [51],
      ]);
    });

    test('no pide nada mientras la página está vacía', () async {
      container.listen(catalogPageProvider(5), (_, _) {});

      final emptyPage = await container.read(catalogPageProvider(5).future);
      await pumpEventQueue();

      expect(emptyPage, isEmpty);
      expect(repository.revalidationRequests, isEmpty);
    });

    test(
      'revalidatePokemonProvider pasa los ids y force al repositorio',
      () async {
        await container.read(revalidatePokemonProvider)([25], force: true);

        expect(requestedIds(), [
          [25],
        ]);
        expect(repository.revalidationRequests.single.force, isTrue);
      },
    );
  });
}
