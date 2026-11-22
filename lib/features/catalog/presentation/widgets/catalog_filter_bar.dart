import 'package:flutter/material.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

class CatalogFilterBar extends StatelessWidget {
  const CatalogFilterBar({
    super.key,
    required this.searchController,
    required this.selectedType,
    required this.selectedSort,
    required this.onSearchChanged,
    required this.onTypeChanged,
    required this.onSortChanged,
  });

  final TextEditingController searchController;
  final String? selectedType;
  final CatalogSort selectedSort;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onTypeChanged;
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
                child: DropdownButtonFormField<String>(
                  key: ValueKey(selectedType),
                  initialValue: selectedType ?? '',
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.catalogTypeFilter,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: '',
                      child: Text(
                        l10n.catalogAllTypes,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    for (final type in types)
                      DropdownMenuItem(
                        value: type,
                        child: Text(
                          _typeLabel(l10n, type),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    onTypeChanged(
                      value == null || value.isEmpty ? null : value,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<CatalogSort>(
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}
