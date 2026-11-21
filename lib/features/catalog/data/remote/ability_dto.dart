import 'package:pokedex_flutter/features/catalog/data/remote/pokeapi_names.dart';

class AbilityDto {
  const AbilityDto({
    required this.id,
    required this.identifier,
    required this.slot,
    required this.isHidden,
    this.namesByLanguage = const {},
    this.shortEffectEn,
    this.flavorTextEs,
  });

  factory AbilityDto.fromJson(Object? json) {
    if (json case {
      'slot': final int slot,
      'is_hidden': final bool isHidden,
      'ability': {
        'id': final int id,
        'name': final String identifier,
        'abilitynames': final List<Object?> names,
        'abilityeffecttexts': final List<Object?> effectTexts,
        'abilityflavortexts': final List<Object?> flavorTexts,
      },
    }) {
      return AbilityDto(
        id: id,
        identifier: identifier,
        slot: slot,
        isHidden: isHidden,
        namesByLanguage: namesByLanguageIn(names),
        shortEffectEn: _shortEffectIn(effectTexts),
        flavorTextEs: _flavorTextIn(flavorTexts),
      );
    }
    throw FormatException('Habilidad con formato inesperado', json);
  }

  final int id;
  final String identifier;
  final int slot;
  final bool isHidden;
  final Map<String, String> namesByLanguage;
  final String? shortEffectEn;
  final String? flavorTextEs;

  static String? _shortEffectIn(List<Object?> effectTexts) {
    return switch (effectTexts.firstOrNull) {
      null => null,
      {'short_effect': final String? shortEffect} => shortEffect,
      final effectText => throw FormatException(
        'Efecto de habilidad con formato inesperado',
        effectText,
      ),
    };
  }

  static String? _flavorTextIn(List<Object?> flavorTexts) {
    return switch (flavorTexts.firstOrNull) {
      null => null,
      {'flavor_text': final String? flavorText} => flavorText,
      final flavorText => throw FormatException(
        'Descripción de habilidad con formato inesperado',
        flavorText,
      ),
    };
  }
}
