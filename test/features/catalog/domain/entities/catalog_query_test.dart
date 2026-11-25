import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query.dart';

void main() {
  group('CatalogQuery', () {
    group('constructor', () {
      test('utiliza los valores predeterminados correctos', () {
        final query = CatalogQuery();

        expect(query.search, isEmpty);
        expect(query.types, isEmpty);
        expect(query.generations, isEmpty);
        expect(query.sort, CatalogSort.numberAscending);
      });

      test('conserva los criterios proporcionados', () {
        final query = CatalogQuery(
          search: 'pikachu',
          types: {'electric'},
          sort: CatalogSort.nameDescending,
        );

        expect(query.search, 'pikachu');
        expect(query.types, {'electric'});
        expect(query.sort, CatalogSort.nameDescending);
      });
    });

    group('copyWith', () {
      final original = CatalogQuery(
        search: 'saur',
        types: {'grass'},
        sort: CatalogSort.nameAscending,
      );

      test('sin argumentos conserva todos los valores', () {
        final copy = original.copyWith();

        expect(copy, original);
      });

      test('permite modificar únicamente la búsqueda', () {
        final copy = original.copyWith(search: 'pikachu');

        expect(copy.search, 'pikachu');
        expect(copy.types, {'grass'});
        expect(copy.sort, CatalogSort.nameAscending);
      });

      test('permite limpiar la búsqueda', () {
        final copy = original.copyWith(search: '');

        expect(copy.search, isEmpty);
        expect(copy.types, {'grass'});
        expect(copy.sort, CatalogSort.nameAscending);
      });

      test('permite modificar únicamente el tipo', () {
        final copy = original.copyWith(types: {'poison'});

        expect(copy.search, 'saur');
        expect(copy.types, {'poison'});
        expect(copy.sort, CatalogSort.nameAscending);
      });

      test('permite asignar un tipo a una consulta sin filtro', () {
        final query = CatalogQuery();

        final copy = query.copyWith(types: {'electric'});

        expect(copy.types, {'electric'});
      });

      test('permite eliminar el filtro por tipo', () {
        final copy = original.copyWith(types: {});

        expect(copy.search, 'saur');
        expect(copy.types, isEmpty);
        expect(copy.sort, CatalogSort.nameAscending);
      });

      test('un conjunto de tipos nulo conserva el filtro anterior', () {
        final copy = original.copyWith(types: null);

        expect(copy.types, {'grass'});
      });

      test('permite limpiar tipos y cambiar generaciones simultáneamente', () {
        final copy = original.copyWith(types: {}, generations: {2});

        expect(copy.types, isEmpty);
        expect(copy.generations, {2});
      });

      test('permite modificar únicamente el ordenamiento', () {
        final copy = original.copyWith(
          sort: CatalogSort.baseStatTotalDescending,
        );

        expect(copy.search, 'saur');
        expect(copy.types, {'grass'});
        expect(copy.sort, CatalogSort.baseStatTotalDescending);
      });

      test('permite modificar todos los criterios simultáneamente', () {
        final copy = original.copyWith(
          search: 'charmander',
          types: {'fire'},
          sort: CatalogSort.numberDescending,
        );

        expect(copy.search, 'charmander');
        expect(copy.types, {'fire'});
        expect(copy.sort, CatalogSort.numberDescending);
      });

      test('permite restablecer los criterios predeterminados', () {
        final copy = original.copyWith(
          search: '',
          types: {},
          sort: CatalogSort.numberAscending,
        );

        expect(copy, CatalogQuery());
      });

      test('no modifica la consulta original', () {
        original.copyWith(
          search: 'pikachu',
          types: {},
          sort: CatalogSort.numberDescending,
        );

        expect(original.search, 'saur');
        expect(original.types, {'grass'});
        expect(original.sort, CatalogSort.nameAscending);
      });
    });

    group('igualdad y hashCode', () {
      test('una consulta es igual a sí misma', () {
        final query = CatalogQuery(search: 'pikachu');

        expect(query == query, isTrue);
      });

      test('consultas distintas con los mismos valores son iguales', () {
        final first = CatalogQuery(
          search: 'pikachu',
          types: {'electric'},
          sort: CatalogSort.nameAscending,
        );

        final second = CatalogQuery(
          search: first.search,
          types: first.types,
          sort: first.sort,
        );

        expect(identical(first, second), isFalse);
        expect(first, second);
        expect(first.hashCode, second.hashCode);
      });

      test('consultas predeterminadas son equivalentes', () {
        final first = CatalogQuery();
        final second = CatalogQuery();

        expect(first, second);
        expect(first.hashCode, second.hashCode);
      });

      test('búsquedas diferentes producen consultas diferentes', () {
        final first = CatalogQuery(search: 'pikachu');
        final second = CatalogQuery(search: 'raichu');

        expect(first, isNot(second));
      });

      test('tipos diferentes producen consultas diferentes', () {
        final first = CatalogQuery(types: {'fire'});
        final second = CatalogQuery(types: {'water'});

        expect(first, isNot(second));
      });

      test('una consulta con tipo es diferente de una sin tipo', () {
        final first = CatalogQuery(types: {'electric'});
        final second = CatalogQuery();

        expect(first, isNot(second));
      });

      test('ordenamientos diferentes producen consultas diferentes', () {
        final first = CatalogQuery(sort: CatalogSort.numberAscending);

        final second = CatalogQuery(sort: CatalogSort.numberDescending);

        expect(first, isNot(second));
      });

      test('no es igual a un objeto de otro tipo', () {
        final query = CatalogQuery();

        expect(query, isNot('CatalogQuery'));
      });

      test('un Set no duplica consultas equivalentes', () {
        final queries = <CatalogQuery>{};

        queries.add(CatalogQuery(search: 'pikachu'));
        queries.add(CatalogQuery(search: 'pikachu'));
        queries.add(CatalogQuery(search: 'raichu'));

        expect(queries, hasLength(2));
      });

      test('puede utilizarse como clave de un Map', () {
        final results = <CatalogQuery, int>{
          CatalogQuery(types: {'electric'}): 2,
        };

        final equivalentQuery = CatalogQuery(types: {'electric'});

        expect(results[equivalentQuery], 2);
      });
    });
    group('filtros múltiples', () {
      test('los conjuntos de filtros están vacíos por defecto', () {
        final query = CatalogQuery();

        expect(query.types, isEmpty);
        expect(query.generations, isEmpty);
        expect(query.types, isEmpty);
      });

      test('conserva varios tipos seleccionados', () {
        final query = CatalogQuery(types: {'fire', 'water'});

        expect(query.types, {'fire', 'water'});
      });

      test('conserva una generación seleccionada', () {
        final query = CatalogQuery(generations: {1});

        expect(query.generations, {1});
      });

      test('conserva varias generaciones seleccionadas', () {
        final query = CatalogQuery(generations: {1, 3, 5});

        expect(query.generations, {1, 3, 5});
      });

      test('conserva un único tipo seleccionado', () {
        final query = CatalogQuery(types: {'electric'});

        expect(query.types, {'electric'});
      });

      test('conserva tres tipos seleccionados', () {
        final query = CatalogQuery(types: {'electric', 'fire', 'water'});

        expect(query.types, {'electric', 'fire', 'water'});
      });

      test('conserva tipos únicos a partir de una colección', () {
        final types = ['fire', 'fire', 'water'];
        final query = CatalogQuery(types: types.toSet());

        expect(query.types, {'fire', 'water'});
        expect(query.types, hasLength(2));
      });

      test('conserva tipos y generaciones simultáneamente', () {
        final query = CatalogQuery(types: {'water'}, generations: {9});

        expect(query.types, {'water'});
        expect(query.generations, {9});
      });
    });
    group('copyWith con filtros múltiples', () {
      final original = CatalogQuery(
        search: 'char',
        types: {'fire', 'flying'},
        generations: {1, 2},
        sort: CatalogSort.nameDescending,
      );

      test('conserva todos los filtros cuando no recibe argumentos', () {
        final copy = original.copyWith();

        expect(copy, original);
        expect(copy.types, original.types);
        expect(copy.generations, original.generations);
      });

      test('permite modificar únicamente los tipos', () {
        final copy = original.copyWith(types: {'water', 'ice'});

        expect(copy.types, {'water', 'ice'});
        expect(copy.generations, {1, 2});
        expect(copy.search, 'char');
        expect(copy.sort, CatalogSort.nameDescending);
      });

      test('permite modificar únicamente las generaciones', () {
        final copy = original.copyWith(generations: {3, 4});

        expect(copy.generations, {3, 4});
        expect(copy.types, {'fire', 'flying'});
        expect(copy.search, 'char');
        expect(copy.sort, CatalogSort.nameDescending);
      });

      test('permite limpiar los tipos seleccionados', () {
        final copy = original.copyWith(types: {});

        expect(copy.types, isEmpty);
        expect(copy.generations, {1, 2});
      });

      test('permite limpiar las generaciones seleccionadas', () {
        final copy = original.copyWith(generations: {});

        expect(copy.generations, isEmpty);
        expect(copy.types, {'fire', 'flying'});
      });

      test('permite restablecer todos los criterios', () {
        final copy = original.copyWith(
          search: '',
          types: {},
          generations: {},
          sort: CatalogSort.numberAscending,
        );

        expect(copy, CatalogQuery());
      });

      test('no modifica los filtros de la consulta original', () {
        original.copyWith(types: {'water'}, generations: {9});

        expect(original.types, {'fire', 'flying'});
        expect(original.generations, {1, 2});
      });

      test('los conjuntos devueltos por copyWith son inmutables', () {
        final copy = original.copyWith();

        expect(() => copy.types.add('water'), throwsUnsupportedError);

        expect(() => copy.generations.add(3), throwsUnsupportedError);
      });
    });
    group('igualdad con filtros múltiples', () {
      test('el orden de selección de los tipos no afecta la igualdad', () {
        final first = CatalogQuery(types: {'fire', 'water'});
        final second = CatalogQuery(types: {'water', 'fire'});

        expect(first, second);
        expect(first.hashCode, second.hashCode);
      });

      test('el orden de las generaciones no afecta la igualdad', () {
        final first = CatalogQuery(generations: {1, 2, 3});
        final second = CatalogQuery(generations: {3, 1, 2});

        expect(first, second);
        expect(first.hashCode, second.hashCode);
      });

      test('conjuntos de tipos diferentes producen consultas diferentes', () {
        final first = CatalogQuery(types: {'fire', 'water'});
        final second = CatalogQuery(types: {'fire', 'grass'});

        expect(first, isNot(second));
      });

      test('generaciones diferentes producen consultas diferentes', () {
        final first = CatalogQuery(generations: {1, 2});
        final second = CatalogQuery(generations: {1, 3});

        expect(first, isNot(second));
      });

      test('conjuntos independientes con un único tipo son equivalentes', () {
        final first = CatalogQuery(types: {'electric'});
        final second = CatalogQuery(types: {'electric'});

        expect(first, second);
        expect(first.hashCode, second.hashCode);
      });

      test('puede recuperar una consulta equivalente desde un Map', () {
        final results = <CatalogQuery, int>{
          CatalogQuery(types: {'fire', 'water'}, generations: {1, 2}): 10,
        };

        final equivalent = CatalogQuery(
          types: {'water', 'fire'},
          generations: {2, 1},
        );

        expect(results[equivalent], 10);
      });
    });
    group('inmutabilidad', () {
      test('el constructor copia defensivamente los tipos', () {
        final types = <String>{'fire', 'water'};
        final query = CatalogQuery(types: types);
        types
          ..clear()
          ..add('electric');
        expect(query.types, {'fire', 'water'});
      });

      test('el constructor copia defensivamente las generaciones', () {
        final generations = <int>{1, 2};
        final query = CatalogQuery(generations: generations);
        generations
          ..clear()
          ..add(9);
        expect(query.generations, {1, 2});
      });

      test('los tipos expuestos por el constructor son inmutables', () {
        final query = CatalogQuery(types: {'fire'});
        expect(() => query.types.add('water'), throwsUnsupportedError);
        expect(() => query.types.clear(), throwsUnsupportedError);
      });

      test('las generaciones expuestas por el constructor son inmutables', () {
        final query = CatalogQuery(generations: {1});
        expect(() => query.generations.add(2), throwsUnsupportedError);
        expect(() => query.generations.clear(), throwsUnsupportedError);
      });

      test('copyWith copia defensivamente los nuevos tipos', () {
        final types = <String>{'water'};
        final copy = CatalogQuery(types: {'fire'}).copyWith(types: types);
        types.add('ice');
        expect(copy.types, {'water'});
      });

      test('copyWith copia defensivamente las nuevas generaciones', () {
        final generations = <int>{2};
        final copy = CatalogQuery(generations: {1})
            .copyWith(generations: generations);
        generations.add(3);
        expect(copy.generations, {2});
      });

      test('el hashCode permanece estable ante cambios externos', () {
        final types = <String>{'fire'};
        final generations = <int>{1};
        final query = CatalogQuery(types: types, generations: generations);
        final hash = query.hashCode;
        types.add('water');
        generations.add(2);
        expect(query.hashCode, hash);
        expect(query, CatalogQuery(types: {'fire'}, generations: {1}));
      });

      test(
        'una clave de Map sigue siendo recuperable tras cambios externos',
        () {
          final types = <String>{'fire'};
          final generations = <int>{1};
          final query = CatalogQuery(types: types, generations: generations);
          final results = <CatalogQuery, int>{query: 5};
          types.clear();
          generations.clear();
          expect(results[query], 5);
          expect(results[CatalogQuery(types: {'fire'}, generations: {1})], 5);
        },
      );
    });
  });
}
