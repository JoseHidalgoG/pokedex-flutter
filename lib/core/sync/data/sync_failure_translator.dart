import 'dart:async';
import 'dart:io';

import 'package:graphql/client.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';

Future<T> asSyncFailures<T>(Future<T> Function() work) async {
  try {
    return await work();
  } on SyncFailure {
    rethrow;
  } catch (error, stackTrace) {
    Error.throwWithStackTrace(syncFailureFrom(error), stackTrace);
  }
}

SyncFailure syncFailureFrom(Object error, {bool dataReceived = false}) {
  return switch (error) {
    SyncFailure() => error,
    OperationException(:final linkException?) => _failureFromLink(
      linkException,
    ),
    OperationException() when dataReceived => const PartialResponse(),
    OperationException(:final graphqlErrors) => QueryError(
      graphqlErrors.map((graphqlError) => graphqlError.message).join('; '),
    ),
    TimeoutException() => const RequestTimeout(),
    SocketException() => const NoConnection(),
    FormatException() => const InvalidResponse(),
    _ => QueryError('$error'),
  };
}

SyncFailure _failureFromLink(LinkException exception) {
  return switch (exception) {
    HttpLinkServerException(:final response) => _failureFromHttpStatus(
      response.statusCode,
      response.headers,
    ),
    HttpLinkParserException(:final response) => _failureFromHttpStatus(
      response.statusCode,
      response.headers,
    ),
    ResponseFormatException() => const InvalidResponse(),
    NetworkException() => const NoConnection(),
    ServerException(:final statusCode?) => _failureFromHttpStatus(
      statusCode,
      const {},
    ),
    ServerException() => const NoConnection(),
    UnknownException(:final originalException?) => syncFailureFrom(
      originalException,
    ),
    _ => QueryError('$exception'),
  };
}

SyncFailure _failureFromHttpStatus(
  int statusCode,
  Map<String, String> headers,
) {
  return switch (statusCode) {
    HttpStatus.tooManyRequests => RateLimited(
      retryAfter: _retryAfterIn(headers),
    ),
    >= HttpStatus.internalServerError => ServerError(statusCode),
    >= HttpStatus.multipleChoices => QueryError('HTTP $statusCode'),
    _ => const InvalidResponse(),
  };
}

Duration? _retryAfterIn(Map<String, String> headers) {
  final seconds = int.tryParse(headers['retry-after']?.trim() ?? '');
  if (seconds == null || seconds < 0) {
    return null;
  }
  return Duration(seconds: seconds);
}
