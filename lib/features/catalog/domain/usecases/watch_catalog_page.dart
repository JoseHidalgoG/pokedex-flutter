import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_repository.dart';

class WatchCatalogPage {
  const WatchCatalogPage(this._repository);

  final CatalogRepository _repository;

  Stream<List<Pokemon>> call({required int page, required int pageSize}) {
    return _repository.watchCatalogPage(page: page, pageSize: pageSize);
  }
}
