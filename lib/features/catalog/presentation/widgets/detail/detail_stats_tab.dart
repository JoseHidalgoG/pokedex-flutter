import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_detail.dart';
import 'package:pokedex_flutter/features/catalog/presentation/texts/pokemon_texts.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/detail/detail_layout.dart';
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
    final statName = localizedStatName(baseStat.stat, l10n);
    final percent = NumberFormat.percentPattern(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(baseStat.fractionOfMaximum);

    final name = Text(statName, style: textTheme.bodyMedium);
    final value = Text(
      '${baseStat.value}',
      textAlign: TextAlign.end,
      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
    );
    final percentText = Text(
      percent,
      textAlign: TextAlign.end,
      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
    );
    final bar = ClipRRect(
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
    );

    return Semantics(
      container: true,
      label: l10n.detailStatSemantics(
        statName,
        baseStat.value,
        BaseStat.maximum,
        percent,
      ),
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: usesLargeTextLayout(context)
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    spacing: 12,
                    children: [
                      Expanded(child: name),
                      value,
                      percentText,
                    ],
                  ),
                  const SizedBox(height: 6),
                  bar,
                ],
              )
            : Row(
                children: [
                  SizedBox(width: 84, child: name),
                  SizedBox(width: 36, child: value),
                  const SizedBox(width: 12),
                  Expanded(child: bar),
                  SizedBox(width: 52, child: percentText),
                ],
              ),
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
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final labelText = Text(label, style: textTheme.titleSmall);
    final totalText = Text(
      '$total',
      textAlign: TextAlign.end,
      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
    );

    return Semantics(
      container: true,
      label: l10n.detailStatTotalSemantics(total),
      excludeSemantics: true,
      child: usesLargeTextLayout(context)
          ? Row(
              spacing: 12,
              children: [
                Expanded(child: labelText),
                totalText,
              ],
            )
          : Row(
              children: [
                SizedBox(width: 84, child: labelText),
                SizedBox(width: 36, child: totalText),
              ],
            ),
    );
  }
}
