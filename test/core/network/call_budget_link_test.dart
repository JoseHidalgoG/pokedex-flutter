import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:pokedex_flutter/core/network/call_budget_link.dart';
import 'package:pokedex_flutter/core/network/pokeapi_graphql_client.dart';
import 'package:pokedex_flutter/core/sync/data/sync_failure_translator.dart';
import 'package:pokedex_flutter/core/sync/domain/call_budget.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';

final probeQuery = gql('query Probe { pokemon(limit: 1) { id } }');

class CountingPokeApiLink extends Link {
  var requests = 0;

  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    requests++;
    return Stream.value(
      const Response(
        data: {
          'pokemon': [
            {'id': 1},
          ],
        },
        response: {},
      ),
    );
  }
}

void main() {
  final now = DateTime(2026, 11, 20, 10);
  late CallBudget budget;
  late CountingPokeApiLink pokeApi;
  late GraphQLClient client;

  setUp(() {
    budget = CallBudget(now: () => now);
    pokeApi = CountingPokeApiLink();
    client = createPokeApiGraphQLClient(link: pokeApi, callBudget: budget);
  });

  Future<QueryResult> probe({CallPriority? priority}) {
    return client.query(
      QueryOptions(
        document: probeQuery,
        errorPolicy: ErrorPolicy.all,
        context: priority == null ? null : withCallPriority(priority),
      ),
    );
  }

  void spendBackgroundCalls(int count) {
    for (var call = 0; call < count; call++) {
      budget.tryReserve(CallPriority.background);
    }
  }

  SyncFailure failureOf(QueryResult result) {
    return syncFailureFrom(
      result.exception!,
      dataReceived: result.data != null,
    );
  }

  test('cuenta cada llamada que deja pasar hacia PokeAPI', () async {
    final result = await probe(priority: CallPriority.user);

    expect(result.hasException, isFalse);
    expect(pokeApi.requests, 1);
    expect(budget.used, 1);
  });

  test(
    'corta una llamada de segundo plano en 60 sin llegar a la red',
    () async {
      spendBackgroundCalls(60);

      final result = await probe(priority: CallPriority.background);

      expect(pokeApi.requests, 0);
      expect(
        failureOf(result),
        CallBudgetExhausted(now.add(CallBudget.window)),
      );
    },
  );

  test(
    'el usuario sigue pasando cuando el segundo plano ya no puede',
    () async {
      spendBackgroundCalls(60);

      final result = await probe(priority: CallPriority.user);

      expect(result.hasException, isFalse);
      expect(pokeApi.requests, 1);
    },
  );

  test('una llamada sin prioridad cuenta como segundo plano', () async {
    spendBackgroundCalls(60);

    final result = await probe();

    expect(pokeApi.requests, 0);
    expect(failureOf(result), isA<CallBudgetExhausted>());
  });

  test('un bloqueo por 429 detiene también al usuario', () async {
    final blockEnds = now.add(const Duration(minutes: 10));
    budget.blockUntil(blockEnds);

    final result = await probe(priority: CallPriority.user);

    expect(pokeApi.requests, 0);
    expect(failureOf(result), CallBudgetExhausted(blockEnds));
  });
}
