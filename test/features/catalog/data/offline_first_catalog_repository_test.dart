import 'package:async/async.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/core/sync/domain/call_budget.dart';
import 'package:pokedex_flutter/core/sync/domain/retry_policy.dart';
import 'package:pokedex_flutter/core/sync/sync_scheduler.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';
import 'package:pokedex_flutter/features/catalog/data/offline_first_catalog_repository.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_batch.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_remote_data_source.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/catalog_sync_service.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';

class SinglePagePokeApiCatalog implements CatalogRemoteDataSource {
  @override
  Future<CatalogBatch> fetchCatalogPage({
    required int limit,
    required int offset,
    bool withTotal = false,
  }) async {
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
  Future<List<PokemonDto>> fetchPokemonByIds(List<int> ids) async {
    requestedIdLists.add(ids);
    return [
      for (final id in ids)
        PokemonDto(id: id, name: 'revalidado-$id', typeNames: const ['normal']),
    ];
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
    'syncCatalog pasa por el planificador y deja el estado en sync_metadata',
    () async {
      await repository.syncCatalog();
      final metadata = await database.syncMetadataDao.readByKey('catalog');

      expect(metadata?.status, 'idle');
      expect(metadata?.isComplete, isTrue);
    },
  );

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
}
