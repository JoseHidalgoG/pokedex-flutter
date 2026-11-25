import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_page_request.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query.dart';

void main() {
  group('CatalogPageRequest', () {
    final query = CatalogQuery(
      search: 'saur',
      types: {'grass'},
      sort: CatalogSort.nameAscending,
    );

    test('conserva los parámetros de la solicitud', () {
      final request = CatalogPageRequest(page: 2, pageSize: 50, query: query);

      expect(request.page, 2);
      expect(request.pageSize, 50);
      expect(request.query, query);
    });

    test('una solicitud es igual a sí misma', () {
      final request = CatalogPageRequest(page: 0, pageSize: 50, query: query);

      expect(request == request, isTrue);
    });

    test('solicitudes distintas con los mismos valores son iguales', () {
      final first = CatalogPageRequest(page: 0, pageSize: 50, query: query);

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
      final first = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(search: 'pikachu', types: {'electric'}),
      );

      final second = CatalogPageRequest(
        page: first.page,
        pageSize: first.pageSize,
        query: CatalogQuery(
          search: first.query.search,
          types: first.query.types,
          sort: first.query.sort,
        ),
      );

      expect(identical(first, second), isFalse);
      expect(identical(first.query, second.query), isFalse);
      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('páginas diferentes producen solicitudes diferentes', () {
      final first = CatalogPageRequest(page: 0, pageSize: 50, query: query);

      final second = CatalogPageRequest(page: 1, pageSize: 50, query: query);

      expect(first, isNot(second));
    });

    test('tamaños de página diferentes producen solicitudes diferentes', () {
      final first = CatalogPageRequest(page: 0, pageSize: 50, query: query);

      final second = CatalogPageRequest(page: 0, pageSize: 25, query: query);

      expect(first, isNot(second));
    });

    test('búsquedas diferentes producen solicitudes diferentes', () {
      final first = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(search: 'pikachu'),
      );

      final second = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(search: 'raichu'),
      );

      expect(first, isNot(second));
    });

    test('tipos diferentes producen solicitudes diferentes', () {
      final first = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(types: {'fire'}),
      );

      final second = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(types: {'water'}),
      );

      expect(first, isNot(second));
    });

    test('ordenamientos diferentes producen solicitudes diferentes', () {
      final first = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(sort: CatalogSort.nameAscending),
      );

      final second = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: CatalogQuery(sort: CatalogSort.nameDescending),
      );

      expect(first, isNot(second));
    });

    test('no es igual a un objeto de otro tipo', () {
      final request = CatalogPageRequest(page: 0, pageSize: 50, query: query);

      expect(request, isNot(query));
    });

    test('un Set no duplica solicitudes equivalentes', () {
      final first = CatalogPageRequest(page: 0, pageSize: 50, query: query);

      final second = CatalogPageRequest(
        page: first.page,
        pageSize: first.pageSize,
        query: first.query,
      );

      final third = CatalogPageRequest(page: 1, pageSize: 50, query: query);

      final requests = <CatalogPageRequest>{first, second, third};

      expect(identical(first, second), isFalse);
      expect(requests, hasLength(2));
    });

    test('puede utilizarse como clave de un Map', () {
      final pages = <CatalogPageRequest, List<int>>{
        CatalogPageRequest(page: 0, pageSize: 50, query: query): [1, 2],
        CatalogPageRequest(page: 1, pageSize: 50, query: query): [3, 4],
      };

      final equivalentRequest = CatalogPageRequest(
        page: 0,
        pageSize: 50,
        query: query,
      );

      expect(pages[equivalentRequest], [1, 2]);
      expect(pages, hasLength(2));
    });
    group('solicitudes con filtros múltiples', () {
      test('conserva los tipos y generaciones de la consulta', () {
        final request = CatalogPageRequest(
          page: 2,
          pageSize: 50,
          query: CatalogQuery(types: {'fire', 'water'}, generations: {1, 3}),
        );

        expect(request.query.types, {'fire', 'water'});
        expect(request.query.generations, {1, 3});
        expect(request.page, 2);
        expect(request.pageSize, 50);
      });

      test('el orden de selección no afecta la igualdad', () {
        final first = CatalogPageRequest(
          page: 0,
          pageSize: 50,
          query: CatalogQuery(types: {'fire', 'water'}, generations: {1, 2}),
        );

        final second = CatalogPageRequest(
          page: 0,
          pageSize: 50,
          query: CatalogQuery(types: {'water', 'fire'}, generations: {2, 1}),
        );

        expect(first, second);
        expect(first.hashCode, second.hashCode);
      });

      test('diferentes conjuntos de tipos producen solicitudes diferentes', () {
        final first = CatalogPageRequest(
          page: 0,
          pageSize: 50,
          query: CatalogQuery(types: {'fire', 'water'}),
        );

        final second = CatalogPageRequest(
          page: 0,
          pageSize: 50,
          query: CatalogQuery(types: {'fire', 'grass'}),
        );

        expect(first, isNot(second));
      });

      test('generaciones diferentes producen solicitudes diferentes', () {
        final first = CatalogPageRequest(
          page: 0,
          pageSize: 50,
          query: CatalogQuery(generations: {1, 2}),
        );

        final second = CatalogPageRequest(
          page: 0,
          pageSize: 50,
          query: CatalogQuery(generations: {1, 3}),
        );

        expect(first, isNot(second));
      });

      test('una generación seleccionada distingue la solicitud', () {
        final first = CatalogPageRequest(
          page: 0,
          pageSize: 50,
          query: CatalogQuery(),
        );

        final second = CatalogPageRequest(
          page: 0,
          pageSize: 50,
          query: CatalogQuery(generations: {1}),
        );

        expect(first, isNot(second));
      });

      test(
        'permite recuperar páginas con filtros equivalentes desde un Map',
        () {
          final pages = <CatalogPageRequest, List<int>>{
            CatalogPageRequest(
              page: 0,
              pageSize: 50,
              query: CatalogQuery(
                types: {'fire', 'water'},
                generations: {1, 2},
              ),
            ): [
              4,
              7,
              155,
              158,
            ],
          };

          final equivalent = CatalogPageRequest(
            page: 0,
            pageSize: 50,
            query: CatalogQuery(types: {'water', 'fire'}, generations: {2, 1}),
          );

          expect(pages[equivalent], [4, 7, 155, 158]);
        },
      );
    });
  });
}
