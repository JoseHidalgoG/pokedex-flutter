import 'package:flutter/material.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

class PokemonTypeChip extends StatelessWidget {
  const PokemonTypeChip({super.key, required this.typeName});

  final String typeName;

  static const Map<String, Color> _typeColors = {
    'normal': Color(0xFFA8A77A),
    'fire': Color(0xFFEE8130),
    'water': Color(0xFF6390F0),
    'electric': Color(0xFFF7D02C),
    'grass': Color(0xFF7AC74C),
    'ice': Color(0xFF96D9D6),
    'fighting': Color(0xFFC22E28),
    'poison': Color(0xFFA33EA1),
    'ground': Color(0xFFE2BF65),
    'flying': Color(0xFFA98FF3),
    'psychic': Color(0xFFF95587),
    'bug': Color(0xFFA6B91A),
    'rock': Color(0xFFB6A136),
    'ghost': Color(0xFF735797),
    'dragon': Color(0xFF6F35FC),
    'dark': Color(0xFF705746),
    'steel': Color(0xFFB7B7CE),
    'fairy': Color(0xFFD685AD),
  };

  String _localizedTypeName(String normalizedName, AppLocalizations l10n) {
    return switch (normalizedName) {
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
      _ =>
        normalizedName.isEmpty
            ? normalizedName
            : normalizedName[0].toUpperCase() + normalizedName.substring(1),
    };
  }

  @override
  Widget build(BuildContext context) {
    final normalizedName = typeName.trim().toLowerCase();
    final color = _typeColors[normalizedName] ?? Colors.grey;
    final l10n = AppLocalizations.of(context)!;
    final displayName = _localizedTypeName(normalizedName, l10n);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayName,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
