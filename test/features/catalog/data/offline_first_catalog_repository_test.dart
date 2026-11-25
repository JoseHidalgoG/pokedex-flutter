import 'dart:async';

import 'package:async/async.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/core/sync/domain/call_budget.dart';
import 'package:pokedex_flutter/core/sync/domain/retry_policy.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_job.dart';
import 'package:pokedex_flutter/core/sync/sync_scheduler.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';
import 'package:pokedex_flutter/features/catalog/data/offline_first_catalog_repository.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_batch.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_remote_data_source.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_detail_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/type_efficacy_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/catalog_sync_service.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_progress.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query.dart';

class SinglePagePokeApiCatalog implements CatalogRemoteDataSource {
  final requestedCatalogPages = <({int limit, int offset, bool withTotal})>[];

  @override
  Future<CatalogBatch> fetchCatalogPage({
    required int limit,
    required int offset,
    bool withTotal = false,
  }) async {
    requestedCatalogPages.add((
      limit: limit,
      offset: offset,
      withTotal: withTotal,
    ));

    return CatalogBatch(
      pokemon: const [
        PokemonDto(id: 1, name: 'bulbasaur', typeNames: ['grass', 'poison']),
        PokemonDto(id: 4, name: 'charmander', typeNames: ['fire']),
      ],
      totalCount: withTotal ? 2 : null,
    );
  }

  final requestedIdLists = <List<int>>[];

  @override
  Future<List<PokemonDto>> fetchPokemonByIds(
    List<int> ids, {
    CallPriority priority = CallPriority.user,
  }) async {
    requestedIdLists.add(ids);
    return [
      for (final id in ids)
        PokemonDto(id: id, name: 'revalidado-$id', typeNames: const ['normal']),
    ];
  }

  @override
  Future<PokemonDetailDto?> fetchPokemonDetail(int id) {
    throw UnimplementedError('el repositorio del catálogo no pide detalles');
  }

  @override
  Future<List<TypeEfficacyDto>> fetchTypeEfficacy({
    CallPriority priority = CallPriority.background,
  }) {
    throw UnimplementedError('el repositorio del catálogo no pide tipos');
  }
}

const bulbasaurEntry = CatalogEntry(
  id: 1,
  name: 'bulbasaur',
  imageUrl: 'https://example.com/1.png',
  typeNames: ['grass', 'poison'],
);
const charmanderEntry = CatalogEntry(
  id: 4,
  name: 'charmander',
  imageUrl: 'https://example.com/4.png',
  typeNames: ['fire'],
);

const ivysaurEntry = CatalogEntry(
  id: 2,
  name: 'ivysaur',
  imageUrl: 'https://example.com/2.png',
  typeNames: ['grass', 'poison'],
  baseStats: {
    'hp': 60,
    'attack': 62,
    'defense': 63,
    'special-attack': 80,
    'special-defense': 80,
    'speed': 60,
  },
);

const squirtleEntry = CatalogEntry(
  id: 7,
  name: 'squirtle',
  imageUrl: 'https://example.com/7.png',
  typeNames: ['water'],
);

const pikachuEntry = CatalogEntry(
  id: 25,
  name: 'pikachu',
  imageUrl: 'https://example.com/25.png',
  typeNames: ['electric'],
);

const raichuEntry = CatalogEntry(
  id: 26,
  name: 'raichu',
  imageUrl: 'https://example.com/26.png',
  typeNames: ['electric'],
  baseStats: {
    'hp': 60,
    'attack': 90,
    'defense': 55,
    'special-attack': 90,
    'special-defense': 80,
    'speed': 110,
  },
);

void main() {
  late AppDatabase database;
  late SinglePagePokeApiCatalog pokeApi;
  late SyncScheduler scheduler;
  late OfflineFirstCatalogRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    pokeApi = SinglePagePokeApiCatalog();
    scheduler = SyncScheduler(
      budget: CallBudget(),
      retryPolicy: RetryPolicy(),
      store: database.syncMetadataDao,
    );
    repository = OfflineFirstCatalogRepository(
      catalogDao: database.catalogDao,
      syncService: CatalogSyncService(
        remoteDataSource: pokeApi,
        catalogDao: database.catalogDao,
      ),
      scheduler: scheduler,
    );
  });

  tearDown(() async {
    await scheduler.dispose();
    await database.close();
  });

  List<int> idsOf(List<Pokemon> catalog) => [
    for (final pokemon in catalog) pokemon.id,
  ];

  Future<void> saveCatalogDownloadedAt(DateTime savedAt) {
    return database.catalogDao.saveCatalogPage(
      entries: const [bulbasaurEntry, charmanderEntry],
      nextOffset: 2,
      isComplete: true,
      savedAt: savedAt,
    );
  }

  Future<void> saveFilteredTestCatalog() {
    return database.catalogDao.saveCatalogPage(
      entries: const [
        raichuEntry,
        squirtleEntry,
        bulbasaurEntry,
        pikachuEntry,
        charmanderEntry,
        ivysaurEntry,
      ],
      nextOffset: 6,
      isComplete: true,
      totalCount: 6,
      savedAt: DateTime(2026, 11, 23),
    );
  }

  Future<void> saveMultiFilterTestCatalog() {
    return database.catalogDao.saveCatalogPage(
      entries: const [
        CatalogEntry(
          id: 1,
          name: 'bulbasaur',
          imageUrl: '',
          typeNames: ['grass', 'poison'],
          generationId: 1,
          baseStats: {'hp': 318},
        ),
        CatalogEntry(
          id: 4,
          name: 'charmander',
          imageUrl: '',
          typeNames: ['fire'],
          generationId: 1,
          baseStats: {'hp': 309},
        ),
        CatalogEntry(
          id: 7,
          name: 'squirtle',
          imageUrl: '',
          typeNames: ['water'],
          generationId: 1,
          baseStats: {'hp': 314},
        ),
        CatalogEntry(
          id: 25,
          name: 'pikachu',
          imageUrl: '',
          typeNames: ['electric'],
          generationId: 1,
          baseStats: {'hp': 320},
        ),
        CatalogEntry(
          id: 155,
          name: 'cyndaquil',
          imageUrl: '',
          typeNames: ['fire'],
          generationId: 2,
          baseStats: {'hp': 309},
        ),
        CatalogEntry(
          id: 158,
          name: 'totodile',
          imageUrl: '',
          typeNames: ['water'],
          generationId: 2,
          baseStats: {'hp': 314},
        ),
        CatalogEntry(
          id: 194,
          name: 'wooper',
          imageUrl: '',
          typeNames: ['water', 'ground'],
          generationId: 2,
          baseStats: {'hp': 210},
        ),
        CatalogEntry(
          id: 255,
          name: 'torchic',
          imageUrl: '',
          typeNames: ['fire'],
          generationId: 3,
          baseStats: {'hp': 310},
        ),
        CatalogEntry(
          id: 258,
          name: 'mudkip',
          imageUrl: '',
          typeNames: ['water'],
          generationId: 3,
          baseStats: {'hp': 310},
        ),
        CatalogEntry(
          id: 9999,
          name: 'desconocido',
          imageUrl: '',
          typeNames: ['normal'],
        ),
      ],
      nextOffset: 10,
      isComplete: true,
      totalCount: 10,
      savedAt: DateTime(2026, 11, 23),
    );
  }

  Future<List<Pokemon>> filteredPage({
    CatalogQuery? query,
    int page = 0,
    int pageSize = 50,
  }) {
    return repository
        .watchFilteredCatalogPage(
          page: page,
          pageSize: pageSize,
          query: query ?? CatalogQuery(),
        )
        .first;
  }

  void expectNoRemoteRequests() {
    expect(pokeApi.requestedCatalogPages, isEmpty);
    expect(pokeApi.requestedIdLists, isEmpty);
  }

  test('emite Pokémon de dominio con los datos guardados', () async {
    await database.catalogDao.saveCatalogPage(
      entries: const [
        CatalogEntry(
          id: 25,
          name: 'pikachu',
          imageUrl: 'https://example.com/25.png',
          typeNames: ['electric'],
        ),
      ],
      nextOffset: 50,
      isComplete: false,
      savedAt: DateTime(2026, 11, 9),
    );

    final pikachu = (await repository.watchCatalog().first).single;

    expect(pikachu.id, 25);
    expect(pikachu.name, 'pikachu');
    expect(pikachu.imageUrl, 'https://example.com/25.png');
    expect(pikachu.typeNames, ['electric']);
  });

  group('watchCatalogProgress', () {
    test('entrega el progreso de dominio', () async {
      await database.catalogDao.saveCatalogPage(
        entries: const [bulbasaurEntry, charmanderEntry],
        nextOffset: 2,
        isComplete: false,
        savedAt: DateTime(2026, 11, 23),
        totalCount: 1025,
      );

      final progress = await repository.watchCatalogProgress().first;

      expect(
        progress,
        const CatalogProgress(
          savedCount: 2,
          totalCount: 1025,
          isComplete: false,
        ),
      );

      expect(progress.isComplete, isFalse);
    });

    test('entrega el progreso inicial sin metadatos', () async {
      final progress = await repository.watchCatalogProgress().first;

      expect(progress, const CatalogProgress(savedCount: 0, isComplete: false));
    });

    test('entrega el estado completo de los metadatos', () async {
      await database.catalogDao.saveCatalogPage(
        entries: const [bulbasaurEntry, charmanderEntry],
        nextOffset: 2,
        isComplete: true,
        savedAt: DateTime(2026, 11, 23),
        totalCount: 2,
      );

      final progress = await repository.watchCatalogProgress().first;

      expect(
        progress,
        const CatalogProgress(savedCount: 2, totalCount: 2, isComplete: true),
      );
    });

    test('no deduce completitud a partir de las cantidades', () async {
      await database.catalogDao.saveCatalogPage(
        entries: const [bulbasaurEntry, charmanderEntry],
        nextOffset: 2,
        isComplete: false,
        savedAt: DateTime(2026, 11, 23),
        totalCount: 2,
      );

      final progress = await repository.watchCatalogProgress().first;

      expect(
        progress,
        const CatalogProgress(savedCount: 2, totalCount: 2, isComplete: false),
      );
    });

    test('entrega el progreso cuando el total es desconocido', () async {
      await database.catalogDao.saveCatalogPage(
        entries: const [bulbasaurEntry],
        nextOffset: 1,
        isComplete: false,
        savedAt: DateTime(2026, 11, 23),
      );

      final progress = await repository.watchCatalogProgress().first;

      expect(progress, const CatalogProgress(savedCount: 1, isComplete: false));
    });

    test('consultar el progreso no genera solicitudes remotas', () async {
      await database.catalogDao.saveCatalogPage(
        entries: const [bulbasaurEntry],
        nextOffset: 1,
        isComplete: false,
        savedAt: DateTime(2026, 11, 23),
        totalCount: 1025,
      );

      await repository.watchCatalogProgress().first;

      expectNoRemoteRequests();
    });
  });

  test(
    'watchPokemonByIds entrega Pokémon de dominio en el orden pedido',
    () async {
      await database.catalogDao.saveCatalogPage(
        entries: const [
          CatalogEntry(
            id: 1,
            name: 'bulbasaur',
            imageUrl: 'https://example.com/1.png',
            typeNames: ['grass', 'poison'],
          ),
          CatalogEntry(
            id: 25,
            name: 'pikachu',
            imageUrl: 'https://example.com/25.png',
            typeNames: ['electric'],
          ),
        ],
        nextOffset: 50,
        isComplete: false,
        savedAt: DateTime(2026, 11, 9),
      );

      final requested = await repository.watchPokemonByIds([25, 1]).first;

      expect(idsOf(requested), [25, 1]);
      final pikachu = requested.first;
      expect(pikachu.name, 'pikachu');
      expect(pikachu.imageUrl, 'https://example.com/25.png');
      expect(pikachu.typeNames, ['electric']);
      expect(requested.last.typeNames, ['grass', 'poison']);
    },
  );

  test(
    'el catálogo se actualiza cuando la sincronización guarda una página',
    () async {
      final catalogUpdates = StreamQueue(repository.watchCatalog().map(idsOf));
      addTearDown(catalogUpdates.cancel);

      expect(await catalogUpdates.next, isEmpty);

      await repository.syncCatalog();

      expect(await catalogUpdates.next, [1, 4]);
      expect(await repository.watchSyncStatus().first, isA<SyncRevalidated>());
    },
  );

  test(
    'una restauración en curso no cambia el estado que ve el banner',
    () async {
      final restoration = Completer<SyncOutcome>();
      final statuses = <SyncStatus>[];
      final subscription = repository.watchSyncStatus().listen(statuses.add);
      addTearDown(subscription.cancel);

      unawaited(
        scheduler.run(
          SyncJob(
            key: 'catalog:restore',
            priority: CallPriority.restoration,
            runningStatus: const SyncRevalidating(),
            perform: () => restoration.future,
          ),
        ),
      );
      await pumpEventQueue();
      restoration.complete(SyncOutcome.revalidated);
      await pumpEventQueue();

      expect(scheduler.statusOf('catalog:restore'), isA<SyncRevalidated>());
      expect(statuses, [isA<SyncIdle>()]);
    },
  );

  test(
    'syncCatalog pasa por el planificador y deja el estado en sync_metadata',
    () async {
      await repository.syncCatalog();
      final metadata = await database.syncMetadataDao.readByKey('catalog');

      expect(metadata?.status, 'idle');
      expect(metadata?.isComplete, isTrue);
    },
  );

  group('consultas filtradas offline-first', () {
    test('permite buscar Pokémon sin conexión', () async {
      scheduler.connectivityChanged(isOnline: false);

      await saveFilteredTestCatalog();

      expect(scheduler.isOnline, isFalse);

      final entries = await filteredPage(
        query: CatalogQuery(search: 'pikachu'),
      );

      expect(idsOf(entries), [25]);
      expectNoRemoteRequests();
    });

    test('permite filtrar Pokémon sin conexión', () async {
      scheduler.connectivityChanged(isOnline: false);

      await saveFilteredTestCatalog();

      final entries = await filteredPage(query: CatalogQuery(types: {'grass'}));

      expect(idsOf(entries), [1, 2]);
      expectNoRemoteRequests();
    });

    test('permite ordenar Pokémon sin conexión', () async {
      scheduler.connectivityChanged(isOnline: false);

      await saveFilteredTestCatalog();

      final entries = await filteredPage(
        query: CatalogQuery(sort: CatalogSort.numberDescending),
      );

      expect(idsOf(entries), [26, 25, 7, 4, 2, 1]);
      expectNoRemoteRequests();
    });

    test('permite paginar resultados filtrados sin conexión', () async {
      scheduler.connectivityChanged(isOnline: false);

      await saveFilteredTestCatalog();

      final query = CatalogQuery(types: {'electric'});

      final firstPage = await filteredPage(query: query, page: 0, pageSize: 1);

      final secondPage = await filteredPage(query: query, page: 1, pageSize: 1);

      expect(idsOf(firstPage), [25]);
      expect(idsOf(secondPage), [26]);
      expectNoRemoteRequests();
    });

    test('permite contar resultados filtrados sin conexión', () async {
      scheduler.connectivityChanged(isOnline: false);

      await saveFilteredTestCatalog();

      final count = await repository
          .watchFilteredCatalogCount(CatalogQuery(types: {'electric'}))
          .first;

      expect(count, 2);
      expectNoRemoteRequests();
    });

    test('combina todos los criterios sin conexión', () async {
      scheduler.connectivityChanged(isOnline: false);

      await saveFilteredTestCatalog();

      final query = CatalogQuery(
        search: 'saur',
        types: {'poison'},
        sort: CatalogSort.numberDescending,
      );

      final entries = await filteredPage(query: query);

      final count = await repository.watchFilteredCatalogCount(query).first;

      expect(idsOf(entries), [2, 1]);
      expect(count, 2);
      expectNoRemoteRequests();
    });

    test('sin conexión y sin datos devuelve resultados vacíos', () async {
      scheduler.connectivityChanged(isOnline: false);

      final query = CatalogQuery(search: 'pikachu');

      final entries = await filteredPage(query: query);

      final count = await repository.watchFilteredCatalogCount(query).first;

      expect(entries, isEmpty);
      expect(count, 0);
      expectNoRemoteRequests();
    });

    test(
      'tener conexión no provoca solicitudes remotas al consultar',
      () async {
        scheduler.connectivityChanged(isOnline: true);

        await saveFilteredTestCatalog();

        expect(scheduler.isOnline, isTrue);

        final query = CatalogQuery(
          types: {'electric'},
          sort: CatalogSort.nameDescending,
        );

        final entries = await filteredPage(query: query);

        final count = await repository.watchFilteredCatalogCount(query).first;

        expect(idsOf(entries), [26, 25]);
        expect(count, 2);
        expectNoRemoteRequests();
      },
    );

    test(
      'las consultas filtradas no modifican el estado de sincronización',
      () async {
        await saveFilteredTestCatalog();

        expect(await repository.watchSyncStatus().first, isA<SyncIdle>());

        await filteredPage(query: CatalogQuery(search: 'pikachu'));

        await repository
            .watchFilteredCatalogCount(CatalogQuery(types: {'electric'}))
            .first;

        expect(await repository.watchSyncStatus().first, isA<SyncIdle>());

        expectNoRemoteRequests();
      },
    );
  });

  group('revalidatePokemon', () {
    final longAgo = DateTime(2026, 11, 9);

    test('sin conexión no llama a PokeAPI', () async {
      await saveCatalogDownloadedAt(longAgo);

      await repository.revalidatePokemon([1, 4]);

      expect(pokeApi.requestedIdLists, isEmpty);
    });

    test(
      'con los ids frescos no llama a PokeAPI y el estado no cambia',
      () async {
        scheduler.connectivityChanged(isOnline: true);
        await saveCatalogDownloadedAt(DateTime.now());
        final statuses = <SyncStatus>[];
        final subscription = repository.watchSyncStatus().listen(statuses.add);
        addTearDown(subscription.cancel);

        await repository.revalidatePokemon([1, 4]);
        await pumpEventQueue();

        expect(pokeApi.requestedIdLists, isEmpty);
        expect(statuses, [isA<SyncIdle>()]);
      },
    );

    test('con ids vencidos hace una llamada y la página vuelve con los datos nuevos', () async {
      scheduler.connectivityChanged(isOnline: true);
      await saveCatalogDownloadedAt(longAgo);
      final pageNames = StreamQueue(
        repository
            .watchCatalogPage(page: 0, pageSize: 50)
            .map((page) => [for (final pokemon in page) pokemon.name]),
      );
      addTearDown(pageNames.cancel);
      final statuses = StreamQueue(repository.watchSyncStatus());
      addTearDown(statuses.cancel);

      expect(await pageNames.next, ['bulbasaur', 'charmander']);
      expect(await statuses.next, isA<SyncIdle>());

      await repository.revalidatePokemon([1, 4]);

      expect(pokeApi.requestedIdLists, [
        [1, 4],
      ]);
      expect(await pageNames.next, ['revalidado-1', 'revalidado-4']);
      expect(await statuses.next, isA<SyncRevalidating>());
      expect(await statuses.next, isA<SyncRevalidated>());
    });

    test('force llama aunque los ids estén frescos', () async {
      scheduler.connectivityChanged(isOnline: true);
      await saveCatalogDownloadedAt(DateTime.now());

      await repository.revalidatePokemon([1], force: true);

      expect(pokeApi.requestedIdLists, [
        [1],
      ]);
    });

    test(
      'al reconectar revalida lo último que se pidió sin conexión',
      () async {
        await saveCatalogDownloadedAt(longAgo);

        await repository.revalidatePokemon([1]);
        await repository.revalidatePokemon([1, 4]);
        scheduler.connectivityChanged(isOnline: true);

        await expectLater(
          repository.watchSyncStatus(),
          emitsThrough(isA<SyncRevalidated>()),
        );
        expect(pokeApi.requestedIdLists, [
          [1, 4],
        ]);
      },
    );

    test(
      'guarda el estado de lo visible en sync_metadata con su propia clave',
      () async {
        scheduler.connectivityChanged(isOnline: true);
        await saveCatalogDownloadedAt(longAgo);

        await repository.revalidatePokemon([1, 4]);
        final visible = await database.syncMetadataDao.readByKey(
          'catalog:visible',
        );
        final catalog = await database.catalogDao.readCatalogSyncProgress();

        expect(visible?.status, 'idle');
        expect(catalog?.lastSyncedAt, longAgo);
      },
    );
  });

  group('consultas filtradas del catálogo', () {
    setUp(() async {
      await saveFilteredTestCatalog();
    });

    test('una consulta predeterminada devuelve el catálogo local', () async {
      final entries = await filteredPage();

      expect(idsOf(entries), [1, 2, 4, 7, 25, 26]);
      expectNoRemoteRequests();
    });

    test('convierte los resultados filtrados en Pokémon de dominio', () async {
      final entries = await filteredPage(
        query: CatalogQuery(search: 'bulbasaur'),
      );

      expect(entries, hasLength(1));

      final pokemon = entries.single;

      expect(pokemon, isA<Pokemon>());
      expect(pokemon.id, 1);
      expect(pokemon.name, 'bulbasaur');
      expect(pokemon.imageUrl, 'https://example.com/1.png');
      expect(pokemon.typeNames, ['grass', 'poison']);

      expectNoRemoteRequests();
    });

    test('transmite la búsqueda por nombre al DAO', () async {
      final entries = await filteredPage(query: CatalogQuery(search: 'SAUR'));

      expect(idsOf(entries), [1, 2]);
      expectNoRemoteRequests();
    });

    test('transmite la búsqueda numérica al DAO', () async {
      final entries = await filteredPage(query: CatalogQuery(search: '25'));

      expect(idsOf(entries), [25]);
      expectNoRemoteRequests();
    });

    test('transmite el filtro por tipo al DAO', () async {
      final entries = await filteredPage(
        query: CatalogQuery(types: {'electric'}),
      );

      expect(idsOf(entries), [25, 26]);
      expectNoRemoteRequests();
    });

    test('transmite el ordenamiento por nombre al DAO', () async {
      final entries = await filteredPage(
        query: CatalogQuery(sort: CatalogSort.nameAscending),
      );

      expect(idsOf(entries), [1, 4, 2, 25, 26, 7]);
      expectNoRemoteRequests();
    });

    test('transmite el ordenamiento por estadísticas al DAO', () async {
      final entries = await filteredPage(
        query: CatalogQuery(sort: CatalogSort.baseStatTotalDescending),
      );

      expect(idsOf(entries), [26, 2, 1, 4, 7, 25]);
      expectNoRemoteRequests();
    });

    test('transmite todos los criterios de una consulta combinada', () async {
      final entries = await filteredPage(
        query: CatalogQuery(
          search: 'saur',
          types: {'poison'},
          sort: CatalogSort.numberDescending,
        ),
      );

      expect(idsOf(entries), [2, 1]);
      expectNoRemoteRequests();
    });

    test('convierte el número de página en el offset correcto', () async {
      final firstPage = await filteredPage(page: 0, pageSize: 2);

      final secondPage = await filteredPage(page: 1, pageSize: 2);

      final thirdPage = await filteredPage(page: 2, pageSize: 2);

      expect(idsOf(firstPage), [1, 2]);
      expect(idsOf(secondPage), [4, 7]);
      expect(idsOf(thirdPage), [25, 26]);
      expectNoRemoteRequests();
    });

    test('pagina los resultados después de aplicar los filtros', () async {
      final query = CatalogQuery(
        types: {'electric'},
        sort: CatalogSort.numberDescending,
      );

      final firstPage = await filteredPage(query: query, page: 0, pageSize: 1);

      final secondPage = await filteredPage(query: query, page: 1, pageSize: 1);

      expect(idsOf(firstPage), [26]);
      expect(idsOf(secondPage), [25]);
      expectNoRemoteRequests();
    });

    test('devuelve una lista vacía si no existen coincidencias', () async {
      final entries = await filteredPage(
        query: CatalogQuery(search: 'pikachu', types: {'water'}),
      );

      expect(entries, isEmpty);
      expectNoRemoteRequests();
    });

    test('devuelve una lista vacía si la página no existe', () async {
      final entries = await filteredPage(
        query: CatalogQuery(types: {'electric'}),
        page: 2,
        pageSize: 2,
      );

      expect(entries, isEmpty);
      expectNoRemoteRequests();
    });
  });

  group('conteo filtrado del catálogo', () {
    setUp(() async {
      await saveFilteredTestCatalog();
    });

    test('devuelve el total del catálogo con una consulta vacía', () async {
      final count = await repository
          .watchFilteredCatalogCount(CatalogQuery())
          .first;

      expect(count, 6);
      expectNoRemoteRequests();
    });

    test('devuelve el conteo correspondiente a una búsqueda', () async {
      final count = await repository
          .watchFilteredCatalogCount(CatalogQuery(search: 'saur'))
          .first;

      expect(count, 2);
      expectNoRemoteRequests();
    });

    test('devuelve el conteo correspondiente a un tipo', () async {
      final count = await repository
          .watchFilteredCatalogCount(CatalogQuery(types: {'electric'}))
          .first;

      expect(count, 2);
      expectNoRemoteRequests();
    });

    test('combina búsqueda y tipo en el conteo', () async {
      final count = await repository
          .watchFilteredCatalogCount(
            CatalogQuery(search: 'pikachu', types: {'electric'}),
          )
          .first;

      expect(count, 1);
      expectNoRemoteRequests();
    });

    test('devuelve cero si no existen coincidencias', () async {
      final count = await repository
          .watchFilteredCatalogCount(
            CatalogQuery(search: 'pikachu', types: {'fire'}),
          )
          .first;

      expect(count, 0);
      expectNoRemoteRequests();
    });

    test('el conteo es independiente del tamaño de página', () async {
      final query = CatalogQuery(types: {'electric'});

      final entries = await filteredPage(query: query, pageSize: 1);

      final count = await repository.watchFilteredCatalogCount(query).first;

      expect(entries, hasLength(1));
      expect(count, 2);
      expectNoRemoteRequests();
    });
  });

  group('actualizaciones reactivas de consultas filtradas', () {
    test('la búsqueda se actualiza cuando se guardan coincidencias', () async {
      final updates = StreamQueue(
        repository
            .watchFilteredCatalogPage(
              page: 0,
              pageSize: 50,
              query: CatalogQuery(search: 'saur'),
            )
            .map(idsOf),
      );

      addTearDown(updates.cancel);

      expect(await updates.next, isEmpty);

      await saveFilteredTestCatalog();

      expect(await updates.next, [1, 2]);
      expectNoRemoteRequests();
    });

    test('el conteo filtrado se actualiza al guardar el catálogo', () async {
      final updates = StreamQueue(
        repository
            .watchFilteredCatalogCount(CatalogQuery(types: {'electric'}))
            .distinct(),
      );

      addTearDown(updates.cancel);

      expect(await updates.next, 0);

      await saveFilteredTestCatalog();

      expect(await updates.next, 2);
      expectNoRemoteRequests();
    });

    test('la sincronización actualiza una página filtrada', () async {
      final updates = StreamQueue(
        repository
            .watchFilteredCatalogPage(
              page: 0,
              pageSize: 50,
              query: CatalogQuery(types: {'fire'}),
            )
            .map(idsOf),
      );

      addTearDown(updates.cancel);

      expect(await updates.next, isEmpty);

      await repository.syncCatalog();

      expect(await updates.next, [4]);
      expect(pokeApi.requestedCatalogPages, isNotEmpty);
      expect(pokeApi.requestedIdLists, isEmpty);
    });

    test('la sincronización actualiza el conteo filtrado', () async {
      final updates = StreamQueue(
        repository
            .watchFilteredCatalogCount(CatalogQuery(types: {'grass'}))
            .distinct(),
      );

      addTearDown(updates.cancel);

      expect(await updates.next, 0);

      await repository.syncCatalog();

      expect(await updates.next, 1);
      expect(pokeApi.requestedCatalogPages, isNotEmpty);
    });

    test('la revalidación actualiza los resultados de búsqueda', () async {
      scheduler.connectivityChanged(isOnline: true);

      await saveFilteredTestCatalog();

      final updates = StreamQueue(
        repository
            .watchFilteredCatalogPage(
              page: 0,
              pageSize: 50,
              query: CatalogQuery(search: 'pikachu'),
            )
            .map(idsOf),
      );

      addTearDown(updates.cancel);

      expect(await updates.next, [25]);

      await repository.revalidatePokemon([25], force: true);

      expect(await updates.next, isEmpty);

      expect(pokeApi.requestedIdLists, [
        [25],
      ]);

      expect(pokeApi.requestedCatalogPages, isEmpty);
    });

    test('la revalidación actualiza el conteo cuando cambia un tipo', () async {
      scheduler.connectivityChanged(isOnline: true);

      await saveFilteredTestCatalog();

      final updates = StreamQueue(
        repository
            .watchFilteredCatalogCount(CatalogQuery(types: {'electric'}))
            .distinct(),
      );

      addTearDown(updates.cancel);

      expect(await updates.next, 2);

      await repository.revalidatePokemon([25], force: true);

      expect(await updates.next, 1);

      expect(pokeApi.requestedIdLists, [
        [25],
      ]);
    });

    test(
      'la revalidación entrega las entidades de dominio actualizadas',
      () async {
        scheduler.connectivityChanged(isOnline: true);

        await saveFilteredTestCatalog();

        final updates = StreamQueue(
          repository.watchFilteredCatalogPage(
            page: 0,
            pageSize: 50,
            query: CatalogQuery(search: '25'),
          ),
        );

        addTearDown(updates.cancel);

        final initial = await updates.next;

        expect(initial.single.name, 'pikachu');
        expect(initial.single.typeNames, ['electric']);

        await repository.revalidatePokemon([25], force: true);

        final updated = await updates.next;

        expect(updated.single.id, 25);
        expect(updated.single.name, 'revalidado-25');
        expect(updated.single.typeNames, ['normal']);

        expect(pokeApi.requestedIdLists, [
          [25],
        ]);
      },
    );
  });
  group('consultas con múltiples tipos y generaciones', () {
    setUp(() async {
      await saveMultiFilterTestCatalog();
    });

    Future<void> expectResults(
      CatalogQuery query,
      List<int> expectedIds,
    ) async {
      final entries = await filteredPage(query: query);
      final count = await repository.watchFilteredCatalogCount(query).first;

      expect(idsOf(entries), expectedIds);
      expect(count, expectedIds.length);
      expectNoRemoteRequests();
    }

    test('transmite múltiples tipos al DAO', () async {
      await expectResults(CatalogQuery(types: {'fire', 'water'}), [
        4,
        7,
        155,
        158,
        194,
        255,
        258,
      ]);
    });

    test('transmite una generación al DAO', () async {
      await expectResults(CatalogQuery(generations: {2}), [155, 158, 194]);
    });

    test('transmite múltiples generaciones al DAO', () async {
      await expectResults(CatalogQuery(generations: {1, 3}), [
        1,
        4,
        7,
        25,
        255,
        258,
      ]);
    });

    test('combina múltiples tipos y generaciones', () async {
      await expectResults(
        CatalogQuery(types: {'fire', 'water'}, generations: {2, 3}),
        [155, 158, 194, 255, 258],
      );
    });

    test('transmite todos los criterios simultáneamente', () async {
      await expectResults(
        CatalogQuery(
          search: 'char',
          types: {'fire', 'water'},
          generations: {1, 2},
          sort: CatalogSort.nameDescending,
        ),
        [4],
      );
    });

    test('no duplica Pokémon que coinciden con dos tipos', () async {
      await expectResults(
        CatalogQuery(types: {'water', 'ground'}, generations: {2}),
        [158, 194],
      );
    });

    test('devuelve cero cuando los criterios son incompatibles', () async {
      await expectResults(
        CatalogQuery(types: {'electric'}, generations: {3}),
        [],
      );
    });

    test('excluye generaciones desconocidas al aplicar el filtro', () async {
      await expectResults(CatalogQuery(generations: {1, 2, 3}), [
        1,
        4,
        7,
        25,
        155,
        158,
        194,
        255,
        258,
      ]);
    });
  });
  group('filtros múltiples offline-first', () {
    setUp(() async {
      scheduler.connectivityChanged(isOnline: false);
      await saveMultiFilterTestCatalog();
    });

    final query = CatalogQuery(
      types: {'fire', 'water'},
      generations: {1, 2},
      sort: CatalogSort.numberDescending,
    );

    test('combina filtros y ordenamiento sin conexión', () async {
      expect(scheduler.isOnline, isFalse);

      final entries = await filteredPage(query: query);

      expect(idsOf(entries), [194, 158, 155, 7, 4]);
      expectNoRemoteRequests();
    });

    test('permite paginar los resultados sin conexión', () async {
      final first = await filteredPage(query: query, page: 0, pageSize: 2);

      final second = await filteredPage(query: query, page: 1, pageSize: 2);

      final third = await filteredPage(query: query, page: 2, pageSize: 2);

      expect(idsOf(first), [194, 158]);
      expect(idsOf(second), [155, 7]);
      expect(idsOf(third), [4]);

      expectNoRemoteRequests();
    });

    test('el conteo filtrado es independiente de la página', () async {
      final entries = await filteredPage(query: query, pageSize: 2);

      final count = await repository.watchFilteredCatalogCount(query).first;

      expect(entries, hasLength(2));
      expect(count, 5);
      expectNoRemoteRequests();
    });

    test('cambiar los filtros no provoca solicitudes remotas', () async {
      await filteredPage(query: query);

      await filteredPage(query: query.copyWith(generations: {3}));

      await filteredPage(query: query.copyWith(types: {'electric'}));

      await repository.watchFilteredCatalogCount(query).first;

      expectNoRemoteRequests();
      expect(await repository.watchSyncStatus().first, isA<SyncIdle>());
    });
  });
  group('reactividad del repositorio con filtros múltiples', () {
    final query = CatalogQuery(types: {'fire', 'water'}, generations: {2});

    test('la página se actualiza al descargar coincidencias', () async {
      final updates = StreamQueue(
        repository
            .watchFilteredCatalogPage(page: 0, pageSize: 50, query: query)
            .map(idsOf),
      );

      addTearDown(updates.cancel);

      expect(await updates.next, isEmpty);

      await saveMultiFilterTestCatalog();

      expect(await updates.next, [155, 158, 194]);
      expectNoRemoteRequests();
    });

    test('el conteo se actualiza al descargar coincidencias', () async {
      final updates = StreamQueue(
        repository.watchFilteredCatalogCount(query).distinct(),
      );

      addTearDown(updates.cancel);

      expect(await updates.next, 0);

      await saveMultiFilterTestCatalog();

      expect(await updates.next, 3);
      expectNoRemoteRequests();
    });

    test('la revalidación actualiza los resultados filtrados', () async {
      scheduler.connectivityChanged(isOnline: true);

      await saveMultiFilterTestCatalog();

      final updates = StreamQueue(
        repository
            .watchFilteredCatalogPage(page: 0, pageSize: 50, query: query)
            .map(idsOf)
            .distinct(
              (previous, next) =>
                  previous.length == next.length &&
                  previous.asMap().entries.every(
                    (entry) => entry.value == next[entry.key],
                  ),
            ),
      );

      addTearDown(updates.cancel);

      expect(await updates.next, [155, 158, 194]);

      await repository.revalidatePokemon([155], force: true);

      expect(await updates.next, [158, 194]);

      expect(pokeApi.requestedIdLists, [
        [155],
      ]);

      expect(pokeApi.requestedCatalogPages, isEmpty);
    });
  });
}
