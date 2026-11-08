import 'package:graphql/client.dart';

const pokeApiGraphQLEndpoint = 'https://graphql.pokeapi.co/v1beta2';

GraphQLClient createPokeApiGraphQLClient({Link? link}) {
  return GraphQLClient(
    link: link ?? HttpLink(pokeApiGraphQLEndpoint),
    cache: GraphQLCache(),
    defaultPolicies: DefaultPolicies(
      query: Policies(fetch: FetchPolicy.noCache),
    ),
  );
}
