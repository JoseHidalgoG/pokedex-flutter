import 'dart:async';

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
    const firstRecheckDelay = Duration(seconds: 15);

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
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [network]);
    }

    setUp(() {
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => const Stream.empty());

      watchingService = ConnectivityService(
        connectivity: mockConnectivity,
        graphQLClient: mockGraphQLClient,
      );
    });

    List<Duration> recordHealthChecksWhilePokeApiIsDown(FakeAsync async) {
      final healthCheckTimes = <Duration>[];
      when(() => mockGraphQLClient.query(any())).thenAnswer((_) async {
        healthCheckTimes.add(async.elapsed);
        throw Exception('PokeAPI no responde');
      });
      return healthCheckTimes;
    }

    test(
      'vuelve a consultar la API mientras el servicio no está disponible',
      () {
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
          async.elapse(firstRecheckDelay);

          expect(statuses, [
            ConnectivityStatus.serviceUnavailable,
            ConnectivityStatus.online,
          ]);

          subscription.cancel();
        });
      },
    );

    test('espacia las reconsultas 15, 30, 60 y 120 s y luego cada 5 min', () {
      fakeAsync((async) {
        givenNetwork(ConnectivityResult.wifi);
        final healthCheckTimes = recordHealthChecksWhilePokeApiIsDown(async);

        final subscription = watchingService.watchStatus().listen((_) {});
        async.elapse(const Duration(minutes: 20));

        expect(healthCheckTimes, const [
          Duration.zero,
          Duration(seconds: 15),
          Duration(seconds: 45),
          Duration(seconds: 105),
          Duration(seconds: 225),
          Duration(seconds: 525),
          Duration(seconds: 825),
          Duration(seconds: 1125),
        ]);

        subscription.cancel();
      });
    });

    test('una hora sin servicio gasta 16 consultas de salud y no 240', () {
      fakeAsync((async) {
        givenNetwork(ConnectivityResult.wifi);
        final healthCheckTimes = recordHealthChecksWhilePokeApiIsDown(async);

        final subscription = watchingService.watchStatus().listen((_) {});
        async.elapse(const Duration(hours: 1));

        expect(healthCheckTimes, hasLength(16));

        subscription.cancel();
      });
    });

    test('un cambio de red vuelve a empezar la espera en 15 s', () {
      fakeAsync((async) {
        givenNetwork(ConnectivityResult.wifi);
        final networkChanges = StreamController<List<ConnectivityResult>>();
        when(() => mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => networkChanges.stream);
        final healthCheckTimes = recordHealthChecksWhilePokeApiIsDown(async);

        final subscription = watchingService.watchStatus().listen((_) {});
        async.elapse(const Duration(seconds: 110));
        givenNetwork(ConnectivityResult.mobile);
        networkChanges.add([ConnectivityResult.mobile]);
        async.elapse(firstRecheckDelay);

        expect(healthCheckTimes, const [
          Duration.zero,
          Duration(seconds: 15),
          Duration(seconds: 45),
          Duration(seconds: 105),
          Duration(seconds: 110),
          Duration(seconds: 125),
        ]);

        subscription.cancel();
        networkChanges.close();
      });
    });

    test('no vuelve a consultar la API mientras está en línea', () {
      fakeAsync((async) {
        givenNetwork(ConnectivityResult.wifi);
        when(() => mockGraphQLClient.query(any()))
            .thenAnswer((_) async => healthyPokeApiResult());

        final subscription = watchingService.watchStatus().listen((_) {});
        async.elapse(firstRecheckDelay * 3);

        verify(() => mockGraphQLClient.query(any())).called(1);

        subscription.cancel();
      });
    });

    test('no consulta la API mientras no hay red', () {
      fakeAsync((async) {
        givenNetwork(ConnectivityResult.none);

        final statuses = <ConnectivityStatus>[];
        final subscription = watchingService.watchStatus().listen(statuses.add);
        async.elapse(firstRecheckDelay * 3);

        expect(statuses, [ConnectivityStatus.offline]);
        verifyNever(() => mockGraphQLClient.query(any()));

        subscription.cancel();
      });
    });

    test('deja de consultar la API cuando nadie observa el estado', () {
      fakeAsync((async) {
        givenNetwork(ConnectivityResult.wifi);
        when(() => mockGraphQLClient.query(any()))
            .thenThrow(Exception('PokeAPI no responde'));

        final subscription = watchingService.watchStatus().listen((_) {});
        async.flushMicrotasks();
        subscription.cancel();
        async.elapse(firstRecheckDelay * 3);

        verify(() => mockGraphQLClient.query(any())).called(1);
      });
    });
  });
}
