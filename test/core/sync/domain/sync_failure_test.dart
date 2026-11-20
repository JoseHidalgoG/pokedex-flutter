import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';

void main() {
  test('solo NoConnection y QueryError no se reintentan', () {
    final failuresAndRetry = <(SyncFailure, bool)>[
      (const NoConnection(), false),
      (const RequestTimeout(), true),
      (const RateLimited(retryAfter: Duration(minutes: 1)), true),
      (const ServerError(503), true),
      (const PartialResponse(), true),
      (const QueryError("field 'pokemon' not found"), false),
      (const InvalidResponse(), true),
      (CallBudgetExhausted(DateTime(2026, 11, 20, 11)), true),
    ];

    for (final (failure, isRetryable) in failuresAndRetry) {
      expect(failure.isRetryable, isRetryable, reason: '$failure');
    }
  });
}
