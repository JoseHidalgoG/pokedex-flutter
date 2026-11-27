import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/core/images/pokemon_image_cache_providers.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_artwork.dart';
import 'package:pokedex_flutter/features/catalog/presentation/texts/pokemon_texts.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/image_decoding.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/pokemon_artwork_hero_tag.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

const detailArtworkBackdropKey = ValueKey('detail-artwork-backdrop');

class DetailArtwork extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheManager = ref.watch(pokemonImageCacheManagerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final decodedWidth = decodedPixelsFor(context, size);
    final fallbackIcon = Icon(
      Icons.catching_pokemon,
      size: size * 0.6,
      color: colorScheme.onPrimaryContainer,
    );

    Widget networkImage(
      String imageUrl, {
      required Widget fallback,
      VoidCallback? onError,
      FilterQuality filterQuality = FilterQuality.medium,
    }) {
      return CachedNetworkImage(
        key: ValueKey(imageUrl),
        imageUrl: imageUrl,
        cacheManager: cacheManager,
        memCacheWidth: decodedWidth,
        fit: BoxFit.contain,
        filterQuality: filterQuality,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorWidget: (context, url, error) => fallback,
        errorListener: onError == null ? null : (_) => onError(),
      );
    }

    final l10n = AppLocalizations.of(context)!;
    final name = displayNameOf(pokemon.name);

    return Semantics(
      container: true,
      image: true,
      label: showsShiny
          ? l10n.pokemonShinyArtworkLabel(name)
          : l10n.pokemonArtworkLabel(name),
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              DecoratedBox(
                key: detailArtworkBackdropKey,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(dimension: size * 0.86),
              ),
              Hero(
                tag: pokemonArtworkHeroTag(pokemon.id),
                child: SizedBox.square(
                  dimension: size,
                  child: switch ((showsShiny, pokemon.imageUrl.isEmpty)) {
                    (true, _) => networkImage(
                      shinyArtworkUrlFor(pokemon.id),
                      fallback: fallbackIcon,
                      onError: onShinyUnavailable,
                    ),
                    (false, true) => fallbackIcon,
                    (false, false) => networkImage(
                      pokemon.imageUrl,
                      fallback: networkImage(
                        frontSpriteUrlFor(pokemon.id),
                        fallback: fallbackIcon,
                        filterQuality: FilterQuality.none,
                      ),
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
