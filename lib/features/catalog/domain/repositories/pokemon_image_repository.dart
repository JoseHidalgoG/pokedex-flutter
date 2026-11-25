import 'package:pokedex_flutter/features/catalog/domain/entities/artwork_save_progress.dart';

abstract interface class PokemonImageRepository {
  Future<Set<int>> pokemonIdsWithSavedArtwork();

  Future<void> saveArtworkOf(int pokemonId);

  Stream<ArtworkSaveProgress> saveAllArtwork();

  Future<int> savedImagesBytes();

  Future<void> deleteSavedImages();
}
