import 'package:graphql/client.dart';

const _catalogPokemonFields = r'''
  fragment CatalogPokemonFields on pokemon {
    id
    name
    height
    weight
    is_default
    pokemonspecy {
      id
      generation_id
    }
    pokemontypes(order_by: { slot: asc }) {
      slot
      type {
        name
      }
    }
    pokemonstats {
      base_stat
      stat {
        name
      }
    }
    pokemonsprites {
      sprites(path: "other.official-artwork.front_default")
    }
  }
''';

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

final catalogPageQuery = gql('$_catalogPageOperation$_catalogPokemonFields');

final pokemonByIdsQuery = gql('$_pokemonByIdsOperation$_catalogPokemonFields');
