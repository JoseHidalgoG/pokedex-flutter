import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fake_async/fake_async.dart';
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
    when(() => mockConnectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.none]);

    final result = await service.checkStatus();

    expect(result, ConnectivityStatus.offline);

    verify(() => mockConnectivity.checkConnectivity()).called(1);
    verifyNever(() => mockGraphQLClient.query(any()));
  });

  test('returns online when PokeAPI responds successfully', () async {
    when(() => mockConnectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.wifi]);

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
    when(() => mockConnectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.wifi]);

    when(() => mockGraphQLClient.query(any()))
        .thenThrow(Exception('PokeAPI is unavailable'));

    final result = await service.checkStatus();

    expect(result, ConnectivityStatus.serviceUnavailable);

    verify(() => mockGraphQLClient.query(any())).called(1);
  });

  group('al observar el estado', () {
    const recheckInterval = Duration(seconds: 15);

    late ConnectivityService watchingService;

    QueryResult healthyPokeApiResult() {
      return QueryResult(
        options: QueryOptions(document: gql('query { pokemon { id } }')),
        source: QueryResultSource.network,
        data: {
          'pokemon': [
            {'id': 1},
          ],
        },
        context: const Context(),
      );
    }

    void givenNetwork(ConnectivityResult network) {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => [network]);
    }

    setUp(() {
      when(
        () => mockConnectivity.onConnectivityChanged,
      ).thenAnswer((_) => const Stream.empty());

      watchingService = ConnectivityService(
        connectivity: mockConnectivity,
        graphQLClient: mockGraphQLClient,
        unavailableServiceRecheckInterval: recheckInterval,
      );
    });

    test('vuelve a consultar la API mientras el servicio no está disponible', () {
      fakeAsync((async) {
        givenNetwork(ConnectivityResult.wifi);
        var pokeApiIsBack = false;
        when(() => mockGraphQLClient.query(any())).thenAnswer((_) async {
          if (!pokeApiIsBack) {
            throw Exception('PokeAPI no responde');
          }
          return healthyPokeApiResult();
        });

        final statuses = <ConnectivityStatus>[];
        final subscription = watchingService.watchStatus().listen(
          statuses.add,
        );
        async.flushMicrotasks();

        expect(statuses, [ConnectivityStatus.serviceUnavailable]);

        pokeApiIsBack = true;
        async.elapse(recheckInterval);

        expect(statuses, [
          ConnectivityStatus.serviceUnavailable,
          ConnectivityStatus.online,
        ]);

        subscription.cancel();
      });
    });

    test('no vuelve a consultar la API mientras está en línea', () {
      fakeAsync((async) {
        givenNetwork(ConnectivityResult.wifi);
        when(
          () => mockGraphQLClient.query(any()),
        ).thenAnswer((_) async => healthyPokeApiResult());

        final subscription = watchingService.watchStatus().listen((_) {});
        async.elapse(recheckInterval * 3);

        verify(() => mockGraphQLClient.query(any())).called(1);

        subscription.cancel();
      });
    });

    test('no consulta la API mientras no hay red', () {
      fakeAsync((async) {
        givenNetwork(ConnectivityResult.none);

        final statuses = <ConnectivityStatus>[];
        final subscription = watchingService.watchStatus().listen(
          statuses.add,
        );
        async.elapse(recheckInterval * 3);

        expect(statuses, [ConnectivityStatus.offline]);
        verifyNever(() => mockGraphQLClient.query(any()));

        subscription.cancel();
      });
    });

    test('deja de consultar la API cuando nadie observa el estado', () {
      fakeAsync((async) {
        givenNetwork(ConnectivityResult.wifi);
        when(
          () => mockGraphQLClient.query(any()),
        ).thenThrow(Exception('PokeAPI no responde'));

        final subscription = watchingService.watchStatus().listen((_) {});
        async.flushMicrotasks();
        subscription.cancel();
        async.elapse(recheckInterval * 3);

        verify(() => mockGraphQLClient.query(any())).called(1);
      });
    });
  });
}
