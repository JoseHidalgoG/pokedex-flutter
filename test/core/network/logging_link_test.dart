import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:pokedex_flutter/core/network/call_budget_link.dart';
import 'package:pokedex_flutter/core/network/logging_link.dart';
import 'package:pokedex_flutter/core/sync/domain/call_budget.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_detail_query.dart';

final anonymousQuery = gql('{ pokemon(limit: 1) { id } }');

void main() {
  late List<String> logged;
  late List<Request> forwarded;
  late LoggingLink link;

  setUp(() {
    logged = [];
    forwarded = [];
    link = LoggingLink(write: logged.add);
  });

  Request detailRequest({CallPriority? priority}) {
    return Request(
      operation: Operation(document: pokemonDetailQuery),
      variables: const {'id': 25},
      context: priority == null ? const Context() : withCallPriority(priority),
    );
  }

  NextLink answering(Stream<Response> Function() responses) {
    return (request) {
      forwarded.add(request);
      return responses();
    };
  }

  test('registra la operación, sus variables, la prioridad y la duración y entrega la respuesta', () async {
    const response = Response(data: {'pokemon': <Object?>[]}, response: {});

    final received = await link
        .request(
          detailRequest(priority: CallPriority.user),
          answering(() => Stream.value(response)),
        )
        .single;

    expect(received, same(response));
    expect(forwarded.single.variables, {'id': 25});
    expect(
      logged.single,
      matches(RegExp(r'^PokemonDetail \{"id":25\} \(user\) \d+ ms$')),
    );
  });

  test('cuenta los errores de GraphQL de la respuesta', () async {
    const response = Response(
      errors: [GraphQLError(message: 'campo inexistente')],
      response: {},
    );

    await link
        .request(detailRequest(), answering(() => Stream.value(response)))
        .drain<void>();

    expect(logged.single, endsWith('ms con 1 errores'));
  });

  test(
    'sin prioridad marcada la registra como de fondo, igual que el presupuesto',
    () async {
      await link
          .request(
            detailRequest(),
            answering(() => Stream.value(const Response(response: {}))),
          )
          .drain<void>();

      expect(
        logged.single,
        startsWith(
          'PokemonDetail {"id":25} '
          '(${CallBudgetLink.unmarkedRequestPriority.name})',
        ),
      );
    },
  );

  test('registra el fallo y lo deja pasar sin cambiarlo', () async {
    final exhausted = CallBudgetExhausted(DateTime(2026, 11, 24, 11));

    final responses = link.request(
      detailRequest(priority: CallPriority.user),
      answering(() => Stream.error(exhausted)),
    );

    await expectLater(responses, emitsError(same(exhausted)));
    expect(
      logged.single,
      matches(RegExp(r'^PokemonDetail \{"id":25\} \(user\) falló en \d+ ms: ')),
    );
    expect(logged.single, contains('$exhausted'));
  });

  test('una consulta sin nombre se registra como tal', () async {
    await link
        .request(
          Request(operation: Operation(document: anonymousQuery)),
          answering(() => Stream.value(const Response(response: {}))),
        )
        .drain<void>();

    expect(logged.single, startsWith('$unnamedOperation {}'));
  });
}
