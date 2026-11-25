import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:pokedex_flutter/core/network/pokeapi_graphql_client.dart';
import 'package:pokedex_flutter/core/network/simulated_outage_http_client.dart';
import 'package:pokedex_flutter/core/sync/data/sync_failure_translator.dart';
import 'package:pokedex_flutter/core/sync/domain/call_budget.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';

import 'fakes/fake_pokeapi_network.dart';

void main() {
  late FakePokeApiNetwork network;
  late CallBudget budget;

  setUp(() {
    network = FakePokeApiNetwork();
    budget = CallBudget();
  });

  GraphQLClient pokeApiClientWith(OutageSimulationCheck isOutageSimulated) {
    return createPokeApiGraphQLClient(
      link: HttpLink(
        pokeApiGraphQLEndpoint,
        httpClient: SimulatedOutageHttpClient(
          isOutageSimulated: isOutageSimulated,
          network: network.client,
        ),
      ),
      callBudget: budget,
    );
  }

  group('con la simulación activa', () {
    test(
      'PokeAPI falla con ServerError(503) y la red no recibe nada',
      () async {
        final result = await probe(pokeApiClientWith(() async => true));

        expect(syncFailureFrom(result.exception!), const ServerError(503));
        expect(network.requests, 0);
      },
    );

    test('la llamada simulada gasta presupuesto como una real', () async {
      await probe(pokeApiClientWith(() async => true));

      expect(budget.used, 1);
    });
  });

  test('con la simulación apagada la consulta llega a PokeAPI', () async {
    final result = await probe(pokeApiClientWith(() async => false));

    expect(result.hasException, isFalse);
    expect(network.requests, 1);
  });

  test('no envía nada hasta saber si la simulación está activa', () async {
    final isOutageSimulated = Completer<bool>();
    var isAnswered = false;
    final answer = probe(pokeApiClientWith(() => isOutageSimulated.future))
        .whenComplete(() => isAnswered = true);

    await pumpEventQueue();
    expect((network.requests, isAnswered), (0, false));

    isOutageSimulated.complete(false);
    await answer;
    expect(network.requests, 1);
  });

  test('cada petición vuelve a mirar el interruptor', () async {
    var isOutageSimulated = true;
    final client = pokeApiClientWith(() async => isOutageSimulated);

    final duringOutage = await probe(client);
    isOutageSimulated = false;
    final afterOutage = await probe(client);

    expect(duringOutage.hasException, isTrue);
    expect(afterOutage.hasException, isFalse);
    expect(network.requests, 1);
  });
}
