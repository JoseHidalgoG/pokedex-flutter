import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/type_matchups.dart';
import 'package:pokedex_flutter/features/catalog/presentation/texts/detail_texts.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/detail/detail_tab_parts.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/pokemon_type_chip.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

class DetailMatchupsTab extends StatelessWidget {
  const DetailMatchupsTab({
    super.key,
    required this.typeNames,
    required this.typeEfficacyState,
    required this.onRefresh,
  });

  final List<String> typeNames;
  final AsyncValue<List<TypeEfficacy>> typeEfficacyState;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DetailRefreshableList(
      onRefresh: onRefresh,
      children: switch (typeEfficacyState) {
        AsyncValue(value: final efficacy?) when efficacy.isNotEmpty => [
          for (final MapEntry(key: matchup, value: attackingTypes)
              in defensiveMatchupsFor(typeNames, efficacy).entries)
            DetailSection(
              title: matchupTitleOf(matchup, l10n),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final attackingType in attackingTypes)
                    PokemonTypeChip(typeName: attackingType),
                ],
              ),
            ),
        ],
        AsyncValue(hasError: true) => [
          DetailMessage(icon: Icons.error_outline, text: l10n.detailLoadError),
        ],
        AsyncValue(isLoading: true, hasValue: false) => const [DetailLoading()],
        _ => [
          DetailMessage(
            icon: Icons.grid_off,
            text:
                '${l10n.detailTypeTablePending}\n${l10n.detailSectionPending}',
          ),
        ],
      },
    );
  }
}
