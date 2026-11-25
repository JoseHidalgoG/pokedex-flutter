import 'dart:async';

import 'package:pokedex_flutter/features/catalog/domain/entities/artwork_save_progress.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/pokemon_image_repository.dart';

class FakePokemonImageRepository implements PokemonImageRepository {
  FakePokemonImageRepository({
    this.savedBytes = 0,
    Set<int> savedIds = const {},
  }) : savedIds = {...savedIds};

  int savedBytes;
  final Set<int> savedIds;
  var artworkDownloadsFail = false;
  var deletionFails = false;

  final artworkRequests = <int>[];
  var sizeReads = 0;
  var saveAllRuns = 0;
  var deletions = 0;
  StreamController<ArtworkSaveProgress>? _saveAll;

  void reportProgress(ArtworkSaveProgress progress) {
    _saveAll!.add(progress);
  }

  void failSaving() {
    _saveAll!.addError(Exception('la base de datos no responde'));
  }

  void finishSaving() {
    unawaited(_saveAll!.close());
  }

  @override
  Future<Set<int>> pokemonIdsWithSavedArtwork() async => {...savedIds};

  @override
  Future<bool> saveArtworkOf(int pokemonId) async {
    artworkRequests.add(pokemonId);
    if (artworkDownloadsFail) {
      return false;
    }
    savedIds.add(pokemonId);
    return true;
  }

  @override
  Stream<ArtworkSaveProgress> saveAllArtwork() {
    saveAllRuns++;
    final saveAll = StreamController<ArtworkSaveProgress>();
    _saveAll = saveAll;
    return saveAll.stream;
  }

  @override
  Future<int> savedImagesBytes() async {
    sizeReads++;
    return savedBytes;
  }

  @override
  Future<void> deleteSavedImages() async {
    deletions++;
    if (deletionFails) {
      throw Exception('no se pudo borrar la carpeta');
    }
    savedBytes = 0;
    savedIds.clear();
  }
}
