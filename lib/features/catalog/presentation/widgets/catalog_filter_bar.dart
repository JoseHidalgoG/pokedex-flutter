import 'package:flutter/material.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/catalog_multi_select_dialog.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

class CatalogFilterBar extends StatelessWidget {
  const CatalogFilterBar({
    super.key,
    required this.searchController,
    required this.selectedTypes,
    required this.selectedGenerations,
    required this.selectedSort,
    required this.onSearchChanged,
    required this.onTypesChanged,
    required this.onGenerationsChanged,
    required this.onSortChanged,
  });

  final TextEditingController searchController;
  final Set<String> selectedTypes;
  final Set<int> selectedGenerations;
  final CatalogSort selectedSort;

  final ValueChanged<String> onSearchChanged;
  final ValueChanged<Set<String>> onTypesChanged;
  final ValueChanged<Set<int>> onGenerationsChanged;
  final ValueChanged<CatalogSort> onSortChanged;

  static const types = [
    'normal',
    'fire',
    'water',
    'electric',
    'grass',
    'ice',
    'fighting',
    'poison',
    'ground',
    'flying',
    'psychic',
    'bug',
    'rock',
    'ghost',
    'dragon',
    'dark',
    'steel',
    'fairy',
  ];

  static const generations = [1, 2, 3, 4, 5, 6, 7, 8, 9];

  static const _romanNumerals = [
    'I',
    'II',
    'III',
    'IV',
    'V',
    'VI',
    'VII',
    'VIII',
    'IX',
  ];

  String _typeLabel(AppLocalizations l10n, String type) {
    return switch (type) {
      'normal' => l10n.pokemonTypeNormal,
      'fire' => l10n.pokemonTypeFire,
      'water' => l10n.pokemonTypeWater,
      'electric' => l10n.pokemonTypeElectric,
      'grass' => l10n.pokemonTypeGrass,
      'ice' => l10n.pokemonTypeIce,
      'fighting' => l10n.pokemonTypeFighting,
      'poison' => l10n.pokemonTypePoison,
      'ground' => l10n.pokemonTypeGround,
      'flying' => l10n.pokemonTypeFlying,
      'psychic' => l10n.pokemonTypePsychic,
      'bug' => l10n.pokemonTypeBug,
      'rock' => l10n.pokemonTypeRock,
      'ghost' => l10n.pokemonTypeGhost,
      'dragon' => l10n.pokemonTypeDragon,
      'dark' => l10n.pokemonTypeDark,
      'steel' => l10n.pokemonTypeSteel,
      'fairy' => l10n.pokemonTypeFairy,
      _ => type,
    };
  }

  String _generationLabel(AppLocalizations l10n, int generation) {
    return l10n.catalogGenerationLabel(_romanNumerals[generation - 1]);
  }

  String _sortLabel(AppLocalizations l10n, CatalogSort sort) {
    return switch (sort) {
      CatalogSort.numberAscending => l10n.catalogSortNumberAsc,
      CatalogSort.numberDescending => l10n.catalogSortNumberDesc,
      CatalogSort.nameAscending => l10n.catalogSortNameAsc,
      CatalogSort.nameDescending => l10n.catalogSortNameDesc,
      CatalogSort.baseStatTotalAscending => l10n.catalogSortStatsAsc,
      CatalogSort.baseStatTotalDescending => l10n.catalogSortStatsDesc,
    };
  }

  Future<void> _selectTypes(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final selection = await showDialog<Set<String>>(
      context: context,
      builder: (_) => CatalogMultiSelectDialog<String>(
        title: l10n.catalogSelectTypes,
        options: types,
        selectedValues: selectedTypes,
        labelOf: (type) => _typeLabel(l10n, type),
      ),
    );

    if (!context.mounted || selection == null) return;

    onTypesChanged(selection);
  }

  Future<void> _selectGenerations(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final selection = await showDialog<Set<int>>(
      context: context,
      builder: (_) => CatalogMultiSelectDialog<int>(
        title: l10n.catalogSelectGenerations,
        options: generations,
        selectedValues: selectedGenerations,
        labelOf: (generation) => _generationLabel(l10n, generation),
      ),
    );

    if (!context.mounted || selection == null) return;

    onGenerationsChanged(selection);
  }

  Widget _buildSelector({
    required Key key,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: key,
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: l10n.catalogSearchHint,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSelector(
                  key: const ValueKey('catalog-types-selector'),
                  label: l10n.catalogTypeFilter,
                  value: selectedTypes.isEmpty
                      ? l10n.catalogAllTypes
                      : l10n.catalogSelectedCount(selectedTypes.length),
                  onTap: () => _selectTypes(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSelector(
                  key: const ValueKey('catalog-generations-selector'),
                  label: l10n.catalogGenerationFilter,
                  value: selectedGenerations.isEmpty
                      ? l10n.catalogAllGenerations
                      : l10n.catalogSelectedCount(selectedGenerations.length),
                  onTap: () => _selectGenerations(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<CatalogSort>(
            key: ValueKey(selectedSort),
            initialValue: selectedSort,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.catalogSortBy,
              border: const OutlineInputBorder(),
            ),
            items: [
              for (final sort in CatalogSort.values)
                DropdownMenuItem(
                  value: sort,
                  child: Text(
                    _sortLabel(l10n, sort),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                onSortChanged(value);
              }
            },
          ),
          if (selectedTypes.isNotEmpty || selectedGenerations.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final type in types)
                    if (selectedTypes.contains(type))
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InputChip(
                          label: Text(_typeLabel(l10n, type)),
                          onDeleted: () {
                            onTypesChanged(
                              Set<String>.of(selectedTypes)..remove(type),
                            );
                          },
                        ),
                      ),
                  for (final generation in generations)
                    if (selectedGenerations.contains(generation))
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InputChip(
                          label: Text(_generationLabel(l10n, generation)),
                          onDeleted: () {
                            onGenerationsChanged(
                              Set<int>.of(selectedGenerations)
                                ..remove(generation),
                            );
                          },
                        ),
                      ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
