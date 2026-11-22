import 'package:graphql/client.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_pokemon_fields.dart';

const _catalogPageOperation = r'''
  query CatalogPage($limit: Int!, $offset: Int!, $withTotal: Boolean!) {
    pokemon(
      limit: $limit
      offset: $offset
      order_by: { id: asc }
      where: { is_default: { _eq: true } }
    ) {
      ...CatalogPokemonFields
    }
    pokemon_aggregate(where: { is_default: { _eq: true } })
      @include(if: $withTotal) {
      aggregate {
        count
      }
    }
  }
''';

const _pokemonByIdsOperation = r'''
  query PokemonByIds($ids: [Int!]!) {
    pokemon(where: { id: { _in: $ids } }, order_by: { id: asc }) {
      ...CatalogPokemonFields
    }
  }
''';

final catalogPageQuery = gql(
  '$_catalogPageOperation$catalogPokemonFieldsFragment',
);

final pokemonByIdsQuery = gql(
  '$_pokemonByIdsOperation$catalogPokemonFieldsFragment',
);
