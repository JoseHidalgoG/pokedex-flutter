import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/evolution_tree.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_artwork.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_detail.dart';
import 'package:pokedex_flutter/features/catalog/presentation/texts/detail_texts.dart';
import 'package:pokedex_flutter/features/catalog/presentation/texts/pokemon_texts.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/detail/detail_tab_parts.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/pokemon_cached_image.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

class DetailEvolutionsTab extends StatelessWidget {
  const DetailEvolutionsTab({
    super.key,
    required this.detailState,
    required this.onRefresh,
  });

  final AsyncValue<PokemonDetail?> detailState;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DetailRefreshableList(
      onRefresh: onRefresh,
      children: detailChildrenOf(
        context,
        detailState,
        (detail) => switch (detail.evolutionTree) {
          final tree? => [
            _EvolutionBranch(node: tree, shownSpeciesId: detail.pokemon.id),
            if (!tree.evolves) ...[
              const SizedBox(height: 12),
              Text(l10n.detailNoEvolutions),
            ],
          ],
          null => [
            MissingDetailData(
              detail: detail,
              storedButEmptyText: l10n.detailNoEvolutions,
            ),
          ],
        },
      ),
    );
  }
}

class _EvolutionBranch extends StatelessWidget {
  const _EvolutionBranch({required this.node, required this.shownSpeciesId});

  final EvolutionNode node;
  final int shownSpeciesId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EvolutionMember(node: node, isShown: node.speciesId == shownSpeciesId),
        for (final evolution in node.evolutions)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    spacing: 6,
                    children: [
                      Icon(
                        Icons.subdirectory_arrow_right,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      if (evolution.trigger case final trigger?)
                        Flexible(
                          child: Text(
                            evolutionTriggerTextOf(trigger, l10n),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                    ],
                  ),
                ),
                _EvolutionBranch(
                  node: evolution,
                  shownSpeciesId: shownSpeciesId,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _EvolutionMember extends StatelessWidget {
  const _EvolutionMember({required this.node, required this.isShown});

  final EvolutionNode node;
  final bool isShown;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      spacing: 12,
      children: [
        PokemonCachedImage(
          imageUrl: officialArtworkUrlFor(node.speciesId),
          size: 56,
          errorIconSize: 32,
        ),
        Flexible(
          child: Text(
            displayNameOf(node.speciesName),
            style: isShown
                ? textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
