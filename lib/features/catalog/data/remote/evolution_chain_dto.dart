import 'package:pokedex_flutter/features/catalog/data/remote/pokeapi_names.dart';

class EvolutionChainDto {
  const EvolutionChainDto({required this.id, this.species = const []});

  factory EvolutionChainDto.fromJson(Object? json) {
    if (json case {
      'id': final int id,
      'pokemonspecies': final List<Object?> species,
    }) {
      return EvolutionChainDto(
        id: id,
        species: [
          for (final member in species) ChainSpeciesDto.fromJson(member),
        ],
      );
    }
    throw FormatException('Cadena evolutiva con formato inesperado', json);
  }

  final int id;
  final List<ChainSpeciesDto> species;
}

class ChainSpeciesDto {
  const ChainSpeciesDto({
    required this.id,
    required this.name,
    this.generationId,
    this.evolvesFromSpeciesId,
    this.evolutions = const [],
  });

  factory ChainSpeciesDto.fromJson(Object? json) {
    if (json case {
      'id': final int id,
      'name': final String name,
      'generation_id': final int? generationId,
      'evolves_from_species_id': final int? evolvesFromSpeciesId,
      'pokemonevolutions': final List<Object?> evolutions,
    }) {
      return ChainSpeciesDto(
        id: id,
        name: name,
        generationId: generationId,
        evolvesFromSpeciesId: evolvesFromSpeciesId,
        evolutions: [
          for (final evolution in evolutions) EvolutionDto.fromJson(evolution),
        ],
      );
    }
    throw FormatException(
      'Especie de la cadena evolutiva con formato inesperado',
      json,
    );
  }

  final int id;
  final String name;
  final int? generationId;
  final int? evolvesFromSpeciesId;
  final List<EvolutionDto> evolutions;
}

class EvolutionDto {
  const EvolutionDto({
    required this.id,
    required this.evolvedSpeciesId,
    this.triggerName,
    this.minLevel,
    this.minHappiness,
    this.timeOfDay,
    this.itemName,
    this.heldItemName,
    this.locationName,
    this.knownMoveTypeName,
  });

  factory EvolutionDto.fromJson(Object? json) {
    if (json case {
      'id': final int id,
      'evolved_species_id': final int evolvedSpeciesId,
      'min_level': final int? minLevel,
      'min_happiness': final int? minHappiness,
      'time_of_day': final String? timeOfDay,
      'evolutiontrigger': final Object? trigger,
      'item': final Object? item,
      'ItemByHeldItemId': final Object? heldItem,
      'location': final Object? location,
      'type': final Object? knownMoveType,
    }) {
      return EvolutionDto(
        id: id,
        evolvedSpeciesId: evolvedSpeciesId,
        triggerName: optionalNameIn(trigger),
        minLevel: minLevel,
        minHappiness: minHappiness,
        timeOfDay: timeOfDay,
        itemName: optionalNameIn(item),
        heldItemName: optionalNameIn(heldItem),
        locationName: optionalNameIn(location),
        knownMoveTypeName: optionalNameIn(knownMoveType),
      );
    }
    throw FormatException('Evolución con formato inesperado', json);
  }

  final int id;
  final int evolvedSpeciesId;
  final String? triggerName;
  final int? minLevel;
  final int? minHappiness;
  final String? timeOfDay;
  final String? itemName;
  final String? heldItemName;
  final String? locationName;
  final String? knownMoveTypeName;
}
