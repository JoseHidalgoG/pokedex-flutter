import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/features/connectivity/data/connectivity_repository_impl.dart';
import 'package:pokedex_flutter/features/connectivity/data/connectivity_service.dart';
import 'package:pokedex_flutter/features/connectivity/domain/connectivity_repository.dart';
import 'package:pokedex_flutter/features/connectivity/domain/connectivity_status.dart';

final connectivityServiceProvider =
Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final connectivityRepositoryProvider =
Provider<ConnectivityRepository>((ref) {
  final service = ref.watch(connectivityServiceProvider);

  return ConnectivityRepositoryImpl(
    connectivityService: service,
  );
});

final connectivityStatusProvider =
StreamProvider<ConnectivityStatus>((ref) {
  final repository = ref.watch(connectivityRepositoryProvider);

  return repository.watchStatus();
});
