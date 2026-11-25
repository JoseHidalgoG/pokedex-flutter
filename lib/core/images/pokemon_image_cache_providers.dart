import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/core/images/pokemon_image_cache.dart';

final pokemonImageCacheProvider = Provider<PokemonImageCache>(
  (ref) => PokemonImageCache(),
);

final pokemonImageCacheManagerProvider = Provider<BaseCacheManager>(
  (ref) => ref.watch(pokemonImageCacheProvider).manager,
);

final clearDecodedImagesProvider = Provider<void Function()>(
  (ref) => () {
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
  },
);
