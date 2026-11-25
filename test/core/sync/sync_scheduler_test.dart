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

class VisibleRequests {
  final performedIds = <List<int>>[];
  final downloads = <Completer<SyncOutcome>>[];

  SyncJob jobFor(List<int> ids) {
    return SyncJob(
      key: 'catalog:visible',
      priority: CallPriority.user,
      runningStatus: const SyncRevalidating(),
      perform: () {
        performedIds.add(ids);
        final download = Completer<SyncOutcome>();
        downloads.add(download);
        return download.future;
      },
    );
  }
}

SyncJob detailJob(int pokemonId, ScriptedWork work) {
  return SyncJob(
    key: 'detail:$pokemonId',
    priority: CallPriority.user,
    runningStatus: const SyncRevalidating(),
    perform: work.perform,
  );
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

  group('el pedido más reciente', () {
    test('sin nada en curso corre en el acto', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async)
          ..connectivityChanged(isOnline: true);
        final visible = VisibleRequests();

        scheduler.runLatest(visible.jobFor([1, 2]));
        async.flushMicrotasks();

        expect(visible.performedIds, [
          [1, 2],
        ]);
      });
    });

    test(
      'con la misma clave en curso espera a que termine y corre después',
      () {
        fakeAsync((async) {
          final scheduler = schedulerIn(async)
            ..connectivityChanged(isOnline: true);
          final visible = VisibleRequests();

          scheduler.runLatest(visible.jobFor([1]));
          async.flushMicrotasks();
          scheduler.runLatest(visible.jobFor([51]));
          async.flushMicrotasks();
          expect(visible.performedIds, [
            [1],
          ]);

          visible.downloads.first.complete(SyncOutcome.revalidated);
          async.flushMicrotasks();

          expect(visible.performedIds, [
            [1],
            [51],
          ]);
        });
      },
    );

    test(
      'un pedido más nuevo reemplaza al que esperaba y los dos terminan con él',
      () {
        fakeAsync((async) {
          final scheduler = schedulerIn(async)
            ..connectivityChanged(isOnline: true);
          final visible = VisibleRequests();
          var finishedRequests = 0;

          scheduler.runLatest(visible.jobFor([1]));
          async.flushMicrotasks();
          for (final ids in [
            [51],
            [101],
          ]) {
            scheduler.runLatest(visible.jobFor(ids)).then((_) {
              finishedRequests++;
            });
          }
          visible.downloads.first.complete(SyncOutcome.revalidated);
          async.flushMicrotasks();

          expect(visible.performedIds, [
            [1],
            [101],
          ]);
          expect(finishedRequests, 0);

          visible.downloads.last.complete(SyncOutcome.revalidated);
          async.flushMicrotasks();

          expect(finishedRequests, 2);
        });
      },
    );

    test('si la red se pierde mientras espera, corre al reconectar', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async)
          ..connectivityChanged(isOnline: true);
        final visible = VisibleRequests();

        scheduler.runLatest(visible.jobFor([1]));
        async.flushMicrotasks();
        scheduler
          ..runLatest(visible.jobFor([51]))
          ..connectivityChanged(isOnline: false);
        visible.downloads.first.complete(SyncOutcome.revalidated);
        async.flushMicrotasks();
        expect(visible.performedIds, [
          [1],
        ]);

        scheduler.connectivityChanged(isOnline: true);
        async.flushMicrotasks();

        expect(visible.performedIds, [
          [1],
          [51],
        ]);
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

    test(
      'watchStatuses publica en orden cada cambio de las claves pedidas',
      () {
        fakeAsync((async) {
          final scheduler = schedulerIn(async);
          final statuses = <List<SyncStatus>>[];
          scheduler
              .watchStatuses(['catalog', 'catalog:visible'])
              .listen(statuses.add);

          scheduler.run(catalogJob(ScriptedWork([SyncOutcome.revalidated])));
          async.flushMicrotasks();
          scheduler.run(
            SyncJob(
              key: 'detail:25',
              priority: CallPriority.user,
              runningStatus: const SyncRevalidating(),
              perform: ScriptedWork([SyncOutcome.revalidated]).perform,
            ),
          );
          async.flushMicrotasks();
          final visible = VisibleRequests();
          scheduler.run(visible.jobFor([1]));
          async.flushMicrotasks();
          visible.downloads.single.complete(SyncOutcome.revalidated);
          async.flushMicrotasks();

          expect(statuses, [
            [isA<SyncIdle>(), isA<SyncIdle>()],
            [isA<SyncFullPassInProgress>(), isA<SyncIdle>()],
            [isA<SyncRevalidated>(), isA<SyncIdle>()],
            [isA<SyncRevalidated>(), isA<SyncRevalidating>()],
            [isA<SyncRevalidated>(), isA<SyncRevalidated>()],
          ]);
        });
      },
    );

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

    test('lastRevalidationOf guarda la última descarga real aunque haya otra en curso', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async);
        final download = Completer<SyncOutcome>();
        final outcomes = [
          Future.value(SyncOutcome.revalidated),
          download.future,
        ];
        var performs = 0;
        SyncJob job() => SyncJob(
          key: 'detail:25',
          priority: CallPriority.user,
          runningStatus: const SyncRevalidating(),
          perform: () => outcomes[performs++],
        );
        expect(scheduler.lastRevalidationOf('detail:25'), isNull);

        scheduler.run(job());
        async.flushMicrotasks();
        async.elapse(const Duration(minutes: 6));
        scheduler.run(job());
        async.flushMicrotasks();

        expect(scheduler.statusOf('detail:25'), isA<SyncRevalidating>());
        expect(scheduler.lastRevalidationOf('detail:25'), start);

        download.complete(SyncOutcome.upToDate);
        async.flushMicrotasks();
        expect(scheduler.lastRevalidationOf('detail:25'), start);
        expect(scheduler.lastRevalidationOf('catalog'), isNull);
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
    test('isOnline sigue al último estado de conexión recibido', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async);
        expect(scheduler.isOnline, isFalse);

        scheduler.connectivityChanged(isOnline: true);
        expect(scheduler.isOnline, isTrue);

        scheduler.connectivityChanged(isOnline: false);
        expect(scheduler.isOnline, isFalse);
      });
    });

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

    test('stopRunningOnReconnect quita solo esa clave de las reconexiones', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async);
        final detailWork = ScriptedWork([SyncOutcome.upToDate]);
        final catalogWork = ScriptedWork([SyncOutcome.upToDate]);
        scheduler
          ..runOnEachReconnect(detailJob(25, detailWork))
          ..runOnEachReconnect(catalogJob(catalogWork))
          ..stopRunningOnReconnect('detail:25')
          ..connectivityChanged(isOnline: true);
        async.flushMicrotasks();

        expect(detailWork.calls, 0);
        expect(catalogWork.calls, 1);
      });
    });

    test(
      'stopRunningOnReconnect descarta lo que esperaba a la próxima reconexión',
      () {
        fakeAsync((async) {
          final scheduler = schedulerIn(async);
          final work = ScriptedWork([
            const NoConnection(),
            SyncOutcome.revalidated,
          ]);

          scheduler.run(detailJob(25, work));
          async.flushMicrotasks();
          scheduler
            ..stopRunningOnReconnect('detail:25')
            ..connectivityChanged(isOnline: true);
          async.flushMicrotasks();

          expect(work.calls, 1);
        });
      },
    );
  });

  group('una vez cuando haya conexión', () {
    test('en línea corre en el acto', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async)
          ..connectivityChanged(isOnline: true);
        final work = ScriptedWork([SyncOutcome.revalidated]);

        scheduler.runWhenOnline(detailJob(25, work));
        async.flushMicrotasks();

        expect(work.calls, 1);
        expect(scheduler.statusOf('detail:25'), isA<SyncRevalidated>());
      });
    });

    test(
      'sin conexión espera a la próxima reconexión y corre una sola vez',
      () {
        fakeAsync((async) {
          final scheduler = schedulerIn(async)
            ..connectivityChanged(isOnline: false);
          final work = ScriptedWork([SyncOutcome.revalidated]);

          scheduler.runWhenOnline(detailJob(25, work));
          async
            ..flushMicrotasks()
            ..elapse(const Duration(minutes: 10));
          expect(work.calls, 0);

          scheduler.connectivityChanged(isOnline: true);
          async.flushMicrotasks();
          expect(work.calls, 1);

          scheduler
            ..connectivityChanged(isOnline: false)
            ..connectivityChanged(isOnline: true);
          async.flushMicrotasks();
          expect(work.calls, 1);
        });
      },
    );

    test('la misma clave pedida varias veces sin conexión corre una vez', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async);
        final work = ScriptedWork([SyncOutcome.revalidated]);

        scheduler
          ..runWhenOnline(detailJob(25, work))
          ..runWhenOnline(detailJob(25, work))
          ..connectivityChanged(isOnline: true);
        async.flushMicrotasks();

        expect(work.calls, 1);
      });
    });

    test('stopRunningOnReconnect de la misma clave no la descarta', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async);
        final work = ScriptedWork([SyncOutcome.revalidated]);

        scheduler
          ..runOnEachReconnect(detailJob(25, work))
          ..runWhenOnline(detailJob(25, work))
          ..stopRunningOnReconnect('detail:25')
          ..connectivityChanged(isOnline: true);
        async.flushMicrotasks();
        expect(work.calls, 1);

        scheduler
          ..connectivityChanged(isOnline: false)
          ..connectivityChanged(isOnline: true);
        async.flushMicrotasks();
        expect(work.calls, 1);
      });
    });
  });

  group('servicio caído con red', () {
    void serviceDown(SyncScheduler scheduler) =>
        scheduler.connectivityChanged(isOnline: false, hasNetwork: true);

    test('hasNetwork distingue el servicio caído de la falta de red', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async);
        expect(scheduler.hasNetwork, isFalse);

        serviceDown(scheduler);
        expect((scheduler.isOnline, scheduler.hasNetwork), (false, true));

        scheduler.connectivityChanged(isOnline: false, hasNetwork: false);
        expect((scheduler.isOnline, scheduler.hasNetwork), (false, false));

        scheduler.connectivityChanged(isOnline: true, hasNetwork: false);
        expect((scheduler.isOnline, scheduler.hasNetwork), (true, true));

        scheduler.connectivityChanged(isOnline: false);
        expect((scheduler.isOnline, scheduler.hasNetwork), (false, false));
      });
    });

    test(
      'un reintento en espera sigue su temporizador al caer el servicio',
      () {
        fakeAsync((async) {
          final scheduler = schedulerIn(async)
            ..connectivityChanged(isOnline: true);
          final work = ScriptedWork([
            const ServerError(503),
            SyncOutcome.revalidated,
          ]);

          scheduler.run(catalogJob(work));
          async.flushMicrotasks();
          serviceDown(scheduler);
          async.elapse(const Duration(seconds: 2));

          expect(work.calls, 2);
          expect(scheduler.statusOf('catalog'), isA<SyncRevalidated>());
          expect(store.history, everyElement(isNot(startsWith('pending'))));
        });
      },
    );

    test('un ServerError se reintenta a los 2, 4, 8, 16 y 32 s y después queda failed', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async);
        serviceDown(scheduler);
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
        expect(store.history, [
          for (var retry = 1; retry <= 5; retry++) ...[
            'in_progress',
            'waiting_retry $retry',
          ],
          'in_progress',
          'failed 5 ServerError(503)',
        ]);
        expect(scheduler.statusOf('catalog'), isA<SyncFailed>());
      });
    });

    test('sin red un ServerError no se reintenta y queda pending', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async)
          ..connectivityChanged(isOnline: false, hasNetwork: false);
        final work = ScriptedWork([const ServerError(503)]);

        scheduler.run(catalogJob(work));
        async
          ..flushMicrotasks()
          ..elapse(const Duration(minutes: 10));

        expect(work.calls, 1);
        expect(store.history.last, 'pending ServerError(503)');
      });
    });

    test('perder también la red retiene el reintento hasta la reconexión', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async);
        serviceDown(scheduler);
        final work = ScriptedWork([
          const ServerError(503),
          SyncOutcome.revalidated,
        ]);

        scheduler.run(catalogJob(work));
        async.flushMicrotasks();
        scheduler.connectivityChanged(isOnline: false, hasNetwork: false);
        async.elapse(const Duration(minutes: 1));

        expect(work.calls, 1);
        expect(store.history.last, 'pending NoConnection');
        expect(scheduler.statusOf('catalog'), isA<SyncFailed>());

        scheduler.connectivityChanged(isOnline: true);
        async.flushMicrotasks();

        expect(work.calls, 2);
        expect(scheduler.statusOf('catalog'), isA<SyncRevalidated>());
      });
    });

    test('al volver el servicio el trabajo que falló corre una sola vez', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async);
        serviceDown(scheduler);
        final work = ScriptedWork([
          for (var attempt = 0; attempt < 6; attempt++) const ServerError(503),
          SyncOutcome.revalidated,
        ]);
        scheduler.runOnEachReconnect(catalogJob(work));

        scheduler.run(catalogJob(work, force: true));
        async
          ..flushMicrotasks()
          ..elapse(const Duration(minutes: 2));
        expect(work.calls, 6);
        expect(scheduler.statusOf('catalog'), isA<SyncFailed>());

        scheduler.connectivityChanged(isOnline: true);
        async
          ..flushMicrotasks()
          ..elapse(const Duration(minutes: 10));

        expect(work.calls, 7);
        expect(scheduler.statusOf('catalog'), isA<SyncRevalidated>());
      });
    });

    test('al volver el servicio un reintento en espera corre en el acto', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async);
        serviceDown(scheduler);
        final work = ScriptedWork([
          const ServerError(503),
          const ServerError(503),
          const ServerError(503),
          SyncOutcome.revalidated,
        ]);

        scheduler.run(catalogJob(work));
        async
          ..flushMicrotasks()
          ..elapse(const Duration(seconds: 6));
        expect(work.calls, 3);
        expect(scheduler.statusOf('catalog'), isA<SyncWaitingRetry>());

        scheduler.connectivityChanged(isOnline: true);
        async.flushMicrotasks();
        expect(work.calls, 4);
        expect(scheduler.statusOf('catalog'), isA<SyncRevalidated>());

        async.elapse(const Duration(minutes: 1));
        expect(work.calls, 4);
      });
    });

    test('al volver el servicio un trabajo sin presupuesto sigue en pausa', () {
      fakeAsync((async) {
        final clock = async.getClock(start);
        final budget = CallBudget(now: clock.now);
        final scheduler = schedulerIn(async, budget: budget);
        serviceDown(scheduler);
        final slotFrees = start.add(const Duration(minutes: 5));
        budget.blockUntil(slotFrees);
        final work = ScriptedWork([
          CallBudgetExhausted(slotFrees),
          SyncOutcome.revalidated,
        ]);

        scheduler.run(catalogJob(work));
        async.flushMicrotasks();
        expect(scheduler.statusOf('catalog'), isA<SyncPaused>());

        scheduler.connectivityChanged(isOnline: true);
        async.flushMicrotasks();
        expect(work.calls, 1);

        async.elapse(const Duration(minutes: 5));
        expect(work.calls, 2);
        expect(scheduler.statusOf('catalog'), isA<SyncRevalidated>());
      });
    });

    test('las tareas periódicas se detienen y vuelven con el servicio', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async)
          ..connectivityChanged(isOnline: true);
        final work = ScriptedWork([SyncOutcome.upToDate]);
        scheduler.runEveryWhileOnline(
          catalogJob(work),
          const Duration(seconds: 60),
        );

        serviceDown(scheduler);
        async.elapse(const Duration(minutes: 5));
        expect(work.calls, 0);

        scheduler.connectivityChanged(isOnline: true);
        async.elapse(const Duration(seconds: 60));
        expect(work.calls, 1);
      });
    });

    test('sin conexión antes del primer estado no reintenta', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async);
        final work = ScriptedWork([const ServerError(503)]);

        scheduler.run(catalogJob(work));
        async
          ..flushMicrotasks()
          ..elapse(const Duration(minutes: 5));

        expect(work.calls, 1);
        expect(store.history.last, 'pending ServerError(503)');
      });
    });
  });

  group('cada cierto tiempo mientras haya servicio', () {
    const period = Duration(seconds: 60);

    SyncJob restorationJob(Future<SyncOutcome> Function() perform) {
      return SyncJob(
        key: 'catalog:restore',
        priority: CallPriority.restoration,
        runningStatus: const SyncRevalidating(),
        perform: perform,
      );
    }

    test('corre cada 60 s mientras está en línea y no al registrarse', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async)
          ..connectivityChanged(isOnline: true);
        final work = ScriptedWork([SyncOutcome.upToDate]);

        scheduler.runEveryWhileOnline(restorationJob(work.perform), period);
        async.elapse(const Duration(seconds: 30));
        scheduler.connectivityChanged(isOnline: true);
        async.elapse(const Duration(seconds: 29));
        expect(work.calls, 0);

        async.elapse(const Duration(seconds: 1));
        expect(work.calls, 1);

        async.elapse(const Duration(seconds: 120));
        expect(work.calls, 3);
      });
    });

    test('sin conexión se detiene y al reconectar vuelve a contar 60 s', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async)
          ..connectivityChanged(isOnline: true);
        final work = ScriptedWork([SyncOutcome.upToDate]);

        scheduler.runEveryWhileOnline(restorationJob(work.perform), period);
        async.elapse(const Duration(seconds: 90));
        expect(work.calls, 1);

        scheduler.connectivityChanged(isOnline: false);
        async.elapse(const Duration(minutes: 5));
        expect(work.calls, 1);

        scheduler.connectivityChanged(isOnline: true);
        async.elapse(const Duration(seconds: 59));
        expect(work.calls, 1);
        async.elapse(const Duration(seconds: 1));
        expect(work.calls, 2);
      });
    });

    test('registrada sin conexión empieza a contar en el primer online', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async);
        final work = ScriptedWork([SyncOutcome.upToDate]);

        scheduler.runEveryWhileOnline(restorationJob(work.perform), period);
        async.elapse(const Duration(minutes: 3));
        expect(work.calls, 0);

        scheduler.connectivityChanged(isOnline: true);
        async.elapse(period);
        expect(work.calls, 1);
      });
    });

    test('un tic con la verificación anterior en curso no la repite', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async)
          ..connectivityChanged(isOnline: true);
        final verification = Completer<SyncOutcome>();
        var performs = 0;

        scheduler.runEveryWhileOnline(
          restorationJob(() {
            performs++;
            return verification.future;
          }),
          period,
        );
        async.elapse(const Duration(seconds: 150));

        expect(performs, 1);
        verification.complete(SyncOutcome.upToDate);
        async.flushMicrotasks();
      });
    });

    test('una descarga real vuelve a contar el periodo desde ese momento', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async)
          ..connectivityChanged(isOnline: true);
        final work = ScriptedWork([SyncOutcome.revalidated]);
        final fullPass = catalogJob(work);

        scheduler.runEveryWhileOnline(fullPass, const Duration(hours: 1));
        async.elapse(const Duration(minutes: 10));
        unawaited(scheduler.run(fullPass));
        async.flushMicrotasks();
        expect(work.calls, 1);

        async.elapse(const Duration(minutes: 59));
        expect(work.calls, 1);

        async.elapse(const Duration(minutes: 1));
        expect(work.calls, 2);
      });
    });

    test('una ejecución sin descarga no mueve el periodo', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async)
          ..connectivityChanged(isOnline: true);
        final work = ScriptedWork([SyncOutcome.upToDate]);
        final fullPass = catalogJob(work);

        scheduler.runEveryWhileOnline(fullPass, const Duration(hours: 1));
        async.elapse(const Duration(minutes: 10));
        unawaited(scheduler.run(fullPass));
        async.elapse(const Duration(minutes: 50));

        expect(work.calls, 2);
      });
    });

    test('una descarga sin conexión no arranca el temporizador', () {
      fakeAsync((async) {
        final scheduler = schedulerIn(async);
        final work = ScriptedWork([SyncOutcome.revalidated]);
        final fullPass = catalogJob(work);

        scheduler.runEveryWhileOnline(fullPass, const Duration(hours: 1));
        unawaited(scheduler.run(fullPass));
        async.elapse(const Duration(hours: 3));

        expect(work.calls, 1);
      });
    });

    test('dispose cancela el temporizador', () {
      fakeAsync((async) {
        final clock = async.getClock(start);
        final scheduler = SyncScheduler(
          budget: CallBudget(now: clock.now),
          retryPolicy: RetryPolicy(random: NoJitterRandom()),
          store: store,
          now: clock.now,
        )..connectivityChanged(isOnline: true);
        final work = ScriptedWork([SyncOutcome.upToDate]);

        scheduler.runEveryWhileOnline(restorationJob(work.perform), period);
        unawaited(scheduler.dispose());
        async.elapse(const Duration(minutes: 3));

        expect(work.calls, 0);
      });
    });
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

  test('la consola muestra la espera de un reintento con una décima', () {
    final shown = [
      const Duration(milliseconds: 1751),
      const Duration(milliseconds: 6840),
      const Duration(seconds: 32),
    ].map(secondsWithOneDecimal);

    expect(shown, ['1,8', '6,8', '32,0']);
  });
}
