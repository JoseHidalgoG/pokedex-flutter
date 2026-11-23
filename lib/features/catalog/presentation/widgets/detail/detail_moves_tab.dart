import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/move_list.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_detail.dart';
import 'package:pokedex_flutter/features/catalog/presentation/texts/pokemon_texts.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/detail/detail_tab_parts.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/pokemon_type_chip.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

class DetailMovesTab extends StatefulWidget {
  const DetailMovesTab({
    super.key,
    required this.detailState,
    required this.onRefresh,
  });

  final AsyncValue<PokemonDetail?> detailState;
  final RefreshCallback onRefresh;

  @override
  State<DetailMovesTab> createState() => _DetailMovesTabState();
}

class _DetailMovesTabState extends State<DetailMovesTab> {
  MoveLearnMethod? _chosenMethod;
  MoveOrder _levelUpOrder = MoveOrder.level;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final detail = widget.detailState.value;
    final defaultMethod = detail == null
        ? null
        : firstMethodWithMoves(detail.moves);

    if (detail == null || defaultMethod == null) {
      return DetailRefreshableList(
        onRefresh: widget.onRefresh,
        children: detailChildrenOf(
          context,
          widget.detailState,
          (detail) => [
            MissingDetailData(
              detail: detail,
              storedButEmptyText: l10n.detailNoMoves,
            ),
          ],
        ),
      );
    }

    final counts = moveCountsByMethod(detail.moves);
    final method = switch (_chosenMethod) {
      final chosen? when counts[chosen]! > 0 => chosen,
      _ => defaultMethod,
    };
    final isLevelUp = method == MoveLearnMethod.levelUp;
    final moves = movesLearnedBy(
      detail.moves,
      method,
      order: isLevelUp ? _levelUpOrder : MoveOrder.name,
      languageCode: Localizations.localeOf(context).languageCode,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (detail.moveVersionGroup case final versionGroup?)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              l10n.detailMovesOf(prettifiedIdentifier(versionGroup)),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            spacing: 8,
            children: [
              for (final learnMethod in MoveLearnMethod.values)
                ChoiceChip(
                  label: Text(
                    '${localizedLearnMethod(learnMethod, l10n)} '
                    '(${counts[learnMethod]})',
                  ),
                  selected: learnMethod == method,
                  onSelected: counts[learnMethod]! == 0
                      ? null
                      : (_) => setState(() => _chosenMethod = learnMethod),
                ),
            ],
          ),
        ),
        if (isLevelUp)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SegmentedButton<MoveOrder>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: MoveOrder.level,
                  label: Text(l10n.detailSortByLevel),
                ),
                ButtonSegment(
                  value: MoveOrder.name,
                  label: Text(l10n.detailSortByName),
                ),
              ],
              selected: {_levelUpOrder},
              onSelectionChanged: (selection) =>
                  setState(() => _levelUpOrder = selection.single),
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: moves.length,
              itemBuilder: (context, index) =>
                  _MoveTile(move: moves[index], showsLevel: isLevelUp),
            ),
          ),
        ),
      ],
    );
  }
}

class _MoveTile extends StatelessWidget {
  const _MoveTile({required this.move, required this.showsLevel});

  final PokemonMove move;
  final bool showsLevel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;

    return ListTile(
      dense: true,
      leading: showsLevel
          ? SizedBox(
              width: 48,
              child: Text(
                move.level == 0
                    ? l10n.detailMoveOnEvolution
                    : l10n.detailMoveLevel(move.level),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            )
          : null,
      title: Text(move.name.inLanguage(languageCode) ?? ''),
      trailing: switch (move.typeName) {
        final typeName? => PokemonTypeChip(typeName: typeName),
        null => null,
      },
    );
  }
}
