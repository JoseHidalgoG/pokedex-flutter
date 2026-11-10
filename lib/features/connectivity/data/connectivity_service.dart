import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:graphql/client.dart';

import 'package:pokedex_flutter/features/connectivity/domain/connectivity_status.dart';

class ConnectivityService {
  final Connectivity _connectivity;
  final GraphQLClient _graphQLClient;

  ConnectivityService({
    Connectivity? connectivity,
    required this._graphQLClient,
  }) : _connectivity = connectivity ?? Connectivity();

  static const _healthCheckTimeout = Duration(seconds: 5);

  static final _healthCheckQuery = gql('''
    query ConnectivityHealthCheck {
      pokemon(limit: 1) {
        id
      }
    }
  ''');

  Future<ConnectivityStatus> checkStatus() async {
    final results = await _connectivity.checkConnectivity();

    final hasNetwork = results.any(
      (result) => result != ConnectivityResult.none,
    );

    if (!hasNetwork) {
      return ConnectivityStatus.offline;
    }

    try {
      final result = await _graphQLClient
          .query(
            QueryOptions(
              document: _healthCheckQuery,
              fetchPolicy: FetchPolicy.noCache,
            ),
          )
          .timeout(_healthCheckTimeout);

      final pokemon = result.data?['pokemon'];

      final apiResponded = result.exception == null && pokemon is List;

      return apiResponded
          ? ConnectivityStatus.online
          : ConnectivityStatus.serviceUnavailable;
    } catch (_) {
      return ConnectivityStatus.serviceUnavailable;
    }
  }

  Stream<ConnectivityStatus> watchStatus() {
    late StreamController<ConnectivityStatus> controller;

    StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;

    var checkSequence = 0;

    Future<void> emitCurrentStatus() async {
      final currentSequence = ++checkSequence;

      try {
        final status = await checkStatus();

        // Evita emitir resultados antiguos si hay varias
        // comprobaciones ejecutándose simultáneamente.
        if (!controller.isClosed && currentSequence == checkSequence) {
          controller.add(status);
        }
      } catch (error, stackTrace) {
        if (!controller.isClosed && currentSequence == checkSequence) {
          controller.addError(error, stackTrace);
        }
      }
    }

    controller = StreamController<ConnectivityStatus>(
      onListen: () {
        connectivitySubscription = _connectivity.onConnectivityChanged.listen(
          (_) => emitCurrentStatus(),
          onError: controller.addError,
        );

        emitCurrentStatus();
      },
      onCancel: () async {
        // Invalida cualquier comprobación que siga ejecutándose.
        checkSequence++;
        await connectivitySubscription?.cancel();
      },
    );

    return controller.stream;
  }
}
