import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query_state.dart';

abstract interface class CatalogQueryRepository {
  Future<CatalogQueryState> load();

  Future<void> save(CatalogQueryState state);

  Future<void> clear();
}
