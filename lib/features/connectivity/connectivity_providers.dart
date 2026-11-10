import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pokedex_flutter/features/connectivity/data/connectivity_repository_impl.dart';
import 'package:pokedex_flutter/features/connectivity/data/connectivity_service.dart';
import 'package:pokedex_flutter/features/connectivity/domain/connectivity_repository.dart';
import 'package:pokedex_flutter/features/connectivity/domain/connectivity_status.dart';
import 'package:pokedex_flutter/core/network/pokeapi_graphql_client_provider.dart';

const _connectivityDebounceDuration = Duration(seconds: 2);

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final graphQLClient = ref.watch(pokeApiGraphQLClientProvider);

  return ConnectivityService(graphQLClient: graphQLClient);
});

final connectivityRepositoryProvider = Provider<ConnectivityRepository>((ref) {
  final service = ref.watch(connectivityServiceProvider);

  return ConnectivityRepositoryImpl(connectivityService: service);
});

final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  final repository = ref.watch(connectivityRepositoryProvider);

  return _stabilizeConnectivity(
    repository.watchStatus(),
    _connectivityDebounceDuration,
  );
});

Stream<ConnectivityStatus> _stabilizeConnectivity(
  Stream<ConnectivityStatus> source,
  Duration duration,
) {
  late final StreamController<ConnectivityStatus> controller;

  StreamSubscription<ConnectivityStatus>? subscription;
  Timer? debounceTimer;

  ConnectivityStatus? lastEmitted;
  ConnectivityStatus? pendingStatus;

  bool hasEmittedFirstStatus = false;

  controller = StreamController<ConnectivityStatus>(
    onListen: () {
      subscription = source.listen(
        (status) {
          if (!hasEmittedFirstStatus) {
            hasEmittedFirstStatus = true;
            lastEmitted = status;
            controller.add(status);
            return;
          }

          if (status == lastEmitted) {
            debounceTimer?.cancel();
            pendingStatus = null;
            return;
          }

          pendingStatus = status;

          debounceTimer?.cancel();

          debounceTimer = Timer(duration, () {
            final stableStatus = pendingStatus;

            if (stableStatus == null || controller.isClosed) {
              return;
            }

            if (stableStatus != lastEmitted) {
              lastEmitted = stableStatus;
              controller.add(stableStatus);
            }

            pendingStatus = null;
          });
        },
        onError: (Object error, StackTrace stackTrace) {
          controller.addError(error, stackTrace);
        },
        onDone: () {
          debounceTimer?.cancel();

          if (pendingStatus != null && !controller.isClosed) {
            lastEmitted = pendingStatus;
            controller.add(pendingStatus!);
            pendingStatus = null;
          }

          controller.close();
        },
      );
    },
    onCancel: () async {
      debounceTimer?.cancel();
      pendingStatus = null;
      await subscription?.cancel();
    },
  );

  return controller.stream;
}
