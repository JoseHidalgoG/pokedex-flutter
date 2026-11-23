import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_artwork.dart';

class DetailArtwork extends StatelessWidget {
  const DetailArtwork({
    super.key,
    required this.pokemon,
    required this.showsShiny,
    required this.onShinyUnavailable,
    this.size = 132,
  });

  final Pokemon pokemon;
  final bool showsShiny;
  final VoidCallback onShinyUnavailable;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: switch ((showsShiny, pokemon.imageUrl.isEmpty)) {
        (true, _) => _networkImage(
          shinyArtworkUrlFor(pokemon.id),
          fallback: _fallbackIcon(),
          onError: onShinyUnavailable,
        ),
        (false, true) => _fallbackIcon(),
        (false, false) => _networkImage(
          pokemon.imageUrl,
          fallback: _networkImage(
            frontSpriteUrlFor(pokemon.id),
            fallback: _fallbackIcon(),
            filterQuality: FilterQuality.none,
          ),
        ),
      },
    );
  }

  Widget _networkImage(
    String imageUrl, {
    required Widget fallback,
    VoidCallback? onError,
    FilterQuality filterQuality = FilterQuality.medium,
  }) {
    return CachedNetworkImage(
      key: ValueKey(imageUrl),
      imageUrl: imageUrl,
      fit: BoxFit.contain,
      filterQuality: filterQuality,
      placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorWidget: (context, url, error) => fallback,
      errorListener: onError == null ? null : (_) => onError(),
    );
  }

  Widget _fallbackIcon() {
    return Icon(Icons.catching_pokemon, size: size * 0.6);
  }
}
