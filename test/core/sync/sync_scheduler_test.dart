import 'dart:async';
import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/sync/domain/call_budget.dart';
import 'package:pokedex_flutter/core/sync/domain/retry_policy.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_job.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_state_store.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';
import 'package:pokedex_flutter/core/sync/sync_scheduler.dart';

class NoJitterRandom implements Random {
  @override
  double nextDouble() => 0.5;

  @override
  int nextInt(int max) => throw UnimplementedError();

  @override
  bool nextBool() => throw UnimplementedError();
}

class RecordingSyncStateStore implements SyncStateStore {
  final history = <String>[];

  @override
  Future<void> recordStarted(String key) async => history.add('in_progress');

  @override
  Future<void> recordSucceeded(String key) async => history.add('idle');

  @override
  Future<void> recordWaitingRetry(
    String key, {
    required int attempt,
    required DateTime retryAt,
    required SyncFailure failure,
  }) async => history.add('waiting_retry $attempt');

  @override
  Future<void> recordPaused(String key, {required DateTime until}) async =>
      history.add('paused');

  @override
  Future<void> recordPending(
    String key, {
    required SyncFailure failure,
  }) async => history.add('pending $failure');

  @override
  Future<void> recordFailed(
    String key, {
    required int attempt,
    required SyncFailure failure,
  }) async => history.add('failed $attempt $failure');
}

class ScriptedWork {
  ScriptedWork(this._results);

  final List<Object> _results;
  var calls = 0;

  Future<SyncOutcome> perform() async {
    final result = _results[min(calls, _results.length - 1)];
    calls++;
    if (result is SyncFailure) {
      throw result;
    }
    return result as SyncOutcome;
  }
}

SyncJob catalogJob(ScriptedWork work, {bool force = false}) {
  return SyncJob(
    key: 'catalog',
    priority: CallPriority.background,
    runningStatus: const SyncFullPassInProgress(),
    perform: work.perform,
    force: force,
  );
}

void main() {
  final start = DateTime(2026, 11, 20, 10);
  late RecordingSyncStateStore store;

  setUp(() => store = RecordingSyncStateStore());

  SyncScheduler schedulerIn(FakeAsync async, {CallBudget? budget}) {
    final clock = async.getClock(start);
    final scheduler = SyncScheduler(
      budget: budget ?? CallBudget(now: clock.now),
      retryPolicy: RetryPolicy(random: NoJitterRandom()),
      store: store,
      now: clock.now,
    );
    addTearDown(scheduler.dispose);
    return scheduler;
  }

  group('una sola descarga por recurso', () {
    test('dos ejecuciones de la misma clave comparten un perform', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async);
        final download = Completer<SyncOutcome>();
        var performs = 0;
        final job = SyncJob(
          key: 'catalog',
          priority: CallPriority.background,
          runningStatus: const SyncFullPassInProgress(),
          perform: () {
            performs++;
            return download.future;
          },
        );

        final first = scheduler.run(job);
        final second = scheduler.run(job);
        async.flushMicrotasks();

        expect(identical(first, second), isTrue);
        expect(performs, 1);

        download.complete(SyncOutcome.revalidated);
        async.flushMicrotasks();
      });
    });

    test('claves distintas corren a la vez', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async);
        final catalog = ScriptedWork([SyncOutcome.revalidated]);
        final detail = ScriptedWork([SyncOutcome.revalidated]);

        scheduler
          ..run(catalogJob(catalog))
          ..run(
            SyncJob(
              key: 'detail:25',
              priority: CallPriority.user,
              runningStatus: const SyncRevalidating(),
              perform: detail.perform,
            ),
          );
        async.flushMicrotasks();

        expect(catalog.calls, 1);
        expect(detail.calls, 1);
      });
    });
  });

  group('estados publicados', () {
    test('publica el trabajo en curso y después la hora de revalidación', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async);
        final statuses = <SyncStatus>[];
        scheduler.watchStatus('catalog').listen(statuses.add);

        scheduler.run(catalogJob(ScriptedWork([SyncOutcome.revalidated])));
        async.flushMicrotasks();

        expect(statuses, [
          isA<SyncIdle>(),
          isA<SyncFullPassInProgress>(),
          isA<SyncRevalidated>().having((status) => status.at, 'at', start),
        ]);
        expect(store.history, ['in_progress', 'idle']);
      });
    });

    test('si no hizo falta pedir nada vuelve a reposo o conserva la última revalidación', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async);
        final work = ScriptedWork([
          SyncOutcome.upToDate,
          SyncOutcome.revalidated,
          SyncOutcome.upToDate,
        ]);

        scheduler.run(catalogJob(work));
        async.flushMicrotasks();
        expect(scheduler.statusOf('catalog'), isA<SyncIdle>());

        scheduler.run(catalogJob(work));
        async.flushMicrotasks();
        async.elapse(const Duration(minutes: 30));

        scheduler.run(catalogJob(work));
        async.flushMicrotasks();
        expect(
          scheduler.statusOf('catalog'),
          isA<SyncRevalidated>().having((status) => status.at, 'at', start),
        );
      });
    });
  });

  group('reintentos', () {
    test('un ServerError se reintenta a los 2, 4, 8, 16 y 32 s y después queda failed', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async)
          ..connectivityChanged(isOnline: true);
        final work = ScriptedWork([const ServerError(503)]);

        scheduler.run(catalogJob(work));
        async.flushMicrotasks();
        expect(work.calls, 1);

        for (final (retry, seconds) in [2, 4, 8, 16, 32].indexed) {
          async.elapse(Duration(seconds: seconds, milliseconds: -1));
          expect(work.calls, retry + 1);
          async.elapse(const Duration(milliseconds: 1));
          expect(work.calls, retry + 2);
        }
        async.elapse(const Duration(minutes: 10));

        expect(work.calls, 6);
        expect(store.history.last, 'failed 5 ServerError(503)');
        expect(scheduler.statusOf('catalog'), isA<SyncFailed>());
      });
    });

    test('mientras espera publica el número de reintento y su hora', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async)
          ..connectivityChanged(isOnline: true);

        scheduler.run(catalogJob(ScriptedWork([const ServerError(503)])));
        async
          ..flushMicrotasks()
          ..elapse(const Duration(seconds: 2));

        expect(
          scheduler.statusOf('catalog'),
          isA<SyncWaitingRetry>()
              .having((status) => status.attempt, 'attempt', 2)
              .having((status) => status.maxAttempts, 'maxAttempts', 5)
              .having(
                (status) => status.retryAt,
                'retryAt',
                start.add(const Duration(seconds: 6)),
              )
              .having(
                (status) => status.failure,
                'failure',
                const ServerError(503),
              ),
        );
        expect(store.history, contains('waiting_retry 2'));
      });
    });

    test('QueryError no se reintenta y queda failed al momento', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async)
          ..connectivityChanged(isOnline: true);
        final work = ScriptedWork([const QueryError('campo inexistente')]);

        scheduler.run(catalogJob(work));
        async
          ..flushMicrotasks()
          ..elapse(const Duration(minutes: 5));

        expect(work.calls, 1);
        expect(store.history.last, startsWith('failed 0'));
      });
    });

    test('una ejecución forzada durante la espera corre en el acto', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async)
          ..connectivityChanged(isOnline: true);
        final work = ScriptedWork([
          const ServerError(503),
          SyncOutcome.revalidated,
        ]);

        scheduler.run(catalogJob(work));
        async.flushMicrotasks();
        scheduler.run(catalogJob(work));
        async.flushMicrotasks();
        expect(work.calls, 1);

        scheduler.run(catalogJob(work, force: true));
        async.flushMicrotasks();
        expect(work.calls, 2);
        expect(scheduler.statusOf('catalog'), isA<SyncRevalidated>());

        async.elapse(const Duration(minutes: 1));
        expect(work.calls, 2);
      });
    });
  });

  group('conexión', () {
    test('NoConnection sin red no se reintenta y retoma al reconectar', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async)
          ..connectivityChanged(isOnline: false);
        final work = ScriptedWork([
          const NoConnection(),
          SyncOutcome.revalidated,
        ]);

        scheduler.run(catalogJob(work));
        async
          ..flushMicrotasks()
          ..elapse(const Duration(minutes: 10));

        expect(work.calls, 1);
        expect(
          scheduler.statusOf('catalog'),
          isA<SyncFailed>().having(
            (status) => status.failure,
            'failure',
            const NoConnection(),
          ),
        );
        expect(store.history.last, 'pending NoConnection');

        scheduler.connectivityChanged(isOnline: true);
        async.flushMicrotasks();

        expect(work.calls, 2);
        expect(scheduler.statusOf('catalog'), isA<SyncRevalidated>());
      });
    });

    test('NoConnection con el estado aún en línea se reintenta como un fallo normal', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async)
          ..connectivityChanged(isOnline: true);
        final work = ScriptedWork([
          const NoConnection(),
          SyncOutcome.revalidated,
        ]);

        scheduler.run(catalogJob(work));
        async
          ..flushMicrotasks()
          ..elapse(const Duration(seconds: 2));

        expect(work.calls, 2);
        expect(scheduler.statusOf('catalog'), isA<SyncRevalidated>());
      });
    });

    test('perder la red durante la espera cancela el temporizador y la reconexión retoma', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async)
          ..connectivityChanged(isOnline: true);
        final work = ScriptedWork([
          const ServerError(503),
          SyncOutcome.revalidated,
        ]);

        scheduler.run(catalogJob(work));
        async.flushMicrotasks();
        scheduler.connectivityChanged(isOnline: false);
        async.elapse(const Duration(minutes: 1));

        expect(work.calls, 1);
        expect(scheduler.statusOf('catalog'), isA<SyncFailed>());

        scheduler.connectivityChanged(isOnline: true);
        async.flushMicrotasks();

        expect(work.calls, 2);
        expect(scheduler.statusOf('catalog'), isA<SyncRevalidated>());
      });
    });

    test(
      'runOnEachReconnect espera al primer online y corre en cada reconexión',
      () {
        fakeAsync((async) {
          final scheduler = schedulerIn(async);
          final work = ScriptedWork([SyncOutcome.upToDate]);

          scheduler.runOnEachReconnect(catalogJob(work));
          async.flushMicrotasks();
          expect(work.calls, 0);

          scheduler.connectivityChanged(isOnline: true);
          async.flushMicrotasks();
          expect(work.calls, 1);

          scheduler.connectivityChanged(isOnline: true);
          async.flushMicrotasks();
          expect(work.calls, 1);

          scheduler
            ..connectivityChanged(isOnline: false)
            ..connectivityChanged(isOnline: true);
          async.flushMicrotasks();
          expect(work.calls, 2);
        });
      },
    );

    test(
      'un recurso en failed vuelve a intentarse en la siguiente reconexión',
      () {
        fakeAsync((async) {
          final scheduler = schedulerIn(async)
            ..connectivityChanged(isOnline: true);
          final work = ScriptedWork([
            const QueryError('campo inexistente'),
            SyncOutcome.revalidated,
          ]);

          scheduler.run(catalogJob(work));
          async.flushMicrotasks();
          scheduler
            ..connectivityChanged(isOnline: false)
            ..connectivityChanged(isOnline: true);
          async.flushMicrotasks();

          expect(work.calls, 2);
          expect(scheduler.statusOf('catalog'), isA<SyncRevalidated>());
        });
      },
    );
  });

  group('presupuesto', () {
    test('un 429 sin Retry-After bloquea el presupuesto 10 min y el reintento lo espera', () {
      fakeAsync((async) {
        final clock = async.getClock(start);
        final budget = CallBudget(now: clock.now);
        final scheduler = schedulerIn(async, budget: budget)
          ..connectivityChanged(isOnline: true);
        final work = ScriptedWork([
          const RateLimited(),
          SyncOutcome.revalidated,
        ]);
        final blockEnds = start.add(const Duration(minutes: 10));

        scheduler.run(catalogJob(work));
        async.flushMicrotasks();

        expect(budget.nextSlotAt(CallPriority.user), blockEnds);
        expect(
          scheduler.statusOf('catalog'),
          isA<SyncWaitingRetry>().having(
            (status) => status.retryAt,
            'retryAt',
            blockEnds,
          ),
        );

        async.elapse(const Duration(minutes: 10, milliseconds: -1));
        expect(work.calls, 1);
        async.elapse(const Duration(milliseconds: 1));
        expect(work.calls, 2);
      });
    });

    test(
      'sin presupuesto publica SyncPaused y retoma al liberarse el hueco',
      () {
        fakeAsync((async) {
          final scheduler = schedulerIn(async)
            ..connectivityChanged(isOnline: true);
          final slotFrees = start.add(const Duration(minutes: 5));
          final work = ScriptedWork([
            CallBudgetExhausted(slotFrees),
            SyncOutcome.revalidated,
          ]);

          scheduler.run(catalogJob(work));
          async.flushMicrotasks();

          expect(
            scheduler.statusOf('catalog'),
            isA<SyncPaused>().having(
              (status) => status.until,
              'until',
              slotFrees,
            ),
          );
          expect(store.history.last, 'paused');

          async.elapse(const Duration(minutes: 5));

          expect(work.calls, 2);
          expect(scheduler.statusOf('catalog'), isA<SyncRevalidated>());
          expect(store.history, isNot(contains(startsWith('waiting_retry'))));
        });
      },
    );
  });
}
