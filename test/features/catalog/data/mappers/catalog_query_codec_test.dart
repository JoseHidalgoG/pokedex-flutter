import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query_state.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query.dart';
import 'package:pokedex_flutter/features/catalog/data/mappers/catalog_query_codec.dart';

void main() {
  const codec = CatalogQueryCodec();
  for (final value in <String?>[
    null,
    '',
    ' ',
    '{',
    'null',
    '[]',
    '42',
    '{"version":2}',
  ]) {
    test('valor invalido: $value', () {
      expect(codec.decode(value), CatalogQueryState.initial());
    });
  }
  for (final sort in CatalogSort.values) {
    test('round trip ${sort.name}', () {
      final s = CatalogQueryState(
        query: CatalogQuery(
          search: 'pika',
          types: {'fire', 'water'},
          generations: {1, 9},
          sort: sort,
        ),
        page: 2,
      );
      expect(codec.decode(codec.encode(s)), s);
    });
  }
  test('campos invalidos se normalizan', () {
    final s = codec.decode(
      '{"search":" pika ","types":[" FIRE ","fire",7,"unknown"],"generations":[1,1,9,0,10,"2"],"sort":"bad","page":-1}',
    );
    expect(
      s,
      CatalogQueryState(
        query: CatalogQuery(
          search: 'pika',
          types: {'fire'},
          generations: {1, 9},
        ),
      ),
    );
  });
  test('campos faltantes', () {
    expect(codec.decode('{}'), CatalogQueryState.initial());
  });
  test('tipos de campos incorrectos', () {
    expect(
      codec.decode('{"search":3,"types":true,"generations":{},"page":1.5}'),
      CatalogQueryState.initial(),
    );
  });
  test('serializacion determinista', () {
    expect(
      codec.encode(
        CatalogQueryState(
          query: CatalogQuery(types: {'fire', 'water'}, generations: {1, 2}),
        ),
      ),
      codec.encode(
        CatalogQueryState(
          query: CatalogQuery(types: {'water', 'fire'}, generations: {2, 1}),
        ),
      ),
    );
  });
}
