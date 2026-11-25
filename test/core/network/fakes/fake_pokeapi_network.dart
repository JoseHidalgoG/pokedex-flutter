import 'dart:convert';

import 'package:graphql/client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final probeQuery = gql('query Probe { pokemon(limit: 1) { id } }');

class FakePokeApiNetwork {
  var requests = 0;

  late final http.Client client = MockClient((_) async {
    requests++;
    return http.Response(
      jsonEncode({
        'data': {
          'pokemon': [
            {'id': 1},
          ],
        },
      }),
      200,
      headers: {'content-type': 'application/json'},
    );
  });
}

Future<QueryResult> probe(GraphQLClient client) {
  return client.query(
    QueryOptions(document: probeQuery, errorPolicy: ErrorPolicy.all),
  );
}
