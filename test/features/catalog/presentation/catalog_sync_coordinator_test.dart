import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/sync_catalog.dart';
import 'package:pokedex_flutter/features/catalog/presentation/catalog_sync_coordinator.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:pokedex_flutter/features/connectivity/connectivity_providers.dart';
import 'package:pokedex_flutter/features/connectivity/domain/connectivity_status.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

void main() {
  late MockCatalogRepository mockRepository;
  late StreamController<ConnectivityStatus> connectivityController;

  setUp(() {
    mockRepository = MockCatalogRepository();

    connectivityController = StreamController<ConnectivityStatus>.broadcast();

    when(() => mockRepository.syncCatalog()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await connectivityController.close();
  });

  Future<void> pumpCoordinator(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncCatalogProvider.overrideWith(
            (ref) => SyncCatalog(mockRepository),
          ),
          connectivityStatusProvider.overrideWith(
            (ref) => connectivityController.stream,
          ),
        ],
        child: const MaterialApp(
          home: CatalogSyncCoordinator(
            child: Scaffold(body: Text('Catálogo de prueba')),
          ),
        ),
      ),
    );

    await tester.pump();
  }

  testWidgets('inicia la sincronización al abrir la aplicación', (
    tester,
  ) async {
    await pumpCoordinator(tester);

    verify(() => mockRepository.syncCatalog()).called(1);
  });

  testWidgets('sincroniza nuevamente cuando se recupera Internet', (
    tester,
  ) async {
    await pumpCoordinator(tester);

    verify(() => mockRepository.syncCatalog()).called(1);

    connectivityController.add(ConnectivityStatus.offline);
    await tester.pump();
    await tester.pump();

    verifyNever(() => mockRepository.syncCatalog());

    connectivityController.add(ConnectivityStatus.online);
    await tester.pump();
    await tester.pump();

    verify(() => mockRepository.syncCatalog()).called(1);
  });

  testWidgets('no sincroniza nuevamente si la conexión sigue online', (
    tester,
  ) async {
    await pumpCoordinator(tester);

    verify(() => mockRepository.syncCatalog()).called(1);

    connectivityController.add(ConnectivityStatus.online);
    await tester.pump();
    await tester.pump();

    verifyNever(() => mockRepository.syncCatalog());

    connectivityController.add(ConnectivityStatus.online);
    await tester.pump();
    await tester.pump();

    verifyNever(() => mockRepository.syncCatalog());
  });
}
