import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';

void main() {
  test('solo NoConnection y QueryError no se reintentan', () {
    const failuresAndRetry = <(SyncFailure, bool)>[
      (NoConnection(), false),
      (RequestTimeout(), true),
      (RateLimited(retryAfter: Duration(minutes: 1)), true),
      (ServerError(503), true),
      (PartialResponse(), true),
      (QueryError("field 'pokemon' not found"), false),
      (InvalidResponse(), true),
    ];

    for (final (failure, isRetryable) in failuresAndRetry) {
      expect(failure.isRetryable, isRetryable, reason: '$failure');
    }
  });
}
