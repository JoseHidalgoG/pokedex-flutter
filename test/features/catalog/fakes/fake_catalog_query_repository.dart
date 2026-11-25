import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query_state.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_query_repository.dart';

class FakeCatalogQueryRepository implements CatalogQueryRepository {
  FakeCatalogQueryRepository({CatalogQueryState? initialState})
    : storedState = initialState;
  CatalogQueryState? storedState;
  int loadCalls = 0;
  int saveCalls = 0;
  int clearCalls = 0;
  final savedStates = <CatalogQueryState>[];
  @override
  Future<CatalogQueryState> load() async {
    loadCalls++;
    return storedState ?? CatalogQueryState.initial();
  }

  @override
  Future<void> save(CatalogQueryState state) async {
    saveCalls++;
    savedStates.add(state);
    storedState = state;
  }

  @override
  Future<void> clear() async {
    clearCalls++;
    storedState = null;
  }
}
