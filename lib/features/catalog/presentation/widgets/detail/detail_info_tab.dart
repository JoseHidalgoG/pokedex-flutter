import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/ability_effect.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_detail.dart';
import 'package:pokedex_flutter/features/catalog/presentation/texts/pokemon_texts.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/detail/detail_tab_parts.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

class DetailInfoTab extends StatelessWidget {
  const DetailInfoTab({
    super.key,
    required this.detailState,
    required this.forms,
    required this.selectedFormId,
    required this.onFormSelected,
    required this.onRefresh,
  });

  final AsyncValue<PokemonDetail?> detailState;
  final List<Pokemon> forms;
  final int selectedFormId;
  final ValueChanged<Pokemon> onFormSelected;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DetailRefreshableList(
      onRefresh: onRefresh,
      children: [
        if (forms.length > 1)
          DetailSection(
            title: l10n.detailForms,
            child: _FormSelector(
              forms: forms,
              selectedFormId: selectedFormId,
              onFormSelected: onFormSelected,
            ),
          ),
        ...detailChildrenOf(
          context,
          detailState,
          (detail) => [
            _Measurements(detail: detail),
            DetailSection(
              title: l10n.detailEggGroups,
              child: detail.eggGroups.isEmpty
                  ? MissingDetailData(detail: detail)
                  : _ChipWrap(
                      labels: [
                        for (final eggGroup in detail.eggGroups)
                          localizedEggGroup(eggGroup, l10n),
                      ],
                    ),
            ),
            DetailSection(
              title: l10n.detailAbilities,
              child: detail.abilities.isEmpty
                  ? MissingDetailData(detail: detail)
                  : Column(
                      children: [
                        for (final ability in detail.abilities)
                          _AbilityTile(ability: ability),
                      ],
                    ),
            ),
            DetailSection(
              title: l10n.detailGames,
              child: detail.games.isEmpty
                  ? MissingDetailData(detail: detail)
                  : _ChipWrap(
                      labels: [
                        for (final game in detail.games)
                          prettifiedIdentifier(game),
                      ],
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FormSelector extends StatelessWidget {
  const _FormSelector({
    required this.forms,
    required this.selectedFormId,
    required this.onFormSelected,
  });

  final List<Pokemon> forms;
  final int selectedFormId;
  final ValueChanged<Pokemon> onFormSelected;

  @override
  Widget build(BuildContext context) {
    final baseFormName = forms.first.name;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 8,
        children: [
          for (final form in forms)
            ChoiceChip(
              label: Text(formLabelOf(form.name, baseFormName: baseFormName)),
              selected: form.id == selectedFormId,
              onSelected: (_) => onFormSelected(form),
            ),
        ],
      ),
    );
  }
}

class _Measurements extends StatelessWidget {
  const _Measurements({required this.detail});

  final PokemonDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final numberFormat = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    );

    String measured(double? value, String unit) {
      return value == null ? '—' : '${numberFormat.format(value)} $unit';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: _Measurement(
              label: l10n.detailHeight,
              value: measured(detail.heightInMeters, 'm'),
            ),
          ),
          Expanded(
            child: _Measurement(
              label: l10n.detailWeight,
              value: measured(detail.weightInKilograms, 'kg'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Measurement extends StatelessWidget {
  const _Measurement({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _AbilityTile extends StatelessWidget {
  const _AbilityTile({required this.ability});

  final PokemonAbility ability;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final textTheme = Theme.of(context).textTheme;
    final effect = ability.effect.inLanguage(languageCode);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 8,
            children: [
              Flexible(
                child: Text(
                  ability.name.inLanguage(languageCode) ?? '',
                  style: textTheme.titleSmall,
                ),
              ),
              if (ability.isHidden)
                Chip(
                  label: Text(l10n.detailHiddenAbility),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
          if (effect != null) ...[
            const SizedBox(height: 4),
            Text(trimmedEffect(effect), style: textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _ChipWrap extends StatelessWidget {
  const _ChipWrap({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final label in labels)
          Chip(
            label: Text(label),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
      ],
    );
  }
}
