import 'package:pokedex_flutter/features/connectivity/domain/connectivity_repository.dart';
import 'package:pokedex_flutter/features/connectivity/domain/connectivity_status.dart';
import 'package:pokedex_flutter/features/connectivity/data/connectivity_service.dart';

class ConnectivityRepositoryImpl implements ConnectivityRepository {
  final ConnectivityService _connectivityService;

  ConnectivityRepositoryImpl({
    required this._connectivityService,
  });

  @override
  Future<ConnectivityStatus> checkStatus() {
    return _connectivityService.checkStatus();
  }

  @override
  Stream<ConnectivityStatus> watchStatus() {
    return _connectivityService.watchStatus();
  }
}
