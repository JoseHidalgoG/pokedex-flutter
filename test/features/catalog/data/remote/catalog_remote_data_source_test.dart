import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:pokedex_flutter/core/network/pokeapi_graphql_client.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_batch.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_remote_data_source.dart';

import '../../../../fixtures/catalog_batch_fixture.dart';

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

Stream<Response> replyWithSavedPage() {
  final savedResponse = savedCatalogBatchResponse();
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

  List<int> idsOf(CatalogBatch batch) => [
    for (final dto in batch.pokemon) dto.id,
  ];

  test(
    'convierte la respuesta guardada en Pokémon ordenados por número',
    () async {
      final dataSource = dataSourceOver(
        ScriptedPokeApiLink(replyWithSavedPage),
      );

      final batch = await dataSource.fetchCatalogPage(limit: 4, offset: 0);

      expect(idsOf(batch), [1, 2, 3, 4]);
      expect(batch.pokemon.first.name, 'bulbasaur');
      expect(batch.pokemon.first.typeNames, ['grass', 'poison']);
      expect(batch.pokemon.first.baseStats, hasLength(6));
      expect(batch.pokemon.last.name, 'charmander');
      expect(batch.pokemon.last.typeNames, ['fire']);
    },
  );

  test('envía el limit, el offset y si pide el total', () async {
    final link = ScriptedPokeApiLink(replyWithSavedPage);

    await dataSourceOver(link).fetchCatalogPage(limit: 100, offset: 200);

    expect(link.receivedRequests.single.variables, {
      'limit': 100,
      'offset': 200,
      'withTotal': false,
    });
  });

  test('devuelve el total de Pokémon cuando lo pide', () async {
    final link = ScriptedPokeApiLink(replyWithSavedPage);

    final batch = await dataSourceOver(link)
        .fetchCatalogPage(limit: 4, offset: 0, withTotal: true);

    expect(link.receivedRequests.single.variables['withTotal'], isTrue);
    expect(batch.totalCount, 1025);
  });

  test('no devuelve total cuando no lo pide', () async {
    final batch = await dataSourceOver(ScriptedPokeApiLink(replyWithSavedPage))
        .fetchCatalogPage(limit: 4, offset: 0);

    expect(batch.totalCount, isNull);
  });

  test('lanza InvalidResponse si pidió el total y no llegó', () async {
    final dataSource = dataSourceOver(
      ScriptedPokeApiLink(
        () => Stream.value(
          const Response(data: {'pokemon': <Object?>[]}, response: {}),
        ),
      ),
    );

    expect(
      dataSource.fetchCatalogPage(limit: 100, offset: 0, withTotal: true),
      throwsA(const InvalidResponse()),
    );
  });

  test('lanza ServerError cuando PokeAPI responde 503', () async {
    final dataSource = dataSourceOver(
      ScriptedPokeApiLink(
        () => Stream.error(
          const ServerException(statusCode: 503, parsedResponse: null),
        ),
      ),
    );

    expect(
      dataSource.fetchCatalogPage(limit: 50, offset: 0),
      throwsA(const ServerError(503)),
    );
  });

  test(
    'lanza QueryError cuando la respuesta solo trae errores de GraphQL',
    () async {
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
        throwsA(const QueryError("field 'pokemon' not found")),
      );
    },
  );

  test(
    'lanza PartialResponse y no devuelve nada cuando llegan datos con errores',
    () async {
      final savedPage = savedCatalogBatchResponse();
      final dataSource = dataSourceOver(
        ScriptedPokeApiLink(
          () => Stream.value(
            Response(
              data: savedPage['data'] as Map<String, Object?>?,
              errors: const [GraphQLError(message: 'tipo no resuelto')],
              response: savedPage,
            ),
          ),
        ),
      );

      expect(
        dataSource.fetchCatalogPage(limit: 4, offset: 0),
        throwsA(const PartialResponse()),
      );
    },
  );

  test('lanza InvalidResponse cuando la respuesta no trae la lista', () async {
    final dataSource = dataSourceOver(
      ScriptedPokeApiLink(
        () =>
            Stream.value(const Response(data: {'pokemon': null}, response: {})),
      ),
    );

    expect(
      dataSource.fetchCatalogPage(limit: 50, offset: 0),
      throwsA(const InvalidResponse()),
    );
  });

  test('acepta una página que tarda más de 5 segundos en llegar', () {
    fakeAsync((async) {
      final dataSource = dataSourceOver(
        ScriptedPokeApiLink(
          () => replyWithSavedPageAfter(const Duration(seconds: 6)),
        ),
      );

      CatalogBatch? batch;
      dataSource
          .fetchCatalogPage(limit: 4, offset: 0)
          .then((receivedBatch) => batch = receivedBatch);

      async.elapse(const Duration(seconds: 6));

      expect(idsOf(batch!), [1, 2, 3, 4]);
    });
  });

  test('lanza RequestTimeout cuando PokeAPI no responde a tiempo', () {
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

      expect(failure, const RequestTimeout());
    });
  });
}
