import 'package:flutter/material.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/detail_freshness.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/presentation/texts/pokemon_texts.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/detail/detail_artwork.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/detail/detail_freshness_line.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/detail/detail_layout.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/pokemon_type_chip.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

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
            child: DetailIdentity(pokemon: pokemon, freshness: freshness),
          ),
        ],
      ),
    );
  }
}

class DetailSidePanel extends StatelessWidget {
  const DetailSidePanel({
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
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: DetailArtwork(
              pokemon: pokemon,
              showsShiny: showsShiny,
              onShinyUnavailable: onShinyUnavailable,
              size: detailSidePanelArtworkSize,
            ),
          ),
          const SizedBox(height: 16),
          DetailIdentity(pokemon: pokemon, freshness: freshness),
        ],
      ),
    );
  }
}

class DetailIdentity extends StatelessWidget {
  const DetailIdentity({
    super.key,
    required this.pokemon,
    required this.freshness,
  });

  final Pokemon pokemon;
  final DetailFreshness? freshness;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          pokedexNumberOf(pokemon.id),
          semanticsLabel: l10n.detailNumberLabel(pokemon.id),
          style: textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Semantics(
          container: true,
          header: true,
          namesRoute: true,
          child: Text(
            displayNameOf(pokemon.name),
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
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
    );
  }
}
