import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query_state.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_query_providers.dart';

class CatalogQueryController extends AsyncNotifier<CatalogQueryState> {
  Future<void> _pendingWrite = Future<void>.value();

  @override
  Future<CatalogQueryState> build() async {
    final repository = ref.watch(catalogQueryRepositoryProvider);

    try {
      return await repository.load();
    } catch (error, stackTrace) {
      _reportPersistenceError(
        'No se pudo restaurar la consulta',
        error,
        stackTrace,
      );

      return CatalogQueryState.initial();
    }
  }

  Future<void> setSearch(String search) {
    return _updateQuery((query) => query.copyWith(search: search.trim()));
  }

  Future<void> setTypes(Set<String> types) {
    return _updateQuery((query) => query.copyWith(types: types));
  }

  Future<void> setGenerations(Set<int> generations) {
    return _updateQuery((query) => query.copyWith(generations: generations));
  }

  Future<void> setSort(CatalogSort sort) {
    return _updateQuery((query) => query.copyWith(sort: sort));
  }

  Future<void> setPage(int page) {
    final current = state.asData?.value;

    if (current == null || page < 0) {
      return Future<void>.value();
    }

    return _updateState(current.copyWith(page: page));
  }

  Future<void> clearFilters() {
    return _updateState(CatalogQueryState.initial());
  }

  Future<void> _updateQuery(CatalogQuery Function(CatalogQuery) update) {
    final current = state.asData?.value;

    if (current == null) {
      return Future<void>.value();
    }

    final updatedQuery = update(current.query);

    if (updatedQuery == current.query) {
      return Future<void>.value();
    }

    return _updateState(current.copyWith(query: updatedQuery, page: 0));
  }

  Future<void> _updateState(CatalogQueryState next) {
    final current = state.asData?.value;

    if (current == null || current == next) {
      return Future<void>.value();
    }

    final repository = ref.read(catalogQueryRepositoryProvider);

    state = AsyncData(next);

    _pendingWrite = _pendingWrite.then((_) async {
      try {
        await repository.save(next);
      } catch (error, stackTrace) {
        _reportPersistenceError(
          'No se pudo guardar la consulta',
          error,
          stackTrace,
        );
      }
    });

    return _pendingWrite;
  }

  Future<void> waitForPendingWrites() {
    return _pendingWrite;
  }

  void _reportPersistenceError(
    String message,
    Object error,
    StackTrace stackTrace,
  ) {
    debugPrint('$message: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}
