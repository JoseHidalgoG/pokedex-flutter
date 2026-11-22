import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';

void main() {
  final earlier = DateTime(2026, 11, 20, 10);
  final later = DateTime(2026, 11, 20, 10, 5);

  group('mostRelevantSyncStatus', () {
    final fromLeastToMostRelevant = <SyncStatus>[
      const SyncIdle(),
      SyncRevalidated(earlier),
      const SyncFailed(ServerError(503)),
      SyncPaused(later),
      SyncWaitingRetry(
        attempt: 2,
        maxAttempts: 5,
        retryAt: later,
        failure: const ServerError(503),
      ),
      const SyncRevalidating(),
      const SyncFullPassInProgress(),
    ];

    test('de dos estados elige el que más importa, en cualquier orden', () {
      for (final (index, lessRelevant) in fromLeastToMostRelevant.indexed) {
        for (final moreRelevant in fromLeastToMostRelevant.skip(index + 1)) {
          expect(
            mostRelevantSyncStatus([lessRelevant, moreRelevant]),
            same(moreRelevant),
          );
          expect(
            mostRelevantSyncStatus([moreRelevant, lessRelevant]),
            same(moreRelevant),
          );
        }
      }
    });

    test('de dos revalidaciones se queda con la más reciente', () {
      final first = SyncRevalidated(earlier);
      final second = SyncRevalidated(later);

      expect(mostRelevantSyncStatus([first, second]), same(second));
      expect(mostRelevantSyncStatus([second, first]), same(second));
    });

    test('un solo estado se devuelve tal cual', () {
      const idle = SyncIdle();

      expect(mostRelevantSyncStatus([idle]), same(idle));
    });
  });
}
