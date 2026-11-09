import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql/client.dart';
import 'package:pokedex_flutter/core/network/pokeapi_graphql_client.dart';

final pokeApiGraphQLClientProvider = Provider<GraphQLClient>(
  (ref) => createPokeApiGraphQLClient(),
);
