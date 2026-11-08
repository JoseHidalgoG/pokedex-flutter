import 'package:graphql/client.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_page_query.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_page_request_failed.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto.dart';

class CatalogRemoteDataSource {
  CatalogRemoteDataSource(this._client);

  final GraphQLClient _client;

  Future<List<PokemonDto>> fetchCatalogPage({
    required int limit,
    required int offset,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: catalogPageQuery,
        variables: {'limit': limit, 'offset': offset},
      ),
    );
    final exception = result.exception;
    if (exception != null) {
      throw CatalogPageRequestFailed(exception);
    }
    try {
      return _pokemonIn(result.data);
    } on FormatException catch (formatError) {
      throw CatalogPageRequestFailed(formatError);
    }
  }

  List<PokemonDto> _pokemonIn(Map<String, Object?>? data) {
    if (data case {'pokemon': final List<Object?> pokemonList}) {
      return [
        for (final pokemon in pokemonList)
          if (pokemon case final Map<String, Object?> pokemonJson)
            PokemonDto.fromJson(pokemonJson)
          else
            throw FormatException('Pokémon con formato inesperado', pokemon),
      ];
    }
    throw FormatException('Página del catálogo sin lista de Pokémon', data);
  }
}
