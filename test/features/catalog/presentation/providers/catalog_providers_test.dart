import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_progress.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_page_request.dart';

class InMemoryCatalogRepository implements CatalogRepository {
  int syncRequests = 0;
  bool? lastForceValue;
  final revalidationRequests = <({List<int> ids, bool force})>[];
  final filteredPageRequests = <CatalogPageRequest>[];
  final filteredCountRequests = <CatalogQuery>[];

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
  Stream<List<Pokemon>> watchFilteredCatalogPage({
    required int page,
    required int pageSize,
    required CatalogQuery query,
  }) {
    filteredPageRequests.add(
      CatalogPageRequest(page: page, pageSize: pageSize, query: query),
    );

    final filtered = _filteredPokemon(query);
    final offset = page * pageSize;

    return Stream.value(filtered.skip(offset).take(pageSize).toList());
  }

  @override
  Stream<int> watchFilteredCatalogCount(CatalogQuery query) {
    filteredCountRequests.add(query);
    return Stream.value(_filteredPokemon(query).length);
  }

  int generationOf(Pokemon pokemon) {
    if (pokemon.id <= 20) return 1;
    if (pokemon.id <= 40) return 2;
    return 3;
  }

  List<Pokemon> _filteredPokemon(CatalogQuery query) {
    final search = query.search.trim().toLowerCase();
    final searchedId = int.tryParse(search);

    final filtered = _pokemon.where((pokemon) {
      final matchesSearch =
          search.isEmpty ||
          (searchedId != null
              ? pokemon.id == searchedId
              : pokemon.name.toLowerCase().startsWith(search));

      final matchesType =
          query.types.isEmpty || pokemon.typeNames.any(query.types.contains);

      final matchesGeneration =
          query.generations.isEmpty ||
          query.generations.contains(generationOf(pokemon));

      return matchesSearch && matchesType && matchesGeneration;
    }).toList();

    filtered.sort((a, b) {
      final comparison = switch (query.sort) {
        CatalogSort.numberAscending => a.id.compareTo(b.id),
        CatalogSort.numberDescending => b.id.compareTo(a.id),
        CatalogSort.nameAscending => a.name.toLowerCase().compareTo(
          b.name.toLowerCase(),
        ),
        CatalogSort.nameDescending => b.name.toLowerCase().compareTo(
          a.name.toLowerCase(),
        ),
        CatalogSort.baseStatTotalAscending => 0,
        CatalogSort.baseStatTotalDescending => 0,
      };

      return comparison != 0 ? comparison : a.id.compareTo(b.id);
    });

    return filtered;
  }

  @override
  Stream<CatalogProgress> watchCatalogProgress() {
    return Stream.value(
      CatalogProgress(
        savedCount: _pokemon.length,
        totalCount: _pokemon.length,
        isComplete: true,
      ),
    );
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

class ControlledFilteredCatalogRepository extends InMemoryCatalogRepository {
  final filteredPageUpdates = StreamController<List<Pokemon>>.broadcast();

  final filteredCountUpdates = StreamController<int>.broadcast();

  @override
  Stream<List<Pokemon>> watchFilteredCatalogPage({
    required int page,
    required int pageSize,
    required CatalogQuery query,
  }) {
    filteredPageRequests.add(
      CatalogPageRequest(page: page, pageSize: pageSize, query: query),
    );

    return filteredPageUpdates.stream;
  }

  @override
  Stream<int> watchFilteredCatalogCount(CatalogQuery query) {
    filteredCountRequests.add(query);

    return filteredCountUpdates.stream;
  }

  Future<void> dispose() async {
    await Future.wait([
      filteredPageUpdates.close(),
      filteredCountUpdates.close(),
    ]);
  }
}

class ControlledCatalogProgressRepository extends InMemoryCatalogRepository {
  final _progressController = StreamController<CatalogProgress>.broadcast();

  int progressRequests = 0;

  @override
  Stream<CatalogProgress> watchCatalogProgress() {
    progressRequests++;
    return _progressController.stream;
  }

  void emitProgress(CatalogProgress progress) {
    _progressController.add(progress);
  }

  void emitProgressError(Object error) {
    _progressController.addError(error);
  }

  Future<void> dispose() => _progressController.close();
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

  List<int> idsOf(List<Pokemon> pokemon) => [
    for (final item in pokemon) item.id,
  ];

  List<List<int>> requestedIds() => [
    for (final request in repository.revalidationRequests) request.ids,
  ];

  Future<List<Pokemon>> readFilteredPage(CatalogPageRequest request) async {
    final provider = filteredCatalogPageProvider(request);

    container.listen(provider, (_, _) {});

    return container.read(provider.future);
  }

  Future<int> readFilteredCount(CatalogQuery query) async {
    final provider = filteredCatalogCountProvider(query);

    container.listen(provider, (_, _) {});

    return container.read(provider.future);
  }

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

  group('providers de casos de uso filtrados', () {
    test('watchFilteredCatalogPageProvider utiliza el repositorio', () async {
      final query = CatalogQuery(search: '25');

      final watchPage = container.read(watchFilteredCatalogPageProvider);

      final result = await watchPage(page: 0, pageSize: 50, query: query).first;

      expect(idsOf(result), [25]);

      expect(repository.filteredPageRequests, [
        CatalogPageRequest(page: 0, pageSize: 50, query: query),
      ]);
    });

    test('watchFilteredCatalogCountProvider utiliza el repositorio', () async {
      final query = CatalogQuery(types: {'normal'});

      final watchCount = container.read(watchFilteredCatalogCountProvider);

      expect(await watchCount(query).first, 51);
      expect(repository.filteredCountRequests, [query]);
    });
  });

  group('filteredCatalogPageProvider', () {
    test('devuelve la primera página con la consulta predeterminada', () async {
      final request = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(),
      );

      final result = await readFilteredPage(request);

      expect(result, hasLength(50));
      expect(result.first.id, 1);
      expect(result.last.id, 50);
      expect(repository.filteredPageRequests, [request]);
    });

    test('devuelve la segunda página', () async {
      final request = CatalogPageRequest(
        page: 1,
        pageSize: 50,
        query: CatalogQuery(),
      );

      final result = await readFilteredPage(request);

      expect(idsOf(result), [51]);
      expect(repository.filteredPageRequests, [request]);
    });

    test('respeta el tamaño de página solicitado', () async {
      final request = CatalogPageRequest(
        page: 1,
        pageSize: 5,
        query: CatalogQuery(),
      );

      final result = await readFilteredPage(request);

      expect(idsOf(result), [6, 7, 8, 9, 10]);
      expect(repository.filteredPageRequests, [request]);
    });

    test('transmite la búsqueda por nombre', () async {
      final request = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(search: 'pokemon1'),
      );

      final result = await readFilteredPage(request);

      expect(idsOf(result), [1, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]);

      expect(repository.filteredPageRequests, [request]);
    });

    test('transmite la búsqueda por número', () async {
      final request = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(search: '25'),
      );

      final result = await readFilteredPage(request);

      expect(idsOf(result), [25]);
      expect(repository.filteredPageRequests, [request]);
    });

    test('transmite el filtro por tipo', () async {
      final request = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(types: {'normal'}),
      );

      final result = await readFilteredPage(request);

      expect(result, hasLength(50));
      expect(repository.filteredPageRequests, [request]);
    });

    test('transmite el ordenamiento descendente', () async {
      final request = CatalogPageRequest(
        page: 0,
        pageSize: 5,
        query: CatalogQuery(sort: CatalogSort.numberDescending),
      );

      final result = await readFilteredPage(request);

      expect(idsOf(result), [51, 50, 49, 48, 47]);
      expect(repository.filteredPageRequests, [request]);
    });

    test('transmite todos los criterios simultáneamente', () async {
      final request = CatalogPageRequest(
        page: 1,
        pageSize: 3,
        query: CatalogQuery(
          search: 'pokemon1',
          types: {'normal'},
          sort: CatalogSort.numberDescending,
        ),
      );

      final result = await readFilteredPage(request);

      expect(idsOf(result), [16, 15, 14]);
      expect(repository.filteredPageRequests, [request]);
    });

    test('devuelve una lista vacía si no hay coincidencias', () async {
      final request = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(types: {'electric'}),
      );

      final result = await readFilteredPage(request);

      expect(result, isEmpty);
      expect(repository.filteredPageRequests, [request]);
    });

    test('devuelve una lista vacía si la página no existe', () async {
      final request = CatalogPageRequest(
        page: 5,
        pageSize: 50,
        query: CatalogQuery(),
      );

      final result = await readFilteredPage(request);

      expect(result, isEmpty);
      expect(repository.filteredPageRequests, [request]);
    });
    test('transmite múltiples tipos seleccionados', () async {
      final request = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(types: {'normal', 'fire'}),
      );

      final result = await readFilteredPage(request);

      expect(result, hasLength(50));
      expect(repository.filteredPageRequests, [request]);
    });

    test('filtra por una generación', () async {
      final request = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(generations: {2}),
      );

      final result = await readFilteredPage(request);

      expect(idsOf(result), List.generate(20, (index) => index + 21));

      expect(repository.filteredPageRequests, [request]);
    });

    test('filtra por múltiples generaciones', () async {
      final request = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(generations: {1, 3}),
      );

      final result = await readFilteredPage(request);

      expect(idsOf(result), [
        ...List.generate(20, (index) => index + 1),
        ...List.generate(11, (index) => index + 41),
      ]);

      expect(repository.filteredPageRequests, [request]);
    });

    test('combina múltiples tipos y generaciones', () async {
      final request = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(types: {'normal', 'fire'}, generations: {2, 3}),
      );

      final result = await readFilteredPage(request);

      expect(idsOf(result), List.generate(31, (index) => index + 21));

      expect(repository.filteredPageRequests, [request]);
    });

    test('combina todos los criterios y la paginación', () async {
      final request = CatalogPageRequest(
        page: 1,
        pageSize: 3,
        query: CatalogQuery(
          search: 'pokemon1',
          types: {'normal', 'fire'},
          generations: {1, 2},
          sort: CatalogSort.numberDescending,
        ),
      );

      final result = await readFilteredPage(request);

      expect(idsOf(result), [16, 15, 14]);
      expect(repository.filteredPageRequests, [request]);
    });

    test(
      'devuelve una lista vacía con generaciones sin coincidencias',
      () async {
        final request = CatalogPageRequest(
          page: 0,
          pageSize: 50,
          query: CatalogQuery(generations: {9}),
        );

        final result = await readFilteredPage(request);

        expect(result, isEmpty);
        expect(repository.filteredPageRequests, [request]);
      },
    );

    test('devuelve una lista vacía con tipos incompatibles', () async {
      final request = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(types: {'fire', 'water'}, generations: {1, 2}),
      );

      final result = await readFilteredPage(request);

      expect(result, isEmpty);
      expect(repository.filteredPageRequests, [request]);
    });
  });

  group('filteredCatalogCountProvider', () {
    test('devuelve el total con la consulta predeterminada', () async {
      final query = CatalogQuery();

      expect(await readFilteredCount(query), 51);
      expect(repository.filteredCountRequests, [query]);
    });

    test('devuelve el conteo de una búsqueda por nombre', () async {
      final query = CatalogQuery(search: 'pokemon1');

      expect(await readFilteredCount(query), 11);
      expect(repository.filteredCountRequests, [query]);
    });

    test('devuelve el conteo de una búsqueda numérica', () async {
      final query = CatalogQuery(search: '25');

      expect(await readFilteredCount(query), 1);
      expect(repository.filteredCountRequests, [query]);
    });

    test('devuelve el conteo correspondiente al tipo', () async {
      final query = CatalogQuery(types: {'normal'});

      expect(await readFilteredCount(query), 51);
      expect(repository.filteredCountRequests, [query]);
    });

    test('devuelve cero cuando no existen coincidencias', () async {
      final query = CatalogQuery(types: {'fire'});

      expect(await readFilteredCount(query), 0);
      expect(repository.filteredCountRequests, [query]);
    });

    test('el conteo no depende del tamaño de página', () async {
      final query = CatalogQuery(search: 'pokemon1');

      final request = CatalogPageRequest(page: 0, pageSize: 3, query: query);

      final page = await readFilteredPage(request);
      final count = await readFilteredCount(query);

      expect(page, hasLength(3));
      expect(count, 11);
    });

    test('el conteo no solicita revalidaciones ni sincronizaciones', () async {
      await readFilteredCount(CatalogQuery());

      expect(repository.revalidationRequests, isEmpty);
      expect(repository.syncRequests, 0);
      expect(repository.filteredPageRequests, isEmpty);
    });
    test('cuenta los resultados de múltiples tipos', () async {
      final query = CatalogQuery(types: {'normal', 'fire'});

      expect(await readFilteredCount(query), 51);
      expect(repository.filteredCountRequests, [query]);
    });

    test('cuenta los resultados de una generación', () async {
      final query = CatalogQuery(generations: {2});

      expect(await readFilteredCount(query), 20);
      expect(repository.filteredCountRequests, [query]);
    });

    test('cuenta los resultados de múltiples generaciones', () async {
      final query = CatalogQuery(generations: {1, 3});

      expect(await readFilteredCount(query), 31);
      expect(repository.filteredCountRequests, [query]);
    });

    test('combina todos los criterios en el conteo', () async {
      final query = CatalogQuery(
        search: 'pokemon1',
        types: {'normal', 'fire'},
        generations: {1, 2},
        sort: CatalogSort.numberDescending,
      );

      expect(await readFilteredCount(query), 11);
      expect(repository.filteredCountRequests, [query]);
    });

    test('devuelve cero con filtros incompatibles', () async {
      final query = CatalogQuery(types: {'fire', 'water'}, generations: {2, 3});

      expect(await readFilteredCount(query), 0);
      expect(repository.filteredCountRequests, [query]);
    });
  });

  group('identidad y ciclo de vida de los providers filtrados', () {
    test('solicitudes equivalentes reutilizan la misma página', () async {
      final first = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(search: '25'),
      );

      final second = CatalogPageRequest(
        page: first.page,
        pageSize: first.pageSize,
        query: first.query.copyWith(),
      );

      expect(identical(first, second), isFalse);

      final firstResult = await readFilteredPage(first);
      final secondResult = await readFilteredPage(second);

      expect(idsOf(firstResult), [25]);
      expect(idsOf(secondResult), [25]);

      expect(repository.filteredPageRequests, hasLength(1));
    });

    test('consultas equivalentes reutilizan el mismo conteo', () async {
      final first = CatalogQuery(search: 'pokemon1');
      final second = first.copyWith();

      expect(identical(first, second), isFalse);

      expect(await readFilteredCount(first), 11);
      expect(await readFilteredCount(second), 11);

      expect(repository.filteredCountRequests, hasLength(1));
    });

    test('búsquedas diferentes mantienen páginas independientes', () async {
      final first = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(search: '25'),
      );

      final second = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(search: '26'),
      );

      expect(idsOf(await readFilteredPage(first)), [25]);
      expect(idsOf(await readFilteredPage(second)), [26]);

      expect(repository.filteredPageRequests, [first, second]);
    });

    test(
      'números de página diferentes mantienen estados independientes',
      () async {
        final first = CatalogPageRequest(
          page: 0,
          pageSize: 50,
          query: CatalogQuery(),
        );

        final second = CatalogPageRequest(
          page: 1,
          pageSize: 50,
          query: CatalogQuery(),
        );

        expect(await readFilteredPage(first), hasLength(50));
        expect(idsOf(await readFilteredPage(second)), [51]);

        expect(repository.filteredPageRequests, [first, second]);
      },
    );

    test('tipos diferentes mantienen conteos independientes', () async {
      final first = CatalogQuery(types: {'normal'});
      final second = CatalogQuery(types: {'electric'});

      expect(await readFilteredCount(first), 51);
      expect(await readFilteredCount(second), 0);

      expect(repository.filteredCountRequests, [first, second]);
    });

    test('ordenamientos diferentes mantienen páginas independientes', () async {
      final first = CatalogPageRequest(
        page: 0,
        pageSize: 3,
        query: CatalogQuery(sort: CatalogSort.numberAscending),
      );

      final second = CatalogPageRequest(
        page: 0,
        pageSize: 3,
        query: CatalogQuery(sort: CatalogSort.numberDescending),
      );

      expect(idsOf(await readFilteredPage(first)), [1, 2, 3]);
      expect(idsOf(await readFilteredPage(second)), [51, 50, 49]);

      expect(repository.filteredPageRequests, [first, second]);
    });

    test('libera la página filtrada cuando deja de utilizarse', () async {
      final request = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(search: '25'),
      );

      final provider = filteredCatalogPageProvider(request);

      final subscription = container.listen(provider, (_, _) {});

      await container.read(provider.future);

      expect(repository.filteredPageRequests, hasLength(1));

      subscription.close();
      await container.pump();

      container.listen(provider, (_, _) {});

      await container.read(provider.future);

      expect(repository.filteredPageRequests, hasLength(2));
    });

    test('libera el conteo filtrado cuando deja de utilizarse', () async {
      final query = CatalogQuery(types: {'normal'});
      final provider = filteredCatalogCountProvider(query);

      final subscription = container.listen(provider, (_, _) {});

      await container.read(provider.future);

      expect(repository.filteredCountRequests, hasLength(1));

      subscription.close();
      await container.pump();

      container.listen(provider, (_, _) {});

      await container.read(provider.future);

      expect(repository.filteredCountRequests, hasLength(2));
    });
    test('el orden de selección no crea otra instancia de página', () async {
      final first = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(types: {'normal', 'fire'}, generations: {1, 3}),
      );

      final second = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(types: {'fire', 'normal'}, generations: {3, 1}),
      );

      final firstResult = await readFilteredPage(first);
      final secondResult = await readFilteredPage(second);

      expect(idsOf(firstResult), idsOf(secondResult));
      expect(repository.filteredPageRequests, hasLength(1));
    });

    test('el orden de selección no crea otra instancia de conteo', () async {
      final first = CatalogQuery(
        types: {'normal', 'fire'},
        generations: {1, 3},
      );

      final second = CatalogQuery(
        types: {'fire', 'normal'},
        generations: {3, 1},
      );

      expect(await readFilteredCount(first), 31);
      expect(await readFilteredCount(second), 31);

      expect(repository.filteredCountRequests, hasLength(1));
    });

    test('diferentes tipos mantienen páginas independientes', () async {
      final first = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(types: {'normal', 'fire'}),
      );

      final second = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(types: {'water', 'fire'}),
      );

      expect(await readFilteredPage(first), hasLength(50));
      expect(await readFilteredPage(second), isEmpty);

      expect(repository.filteredPageRequests, [first, second]);
    });

    test('diferentes generaciones mantienen páginas independientes', () async {
      final first = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(generations: {1}),
      );

      final second = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(generations: {3}),
      );

      expect(await readFilteredPage(first), hasLength(20));
      expect(await readFilteredPage(second), hasLength(11));

      expect(repository.filteredPageRequests, [first, second]);
    });

    test('diferentes tipos mantienen conteos independientes', () async {
      final first = CatalogQuery(types: {'normal', 'fire'});
      final second = CatalogQuery(types: {'water', 'fire'});

      expect(await readFilteredCount(first), 51);
      expect(await readFilteredCount(second), 0);

      expect(repository.filteredCountRequests, [first, second]);
    });

    test('diferentes generaciones mantienen conteos independientes', () async {
      final first = CatalogQuery(generations: {1});
      final second = CatalogQuery(generations: {3});

      expect(await readFilteredCount(first), 20);
      expect(await readFilteredCount(second), 11);

      expect(repository.filteredCountRequests, [first, second]);
    });
  });

  group('estados reactivos de los providers filtrados', () {
    late ControlledFilteredCatalogRepository controlledRepository;
    late ProviderContainer controlledContainer;

    final request = CatalogPageRequest(
      page: 0,
      pageSize: 50,
      query: CatalogQuery(types: {'electric'}),
    );

    const pikachu = Pokemon(
      id: 25,
      name: 'pikachu',
      imageUrl: 'https://example.com/25.png',
      typeNames: ['electric'],
    );

    const raichu = Pokemon(
      id: 26,
      name: 'raichu',
      imageUrl: 'https://example.com/26.png',
      typeNames: ['electric'],
    );

    setUp(() {
      controlledRepository = ControlledFilteredCatalogRepository();

      controlledContainer = ProviderContainer(
        overrides: [
          catalogRepositoryProvider.overrideWithValue(controlledRepository),
        ],
      );

      addTearDown(() async {
        controlledContainer.dispose();
        await controlledRepository.dispose();
      });
    });

    test('la página comienza en estado de carga', () {
      final provider = filteredCatalogPageProvider(request);

      controlledContainer.listen(provider, (_, _) {});

      expect(
        controlledContainer.read(provider),
        isA<AsyncLoading<List<Pokemon>>>(),
      );
    });

    test('la página cambia a AsyncData cuando recibe resultados', () async {
      final provider = filteredCatalogPageProvider(request);

      controlledContainer.listen(provider, (_, _) {});

      controlledRepository.filteredPageUpdates.add(const [pikachu]);

      await pumpEventQueue();

      final state = controlledContainer.read(provider);

      expect(state, isA<AsyncData<List<Pokemon>>>());
      expect(idsOf(state.asData!.value), [25]);
    });

    test('la página propaga actualizaciones posteriores', () async {
      final provider = filteredCatalogPageProvider(request);

      controlledContainer.listen(provider, (_, _) {});

      controlledRepository.filteredPageUpdates.add(const [pikachu]);

      await pumpEventQueue();

      expect(idsOf(controlledContainer.read(provider).asData!.value), [25]);

      controlledRepository.filteredPageUpdates.add(const [pikachu, raichu]);

      await pumpEventQueue();

      expect(idsOf(controlledContainer.read(provider).asData!.value), [25, 26]);
    });

    test('una página vacía es un resultado válido', () async {
      final provider = filteredCatalogPageProvider(request);

      controlledContainer.listen(provider, (_, _) {});

      controlledRepository.filteredPageUpdates.add(const []);

      await pumpEventQueue();

      final state = controlledContainer.read(provider);

      expect(state, isA<AsyncData<List<Pokemon>>>());
      expect(state.asData!.value, isEmpty);
    });

    test('la página propaga los errores del repositorio', () async {
      final provider = filteredCatalogPageProvider(request);
      final error = StateError('Error de consulta');

      controlledContainer.listen(provider, (_, _) {});

      controlledRepository.filteredPageUpdates.addError(error);

      await pumpEventQueue();

      final state = controlledContainer.read(provider);

      expect(state, isA<AsyncError<List<Pokemon>>>());
      expect(state.asError!.error, same(error));
    });

    test('el conteo comienza en estado de carga', () {
      final provider = filteredCatalogCountProvider(request.query);

      controlledContainer.listen(provider, (_, _) {});

      expect(controlledContainer.read(provider), isA<AsyncLoading<int>>());
    });

    test('el conteo cambia a AsyncData al recibir resultados', () async {
      final provider = filteredCatalogCountProvider(request.query);

      controlledContainer.listen(provider, (_, _) {});

      controlledRepository.filteredCountUpdates.add(2);

      await pumpEventQueue();

      final state = controlledContainer.read(provider);

      expect(state, isA<AsyncData<int>>());
      expect(state.asData!.value, 2);
    });

    test('el conteo propaga actualizaciones posteriores', () async {
      final provider = filteredCatalogCountProvider(request.query);

      controlledContainer.listen(provider, (_, _) {});

      controlledRepository.filteredCountUpdates.add(2);

      await pumpEventQueue();

      expect(controlledContainer.read(provider).asData!.value, 2);

      controlledRepository.filteredCountUpdates.add(1);

      await pumpEventQueue();

      expect(controlledContainer.read(provider).asData!.value, 1);
    });

    test('un conteo de cero es un resultado válido', () async {
      final provider = filteredCatalogCountProvider(request.query);

      controlledContainer.listen(provider, (_, _) {});

      controlledRepository.filteredCountUpdates.add(0);

      await pumpEventQueue();

      final state = controlledContainer.read(provider);

      expect(state, isA<AsyncData<int>>());
      expect(state.asData!.value, 0);
    });

    test('el conteo propaga los errores del repositorio', () async {
      final provider = filteredCatalogCountProvider(request.query);
      final error = StateError('Error de conteo');

      controlledContainer.listen(provider, (_, _) {});

      controlledRepository.filteredCountUpdates.addError(error);

      await pumpEventQueue();

      final state = controlledContainer.read(provider);

      expect(state, isA<AsyncError<int>>());
      expect(state.asError!.error, same(error));
    });
  });

  group('revalidación de páginas filtradas', () {
    test('revalida únicamente los Pokémon de la página filtrada', () async {
      final request = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(search: '25'),
      );

      await readFilteredPage(request);
      await pumpEventQueue();

      expect(requestedIds(), [
        [25],
      ]);

      expect(repository.revalidationRequests.single.force, isFalse);
    });

    test('revalida únicamente los Pokémon de la página solicitada', () async {
      final request = CatalogPageRequest(
        page: 1,
        pageSize: 3,
        query: CatalogQuery(sort: CatalogSort.numberDescending),
      );

      await readFilteredPage(request);
      await pumpEventQueue();

      expect(requestedIds(), [
        [48, 47, 46],
      ]);
    });

    test('no solicita revalidaciones cuando no hay resultados', () async {
      final request = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(types: {'electric'}),
      );

      await readFilteredPage(request);
      await pumpEventQueue();

      expect(repository.revalidationRequests, isEmpty);
    });

    test('consultas equivalentes no duplican la revalidación', () async {
      final first = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(search: '25'),
      );

      final second = CatalogPageRequest(
        page: first.page,
        pageSize: first.pageSize,
        query: first.query.copyWith(),
      );

      await readFilteredPage(first);
      await readFilteredPage(second);
      await pumpEventQueue();

      expect(requestedIds(), [
        [25],
      ]);
    });

    test('una consulta diferente revalida sus propios resultados', () async {
      final first = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(search: '25'),
      );

      final second = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(search: '26'),
      );

      await readFilteredPage(first);
      await readFilteredPage(second);
      await pumpEventQueue();

      expect(requestedIds(), [
        [25],
        [26],
      ]);
    });

    test('vuelve a revalidar cuando se abre una consulta liberada', () async {
      final request = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(search: '25'),
      );

      final provider = filteredCatalogPageProvider(request);

      final subscription = container.listen(provider, (_, _) {});

      await container.read(provider.future);

      subscription.close();
      await container.pump();

      container.listen(provider, (_, _) {});

      await container.read(provider.future);
      await pumpEventQueue();

      expect(requestedIds(), [
        [25],
        [25],
      ]);
    });

    test('no repite la revalidación ante emisiones consecutivas', () async {
      final controlledRepository = ControlledFilteredCatalogRepository();

      final controlledContainer = ProviderContainer(
        overrides: [
          catalogRepositoryProvider.overrideWithValue(controlledRepository),
        ],
      );

      addTearDown(() async {
        controlledContainer.dispose();
        await controlledRepository.dispose();
      });

      final request = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(types: {'electric'}),
      );

      const pikachu = Pokemon(
        id: 25,
        name: 'pikachu',
        imageUrl: 'https://example.com/25.png',
        typeNames: ['electric'],
      );

      controlledContainer.listen(
        filteredCatalogPageProvider(request),
        (_, _) {},
      );

      controlledRepository.filteredPageUpdates
        ..add(const [])
        ..add(const [pikachu])
        ..add(const [pikachu]);

      await pumpEventQueue();

      expect(controlledRepository.revalidationRequests, hasLength(1));

      expect(controlledRepository.revalidationRequests.single.ids, [25]);
    });

    test(
      'revalida cuando una página vacía vuelve a tener resultados',
      () async {
        final controlledRepository = ControlledFilteredCatalogRepository();

        final controlledContainer = ProviderContainer(
          overrides: [
            catalogRepositoryProvider.overrideWithValue(controlledRepository),
          ],
        );

        addTearDown(() async {
          controlledContainer.dispose();
          await controlledRepository.dispose();
        });

        final request = CatalogPageRequest(
          page: 0,
          pageSize: 50,
          query: CatalogQuery(types: {'electric'}),
        );

        const pikachu = Pokemon(
          id: 25,
          name: 'pikachu',
          imageUrl: 'https://example.com/25.png',
          typeNames: ['electric'],
        );

        const raichu = Pokemon(
          id: 26,
          name: 'raichu',
          imageUrl: 'https://example.com/26.png',
          typeNames: ['electric'],
        );

        controlledContainer.listen(
          filteredCatalogPageProvider(request),
          (_, _) {},
        );

        controlledRepository.filteredPageUpdates
          ..add(const [pikachu])
          ..add(const [])
          ..add(const [raichu]);

        await pumpEventQueue();

        expect(
          [
            for (final request in controlledRepository.revalidationRequests)
              request.ids,
          ],
          [
            [25],
            [26],
          ],
        );
      },
    );
  });
  group('revalidación con múltiples filtros', () {
    test('solo revalida los Pokémon que coinciden con los filtros', () async {
      final request = CatalogPageRequest(
        page: 0,
        pageSize: 5,
        query: CatalogQuery(types: {'normal', 'fire'}, generations: {2}),
      );

      final result = await readFilteredPage(request);

      await pumpEventQueue();

      expect(idsOf(result), [21, 22, 23, 24, 25]);

      expect(requestedIds(), [
        [21, 22, 23, 24, 25],
      ]);

      expect(repository.revalidationRequests.single.force, isFalse);
    });

    test('revalida los resultados de la página correspondiente', () async {
      final request = CatalogPageRequest(
        page: 1,
        pageSize: 5,
        query: CatalogQuery(types: {'normal', 'water'}, generations: {2}),
      );

      final result = await readFilteredPage(request);

      await pumpEventQueue();

      expect(idsOf(result), [26, 27, 28, 29, 30]);

      expect(requestedIds(), [
        [26, 27, 28, 29, 30],
      ]);
    });

    test('no solicita revalidaciones si no existen coincidencias', () async {
      final request = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(types: {'fire', 'water'}, generations: {2, 3}),
      );

      final result = await readFilteredPage(request);

      await pumpEventQueue();

      expect(result, isEmpty);
      expect(repository.revalidationRequests, isEmpty);
    });

    test('consultar el conteo no provoca revalidaciones', () async {
      final query = CatalogQuery(
        types: {'normal', 'fire'},
        generations: {1, 3},
      );

      expect(await readFilteredCount(query), 31);

      await pumpEventQueue();

      expect(repository.revalidationRequests, isEmpty);
      expect(repository.syncRequests, 0);
      expect(repository.filteredPageRequests, isEmpty);
    });
  });
  group('catalogProgressProvider', () {
    late ControlledCatalogProgressRepository progressRepository;
    late ProviderContainer progressContainer;
    late ProviderSubscription<AsyncValue<CatalogProgress>> progressSubscription;

    setUp(() async {
      progressRepository = ControlledCatalogProgressRepository();

      progressContainer = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          catalogRepositoryProvider.overrideWithValue(progressRepository),
        ],
      );

      progressSubscription = progressContainer.listen(
        catalogProgressProvider,
        (_, _) {},
      );

      await progressContainer.pump();
    });

    tearDown(() async {
      progressSubscription.close();
      progressContainer.dispose();
      await progressRepository.dispose();
    });

    test('comienza en estado de carga', () {
      final state = progressContainer.read(catalogProgressProvider);

      expect(state.isLoading, isTrue);
    });

    test('entrega un catálogo parcial', () async {
      const progress = CatalogProgress(
        savedCount: 412,
        totalCount: 1025,
        isComplete: false,
      );

      final future = progressContainer.read(catalogProgressProvider.future);

      progressRepository.emitProgress(progress);

      expect(await future, progress);
    });

    test('entrega un catálogo completo', () async {
      const progress = CatalogProgress(
        savedCount: 1025,
        totalCount: 1025,
        isComplete: true,
      );

      final future = progressContainer.read(catalogProgressProvider.future);

      progressRepository.emitProgress(progress);

      expect(await future, progress);
    });

    test('entrega progreso con total desconocido', () async {
      const progress = CatalogProgress(savedCount: 200, isComplete: false);

      final future = progressContainer.read(catalogProgressProvider.future);

      progressRepository.emitProgress(progress);

      final result = await future;

      expect(result.savedCount, 200);
      expect(result.totalCount, isNull);
      expect(result.isComplete, isFalse);
    });

    test('recibe actualizaciones durante la sincronización', () async {
      final received = <CatalogProgress>[];

      final subscription = progressContainer.listen(catalogProgressProvider, (
        _,
        next,
      ) {
        final progress = next.asData?.value;

        if (progress != null) {
          received.add(progress);
        }
      });

      addTearDown(subscription.close);

      const first = CatalogProgress(
        savedCount: 200,
        totalCount: 1025,
        isComplete: false,
      );

      const second = CatalogProgress(
        savedCount: 500,
        totalCount: 1025,
        isComplete: false,
      );

      final future = progressContainer.read(catalogProgressProvider.future);

      progressRepository.emitProgress(first);

      await future;
      await progressContainer.pump();

      progressRepository.emitProgress(second);

      await progressContainer.pump();

      expect(received, [first, second]);
    });

    test('recibe el cambio de completitud sin cambiar cantidades', () async {
      final received = <CatalogProgress>[];

      final subscription = progressContainer.listen(catalogProgressProvider, (
        _,
        next,
      ) {
        final progress = next.asData?.value;

        if (progress != null) {
          received.add(progress);
        }
      });

      addTearDown(subscription.close);

      const incomplete = CatalogProgress(
        savedCount: 1025,
        totalCount: 1025,
        isComplete: false,
      );

      const complete = CatalogProgress(
        savedCount: 1025,
        totalCount: 1025,
        isComplete: true,
      );

      final future = progressContainer.read(catalogProgressProvider.future);

      progressRepository.emitProgress(incomplete);

      await future;
      await progressContainer.pump();

      progressRepository.emitProgress(complete);

      await progressContainer.pump();

      expect(received, [incomplete, complete]);
    });

    test('comparte la consulta entre múltiples consumidores', () async {
      final first = progressContainer.listen(
        catalogProgressProvider,
        (_, _) {},
      );

      final second = progressContainer.listen(
        catalogProgressProvider,
        (_, _) {},
      );

      addTearDown(first.close);
      addTearDown(second.close);

      final future = progressContainer.read(catalogProgressProvider.future);

      progressRepository.emitProgress(
        const CatalogProgress(
          savedCount: 200,
          totalCount: 1025,
          isComplete: false,
        ),
      );

      await future;

      expect(progressRepository.progressRequests, 1);
    });

    test('observar el progreso no inicia sincronizaciones', () async {
      final future = progressContainer.read(catalogProgressProvider.future);

      progressRepository.emitProgress(
        const CatalogProgress(
          savedCount: 200,
          totalCount: 1025,
          isComplete: false,
        ),
      );

      await future;

      expect(progressRepository.syncRequests, 0);
      expect(progressRepository.revalidationRequests, isEmpty);
      expect(progressRepository.filteredPageRequests, isEmpty);
      expect(progressRepository.filteredCountRequests, isEmpty);
    });

    test('expone errores del stream de progreso', () async {
      final future = progressContainer.read(catalogProgressProvider.future);

      final error = StateError('Error leyendo el progreso');

      final expectation = expectLater(future, throwsA(same(error)));

      progressRepository.emitProgressError(error);

      await expectation;

      expect(progressContainer.read(catalogProgressProvider).hasError, isTrue);
    });
  });
}
