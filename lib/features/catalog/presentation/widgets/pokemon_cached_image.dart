import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PokemonCachedImage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildFallback();
    }

    return SizedBox(
      width: size,
      height: size,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
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
