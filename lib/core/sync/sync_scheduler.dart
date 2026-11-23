import 'dart:async';
import 'dart:developer' as developer;

import 'package:pokedex_flutter/core/sync/domain/call_budget.dart';
import 'package:pokedex_flutter/core/sync/domain/retry_policy.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_job.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_state_store.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';

typedef SyncStatusChange = ({String key, SyncStatus status});

typedef _JobAfterRunning = ({SyncJob job, Completer<void> done});

typedef _PeriodicJob = ({SyncJob job, Duration period});

class SyncScheduler {
  SyncScheduler({
    required this._budget,
    required this._retryPolicy,
    required this._store,
    this._now = DateTime.now,
  });

  static const rateLimitPause = Duration(minutes: 10);

  final CallBudget _budget;
  final RetryPolicy _retryPolicy;
  final SyncStateStore _store;
  final DateTime Function() _now;

  final _runningAttempts = <String, Future<void>>{};
  final _scheduledJobs = <String, SyncJob>{};
  final _scheduledStarts = <String, Timer>{};
  final _jobsForNextReconnect = <String, SyncJob>{};
  final _jobsOnEachReconnect = <String, SyncJob>{};
  final _jobsAfterRunning = <String, _JobAfterRunning>{};
  final _periodicJobs = <String, _PeriodicJob>{};
  final _periodicTimers = <String, Timer>{};
  final _statuses = <String, SyncStatus>{};
  final _lastRevalidations = <String, DateTime>{};
  final _statusChanges = StreamController<SyncStatusChange>.broadcast();
  var _isOnline = false;
  var _isDisposed = false;

  bool get isOnline => _isOnline;

  SyncStatus statusOf(String key) => _statuses[key] ?? const SyncIdle();

  DateTime? lastRevalidationOf(String key) => _lastRevalidations[key];

  Stream<SyncStatus> watchStatus(String key) {
    return watchStatuses([key]).map((statuses) => statuses.single);
  }

  Stream<List<SyncStatus>> watchStatuses(List<String> keys) {
    return Stream.multi((listener) {
      final latest = {for (final key in keys) key: statusOf(key)};
      listener.add([...latest.values]);
      final subscription = _statusChanges.stream
          .where((change) => latest.containsKey(change.key))
          .listen((change) {
            latest[change.key] = change.status;
            listener.add([...latest.values]);
          }, onDone: listener.close);
      listener.onCancel = subscription.cancel;
    });
  }

  Future<void> run(SyncJob job) {
    final runningAttempt = _runningAttempts[job.key];
    if (runningAttempt != null) {
      return runningAttempt;
    }
    if (!job.force && _scheduledJobs.containsKey(job.key)) {
      _scheduledJobs[job.key] = job;
      return Future.value();
    }
    return _start(job, retriesSoFar: 0);
  }

  Future<void> runLatest(SyncJob job) {
    if (!_runningAttempts.containsKey(job.key)) {
      return run(job);
    }
    final done = _jobsAfterRunning[job.key]?.done ?? Completer<void>();
    _jobsAfterRunning[job.key] = (job: job, done: done);
    return done.future;
  }

  void runOnEachReconnect(SyncJob job) {
    _jobsOnEachReconnect[job.key] = job;
  }

  void stopRunningOnReconnect(String key) {
    _jobsOnEachReconnect.remove(key);
    _jobsForNextReconnect.remove(key);
  }

  void runEveryWhileOnline(SyncJob job, Duration period) {
    _periodicJobs[job.key] = (job: job, period: period);
    if (_isOnline) {
      _startPeriodicTimer(job.key);
    }
  }

  void connectivityChanged({required bool isOnline}) {
    final cameOnline = isOnline && !_isOnline;
    _isOnline = isOnline;
    if (cameOnline) {
      _runJobsAfterReconnect();
      _periodicJobs.keys.forEach(_startPeriodicTimer);
    } else if (!isOnline) {
      _holdScheduledJobsUntilReconnect();
      _cancelPeriodicTimers();
    }
  }

  Future<void> dispose() async {
    _isDisposed = true;
    _cancelScheduledStarts();
    _cancelPeriodicTimers();
    await _statusChanges.close();
  }

  void _startPeriodicTimer(String key) {
    final periodicJob = _periodicJobs[key];
    if (periodicJob == null || _isDisposed) {
      return;
    }
    _periodicTimers.remove(key)?.cancel();
    _periodicTimers[key] = Timer.periodic(periodicJob.period, (_) {
      unawaited(run(periodicJob.job));
    });
  }

  void _cancelPeriodicTimers() {
    for (final periodicTimer in _periodicTimers.values) {
      periodicTimer.cancel();
    }
    _periodicTimers.clear();
  }

  void _runJobsAfterReconnect() {
    final jobs = {..._jobsOnEachReconnect, ..._jobsForNextReconnect};
    _jobsForNextReconnect.clear();
    for (final job in jobs.values) {
      unawaited(run(job));
    }
  }

  void _holdScheduledJobsUntilReconnect() {
    _cancelScheduledStarts();
    final heldJobs = [..._scheduledJobs.values];
    _scheduledJobs.clear();
    for (final job in heldJobs) {
      _jobsForNextReconnect[job.key] = job;
      _emit(job.key, const SyncFailed(NoConnection()));
      unawaited(_store.recordPending(job.key, failure: const NoConnection()));
    }
  }

  Future<void> _start(SyncJob job, {required int retriesSoFar}) {
    _scheduledStarts.remove(job.key)?.cancel();
    _scheduledJobs.remove(job.key);
    _jobsForNextReconnect.remove(job.key);

    late final Future<void> attempt;
    attempt = _attempt(job, retriesSoFar: retriesSoFar).whenComplete(() {
      if (identical(_runningAttempts[job.key], attempt)) {
        _runningAttempts.remove(job.key);
        _startJobWaitingFor(job.key);
      }
    });
    _runningAttempts[job.key] = attempt;
    return attempt;
  }

  void _startJobWaitingFor(String key) {
    final waiting = _jobsAfterRunning.remove(key);
    if (waiting == null) {
      return;
    }
    if (_isDisposed) {
      waiting.done.complete();
    } else if (!_isOnline) {
      _jobsForNextReconnect[key] = waiting.job;
      waiting.done.complete();
    } else {
      waiting.done.complete(run(waiting.job));
    }
  }

  Future<void> _attempt(SyncJob job, {required int retriesSoFar}) async {
    _emit(job.key, job.runningStatus);
    try {
      await _store.recordStarted(job.key);
      final outcome = await job.perform();
      await _store.recordSucceeded(job.key);
      _emit(job.key, _statusAfter(job.key, outcome));
      if (outcome == SyncOutcome.revalidated && _isOnline) {
        _startPeriodicTimer(job.key);
      }
    } on CallBudgetExhausted catch (exhausted) {
      await _pauseUntil(job, exhausted.until, retriesSoFar: retriesSoFar);
    } on SyncFailure catch (failure) {
      await _handleFailure(job, failure, retriesSoFar: retriesSoFar);
    } catch (error, stackTrace) {
      developer.log(
        '${job.key}: error inesperado',
        name: 'sync',
        error: error,
        stackTrace: stackTrace,
      );
      _emit(job.key, SyncFailed(QueryError('$error')));
    }
  }

  SyncStatus _statusAfter(String key, SyncOutcome outcome) {
    if (outcome == SyncOutcome.revalidated) {
      _lastRevalidations[key] = _now();
    }
    final lastRevalidation = _lastRevalidations[key];
    if (lastRevalidation == null) {
      return const SyncIdle();
    }
    return SyncRevalidated(lastRevalidation);
  }

  Future<void> _handleFailure(
    SyncJob job,
    SyncFailure failure, {
    required int retriesSoFar,
  }) async {
    if (failure is RateLimited) {
      _budget.blockUntil(_now().add(failure.retryAfter ?? rateLimitPause));
    }
    final isWorthRetrying = failure.isRetryable || failure is NoConnection;
    if (!isWorthRetrying) {
      await _fail(job, failure, attempt: retriesSoFar);
    } else if (!_isOnline) {
      await _waitForReconnect(job, failure);
    } else {
      await _retryLater(job, failure, retriesSoFar: retriesSoFar);
    }
  }

  Future<void> _retryLater(
    SyncJob job,
    SyncFailure failure, {
    required int retriesSoFar,
  }) async {
    final retry = retriesSoFar + 1;
    final delay = _retryPolicy.delayBeforeRetry(retry);
    if (delay == null) {
      await _fail(job, failure, attempt: retriesSoFar);
      return;
    }
    final retryAt = _laterOf(
      _now().add(delay),
      _budget.nextSlotAt(job.priority),
    );
    await _store.recordWaitingRetry(
      job.key,
      attempt: retry,
      retryAt: retryAt,
      failure: failure,
    );
    final maxAttempts = _retryPolicy.maxAttempts;
    final secondsToWait = retryAt.difference(_now()).inSeconds;
    developer.log(
      '${job.key}: reintento $retry/$maxAttempts en $secondsToWait s ($failure)',
      name: 'sync',
    );
    _emit(
      job.key,
      SyncWaitingRetry(
        attempt: retry,
        maxAttempts: maxAttempts,
        retryAt: retryAt,
        failure: failure,
      ),
    );
    _scheduleStart(job, at: retryAt, retriesSoFar: retry);
  }

  Future<void> _pauseUntil(
    SyncJob job,
    DateTime until, {
    required int retriesSoFar,
  }) async {
    if (!_isOnline) {
      await _waitForReconnect(job, CallBudgetExhausted(until));
      return;
    }
    await _store.recordPaused(job.key, until: until);
    developer.log(
      '${job.key}: presupuesto agotado, en pausa hasta $until',
      name: 'sync',
    );
    _emit(job.key, SyncPaused(until));
    _scheduleStart(job, at: until, retriesSoFar: retriesSoFar);
  }

  Future<void> _waitForReconnect(SyncJob job, SyncFailure failure) async {
    await _store.recordPending(job.key, failure: failure);
    _jobsForNextReconnect[job.key] = job;
    _emit(job.key, SyncFailed(failure));
  }

  Future<void> _fail(
    SyncJob job,
    SyncFailure failure, {
    required int attempt,
  }) async {
    await _store.recordFailed(job.key, attempt: attempt, failure: failure);
    developer.log(
      '${job.key}: falló tras $attempt reintentos ($failure)',
      name: 'sync',
    );
    _jobsForNextReconnect[job.key] = job;
    _emit(job.key, SyncFailed(failure));
  }

  void _scheduleStart(
    SyncJob job, {
    required DateTime at,
    required int retriesSoFar,
  }) {
    if (_isDisposed) {
      return;
    }
    _scheduledJobs[job.key] = job;
    _scheduledStarts.remove(job.key)?.cancel();
    _scheduledStarts[job.key] = Timer(at.difference(_now()), () {
      _scheduledStarts.remove(job.key);
      final newestJob = _scheduledJobs.remove(job.key) ?? job;
      unawaited(_start(newestJob, retriesSoFar: retriesSoFar));
    });
  }

  void _cancelScheduledStarts() {
    for (final scheduledStart in _scheduledStarts.values) {
      scheduledStart.cancel();
    }
    _scheduledStarts.clear();
  }

  void _emit(String key, SyncStatus status) {
    _statuses[key] = status;
    if (!_statusChanges.isClosed) {
      _statusChanges.add((key: key, status: status));
    }
  }

  static DateTime _laterOf(DateTime candidate, DateTime? other) {
    if (other != null && other.isAfter(candidate)) {
      return other;
    }
    return candidate;
  }
}
