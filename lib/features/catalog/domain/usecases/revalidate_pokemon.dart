import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_repository.dart';

class RevalidatePokemon {
  const RevalidatePokemon(this._repository);

  final CatalogRepository _repository;

  Future<void> call(List<int> ids, {bool force = false}) =>
      _repository.revalidatePokemon(ids, force: force);
}
