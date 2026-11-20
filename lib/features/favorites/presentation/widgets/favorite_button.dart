import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/features/favorites/presentation/providers/favorites_providers.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.pokemonId});

  final int pokemonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final favoriteState = ref.watch(isFavoriteProvider(pokemonId));

    return favoriteState.when(
      data: (isFavorite) => IconButton(
        tooltip: isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites,
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : null,
        ),
        onPressed: () async {
          try {
            await ref.read(toggleFavoriteProvider)(pokemonId);
          } catch (error) {
            if (!context.mounted) return;

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.favoriteUpdateError)));
          }
        },
      ),
      loading: () =>
          const IconButton(onPressed: null, icon: Icon(Icons.favorite_border)),
      error: (error, stackTrace) => IconButton(
        tooltip: l10n.favoriteLoadError,
        onPressed: null,
        icon: const Icon(Icons.error_outline),
      ),
    );
  }
}
