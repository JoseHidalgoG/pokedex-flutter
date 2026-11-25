import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/core/images/pokemon_image_cache_providers.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/image_decoding.dart';

class PokemonCachedImage extends ConsumerWidget {
  const PokemonCachedImage({
    super.key,
    required this.imageUrl,
    required this.size,
    this.errorIconSize = 48,
  });

  final String imageUrl;
  final double size;
  final double errorIconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (imageUrl.isEmpty) {
      return _buildFallback();
    }

    return SizedBox(
      width: size,
      height: size,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        cacheManager: ref.watch(pokemonImageCacheManagerProvider),
        memCacheWidth: decodedPixelsFor(context, size),
        fit: BoxFit.contain,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorWidget: (context, url, error) => _buildFallback(),
      ),
    );
  }

  Widget _buildFallback() {
    return Icon(Icons.catching_pokemon, size: errorIconSize);
  }
}
