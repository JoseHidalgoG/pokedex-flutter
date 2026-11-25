import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql/client.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex_flutter/core/network/api_outage_simulation.dart';
import 'package:pokedex_flutter/core/network/pokeapi_graphql_client.dart';
import 'package:pokedex_flutter/core/network/simulated_outage_http_client.dart';
import 'package:pokedex_flutter/core/sync/sync_providers.dart';

final pokeApiHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final pokeApiGraphQLClientProvider = Provider<GraphQLClient>(
  (ref) => createPokeApiGraphQLClient(
    link: HttpLink(pokeApiGraphQLEndpoint, httpClient: _pokeApiTransport(ref)),
    callBudget: ref.watch(callBudgetProvider),
  ),
);

http.Client _pokeApiTransport(Ref ref) {
  final network = ref.watch(pokeApiHttpClientProvider);
  final simulationMode = ref.watch(apiOutageSimulationModeProvider);
  if (simulationMode == ApiOutageSimulationMode.unavailable) {
    return network;
  }
  return SimulatedOutageHttpClient(
    isOutageSimulated: () => ref.read(apiOutageSimulationProvider.future),
    network: network,
  );
}
