import 'dart:math';

class RetryPolicy {
  RetryPolicy({Random? random, this.maxAttempts = 5})
    : _random = random ?? Random();

  static const firstDelay = Duration(seconds: 2);
  static const maxDelay = Duration(seconds: 60);
  static const jitter = 0.2;

  final Random _random;
  final int maxAttempts;

  Duration? delayBeforeRetry(int attempt) {
    assert(attempt >= 1, 'Los reintentos se numeran desde 1');
    if (attempt > maxAttempts) {
      return null;
    }
    final exponentialDelay = firstDelay * pow(2, attempt - 1);
    final jitterFactor = 1 + jitter * (2 * _random.nextDouble() - 1);
    final delay = exponentialDelay * jitterFactor;
    return delay < maxDelay ? delay : maxDelay;
  }
}
