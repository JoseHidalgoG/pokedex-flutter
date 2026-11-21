import 'dart:convert';
import 'dart:io';

Map<String, Object?> savedPokemonDetailResponse(String pokemonName) {
  final fixture = File('test/fixtures/pokemon_detail_$pokemonName.json');
  return jsonDecode(fixture.readAsStringSync()) as Map<String, Object?>;
}

Map<String, Object?> savedPokemonDetailJson(String pokemonName) {
  final response = savedPokemonDetailResponse(pokemonName);
  if (response case {
    'data': {'pokemon': [final Map<String, Object?> pokemonJson]},
  }) {
    return pokemonJson;
  }
  throw StateError('pokemon_detail_$pokemonName.json no trae un Pokémon');
}

Map<String, Object?> savedTypeEfficacyResponse() {
  final fixture = File('test/fixtures/type_efficacy.json');
  return jsonDecode(fixture.readAsStringSync()) as Map<String, Object?>;
}

List<Object?> savedTypeEfficacyRows() {
  if (savedTypeEfficacyResponse() case {
    'data': {'typeefficacy': final List<Object?> rows},
  }) {
    return rows;
  }
  throw StateError('type_efficacy.json no trae la tabla de tipos');
}
