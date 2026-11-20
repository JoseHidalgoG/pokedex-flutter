import 'dart:developer' as developer;

import 'package:graphql/client.dart';
import 'package:pokedex_flutter/core/sync/domain/call_budget.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';

class CallPriorityEntry extends ContextEntry {
  const CallPriorityEntry(this.priority);

  final CallPriority priority;

  @override
  List<Object?> get fieldsForEquality => [priority];
}

Context withCallPriority(CallPriority priority) {
  return const Context().withEntry(CallPriorityEntry(priority));
}

class CallBudgetLink extends Link {
  CallBudgetLink(this._budget);

  static const unmarkedRequestPriority = CallPriority.background;

  final CallBudget _budget;

  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    final priority =
        request.context.entry<CallPriorityEntry>()?.priority ??
        unmarkedRequestPriority;

    if (!_budget.tryReserve(priority)) {
      final until = _budget.nextSlotAt(priority) ?? DateTime.now();
      developer.log(
        'presupuesto agotado para ${priority.name} hasta $until',
        name: 'sync',
      );
      return Stream.error(CallBudgetExhausted(until));
    }

    developer.log(
      'presupuesto ${_budget.used}/${CallPriority.user.hourlyLimit} '
      '(${priority.name})',
      name: 'sync',
    );
    return forward!(request);
  }
}
