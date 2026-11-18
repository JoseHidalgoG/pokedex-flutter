import 'package:graphql/client.dart';
import 'package:pokedex_flutter/core/sync/data/sync_failure_translator.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_batch.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_page_query.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto.dart';

const catalogPageRequestTimeout = Duration(seconds: 30);

class CatalogRemoteDataSource {
  CatalogRemoteDataSource(
    this._client, {
    this._requestTimeout = catalogPageRequestTimeout,
  });

  final GraphQLClient _client;
  final Duration _requestTimeout;

  Future<CatalogBatch> fetchCatalogPage({
    required int limit,
    required int offset,
    bool withTotal = false,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: catalogPageQuery,
        variables: {'limit': limit, 'offset': offset, 'withTotal': withTotal},
        queryRequestTimeout: _requestTimeout,
        errorPolicy: ErrorPolicy.all,
      ),
    );
    final exception = result.exception;
    if (exception != null) {
      throw syncFailureFrom(exception, dataReceived: result.data != null);
    }
    try {
      return CatalogBatch(
        pokemon: _pokemonIn(result.data),
        totalCount: withTotal ? _totalCountIn(result.data) : null,
      );
    } on FormatException catch (formatError) {
      throw syncFailureFrom(formatError);
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

  int _totalCountIn(Map<String, Object?>? data) {
    if (data case {
      'pokemon_aggregate': {'aggregate': {'count': final int count}},
    }) {
      return count;
    }
    throw FormatException('Página del catálogo sin el total de Pokémon', data);
  }
}
