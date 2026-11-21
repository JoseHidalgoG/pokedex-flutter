import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:gql/ast.dart';
import 'package:graphql/client.dart';
import 'package:pokedex_flutter/core/network/call_budget_link.dart';

typedef LogWriter = void Function(String message);

const unnamedOperation = 'consulta sin nombre';

void _writeToDeveloperLog(String message) {
  developer.log(message, name: 'pokeapi');
}

class LoggingLink extends Link {
  LoggingLink({this._write = _writeToDeveloperLog});

  final LogWriter _write;

  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    final description = _describe(request);
    final stopwatch = Stopwatch()..start();
    return forward!(request).transform(
      StreamTransformer.fromHandlers(
        handleData: (response, sink) {
          final graphqlErrors = response.errors?.length ?? 0;
          _write(
            '$description ${stopwatch.elapsedMilliseconds} ms'
            '${graphqlErrors == 0 ? '' : ' con $graphqlErrors errores'}',
          );
          sink.add(response);
        },
        handleError: (error, stackTrace, sink) {
          _write(
            '$description falló en ${stopwatch.elapsedMilliseconds} ms: '
            '$error',
          );
          sink.addError(error, stackTrace);
        },
      ),
    );
  }

  static String _describe(Request request) {
    final priority =
        request.context.entry<CallPriorityEntry>()?.priority ??
        CallBudgetLink.unmarkedRequestPriority;
    return '${_operationNameOf(request.operation)} '
        '${jsonEncode(request.variables)} (${priority.name})';
  }

  static String _operationNameOf(Operation operation) {
    final namedOperation = operation.operationName;
    if (namedOperation != null) {
      return namedOperation;
    }
    final definitions = operation.document.definitions
        .whereType<OperationDefinitionNode>();
    return definitions.firstOrNull?.name?.value ?? unnamedOperation;
  }
}
