import 'package:pokedex_flutter/features/catalog/data/remote/evolution_chain_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto.dart';

class SpeciesDto {
  const SpeciesDto({
    required this.id,
    required this.name,
    this.generationId,
    this.eggGroupNames = const [],
    this.forms = const [],
    this.evolutionChain,
  });

  factory SpeciesDto.fromJson(Object? json) {
    if (json case {
      'id': final int id,
      'name': final String name,
      'generation_id': final int? generationId,
      'pokemonegggroups': final List<Object?> eggGroups,
      'pokemons': final List<Object?> forms,
      'evolutionchain': final Object? evolutionChain,
    }) {
      return SpeciesDto(
        id: id,
        name: name,
        generationId: generationId,
        eggGroupNames: [
          for (final eggGroup in eggGroups) _eggGroupNameOf(eggGroup),
        ],
        forms: [for (final form in forms) _formOf(form)],
        evolutionChain: evolutionChain == null
            ? null
            : EvolutionChainDto.fromJson(evolutionChain),
      );
    }
    throw FormatException('Especie con formato inesperado', json);
  }

  final int id;
  final String name;
  final int? generationId;
  final List<String> eggGroupNames;
  final List<PokemonDto> forms;
  final EvolutionChainDto? evolutionChain;

  static String _eggGroupNameOf(Object? eggGroup) {
    if (eggGroup case {'egggroup': {'name': final String name}}) {
      return name;
    }
    throw FormatException('Grupo huevo con formato inesperado', eggGroup);
  }

  static PokemonDto _formOf(Object? form) {
    if (form case final Map<String, Object?> formJson) {
      return PokemonDto.fromJson(formJson);
    }
    throw FormatException('Forma con formato inesperado', form);
  }
}
