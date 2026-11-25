import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query_state.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_query_providers.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_query_controller_provider.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../fakes/fake_catalog_query_repository.dart';

class ControlledRepository extends FakeCatalogQueryRepository {
  final gate = Completer<void>();
  final started = Completer<void>();
  @override
  Future<void> save(CatalogQueryState state) async {
    if (!started.isCompleted) {
      started.complete();
      await gate.future;
    }
    await super.save(state);
  }
}

class FailingRepository extends FakeCatalogQueryRepository {
  bool failLoad = false;
  bool failSave = false;
  @override
  Future<CatalogQueryState> load() async {
    if (failLoad) throw StateError('read');
    return super.load();
  }

  @override
  Future<void> save(CatalogQueryState state) async {
    if (failSave) throw StateError('write');
    await super.save(state);
  }
}

void main() {
  ProviderContainer containerFor(FakeCatalogQueryRepository repo) {
    final c = ProviderContainer(
      overrides: [catalogQueryRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('restaura sin escribir', () async {
    final s = CatalogQueryState(query: CatalogQuery(search: 'pika'), page: 2);
    final r = FakeCatalogQueryRepository(initialState: s);
    final c = containerFor(r);
    expect(await c.read(catalogQueryControllerProvider.future), s);
    expect(r.saveCalls, 0);
  });
  for (final field in ['search', 'types', 'generations', 'sort']) {
    test('$field reinicia pagina y guarda', () async {
      final r = FakeCatalogQueryRepository(
        initialState: CatalogQueryState(query: CatalogQuery(), page: 2),
      );
      final c = containerFor(r);
      await c.read(catalogQueryControllerProvider.future);
      final n = c.read(catalogQueryControllerProvider.notifier);
      final expected = switch (field) {
        'search' => CatalogQuery(search: 'pika'),
        'types' => CatalogQuery(types: {'fire'}),
        'generations' => CatalogQuery(generations: {2}),
        _ => CatalogQuery(sort: CatalogSort.nameDescending),
      };
      switch (field) {
        case 'search':
          await n.setSearch(' pika ');
        case 'types':
          await n.setTypes({'fire'});
        case 'generations':
          await n.setGenerations({2});
        default:
          await n.setSort(CatalogSort.nameDescending);
      }
      expect(r.storedState, CatalogQueryState(query: expected));
      expect(r.saveCalls, 1);
    });
  }
  test('pagina conserva criterios y omite cambios identicos', () async {
    final q = CatalogQuery(search: 'pika', types: {'electric'});
    final r = FakeCatalogQueryRepository(
      initialState: CatalogQueryState(query: q),
    );
    final c = containerFor(r);
    await c.read(catalogQueryControllerProvider.future);
    final n = c.read(catalogQueryControllerProvider.notifier);
    await n.setPage(2);
    await n.setPage(2);
    await n.setPage(-1);
    await n.setTypes({'electric'});
    await n.setSearch('pika');
    expect(r.saveCalls, 1);
    expect(r.storedState, CatalogQueryState(query: q, page: 2));
    await n.clearFilters();
    expect(r.storedState, CatalogQueryState.initial());
  });
  test('escrituras consecutivas en orden', () async {
    final r = ControlledRepository();
    final c = containerFor(r);
    await c.read(catalogQueryControllerProvider.future);
    final n = c.read(catalogQueryControllerProvider.notifier);
    final first = n.setSearch('a');
    await r.started.future;
    final second = n.setSearch('b');
    expect(
      c.read(catalogQueryControllerProvider).requireValue.query.search,
      'b',
    );
    expect(r.saveCalls, 0);
    r.gate.complete();
    await Future.wait([first, second]);
    expect(r.savedStates.map((s) => s.query.search), ['a', 'b']);
  });
  test('error de lectura recupera estado inicial', () async {
    final r = FailingRepository()..failLoad = true;
    final c = containerFor(r);
    expect(
      await c.read(catalogQueryControllerProvider.future),
      CatalogQueryState.initial(),
    );
  });
  test('error de escritura no bloquea siguiente cambio', () async {
    final r = FailingRepository()..failSave = true;
    final c = containerFor(r);
    await c.read(catalogQueryControllerProvider.future);
    final n = c.read(catalogQueryControllerProvider.notifier);
    await n.setSearch('a');
    expect(
      c.read(catalogQueryControllerProvider).requireValue.query.search,
      'a',
    );
    r.failSave = false;
    await n.setSearch('b');
    expect(r.storedState!.query.search, 'b');
  });
}
