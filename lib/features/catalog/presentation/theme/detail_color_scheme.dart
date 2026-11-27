import 'package:flutter/material.dart';
import 'package:pokedex_flutter/features/catalog/presentation/theme/pokemon_type_palette.dart';

const detailSchemeVariant = DynamicSchemeVariant.fidelity;

final _schemesByTypeAndBrightness = <(String, Brightness), ColorScheme>{};

ColorScheme? detailColorSchemeOf(String? primaryType, Brightness brightness) {
  final typeName = primaryType?.trim().toLowerCase();
  final seedColor = pokemonTypePalette[typeName];
  if (typeName == null || seedColor == null) {
    return null;
  }
  return _schemesByTypeAndBrightness.putIfAbsent(
    (typeName, brightness),
    () => ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      dynamicSchemeVariant: detailSchemeVariant,
    ),
  );
}

ThemeData detailThemeOf(ThemeData appTheme, List<String> typeNames) {
  final scheme = detailColorSchemeOf(
    typeNames.firstOrNull,
    appTheme.colorScheme.brightness,
  );
  if (scheme == null) {
    return appTheme;
  }
  return appTheme.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    canvasColor: scheme.surface,
  );
}
