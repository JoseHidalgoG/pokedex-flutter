import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/watch_filtered_catalog_page.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/watch_filtered_catalog_count.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

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

void main() {
  late MockCatalogRepository repository;
  late WatchFilteredCatalogPage watchPage;
  late WatchFilteredCatalogCount watchCount;

  setUp(() {
    repository = MockCatalogRepository();
    watchPage = WatchFilteredCatalogPage(repository);
    watchCount = WatchFilteredCatalogCount(repository);
  });

  group('WatchFilteredCatalogPage', () {
    test('delega una consulta predeterminada al repositorio', () async {
      const query = CatalogQuery();

      when(
        () => repository.watchFilteredCatalogPage(
          page: 0,
          pageSize: 50,
          query: query,
        ),
      ).thenAnswer((_) => Stream.value(const [pikachu, raichu]));

      final result = await watchPage(page: 0, pageSize: 50, query: query).first;

      expect(result, [pikachu, raichu]);

      verify(
        () => repository.watchFilteredCatalogPage(
          page: 0,
          pageSize: 50,
          query: query,
        ),
      ).called(1);

      verifyNoMoreInteractions(repository);
    });

    test('transmite todos los parámetros al repositorio', () async {
      const query = CatalogQuery(
        search: 'rai',
        type: 'electric',
        sort: CatalogSort.nameDescending,
      );

      when(
        () => repository.watchFilteredCatalogPage(
          page: 2,
          pageSize: 10,
          query: query,
        ),
      ).thenAnswer((_) => Stream.value(const [raichu]));

      final result = await watchPage(page: 2, pageSize: 10, query: query).first;

      expect(result, [raichu]);

      verify(
        () => repository.watchFilteredCatalogPage(
          page: 2,
          pageSize: 10,
          query: query,
        ),
      ).called(1);

      verifyNoMoreInteractions(repository);
    });

    test('devuelve el mismo stream proporcionado por el repositorio', () {
      const query = CatalogQuery(type: 'electric');
      final stream = Stream.value(const [pikachu, raichu]);

      when(
        () => repository.watchFilteredCatalogPage(
          page: 0,
          pageSize: 50,
          query: query,
        ),
      ).thenAnswer((_) => stream);

      final result = watchPage(page: 0, pageSize: 50, query: query);

      expect(result, same(stream));
    });

    test('propaga una lista vacía', () async {
      const query = CatalogQuery(search: 'inexistente');

      when(
        () => repository.watchFilteredCatalogPage(
          page: 0,
          pageSize: 50,
          query: query,
        ),
      ).thenAnswer((_) => Stream.value(const <Pokemon>[]));

      final result = await watchPage(page: 0, pageSize: 50, query: query).first;

      expect(result, isEmpty);
    });

    test('propaga todas las actualizaciones del repositorio', () async {
      const query = CatalogQuery(type: 'electric');

      when(
        () => repository.watchFilteredCatalogPage(
          page: 0,
          pageSize: 50,
          query: query,
        ),
      ).thenAnswer(
        (_) => Stream<List<Pokemon>>.fromIterable(const [
          [],
          [pikachu],
          [pikachu, raichu],
        ]),
      );

      await expectLater(
        watchPage(page: 0, pageSize: 50, query: query),
        emitsInOrder([
          isEmpty,
          [pikachu],
          [pikachu, raichu],
          emitsDone,
        ]),
      );
    });

    test('propaga los errores del repositorio', () async {
      const query = CatalogQuery();
      final error = StateError('Error consultando el catálogo');

      when(
        () => repository.watchFilteredCatalogPage(
          page: 0,
          pageSize: 50,
          query: query,
        ),
      ).thenAnswer((_) => Stream<List<Pokemon>>.error(error));

      await expectLater(
        watchPage(page: 0, pageSize: 50, query: query),
        emitsError(same(error)),
      );
    });
  });

  group('WatchFilteredCatalogCount', () {
    test('delega una consulta predeterminada al repositorio', () async {
      const query = CatalogQuery();

      when(() => repository.watchFilteredCatalogCount(query))
          .thenAnswer((_) => Stream.value(51));

      expect(await watchCount(query).first, 51);

      verify(() => repository.watchFilteredCatalogCount(query)).called(1);

      verifyNoMoreInteractions(repository);
    });

    test('transmite todos los criterios de la consulta', () async {
      const query = CatalogQuery(
        search: 'pika',
        type: 'electric',
        sort: CatalogSort.nameAscending,
      );

      when(() => repository.watchFilteredCatalogCount(query))
          .thenAnswer((_) => Stream.value(1));

      expect(await watchCount(query).first, 1);

      verify(() => repository.watchFilteredCatalogCount(query)).called(1);

      verifyNoMoreInteractions(repository);
    });

    test('devuelve el mismo stream proporcionado por el repositorio', () {
      const query = CatalogQuery(type: 'electric');
      final stream = Stream.value(2);

      when(() => repository.watchFilteredCatalogCount(query))
          .thenAnswer((_) => stream);

      expect(watchCount(query), same(stream));
    });

    test('propaga un conteo de cero', () async {
      const query = CatalogQuery(search: 'inexistente');

      when(() => repository.watchFilteredCatalogCount(query))
          .thenAnswer((_) => Stream.value(0));

      expect(await watchCount(query).first, 0);
    });

    test('propaga todas las actualizaciones del conteo', () async {
      const query = CatalogQuery(type: 'electric');

      when(() => repository.watchFilteredCatalogCount(query))
          .thenAnswer((_) => Stream.fromIterable([0, 1, 2, 1]));

      await expectLater(
        watchCount(query),
        emitsInOrder([0, 1, 2, 1, emitsDone]),
      );
    });

    test('propaga los errores del repositorio', () async {
      const query = CatalogQuery();
      final error = StateError('Error contando el catálogo');

      when(() => repository.watchFilteredCatalogCount(query))
          .thenAnswer((_) => Stream<int>.error(error));

      await expectLater(watchCount(query), emitsError(same(error)));
    });
  });
}
