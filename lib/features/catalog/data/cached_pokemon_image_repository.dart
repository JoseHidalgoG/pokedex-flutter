import 'dart:async';

import 'package:pokedex_flutter/core/images/image_file_cache.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_dao.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/artwork_save_progress.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_artwork.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/pokemon_image_repository.dart';

const artworkDownloadsAtOnce = 4;
const artworkFailuresInARowBeforeStopping = 10;

class CachedPokemonImageRepository implements PokemonImageRepository {
  CachedPokemonImageRepository({
    required this._catalogDao,
    required this._images,
  });

  final CatalogDao _catalogDao;
  final ImageFileCache _images;

  @override
  Future<Set<int>> pokemonIdsWithSavedArtwork() async {
    final artworkUrls = await _catalogDao.readArtworkUrls();
    final savedUrls = await _images.savedUrlsAmong(artworkUrls.values.toSet());
    return {
      for (final MapEntry(key: pokemonId, value: url) in artworkUrls.entries)
        if (savedUrls.contains(url)) pokemonId,
    };
  }

  @override
  Future<void> saveArtworkOf(int pokemonId) async {
    final storedUrl = await _catalogDao.readImageUrlOf(pokemonId);
    final url = switch (storedUrl) {
      final url? when url.isNotEmpty => url,
      _ => officialArtworkUrlFor(pokemonId),
    };
    if (await _images.isSaved(url)) {
      return;
    }
    await _images.save(url);
  }

  @override
  Stream<ArtworkSaveProgress> saveAllArtwork() async* {
    final artworkUrls = await _catalogDao.readArtworkUrls();
    final wantedUrls = {
      for (final url in artworkUrls.values)
        if (url.isNotEmpty) url,
    };
    final savedUrls = await _images.savedUrlsAmong(wantedUrls);
    final pendingUrls = wantedUrls.difference(savedUrls).iterator;
    var progress = ArtworkSaveProgress(
      saved: savedUrls.length,
      failed: 0,
      total: wantedUrls.length,
    );
    yield progress;

    final downloads = StreamController<bool>();
    var isStopped = false;

    Future<void> downloadPendingUrls() async {
      while (!isStopped && pendingUrls.moveNext()) {
        final url = pendingUrls.current;
        try {
          await _images.save(url);
          downloads.add(true);
        } catch (_) {
          downloads.add(false);
        }
      }
    }

    unawaited(
      Future.wait([
        for (var worker = 0; worker < artworkDownloadsAtOnce; worker++)
          downloadPendingUrls(),
      ]).whenComplete(downloads.close),
    );

    var failuresInARow = 0;
    try {
      await for (final succeeded in downloads.stream) {
        failuresInARow = succeeded ? 0 : failuresInARow + 1;
        if (failuresInARow >= artworkFailuresInARowBeforeStopping) {
          isStopped = true;
        }
        progress = progress.afterDownload(succeeded: succeeded);
        yield progress;
      }
    } finally {
      isStopped = true;
    }
  }

  @override
  Future<int> savedImagesBytes() => _images.savedBytes();

  @override
  Future<void> deleteSavedImages() => _images.deleteAll();
}
