import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/sync/domain/retry_policy.dart';

class FixedRandom implements Random {
  FixedRandom(this._value);

  final double _value;

  @override
  double nextDouble() => _value;

  @override
  int nextInt(int max) => throw UnimplementedError();

  @override
  bool nextBool() => throw UnimplementedError();
}

const noJitter = 0.5;
const lowestJitter = 0.0;
const highestJitter = 0.999999;

const exponentialDelays = [
  Duration(seconds: 2),
  Duration(seconds: 4),
  Duration(seconds: 8),
  Duration(seconds: 16),
  Duration(seconds: 32),
];

List<Duration?> delaysOf(RetryPolicy policy) => [
  for (var attempt = 1; attempt <= 5; attempt++)
    policy.delayBeforeRetry(attempt),
];

void main() {
  test('sin variación espera 2, 4, 8, 16 y 32 s', () {
    final policy = RetryPolicy(random: FixedRandom(noJitter));

    expect(delaysOf(policy), exponentialDelays);
  });

  test('la variación nunca baja del 80 % de la espera', () {
    final policy = RetryPolicy(random: FixedRandom(lowestJitter));

    expect(delaysOf(policy), [
      for (final delay in exponentialDelays) delay * 0.8,
    ]);
  });

  test('la variación nunca pasa del 120 % de la espera', () {
    final policy = RetryPolicy(random: FixedRandom(highestJitter));

    for (final (index, delay) in delaysOf(policy).indexed) {
      expect(delay! <= exponentialDelays[index] * 1.2, isTrue);
      expect(delay > exponentialDelays[index] * 1.19, isTrue);
    }
  });

  test('con azar real cada espera queda dentro de ±20 %', () {
    final policy = RetryPolicy(random: Random(42));

    for (var round = 0; round < 200; round++) {
      for (final (index, delay) in delaysOf(policy).indexed) {
        expect(delay! >= exponentialDelays[index] * 0.8, isTrue);
        expect(delay <= exponentialDelays[index] * 1.2, isTrue);
      }
    }
  });

  test('nunca espera más de 60 s', () {
    final policy = RetryPolicy(
      random: FixedRandom(highestJitter),
      maxAttempts: 8,
    );

    expect(policy.delayBeforeRetry(6), RetryPolicy.maxDelay);
    expect(policy.delayBeforeRetry(8), RetryPolicy.maxDelay);
  });

  test('después del quinto reintento devuelve null', () {
    final policy = RetryPolicy(random: FixedRandom(noJitter));

    expect(policy.delayBeforeRetry(5), isNotNull);
    expect(policy.delayBeforeRetry(6), isNull);
  });
}
