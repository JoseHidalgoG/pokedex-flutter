import 'package:graphql/client.dart';
import 'package:pokedex_flutter/core/network/call_budget_link.dart';
import 'package:pokedex_flutter/core/sync/domain/call_budget.dart';

const pokeApiGraphQLEndpoint = 'https://graphql.pokeapi.co/v1beta2';

GraphQLClient createPokeApiGraphQLClient({Link? link, CallBudget? callBudget}) {
  final networkLink = link ?? HttpLink(pokeApiGraphQLEndpoint);
  return GraphQLClient(
    link: callBudget == null
        ? networkLink
        : CallBudgetLink(callBudget).concat(networkLink),
    cache: GraphQLCache(),
    defaultPolicies: DefaultPolicies(
      query: Policies(fetch: FetchPolicy.noCache),
    ),
  );
}
