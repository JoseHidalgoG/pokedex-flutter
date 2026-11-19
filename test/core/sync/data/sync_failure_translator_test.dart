import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokedex_flutter/core/network/pokeapi_graphql_client.dart';
import 'package:pokedex_flutter/core/sync/data/sync_failure_translator.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';

final probeQuery = gql('query Probe { pokemon(limit: 1) { id } }');

const pokeApiTimeout = Duration(seconds: 30);

Future<SyncFailure> failureWhenPokeApi(MockClientHandler respond) async {
  final client = createPokeApiGraphQLClient(
    link: HttpLink(pokeApiGraphQLEndpoint, httpClient: MockClient(respond)),
  );
  final result = await client.query(
    QueryOptions(
      document: probeQuery,
      errorPolicy: ErrorPolicy.all,
      queryRequestTimeout: pokeApiTimeout,
    ),
  );
  return syncFailureFrom(result.exception!, dataReceived: result.data != null);
}

MockClientHandler replyJson(
  int statusCode,
  Map<String, Object?> body, {
  Map<String, String> headers = const {},
}) {
  return (_) async => http.Response(
    jsonEncode(body),
    statusCode,
    headers: {'content-type': 'application/json', ...headers},
  );
}

MockClientHandler replyText(
  int statusCode,
  String body, {
  Map<String, String> headers = const {},
}) {
  return (_) async => http.Response(body, statusCode, headers: headers);
}

void main() {
  group('sin respuesta HTTP', () {
    test('un SocketException es NoConnection', () async {
      final failure = await failureWhenPokeApi(
        (_) => throw const SocketException('Failed host lookup'),
      );

      expect(failure, const NoConnection());
    });

    test('un ClientException es NoConnection', () async {
      final failure = await failureWhenPokeApi(
        (_) => throw http.ClientException('Connection closed'),
      );

      expect(failure, const NoConnection());
    });

    test('superar el tiempo de la consulta es RequestTimeout', () {
      fakeAsync((async) {
        SyncFailure? failure;
        failureWhenPokeApi((_) => Completer<http.Response>().future)
            .then((translated) => failure = translated);

        async.elapse(pokeApiTimeout + const Duration(seconds: 1));

        expect(failure, const RequestTimeout());
      });
    });
  });

  group('HTTP 429', () {
    test('con cuerpo JSON es RateLimited con su Retry-After', () async {
      final failure = await failureWhenPokeApi(
        replyJson(
          429,
          {
            'errors': [
              {'message': 'rate limit exceeded'},
            ],
          },
          headers: {'retry-after': '120'},
        ),
      );

      expect(failure, const RateLimited(retryAfter: Duration(seconds: 120)));
    });

    test('con cuerpo de texto también es RateLimited', () async {
      final failure = await failureWhenPokeApi(
        replyText(429, 'Too Many Requests', headers: {'retry-after': '60'}),
      );

      expect(failure, const RateLimited(retryAfter: Duration(seconds: 60)));
    });

    test('sin Retry-After en segundos deja la espera sin indicar', () async {
      final failure = await failureWhenPokeApi(
        replyText(
          429,
          'Too Many Requests',
          headers: {'retry-after': 'Wed, 19 Nov 2026 10:00:00 GMT'},
        ),
      );

      expect(failure, const RateLimited());
    });
  });

  group('HTTP 5xx', () {
    test('una página HTML de 503 es ServerError(503)', () async {
      final failure = await failureWhenPokeApi(
        replyText(503, '<html><body>Service Unavailable</body></html>'),
      );

      expect(failure, const ServerError(503));
    });

    test('un 500 con cuerpo JSON es ServerError(500)', () async {
      final failure = await failureWhenPokeApi(
        replyJson(500, {
          'errors': [
            {'message': 'internal error'},
          ],
        }),
      );

      expect(failure, const ServerError(500));
    });
  });

  group('respuestas de GraphQL', () {
    test('data con errors es PartialResponse', () async {
      final failure = await failureWhenPokeApi(
        replyJson(200, {
          'data': {
            'pokemon': [
              {'id': 1},
            ],
          },
          'errors': [
            {'message': 'one field could not be resolved'},
          ],
        }),
      );

      expect(failure, const PartialResponse());
    });

    test('errors sin data es QueryError con el mensaje', () async {
      final failure = await failureWhenPokeApi(
        replyJson(200, {
          'errors': [
            {'message': "field 'pokemon' not found"},
          ],
        }),
      );

      expect(failure, const QueryError("field 'pokemon' not found"));
    });

    test('un 400 es QueryError', () async {
      final failure = await failureWhenPokeApi(replyText(400, 'Bad Request'));

      expect(failure, const QueryError('HTTP 400'));
    });
  });

  group('respuestas ilegibles', () {
    test('un 200 que no es JSON es InvalidResponse', () async {
      final failure = await failureWhenPokeApi(replyText(200, '<html>'));

      expect(failure, const InvalidResponse());
    });

    test('un 200 sin data ni errors es InvalidResponse', () async {
      final failure = await failureWhenPokeApi(replyJson(200, {}));

      expect(failure, const InvalidResponse());
    });

    test('un FormatException al leer el DTO es InvalidResponse', () {
      expect(
        syncFailureFrom(const FormatException('Pokémon sin nombre')),
        const InvalidResponse(),
      );
    });
  });

  test('un SyncFailure ya traducido pasa sin cambios', () {
    expect(syncFailureFrom(const ServerError(502)), const ServerError(502));
  });

  test(
    'deja pasar CallBudgetExhausted aunque llegue envuelto en UnknownException',
    () {
      final exhausted = CallBudgetExhausted(DateTime(2026, 11, 20, 11));

      final failure = syncFailureFrom(
        OperationException(
          linkException: UnknownException(exhausted, StackTrace.current),
        ),
      );

      expect(failure, exhausted);
    },
  );

  test('un error desconocido es QueryError y no se reintenta', () {
    final failure = syncFailureFrom(StateError('base de datos cerrada'));

    expect(failure, isA<QueryError>());
    expect(failure.isRetryable, isFalse);
  });
}
