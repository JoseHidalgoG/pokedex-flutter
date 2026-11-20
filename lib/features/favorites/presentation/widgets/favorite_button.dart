import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/features/favorites/presentation/providers/favorites_providers.dart';

class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.pokemonId});

  final int pokemonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteState = ref.watch(isFavoriteProvider(pokemonId));

    return favoriteState.when(
      data: (isFavorite) => IconButton(
        tooltip: isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : null,
        ),
        onPressed: () async {
          try {
            await ref.read(toggleFavoriteProvider)(pokemonId);
          } catch (error) {
            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se pudo actualizar el favorito'),
              ),
            );
          }
        },
      ),
      loading: () =>
          const IconButton(onPressed: null, icon: Icon(Icons.favorite_border)),
      error: (error, stackTrace) => const IconButton(
        tooltip: 'Error al cargar favorito',
        onPressed: null,
        icon: Icon(Icons.error_outline),
      ),
    );
  }
}
