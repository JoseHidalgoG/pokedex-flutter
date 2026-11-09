import 'package:pokedex_flutter/features/connectivity/domain/connectivity_status.dart';

abstract class ConnectivityRepository {
  Future<ConnectivityStatus> checkStatus();
  Stream<ConnectivityStatus> watchStatus();
}
