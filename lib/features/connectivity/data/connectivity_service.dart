import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pokedex_flutter/features/connectivity/domain/connectivity_status.dart';

class ConnectivityService {
  final Connectivity _connectivity;
  final InternetConnection _internetConnection;

  ConnectivityService({
    Connectivity? connectivity,
    InternetConnection? internetConnection,
  })  : _connectivity = connectivity ?? Connectivity(),
        _internetConnection =
            internetConnection ?? InternetConnection();

  Future<ConnectivityStatus> checkStatus() async {
    final results = await _connectivity.checkConnectivity();

    final hasNetwork = results.any(
          (result) => result != ConnectivityResult.none,
    );

    if (!hasNetwork) {
      return ConnectivityStatus.offline;
    }

    final hasInternet =
    await _internetConnection.hasInternetAccess;

    if (!hasInternet) {
      return ConnectivityStatus.serviceUnavailable;
    }

    return ConnectivityStatus.online;
  }

  Stream<ConnectivityStatus> watchStatus() {
    late StreamController<ConnectivityStatus> controller;

    StreamSubscription<List<ConnectivityResult>>?
    connectivitySubscription;

    StreamSubscription<InternetStatus>? internetSubscription;

    Future<void> emitCurrentStatus() async {
      try {
        final status = await checkStatus();

        if (!controller.isClosed) {
          controller.add(status);
        }
      } catch (error, stackTrace) {
        if (!controller.isClosed) {
          controller.addError(error, stackTrace);
        }
      }
    }

    controller = StreamController<ConnectivityStatus>(
      onListen: () {
        connectivitySubscription =
            _connectivity.onConnectivityChanged.listen(
                  (_) => emitCurrentStatus(),
              onError: controller.addError,
            );

        internetSubscription =
            _internetConnection.onStatusChange.listen(
                  (_) => emitCurrentStatus(),
              onError: controller.addError,
            );

        emitCurrentStatus();
      },
      onCancel: () async {
        await connectivitySubscription?.cancel();
        await internetSubscription?.cancel();
      },
    );

    return controller.stream;
  }
}