import 'dart:convert';
import 'dart:io';

Map<String, Object?> savedCatalogBatchResponse() {
  final fixture = File('test/fixtures/catalog_batch.json');
  return jsonDecode(fixture.readAsStringSync()) as Map<String, Object?>;
}

Map<String, Object?> savedPokemonJson({required String name}) {
  final response = savedCatalogBatchResponse();
  if (response case {'data': {'pokemon': final List<Object?> pokemonList}}) {
    return pokemonList.cast<Map<String, Object?>>().firstWhere(
      (pokemon) => pokemon['name'] == name,
    );
  }
  throw StateError('catalog_batch.json no trae la lista de Pokémon');
}
