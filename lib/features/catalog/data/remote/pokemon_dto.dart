class PokemonDto {
  const PokemonDto({
    required this.id,
    required this.name,
    required this.typeNames,
    this.speciesId,
    this.generationId,
    this.isDefault = true,
    this.heightDm,
    this.weightHg,
    this.baseStats = const {},
    this.officialArtworkUrl,
  });

  factory PokemonDto.fromJson(Map<String, Object?> json) {
    if (json case {
      'id': final int id,
      'name': final String name,
      'height': final int? heightDm,
      'weight': final int? weightHg,
      'is_default': final bool isDefault,
      'pokemonspecy': final Object? species,
      'pokemontypes': final List<Object?> pokemonTypes,
      'pokemonstats': final List<Object?> pokemonStats,
      'pokemonsprites': final List<Object?> pokemonSprites,
    }) {
      final (:speciesId, :generationId) = _speciesOf(species);
      return PokemonDto(
        id: id,
        name: name,
        typeNames: _typeNamesInSlotOrder(pokemonTypes),
        speciesId: speciesId,
        generationId: generationId,
        isDefault: isDefault,
        heightDm: heightDm,
        weightHg: weightHg,
        baseStats: _baseStatsByName(pokemonStats),
        officialArtworkUrl: _officialArtworkUrlIn(pokemonSprites),
      );
    }
    throw FormatException('Pokémon con formato inesperado', json);
  }

  final int id;
  final String name;
  final List<String> typeNames;
  final int? speciesId;
  final int? generationId;
  final bool isDefault;
  final int? heightDm;
  final int? weightHg;
  final Map<String, int> baseStats;
  final String? officialArtworkUrl;

  static List<String> _typeNamesInSlotOrder(List<Object?> pokemonTypes) {
    final slots = [for (final pokemonType in pokemonTypes) _slotOf(pokemonType)]
      ..sort((first, second) => first.slot.compareTo(second.slot));
    return [for (final slot in slots) slot.typeName];
  }

  static ({int slot, String typeName}) _slotOf(Object? pokemonType) {
    if (pokemonType case {
      'slot': final int slot,
      'type': {'name': final String typeName},
    }) {
      return (slot: slot, typeName: typeName);
    }
    throw FormatException(
      'Tipo de Pokémon con formato inesperado',
      pokemonType,
    );
  }

  static ({int? speciesId, int? generationId}) _speciesOf(Object? species) {
    return switch (species) {
      null => (speciesId: null, generationId: null),
      {'id': final int speciesId, 'generation_id': final int? generationId} => (
        speciesId: speciesId,
        generationId: generationId,
      ),
      _ => throw FormatException('Especie con formato inesperado', species),
    };
  }

  static Map<String, int> _baseStatsByName(List<Object?> pokemonStats) {
    return {
      for (final (:statName, :baseStat) in pokemonStats.map(_statOf))
        statName: baseStat,
    };
  }

  static ({String statName, int baseStat}) _statOf(Object? pokemonStat) {
    if (pokemonStat case {
      'base_stat': final int baseStat,
      'stat': {'name': final String statName},
    }) {
      return (statName: statName, baseStat: baseStat);
    }
    throw FormatException('Estadística con formato inesperado', pokemonStat);
  }

  static String? _officialArtworkUrlIn(List<Object?> pokemonSprites) {
    for (final pokemonSprite in pokemonSprites) {
      if (pokemonSprite case {'sprites': final String url}
          when url.isNotEmpty) {
        return url;
      }
    }
    return null;
  }
}
