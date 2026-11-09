class PokemonDto {
  const PokemonDto({
    required this.id,
    required this.name,
    required this.typeNames,
  });

  factory PokemonDto.fromJson(Map<String, Object?> json) {
    if (json case {
      'id': final int id,
      'name': final String name,
      'pokemontypes': final List<Object?> pokemonTypes,
    }) {
      return PokemonDto(
        id: id,
        name: name,
        typeNames: _typeNamesInSlotOrder(pokemonTypes),
      );
    }
    throw FormatException('Pokémon con formato inesperado', json);
  }

  final int id;
  final String name;
  final List<String> typeNames;

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
}
