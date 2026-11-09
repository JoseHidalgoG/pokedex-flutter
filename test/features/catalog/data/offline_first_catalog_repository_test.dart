import 'package:async/async.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';
import 'package:pokedex_flutter/features/catalog/data/offline_first_catalog_repository.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_remote_data_source.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/catalog_sync_service.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_sync_status.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';

class SinglePagePokeApiCatalog implements CatalogRemoteDataSource {
  @override
  Future<List<PokemonDto>> fetchCatalogPage({
    required int limit,
    required int offset,
  }) async {
    if (offset > 0) {
      return const [];
    }
    return const [
      PokemonDto(id: 1, name: 'bulbasaur', typeNames: ['grass', 'poison']),
      PokemonDto(id: 4, name: 'charmander', typeNames: ['fire']),
    ];
  }
}

void main() {
  late AppDatabase database;
  late CatalogSyncService syncService;
  late OfflineFirstCatalogRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    syncService = CatalogSyncService(
      remoteDataSource: SinglePagePokeApiCatalog(),
      catalogDao: database.catalogDao,
      hasInternetAccess: () async => true,
    );
    repository = OfflineFirstCatalogRepository(
      catalogDao: database.catalogDao,
      syncService: syncService,
    );
  });

  tearDown(() async {
    await syncService.dispose();
    await database.close();
  });

  List<int> idsOf(List<Pokemon> catalog) => [
    for (final pokemon in catalog) pokemon.id,
  ];

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
    'el catálogo se actualiza cuando la sincronización guarda una página',
    () async {
      final catalogUpdates = StreamQueue(repository.watchCatalog().map(idsOf));
      addTearDown(catalogUpdates.cancel);

      expect(await catalogUpdates.next, isEmpty);

      await repository.syncCatalog();

      expect(await catalogUpdates.next, [1, 4]);
      expect(
        await repository.watchSyncStatus().first,
        isA<CatalogSyncSucceeded>(),
      );
    },
  );
}
