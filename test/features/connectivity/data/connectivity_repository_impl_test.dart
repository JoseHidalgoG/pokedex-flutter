import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pokedex_flutter/features/connectivity/data/connectivity_repository_impl.dart';
import 'package:pokedex_flutter/features/connectivity/data/connectivity_service.dart';
import 'package:pokedex_flutter/features/connectivity/domain/connectivity_status.dart';

class MockConnectivityService extends Mock
    implements ConnectivityService {}

void main() {
  late MockConnectivityService mockService;
  late ConnectivityRepositoryImpl repository;

  setUp(() {
    mockService = MockConnectivityService();

    repository = ConnectivityRepositoryImpl(
      connectivityService: mockService,
    );
  });

  test('delegates checkStatus to the connectivity service', () async {
    when(() => mockService.checkStatus()).thenAnswer(
          (_) async => ConnectivityStatus.online,
    );

    final result = await repository.checkStatus();

    expect(result, ConnectivityStatus.online);

    verify(() => mockService.checkStatus()).called(1);
  });

  test('delegates watchStatus to the connectivity service', () async {
    final statuses = Stream<ConnectivityStatus>.fromIterable([
      ConnectivityStatus.online,
      ConnectivityStatus.offline,
    ]);

    when(() => mockService.watchStatus()).thenAnswer(
          (_) => statuses,
    );

    final result = await repository.watchStatus().toList();

    expect(result, [
      ConnectivityStatus.online,
      ConnectivityStatus.offline,
    ]);

    verify(() => mockService.watchStatus()).called(1);
  });
}