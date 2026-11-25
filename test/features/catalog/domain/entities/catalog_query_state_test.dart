import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query_state.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query.dart';

void main() {
  test('estado inicial', () {
    final s = CatalogQueryState.initial();
    expect(s.query, CatalogQuery());
    expect(s.page, 0);
  });
  test('igualdad y hash', () {
    final a = CatalogQueryState.initial();
    final b = CatalogQueryState.initial();
    expect(a, b);
    expect(a.hashCode, b.hashCode);
  });
  test('copyWith conserva consulta', () {
    final a = CatalogQueryState.initial();
    final b = a.copyWith(page: 2);
    expect(b.query, a.query);
    expect(b.page, 2);
    expect(a.page, 0);
    expect(a, isNot(b));
  });
  test('copyWith conserva pagina', () {
    final a = CatalogQueryState(query: CatalogQuery(), page: 2);
    final b = a.copyWith(query: CatalogQuery(search: 'pika'));
    expect(b.page, 2);
    expect(b.query.search, 'pika');
    expect(a.query.search, isEmpty);
  });
}
