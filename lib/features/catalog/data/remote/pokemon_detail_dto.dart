import 'package:pokedex_flutter/features/catalog/data/remote/ability_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/move_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/species_dto.dart';

class PokemonDetailDto {
  const PokemonDetailDto({
    required this.pokemon,
    required this.species,
    this.abilities = const [],
    this.moves = const [],
    this.gameVersionNames = const [],
  });

  factory PokemonDetailDto.fromJson(Map<String, Object?> json) {
    if (json case {
      'pokemonspecy': final Object? species,
      'pokemonabilities': final List<Object?> abilities,
      'pokemonmoves': final List<Object?> moves,
      'pokemongameindices': final List<Object?> gameIndices,
    }) {
      return PokemonDetailDto(
        pokemon: PokemonDto.fromJson(json),
        species: SpeciesDto.fromJson(species),
        abilities: [
          for (final ability in abilities) AbilityDto.fromJson(ability),
        ],
        moves: [for (final move in moves) MoveDto.fromJson(move)],
        gameVersionNames: [
          for (final gameIndex in gameIndices) _versionNameOf(gameIndex),
        ],
      );
    }
    throw FormatException('Detalle de Pokémon con formato inesperado', json);
  }

  final PokemonDto pokemon;
  final SpeciesDto species;
  final List<AbilityDto> abilities;
  final List<MoveDto> moves;
  final List<String> gameVersionNames;

  static String _versionNameOf(Object? gameIndex) {
    if (gameIndex case {'version': {'name': final String versionName}}) {
      return versionName;
    }
    throw FormatException('Juego con formato inesperado', gameIndex);
  }
}
