import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:pokedex_flutter/core/images/image_file_cache.dart';

const pokemonImageCacheKey = 'pokemonImages';
const pokemonImageCacheCapacity = 2500;
const pokemonImageMaxIdle = Duration(days: 180);

class PokemonImageCache implements ImageFileCache {
  PokemonImageCache({Config? config})
    : this._(
        config ??
            Config(
              pokemonImageCacheKey,
              maxNrOfCacheObjects: pokemonImageCacheCapacity,
              stalePeriod: pokemonImageMaxIdle,
            ),
      );

  PokemonImageCache._(this._config) : manager = CacheManager(_config);

  final Config _config;
  final CacheManager manager;

  late final Future<void> _index = _config.repo.open();

  @override
  Future<bool> isSaved(String url) async {
    return await manager.getFileFromCache(url) != null;
  }

  @override
  Future<Set<String>> savedUrlsAmong(Set<String> urls) async {
    final savedFiles = await _savedFilesWhere((url) => urls.contains(url));
    return {for (final savedFile in savedFiles) savedFile.url};
  }

  @override
  Future<void> save(String url) async {
    await manager.downloadFile(url);
  }

  @override
  Future<int> savedBytes() async {
    final savedFiles = await _savedFilesWhere((_) => true);
    return savedFiles.fold<int>(
      0,
      (total, savedFile) => total + savedFile.bytes,
    );
  }

  @override
  Future<void> deleteAll() => manager.emptyCache();

  Future<List<({String url, int bytes})>> _savedFilesWhere(
    bool Function(String url) isWanted,
  ) async {
    await _index;
    final indexedFiles = await _config.repo.getAllObjects();
    final savedFiles = <({String url, int bytes})>[];
    for (final indexedFile in indexedFiles) {
      if (!isWanted(indexedFile.key)) {
        continue;
      }
      final file = await _config.fileSystem.createFile(
        indexedFile.relativePath,
      );
      if (await file.exists()) {
        savedFiles.add((
          url: indexedFile.key,
          bytes: indexedFile.length ?? await file.length(),
        ));
      }
    }
    return savedFiles;
  }
}
