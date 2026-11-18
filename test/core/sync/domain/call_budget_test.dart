import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/sync/domain/call_budget.dart';

void main() {
  final start = DateTime(2026, 11, 19, 10);
  late DateTime now;
  late CallBudget budget;

  setUp(() {
    now = start;
    budget = CallBudget(now: () => now);
  });

  void reserve(int calls, CallPriority priority) {
    for (var call = 0; call < calls; call++) {
      expect(budget.tryReserve(priority), isTrue, reason: 'llamada $call');
    }
  }

  test('cada prioridad se detiene en su límite: 60, 70 y 80 por hora', () {
    reserve(60, CallPriority.background);
    expect(budget.tryReserve(CallPriority.background), isFalse);

    reserve(10, CallPriority.restoration);
    expect(budget.tryReserve(CallPriority.restoration), isFalse);

    reserve(10, CallPriority.user);
    expect(budget.tryReserve(CallPriority.user), isFalse);

    expect(budget.used, 80);
  });

  test('las pasadas completas dejan 20 llamadas al usuario', () {
    reserve(60, CallPriority.background);

    expect(budget.tryReserve(CallPriority.background), isFalse);
    reserve(20, CallPriority.user);
  });

  test('una llamada deja de contar 60 minutos después', () {
    reserve(80, CallPriority.user);

    now = start.add(const Duration(minutes: 59, seconds: 59));
    expect(budget.tryReserve(CallPriority.user), isFalse);

    now = start.add(const Duration(minutes: 60));
    expect(budget.used, 0);
    expect(budget.tryReserve(CallPriority.user), isTrue);
    expect(budget.used, 1);
  });

  test('nextSlotAt dice cuándo vuelve a haber hueco para cada prioridad', () {
    reserve(5, CallPriority.user);
    now = start.add(const Duration(minutes: 10));
    reserve(55, CallPriority.user);
    now = start.add(const Duration(minutes: 20));
    reserve(5, CallPriority.user);

    expect(budget.used, 65);
    expect(
      budget.nextSlotAt(CallPriority.background),
      start.add(const Duration(minutes: 70)),
    );
    expect(budget.nextSlotAt(CallPriority.restoration), isNull);
    expect(budget.nextSlotAt(CallPriority.user), isNull);
  });

  test('blockUntil deja el presupuesto en cero hasta la hora indicada', () {
    final rateLimitEnds = start.add(const Duration(minutes: 10));

    budget.blockUntil(rateLimitEnds);

    expect(budget.tryReserve(CallPriority.user), isFalse);
    expect(budget.nextSlotAt(CallPriority.user), rateLimitEnds);

    now = rateLimitEnds;
    expect(budget.nextSlotAt(CallPriority.user), isNull);
    expect(budget.tryReserve(CallPriority.user), isTrue);
  });

  test('un bloqueo más corto no acorta uno más largo', () {
    budget
      ..blockUntil(start.add(const Duration(minutes: 10)))
      ..blockUntil(start.add(const Duration(minutes: 5)));

    now = start.add(const Duration(minutes: 5));

    expect(budget.tryReserve(CallPriority.user), isFalse);
    expect(
      budget.nextSlotAt(CallPriority.user),
      start.add(const Duration(minutes: 10)),
    );
  });

  test('las llamadas rechazadas no gastan presupuesto', () {
    reserve(60, CallPriority.background);

    for (var call = 0; call < 5; call++) {
      budget.tryReserve(CallPriority.background);
    }

    expect(budget.used, 60);
  });
}
