import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_repository.dart';

class WatchFilteredCatalogPage {
  const WatchFilteredCatalogPage(this._repository);

  final CatalogRepository _repository;

  Stream<List<Pokemon>> call({
    required int page,
    required int pageSize,
    required CatalogQuery query,
  }) {
    return _repository.watchFilteredCatalogPage(
      page: page,
      pageSize: pageSize,
      query: query,
    );
  }
}
