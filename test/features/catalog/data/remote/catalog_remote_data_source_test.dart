import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:pokedex_flutter/core/network/pokeapi_graphql_client.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_page_request_failed.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_remote_data_source.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto.dart';

class ScriptedPokeApiLink extends Link {
  ScriptedPokeApiLink(this._reply);

  final Stream<Response> Function() _reply;
  final receivedRequests = <Request>[];

  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    receivedRequests.add(request);
    return _reply();
  }
}

Map<String, Object?> savedCatalogPageResponse() {
  final fixture = File('test/fixtures/catalog_page_response.json');
  return jsonDecode(fixture.readAsStringSync()) as Map<String, Object?>;
}

Stream<Response> replyWithSavedPage() {
  final savedResponse = savedCatalogPageResponse();
  return Stream.value(
    Response(
      data: savedResponse['data'] as Map<String, Object?>?,
      response: savedResponse,
    ),
  );
}

Stream<Response> replyWithSavedPageAfter(Duration delay) {
  return Stream.fromFuture(
    Future.delayed(delay, () => replyWithSavedPage().single),
  );
}

Stream<Response> neverReply() {
  return Stream.fromFuture(Completer<Response>().future);
}

void main() {
  CatalogRemoteDataSource dataSourceOver(ScriptedPokeApiLink link) {
    return CatalogRemoteDataSource(createPokeApiGraphQLClient(link: link));
  }

  List<int> idsOf(List<PokemonDto> pokemon) => [
    for (final dto in pokemon) dto.id,
  ];

  test(
    'convierte la respuesta guardada en Pokémon ordenados por número',
    () async {
      final dataSource = dataSourceOver(
        ScriptedPokeApiLink(replyWithSavedPage),
      );

      final page = await dataSource.fetchCatalogPage(limit: 4, offset: 0);

      expect(idsOf(page), [1, 2, 3, 4]);
      expect(page.first.name, 'bulbasaur');
      expect(page.first.typeNames, ['grass', 'poison']);
      expect(page.last.name, 'charmander');
      expect(page.last.typeNames, ['fire']);
    },
  );

  test('envía el limit y el offset pedidos', () async {
    final link = ScriptedPokeApiLink(replyWithSavedPage);

    await dataSourceOver(link).fetchCatalogPage(limit: 50, offset: 100);

    expect(link.receivedRequests.single.variables, {
      'limit': 50,
      'offset': 100,
    });
  });

  test('lanza CatalogPageRequestFailed cuando falla la red', () async {
    final dataSource = dataSourceOver(
      ScriptedPokeApiLink(
        () => Stream.error(
          const ServerException(statusCode: 503, parsedResponse: null),
        ),
      ),
    );

    expect(
      dataSource.fetchCatalogPage(limit: 50, offset: 0),
      throwsA(isA<CatalogPageRequestFailed>()),
    );
  });

  test('lanza CatalogPageRequestFailed cuando la respuesta trae errores de GraphQL', () async {
    final dataSource = dataSourceOver(
      ScriptedPokeApiLink(
        () => Stream.value(
          const Response(
            errors: [GraphQLError(message: "field 'pokemon' not found")],
            response: {},
          ),
        ),
      ),
    );

    expect(
      dataSource.fetchCatalogPage(limit: 50, offset: 0),
      throwsA(isA<CatalogPageRequestFailed>()),
    );
  });

  test(
    'lanza CatalogPageRequestFailed cuando la respuesta no trae la lista',
    () async {
      final dataSource = dataSourceOver(
        ScriptedPokeApiLink(
          () => Stream.value(
            const Response(data: {'pokemon': null}, response: {}),
          ),
        ),
      );

      expect(
        dataSource.fetchCatalogPage(limit: 50, offset: 0),
        throwsA(isA<CatalogPageRequestFailed>()),
      );
    },
  );

  test('acepta una página que tarda más de 5 segundos en llegar', () {
    fakeAsync((async) {
      final dataSource = dataSourceOver(
        ScriptedPokeApiLink(
          () => replyWithSavedPageAfter(const Duration(seconds: 6)),
        ),
      );

      List<PokemonDto>? page;
      dataSource
          .fetchCatalogPage(limit: 4, offset: 0)
          .then((receivedPage) => page = receivedPage);

      async.elapse(const Duration(seconds: 6));

      expect(idsOf(page!), [1, 2, 3, 4]);
    });
  });

  test(
    'lanza CatalogPageRequestFailed cuando PokeAPI no responde a tiempo',
    () {
      fakeAsync((async) {
        final tooLate = catalogPageRequestTimeout + const Duration(seconds: 1);
        final dataSource = dataSourceOver(ScriptedPokeApiLink(neverReply));

        Object? failure;
        dataSource
            .fetchCatalogPage(limit: 50, offset: 0)
            .then(
              (_) {},
              onError: (Object error) {
                failure = error;
              },
            );

        async.elapse(tooLate);

        expect(failure, isA<CatalogPageRequestFailed>());
      });
    },
  );
}
