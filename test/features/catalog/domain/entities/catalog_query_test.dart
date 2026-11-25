import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query.dart';

void main() {
  group('CatalogQuery', () {
    group('constructor', () {
      test('utiliza los valores predeterminados correctos', () {
        const query = CatalogQuery();

        expect(query.search, isEmpty);
        expect(query.type, isNull);
        expect(query.sort, CatalogSort.numberAscending);
      });

      test('conserva los criterios proporcionados', () {
        const query = CatalogQuery(
          search: 'pikachu',
          type: 'electric',
          sort: CatalogSort.nameDescending,
        );

        expect(query.search, 'pikachu');
        expect(query.type, 'electric');
        expect(query.sort, CatalogSort.nameDescending);
      });
    });

    group('copyWith', () {
      const original = CatalogQuery(
        search: 'saur',
        type: 'grass',
        sort: CatalogSort.nameAscending,
      );

      test('sin argumentos conserva todos los valores', () {
        final copy = original.copyWith();

        expect(copy, original);
      });

      test('permite modificar únicamente la búsqueda', () {
        final copy = original.copyWith(search: 'pikachu');

        expect(copy.search, 'pikachu');
        expect(copy.type, 'grass');
        expect(copy.sort, CatalogSort.nameAscending);
      });

      test('permite limpiar la búsqueda', () {
        final copy = original.copyWith(search: '');

        expect(copy.search, isEmpty);
        expect(copy.type, 'grass');
        expect(copy.sort, CatalogSort.nameAscending);
      });

      test('permite modificar únicamente el tipo', () {
        final copy = original.copyWith(type: 'poison');

        expect(copy.search, 'saur');
        expect(copy.type, 'poison');
        expect(copy.sort, CatalogSort.nameAscending);
      });

      test('permite asignar un tipo a una consulta sin filtro', () {
        const query = CatalogQuery();

        final copy = query.copyWith(type: 'electric');

        expect(copy.type, 'electric');
      });

      test('permite eliminar el filtro por tipo', () {
        final copy = original.copyWith(clearType: true);

        expect(copy.search, 'saur');
        expect(copy.type, isNull);
        expect(copy.sort, CatalogSort.nameAscending);
      });

      test('un tipo nulo conserva el filtro anterior', () {
        final copy = original.copyWith(type: null);

        expect(copy.type, 'grass');
      });

      test('clearType tiene prioridad sobre el tipo proporcionado', () {
        final copy = original.copyWith(type: 'fire', clearType: true);

        expect(copy.type, isNull);
      });

      test('permite modificar únicamente el ordenamiento', () {
        final copy = original.copyWith(
          sort: CatalogSort.baseStatTotalDescending,
        );

        expect(copy.search, 'saur');
        expect(copy.type, 'grass');
        expect(copy.sort, CatalogSort.baseStatTotalDescending);
      });

      test('permite modificar todos los criterios simultáneamente', () {
        final copy = original.copyWith(
          search: 'charmander',
          type: 'fire',
          sort: CatalogSort.numberDescending,
        );

        expect(copy.search, 'charmander');
        expect(copy.type, 'fire');
        expect(copy.sort, CatalogSort.numberDescending);
      });

      test('permite restablecer los criterios predeterminados', () {
        final copy = original.copyWith(
          search: '',
          clearType: true,
          sort: CatalogSort.numberAscending,
        );

        expect(copy, const CatalogQuery());
      });

      test('no modifica la consulta original', () {
        original.copyWith(
          search: 'pikachu',
          clearType: true,
          sort: CatalogSort.numberDescending,
        );

        expect(original.search, 'saur');
        expect(original.type, 'grass');
        expect(original.sort, CatalogSort.nameAscending);
      });
    });

    group('igualdad y hashCode', () {
      test('una consulta es igual a sí misma', () {
        const query = CatalogQuery(search: 'pikachu');

        expect(query == query, isTrue);
      });

      test('consultas distintas con los mismos valores son iguales', () {
        const first = CatalogQuery(
          search: 'pikachu',
          type: 'electric',
          sort: CatalogSort.nameAscending,
        );

        final second = CatalogQuery(
          search: first.search,
          type: first.type,
          sort: first.sort,
        );

        expect(identical(first, second), isFalse);
        expect(first, second);
        expect(first.hashCode, second.hashCode);
      });

      test('consultas predeterminadas son equivalentes', () {
        const first = CatalogQuery();
        const second = CatalogQuery();

        expect(first, second);
        expect(first.hashCode, second.hashCode);
      });

      test('búsquedas diferentes producen consultas diferentes', () {
        const first = CatalogQuery(search: 'pikachu');
        const second = CatalogQuery(search: 'raichu');

        expect(first, isNot(second));
      });

      test('tipos diferentes producen consultas diferentes', () {
        const first = CatalogQuery(type: 'fire');
        const second = CatalogQuery(type: 'water');

        expect(first, isNot(second));
      });

      test('una consulta con tipo es diferente de una sin tipo', () {
        const first = CatalogQuery(type: 'electric');
        const second = CatalogQuery();

        expect(first, isNot(second));
      });

      test('ordenamientos diferentes producen consultas diferentes', () {
        const first = CatalogQuery(sort: CatalogSort.numberAscending);

        const second = CatalogQuery(sort: CatalogSort.numberDescending);

        expect(first, isNot(second));
      });

      test('no es igual a un objeto de otro tipo', () {
        const query = CatalogQuery();

        expect(query, isNot('CatalogQuery'));
      });

      test('un Set no duplica consultas equivalentes', () {
        final queries = <CatalogQuery>{};

        queries.add(const CatalogQuery(search: 'pikachu'));
        queries.add(const CatalogQuery(search: 'pikachu'));
        queries.add(const CatalogQuery(search: 'raichu'));

        expect(queries, hasLength(2));
      });

      test('puede utilizarse como clave de un Map', () {
        final results = <CatalogQuery, int>{
          const CatalogQuery(type: 'electric'): 2,
        };

        const equivalentQuery = CatalogQuery(type: 'electric');

        expect(results[equivalentQuery], 2);
      });
    });
  });
}
