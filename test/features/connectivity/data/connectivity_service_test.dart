import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pokedex_flutter/features/connectivity/data/connectivity_service.dart';
import 'package:pokedex_flutter/features/connectivity/domain/connectivity_status.dart';

class MockConnectivity extends Mock implements Connectivity {}

class MockGraphQLClient extends Mock implements GraphQLClient {}

class FakeQueryOptions extends Fake implements QueryOptions {}

void main() {
  late MockConnectivity mockConnectivity;
  late MockGraphQLClient mockGraphQLClient;
  late ConnectivityService service;

  setUpAll(() {
    registerFallbackValue(FakeQueryOptions());
  });

  setUp(() {
    mockConnectivity = MockConnectivity();
    mockGraphQLClient = MockGraphQLClient();

    service = ConnectivityService(
      connectivity: mockConnectivity,
      graphQLClient: mockGraphQLClient,
    );
  });

  test('returns offline when there is no network connection', () async {
    when(() => mockConnectivity.checkConnectivity()).thenAnswer(
          (_) async => [ConnectivityResult.none],
    );

    final result = await service.checkStatus();

    expect(result, ConnectivityStatus.offline);

    verify(() => mockConnectivity.checkConnectivity()).called(1);
    verifyNever(() => mockGraphQLClient.query(any()));
  });

  test('returns online when PokeAPI responds successfully', () async {
    when(() => mockConnectivity.checkConnectivity()).thenAnswer(
          (_) async => [ConnectivityResult.wifi],
    );

    when(() => mockGraphQLClient.query(any())).thenAnswer(
          (_) async => QueryResult(
        options: QueryOptions(
          document: gql('''
        query {
          pokemon {
            id
          }
        }
      '''),
        ),
        source: QueryResultSource.network,
        data: {
          'pokemon': [
            {'id': 1},
          ],
        },
        context: const Context(),
      ),
    );

    final result = await service.checkStatus();

    expect(result, ConnectivityStatus.online);

    verify(() => mockGraphQLClient.query(any())).called(1);
  });

  test('returns serviceUnavailable when the GraphQL request fails', () async {
    when(() => mockConnectivity.checkConnectivity()).thenAnswer(
          (_) async => [ConnectivityResult.wifi],
    );

    when(() => mockGraphQLClient.query(any())).thenThrow(
      Exception('PokeAPI is unavailable'),
    );

    final result = await service.checkStatus();

    expect(result, ConnectivityStatus.serviceUnavailable);

    verify(() => mockGraphQLClient.query(any())).called(1);
  });
}