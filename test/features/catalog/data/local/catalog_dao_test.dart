import 'package:async/async.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_dao.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';

const bulbasaur = CatalogEntry(
  id: 1,
  name: 'bulbasaur',
  imageUrl: 'https://example.com/1.png',
  typeNames: ['grass', 'poison'],
);
const charmander = CatalogEntry(
  id: 4,
  name: 'charmander',
  imageUrl: 'https://example.com/4.png',
  typeNames: ['fire'],
);
const squirtle = CatalogEntry(
  id: 7,
  name: 'squirtle',
  imageUrl: 'https://example.com/7.png',
  typeNames: ['water'],
);

void main() {
  late AppDatabase database;
  late CatalogDao catalogDao;
  final savedAt = DateTime(2026, 11, 7, 10, 30);

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    catalogDao = database.catalogDao;
  });

  tearDown(() => database.close());

  Future<void> savePage(
    List<CatalogEntry> entries, {
    int nextOffset = 50,
    bool isComplete = false,
  }) {
    return catalogDao.saveCatalogPage(
      entries: entries,
      nextOffset: nextOffset,
      isComplete: isComplete,
      savedAt: savedAt,
    );
  }

  Future<int> countRowsIn(TableInfo<Table, Object?> table) {
    return database.select(table).get().then((rows) => rows.length);
  }

  List<int> idsOf(List<CatalogEntry> entries) => [
    for (final entry in entries) entry.id,
  ];

  test('no guarda duplicados cuando la misma página llega dos veces', () async {
    await savePage([bulbasaur, charmander, squirtle]);
    await savePage([bulbasaur, charmander, squirtle]);

    expect(await countRowsIn(database.pokemonTable), 3);
    expect(await countRowsIn(database.pokemonTypesTable), 4);
  });

  test(
    'reemplaza los tipos de un Pokémon cuando vuelve a llegar con otros',
    () async {
      await savePage([bulbasaur]);
      await savePage([
        const CatalogEntry(
          id: 1,
          name: 'bulbasaur',
          imageUrl: 'https://example.com/1.png',
          typeNames: ['grass'],
        ),
      ]);

      final catalog = await catalogDao.watchCatalog().first;

      expect(catalog.single.typeNames, ['grass']);
    },
  );

  test(
    'emite el catálogo ordenado por número con los tipos en orden de slot',
    () async {
      await savePage([squirtle, bulbasaur, charmander]);

      final catalog = await catalogDao.watchCatalog().first;

      expect(idsOf(catalog), [1, 4, 7]);
      expect(catalog.first.name, 'bulbasaur');
      expect(catalog.first.imageUrl, 'https://example.com/1.png');
      expect(catalog.first.typeNames, ['grass', 'poison']);
    },
  );

  test('vuelve a emitir el catálogo cuando se guarda una página', () async {
    final catalogUpdates = StreamQueue(catalogDao.watchCatalog().map(idsOf));
    addTearDown(catalogUpdates.cancel);

    expect(await catalogUpdates.next, isEmpty);

    await savePage([bulbasaur, charmander]);
    expect(await catalogUpdates.next, [1, 4]);

    await savePage([squirtle], nextOffset: 100);
    expect(await catalogUpdates.next, [1, 4, 7]);
  });

  test('guarda el siguiente offset junto con la página', () async {
    await savePage([bulbasaur, charmander, squirtle], nextOffset: 50);

    final progress = await catalogDao.readCatalogSyncProgress();

    expect(progress?.nextOffset, 50);
    expect(progress?.isComplete, isFalse);
    expect(progress?.lastSyncedAt, savedAt);
    expect(progress?.lastError, isNull);
  });

  test('no tiene progreso antes de la primera sincronización', () async {
    expect(await catalogDao.readCatalogSyncProgress(), isNull);
  });

  test('un fallo de sincronización conserva el progreso guardado', () async {
    await savePage([bulbasaur], nextOffset: 50);

    await catalogDao.recordCatalogSyncFailure('Sin conexión');
    final progress = await catalogDao.readCatalogSyncProgress();

    expect(progress?.nextOffset, 50);
    expect(progress?.lastError, 'Sin conexión');
    expect(await countRowsIn(database.pokemonTable), 1);
  });

  test('limpia el último error cuando una página se guarda bien', () async {
    await catalogDao.recordCatalogSyncFailure('Sin conexión');

    await savePage([bulbasaur], nextOffset: 50, isComplete: true);
    final progress = await catalogDao.readCatalogSyncProgress();

    expect(progress?.lastError, isNull);
    expect(progress?.isComplete, isTrue);
  });

  test('resincronizar el catálogo no toca los favoritos', () async {
    await savePage([bulbasaur, charmander]);
    await database
        .into(database.favoritesTable)
        .insert(
          FavoritesTableCompanion.insert(
            pokemonId: const Value(4),
            createdAt: savedAt,
          ),
        );

    await savePage([bulbasaur, charmander]);
    final favorites = await database.select(database.favoritesTable).get();

    expect([for (final favorite in favorites) favorite.pokemonId], [4]);
  });
}
