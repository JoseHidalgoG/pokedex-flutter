import 'package:flutter/material.dart';
import 'package:pokedex_flutter/core/theme/color_contrast.dart';
import 'package:pokedex_flutter/features/catalog/presentation/texts/pokemon_texts.dart';
import 'package:pokedex_flutter/features/catalog/presentation/theme/pokemon_type_palette.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

class PokemonTypeChip extends StatelessWidget {
  const PokemonTypeChip({super.key, required this.typeName});

  final String typeName;

  @override
  Widget build(BuildContext context) {
    final normalizedName = typeName.trim().toLowerCase();
    final color = pokemonTypeColorOf(normalizedName);
    final l10n = AppLocalizations.of(context)!;
    final displayName = localizedTypeName(normalizedName, l10n);
    final labelStyle = Theme.of(context).textTheme.labelMedium;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayName,
        style: labelStyle?.copyWith(
          color: readableTextColorOn(color),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
