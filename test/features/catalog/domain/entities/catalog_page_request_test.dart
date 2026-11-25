import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_page_request.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query.dart';

void main() {
  group('CatalogPageRequest', () {
    const query = CatalogQuery(
      search: 'saur',
      type: 'grass',
      sort: CatalogSort.nameAscending,
    );

    test('conserva los parámetros de la solicitud', () {
      const request = CatalogPageRequest(page: 2, pageSize: 50, query: query);

      expect(request.page, 2);
      expect(request.pageSize, 50);
      expect(request.query, query);
    });

    test('una solicitud es igual a sí misma', () {
      const request = CatalogPageRequest(page: 0, pageSize: 50, query: query);

      expect(request == request, isTrue);
    });

    test('solicitudes distintas con los mismos valores son iguales', () {
      const first = CatalogPageRequest(page: 0, pageSize: 50, query: query);

      final second = CatalogPageRequest(
        page: first.page,
        pageSize: first.pageSize,
        query: first.query,
      );

      expect(identical(first, second), isFalse);
      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('consultas equivalentes producen solicitudes equivalentes', () {
      const first = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(search: 'pikachu', type: 'electric'),
      );

      final second = CatalogPageRequest(
        page: first.page,
        pageSize: first.pageSize,
        query: CatalogQuery(
          search: first.query.search,
          type: first.query.type,
          sort: first.query.sort,
        ),
      );

      expect(identical(first, second), isFalse);
      expect(identical(first.query, second.query), isFalse);
      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('páginas diferentes producen solicitudes diferentes', () {
      const first = CatalogPageRequest(page: 0, pageSize: 50, query: query);

      const second = CatalogPageRequest(page: 1, pageSize: 50, query: query);

      expect(first, isNot(second));
    });

    test('tamaños de página diferentes producen solicitudes diferentes', () {
      const first = CatalogPageRequest(page: 0, pageSize: 50, query: query);

      const second = CatalogPageRequest(page: 0, pageSize: 25, query: query);

      expect(first, isNot(second));
    });

    test('búsquedas diferentes producen solicitudes diferentes', () {
      const first = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(search: 'pikachu'),
      );

      const second = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(search: 'raichu'),
      );

      expect(first, isNot(second));
    });

    test('tipos diferentes producen solicitudes diferentes', () {
      const first = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(type: 'fire'),
      );

      const second = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(type: 'water'),
      );

      expect(first, isNot(second));
    });

    test('ordenamientos diferentes producen solicitudes diferentes', () {
      const first = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(sort: CatalogSort.nameAscending),
      );

      const second = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(sort: CatalogSort.nameDescending),
      );

      expect(first, isNot(second));
    });

    test('no es igual a un objeto de otro tipo', () {
      const request = CatalogPageRequest(page: 0, pageSize: 50, query: query);

      expect(request, isNot(query));
    });

    test('un Set no duplica solicitudes equivalentes', () {
      const first = CatalogPageRequest(page: 0, pageSize: 50, query: query);

      final second = CatalogPageRequest(
        page: first.page,
        pageSize: first.pageSize,
        query: first.query,
      );

      const third = CatalogPageRequest(page: 1, pageSize: 50, query: query);

      final requests = <CatalogPageRequest>{first, second, third};

      expect(identical(first, second), isFalse);
      expect(requests, hasLength(2));
    });

    test('puede utilizarse como clave de un Map', () {
      final pages = <CatalogPageRequest, List<int>>{
        const CatalogPageRequest(page: 0, pageSize: 50, query: query): [1, 2],
        const CatalogPageRequest(page: 1, pageSize: 50, query: query): [3, 4],
      };

      const equivalentRequest = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: query,
      );

      expect(pages[equivalentRequest], [1, 2]);
      expect(pages, hasLength(2));
    });
  });
}
