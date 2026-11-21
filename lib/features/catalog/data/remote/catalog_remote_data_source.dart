import 'package:graphql/client.dart';
import 'package:pokedex_flutter/core/network/call_budget_link.dart';
import 'package:pokedex_flutter/core/sync/data/sync_failure_translator.dart';
import 'package:pokedex_flutter/core/sync/domain/call_budget.dart';
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
  }) {
    return _send(
      QueryOptions(
        document: catalogPageQuery,
        variables: {'limit': limit, 'offset': offset, 'withTotal': withTotal},
        queryRequestTimeout: _requestTimeout,
        errorPolicy: ErrorPolicy.all,
        context: withCallPriority(CallPriority.background),
      ),
      parse: (data) => CatalogBatch(
        pokemon: _pokemonIn(data),
        totalCount: withTotal ? _totalCountIn(data) : null,
      ),
    );
  }

  Future<List<PokemonDto>> fetchPokemonByIds(
    List<int> ids, {
    CallPriority priority = CallPriority.user,
  }) {
    return _send(
      QueryOptions(
        document: pokemonByIdsQuery,
        variables: {'ids': ids},
        queryRequestTimeout: _requestTimeout,
        errorPolicy: ErrorPolicy.all,
        context: withCallPriority(priority),
      ),
      parse: _pokemonIn,
    );
  }

  Future<T> _send<T>(
    QueryOptions options, {
    required T Function(Map<String, Object?>? data) parse,
  }) async {
    final result = await _client.query(options);
    final exception = result.exception;
    if (exception != null) {
      throw syncFailureFrom(exception, dataReceived: result.data != null);
    }
    try {
      return parse(result.data);
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
    throw FormatException('Respuesta sin lista de Pokémon', data);
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
