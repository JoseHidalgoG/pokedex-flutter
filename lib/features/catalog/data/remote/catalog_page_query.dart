import 'package:graphql/client.dart';

final catalogPageQuery = gql(r'''
  query CatalogPage($limit: Int!, $offset: Int!) {
    pokemon(
      limit: $limit
      offset: $offset
      order_by: { id: asc }
      where: { is_default: { _eq: true } }
    ) {
      id
      name
      pokemontypes(order_by: { slot: asc }) {
        slot
        type {
          name
        }
      }
    }
  }
''');
