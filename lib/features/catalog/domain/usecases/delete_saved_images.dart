import 'package:pokedex_flutter/features/catalog/domain/repositories/pokemon_image_repository.dart';

class DeleteSavedImages {
  const DeleteSavedImages(this._repository);

  final PokemonImageRepository _repository;

  Future<void> call() => _repository.deleteSavedImages();
}
