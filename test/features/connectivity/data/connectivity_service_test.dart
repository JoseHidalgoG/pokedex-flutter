import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pokedex_flutter/features/connectivity/data/connectivity_service.dart';
import 'package:pokedex_flutter/features/connectivity/domain/connectivity_status.dart';

class MockConnectivity extends Mock implements Connectivity {}

class MockInternetConnection extends Mock
    implements InternetConnection {}

void main() {
  late MockConnectivity mockConnectivity;
  late MockInternetConnection mockInternetConnection;
  late ConnectivityService service;

  setUp(() {
    mockConnectivity = MockConnectivity();
    mockInternetConnection = MockInternetConnection();

    service = ConnectivityService(
      connectivity: mockConnectivity,
      internetConnection: mockInternetConnection,
    );
  });

  test('returns offline when there is no network connection', () async {
    when(() => mockConnectivity.checkConnectivity()).thenAnswer(
          (_) async => [ConnectivityResult.none],
    );

    final result = await service.checkStatus();

    expect(result, ConnectivityStatus.offline);

    verify(() => mockConnectivity.checkConnectivity()).called(1);
    verifyNever(() => mockInternetConnection.hasInternetAccess);
  });

  test('returns serviceUnavailable when network exists but internet is unavailable', () async {
    when(() => mockConnectivity.checkConnectivity()).thenAnswer(
          (_) async => [ConnectivityResult.wifi],
    );

    when(() => mockInternetConnection.hasInternetAccess).thenAnswer(
          (_) async => false,
    );

    final result = await service.checkStatus();

    expect(result, ConnectivityStatus.serviceUnavailable);
  });

  test('returns online when network and internet are available', () async {
    when(() => mockConnectivity.checkConnectivity()).thenAnswer(
          (_) async => [ConnectivityResult.wifi],
    );

    when(() => mockInternetConnection.hasInternetAccess).thenAnswer(
          (_) async => true,
    );

    final result = await service.checkStatus();

    expect(result, ConnectivityStatus.online);
  });
}