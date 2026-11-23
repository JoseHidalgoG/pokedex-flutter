import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_detail.dart';
import 'package:pokedex_flutter/features/catalog/presentation/texts/pokemon_texts.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/detail/detail_tab_parts.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

class DetailStatsTab extends StatelessWidget {
  const DetailStatsTab({
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
        (detail) => switch (detail.baseStatTotal) {
          final total? => [
            for (final baseStat in detail.baseStats)
              _StatBar(baseStat: baseStat),
            const Divider(height: 24),
            _StatTotal(label: l10n.detailStatTotal, total: total),
          ],
          null => [MissingDetailData(detail: detail)],
        },
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  const _StatBar({required this.baseStat});

  final BaseStat baseStat;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final percent = NumberFormat.percentPattern(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(baseStat.fractionOfMaximum);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(
              localizedStatName(baseStat.stat, l10n),
              style: textTheme.bodyMedium,
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '${baseStat.value}',
              textAlign: TextAlign.end,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                height: 10,
                color: colorScheme.surfaceContainerHighest,
                alignment: AlignmentDirectional.centerStart,
                child: FractionallySizedBox(
                  widthFactor: baseStat.fractionOfMaximum.clamp(0, 1),
                  heightFactor: 1,
                  child: ColoredBox(color: colorScheme.primary),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 52,
            child: Text(
              percent,
              textAlign: TextAlign.end,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTotal extends StatelessWidget {
  const _StatTotal({required this.label, required this.total});

  final String label;
  final int total;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        SizedBox(width: 84, child: Text(label, style: textTheme.titleSmall)),
        SizedBox(
          width: 36,
          child: Text(
            '$total',
            textAlign: TextAlign.end,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
