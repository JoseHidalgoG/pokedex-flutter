import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query_state.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query.dart';
import 'package:pokedex_flutter/features/catalog/data/repositories/catalog_query_repository_impl.dart';
import 'package:drift/native.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';

void main() {
  late AppDatabase db;
  late CatalogQueryRepositoryImpl repository;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = CatalogQueryRepositoryImpl(db.userPreferencesDao);
  });
  tearDown(() async {
    await db.close();
  });
  test('sin preferencia', () async {
    expect(await repository.load(), CatalogQueryState.initial());
  });
  test('guarda y restaura desde otra instancia', () async {
    final s = CatalogQueryState(
      query: CatalogQuery(
        search: 'pika',
        types: {'electric'},
        generations: {1},
        sort: CatalogSort.nameDescending,
      ),
      page: 2,
    );
    await repository.save(s);
    expect(await CatalogQueryRepositoryImpl(db.userPreferencesDao).load(), s);
  });
  test('sobrescribe consulta', () async {
    await repository.save(CatalogQueryState(query: CatalogQuery(search: 'a')));
    await repository.save(CatalogQueryState(query: CatalogQuery(search: 'b')));
    expect((await repository.load()).query.search, 'b');
  });
  test('clear conserva otras preferencias', () async {
    await db.userPreferencesDao.setPreference('language', 'es');
    await repository.save(CatalogQueryState(query: CatalogQuery(search: 'a')));
    await repository.clear();
    expect(await repository.load(), CatalogQueryState.initial());
    expect(await db.userPreferencesDao.getPreference('language'), 'es');
  });
  test('JSON corrupto', () async {
    await db.userPreferencesDao.setPreference('catalog_query', '{');
    expect(await repository.load(), CatalogQueryState.initial());
  });
}
