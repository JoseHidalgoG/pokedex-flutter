import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:pokedex_flutter/core/network/call_budget_link.dart';
import 'package:pokedex_flutter/core/network/pokeapi_graphql_client.dart';
import 'package:pokedex_flutter/core/sync/domain/call_budget.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_batch.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_page_query.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_remote_data_source.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_detail_query.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/type_efficacy_query.dart';

import '../../../../fixtures/catalog_batch_fixture.dart';
import '../../../../fixtures/pokemon_detail_fixture.dart';

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

Stream<Response> Function() replyWith(Map<String, Object?> savedResponse) {
  return () => Stream.value(
    Response(
      data: savedResponse['data'] as Map<String, Object?>?,
      response: savedResponse,
    ),
  );
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

  test('marca sus consultas con la prioridad de segundo plano', () async {
    final link = ScriptedPokeApiLink(replyWithSavedPage);

    await dataSourceOver(link).fetchCatalogPage(limit: 100, offset: 0);
    final request = link.receivedRequests.single;

    expect(
      request.context.entry<CallPriorityEntry>()?.priority,
      CallPriority.background,
    );
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

  group('fetchPokemonByIds', () {
    test(
      'envía los ids y marca la consulta con la prioridad del usuario',
      () async {
        final link = ScriptedPokeApiLink(replyWithSavedPage);

        await dataSourceOver(link).fetchPokemonByIds([25, 1]);
        final request = link.receivedRequests.single;

        expect(request.operation.document, same(pokemonByIdsQuery));
        expect(request.variables, {
          'ids': [25, 1],
        });
        expect(
          request.context.entry<CallPriorityEntry>()?.priority,
          CallPriority.user,
        );
      },
    );

    test('la restauración marca la consulta con su propia prioridad', () async {
      final link = ScriptedPokeApiLink(replyWithSavedPage);

      await dataSourceOver(link)
          .fetchPokemonByIds([25], priority: CallPriority.restoration);

      expect(
        link.receivedRequests.single.context
            .entry<CallPriorityEntry>()
            ?.priority,
        CallPriority.restoration,
      );
    });

    test('convierte la respuesta en los Pokémon recibidos', () async {
      final pokemon = await dataSourceOver(
        ScriptedPokeApiLink(replyWithSavedPage),
      ).fetchPokemonByIds([1, 2, 3, 4]);

      expect([for (final dto in pokemon) dto.id], [1, 2, 3, 4]);
      expect(pokemon.first.name, 'bulbasaur');
      expect(pokemon.first.baseStats, hasLength(6));
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
        dataSource.fetchPokemonByIds([25]),
        throwsA(const ServerError(503)),
      );
    });
  });

  group('fetchPokemonDetail', () {
    test(
      'envía el id y marca la consulta con la prioridad del usuario',
      () async {
        final link = ScriptedPokeApiLink(
          replyWith(savedPokemonDetailResponse('pikachu')),
        );

        await dataSourceOver(link).fetchPokemonDetail(25);
        final request = link.receivedRequests.single;

        expect(request.operation.document, same(pokemonDetailQuery));
        expect(request.variables, {'id': 25});
        expect(
          request.context.entry<CallPriorityEntry>()?.priority,
          CallPriority.user,
        );
      },
    );

    test('convierte la respuesta en el detalle del Pokémon', () async {
      final detail = await dataSourceOver(
        ScriptedPokeApiLink(replyWith(savedPokemonDetailResponse('eevee'))),
      ).fetchPokemonDetail(133);

      expect(detail!.pokemon.id, 133);
      expect(detail.species.name, 'eevee');
      expect(detail.species.evolutionChain!.species, hasLength(9));
      expect(detail.abilities, hasLength(3));
    });

    test('devuelve null cuando PokeAPI no tiene ese Pokémon', () async {
      final detail = await dataSourceOver(
        ScriptedPokeApiLink(
          () => Stream.value(
            const Response(data: {'pokemon': <Object?>[]}, response: {}),
          ),
        ),
      ).fetchPokemonDetail(99999);

      expect(detail, isNull);
    });

    test('lanza InvalidResponse cuando el detalle llega incompleto', () async {
      final dataSource = dataSourceOver(
        ScriptedPokeApiLink(
          () => Stream.value(
            const Response(
              data: {
                'pokemon': [
                  {'id': 25, 'name': 'pikachu'},
                ],
              },
              response: {},
            ),
          ),
        ),
      );

      expect(
        dataSource.fetchPokemonDetail(25),
        throwsA(const InvalidResponse()),
      );
    });

    test('espera la respuesta hasta 15 segundos', () {
      fakeAsync((async) {
        final dataSource = dataSourceOver(ScriptedPokeApiLink(neverReply));

        Object? failure;
        dataSource
            .fetchPokemonDetail(25)
            .then(
              (_) {},
              onError: (Object error) {
                failure = error;
              },
            );

        async.elapse(detailRequestTimeout - const Duration(seconds: 1));
        expect(failure, isNull);

        async.elapse(const Duration(seconds: 2));
        expect(failure, const RequestTimeout());
      });
    });
  });

  group('fetchTypeEfficacy', () {
    test('pide la tabla de tipos con prioridad de segundo plano', () async {
      final link = ScriptedPokeApiLink(replyWith(savedTypeEfficacyResponse()));

      await dataSourceOver(link).fetchTypeEfficacy();
      final request = link.receivedRequests.single;

      expect(request.operation.document, same(typeEfficacyQuery));
      expect(
        request.context.entry<CallPriorityEntry>()?.priority,
        CallPriority.background,
      );
    });

    test(
      'al abrir un detalle sin tabla la pide con prioridad del usuario',
      () async {
        final link = ScriptedPokeApiLink(
          replyWith(savedTypeEfficacyResponse()),
        );

        await dataSourceOver(link)
            .fetchTypeEfficacy(priority: CallPriority.user);

        expect(
          link.receivedRequests.single.context
              .entry<CallPriorityEntry>()
              ?.priority,
          CallPriority.user,
        );
      },
    );

    test('convierte la respuesta en las 324 filas de la tabla', () async {
      final rows = await dataSourceOver(
        ScriptedPokeApiLink(replyWith(savedTypeEfficacyResponse())),
      ).fetchTypeEfficacy();

      expect(rows, hasLength(324));
      expect(rows.first.attackingType, 'normal');
      expect(rows.first.defendingType, 'normal');
    });

    test(
      'lanza InvalidResponse cuando la respuesta no trae la tabla',
      () async {
        final dataSource = dataSourceOver(
          ScriptedPokeApiLink(
            () => Stream.value(
              const Response(data: {'typeefficacy': null}, response: {}),
            ),
          ),
        );

        expect(
          dataSource.fetchTypeEfficacy(),
          throwsA(const InvalidResponse()),
        );
      },
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
