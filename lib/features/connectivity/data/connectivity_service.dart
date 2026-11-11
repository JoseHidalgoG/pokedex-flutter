import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:graphql/client.dart';

import 'package:pokedex_flutter/features/connectivity/domain/connectivity_status.dart';

class ConnectivityService {
  final Connectivity _connectivity;
  final GraphQLClient _graphQLClient;

  final Duration _unavailableServiceRecheckInterval;

  ConnectivityService({
    Connectivity? connectivity,
    required this._graphQLClient,
    this._unavailableServiceRecheckInterval =
        defaultUnavailableServiceRecheckInterval,
  }) : _connectivity = connectivity ?? Connectivity();

  static const defaultUnavailableServiceRecheckInterval = Duration(
    seconds: 15,
  );

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
    Timer? unavailableServiceRecheck;

    var checkSequence = 0;

    Future<void> emitCurrentStatus() async {
      unavailableServiceRecheck?.cancel();
      final currentSequence = ++checkSequence;

      try {
        final status = await checkStatus();

        if (controller.isClosed || currentSequence != checkSequence) {
          return;
        }

        controller.add(status);

        if (status == ConnectivityStatus.serviceUnavailable) {
          unavailableServiceRecheck = Timer(
            _unavailableServiceRecheckInterval,
            emitCurrentStatus,
          );
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
        checkSequence++;
        unavailableServiceRecheck?.cancel();
        await connectivitySubscription?.cancel();
      },
    );

    return controller.stream;
  }
}
