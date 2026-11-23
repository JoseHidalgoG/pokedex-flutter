import 'package:flutter/material.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/detail_freshness.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/presentation/texts/pokemon_texts.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/detail/detail_artwork.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/detail/detail_freshness_line.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/pokemon_type_chip.dart';

class DetailHeader extends StatelessWidget {
  const DetailHeader({
    super.key,
    required this.pokemon,
    required this.freshness,
    required this.showsShiny,
    required this.onShinyUnavailable,
  });

  final Pokemon pokemon;
  final DetailFreshness? freshness;
  final bool showsShiny;
  final VoidCallback onShinyUnavailable;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          DetailArtwork(
            pokemon: pokemon,
            showsShiny: showsShiny,
            onShinyUnavailable: onShinyUnavailable,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  pokedexNumberOf(pokemon.id),
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  displayNameOf(pokemon.name),
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final typeName in pokemon.typeNames)
                      PokemonTypeChip(typeName: typeName),
                  ],
                ),
                if (freshness case final freshness?) ...[
                  const SizedBox(height: 8),
                  DetailFreshnessLine(freshness: freshness),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
