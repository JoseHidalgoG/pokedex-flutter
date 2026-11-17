import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:graphql/client.dart';

import 'package:pokedex_flutter/features/connectivity/domain/connectivity_status.dart';

class ConnectivityService {
  final Connectivity _connectivity;
  final GraphQLClient _graphQLClient;

  final List<Duration> _unavailableServiceRecheckDelays;

  ConnectivityService({
    Connectivity? connectivity,
    required this._graphQLClient,
    this._unavailableServiceRecheckDelays =
        defaultUnavailableServiceRecheckDelays,
  }) : assert(_unavailableServiceRecheckDelays.isNotEmpty),
       _connectivity = connectivity ?? Connectivity();

  static const defaultUnavailableServiceRecheckDelays = [
    Duration(seconds: 15),
    Duration(seconds: 30),
    Duration(seconds: 60),
    Duration(seconds: 120),
    Duration(minutes: 5),
  ];

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
    var consecutiveUnavailableChecks = 0;

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
            _delayBeforeRecheck(consecutiveUnavailableChecks),
            emitCurrentStatus,
          );
          consecutiveUnavailableChecks++;
        } else {
          consecutiveUnavailableChecks = 0;
        }
      } catch (error, stackTrace) {
        if (!controller.isClosed && currentSequence == checkSequence) {
          controller.addError(error, stackTrace);
        }
      }
    }

    void recheckFromFirstDelayAfterNetworkChange(List<ConnectivityResult> _) {
      consecutiveUnavailableChecks = 0;
      emitCurrentStatus();
    }

    controller = StreamController<ConnectivityStatus>(
      onListen: () {
        connectivitySubscription = _connectivity.onConnectivityChanged.listen(
          recheckFromFirstDelayAfterNetworkChange,
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

  Duration _delayBeforeRecheck(int consecutiveUnavailableChecks) {
    final delays = _unavailableServiceRecheckDelays;
    return delays[min(consecutiveUnavailableChecks, delays.length - 1)];
  }
}
