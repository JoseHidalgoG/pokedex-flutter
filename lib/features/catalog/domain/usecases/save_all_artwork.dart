import 'package:pokedex_flutter/features/catalog/domain/entities/artwork_save_progress.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/pokemon_image_repository.dart';

class SaveAllArtwork {
  const SaveAllArtwork(this._repository);

  final PokemonImageRepository _repository;

  Stream<ArtworkSaveProgress> call() => _repository.saveAllArtwork();
}
