import 'package:pokedex_flutter/features/catalog/domain/repositories/pokemon_image_repository.dart';

class GetSavedImagesSize {
  const GetSavedImagesSize(this._repository);

  final PokemonImageRepository _repository;

  Future<int> call() => _repository.savedImagesBytes();
}
