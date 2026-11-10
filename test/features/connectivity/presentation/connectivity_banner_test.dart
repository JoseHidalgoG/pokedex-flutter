import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pokedex_flutter/features/connectivity/connectivity_providers.dart';
import 'package:pokedex_flutter/features/connectivity/domain/connectivity_status.dart';
import 'package:pokedex_flutter/features/connectivity/presentation/connectivity_banner.dart';

import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_sync_status.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_providers.dart';

Widget buildBanner({
  required ConnectivityStatus connectivityStatus,
  CatalogSyncStatus syncStatus = const CatalogSyncIdle(),
  DateTime? lastSyncAt,
}) {
  return ProviderScope(
    overrides: [
      connectivityStatusProvider.overrideWith(
            (ref) => Stream.value(connectivityStatus),
      ),
      catalogSyncStatusProvider.overrideWith(
            (ref) => Stream.value(syncStatus),
      ),
      lastCatalogSyncProvider.overrideWith(
            (ref) async => lastSyncAt,
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: ConnectivityBanner(),
      ),
    ),
  );
}

void main() {
  group('ConnectivityBanner', () {
    testWidgets('muestra el estado online', (tester) async {
      await tester.pumpWidget(
        buildBanner(
          connectivityStatus: ConnectivityStatus.online,
        ),
      );

      await tester.pump();

      expect(find.text('En línea'), findsOneWidget);
      expect(find.textContaining('API disponible'), findsOneWidget);
    });

    testWidgets('muestra el estado offline', (tester) async {
      await tester.pumpWidget(
        buildBanner(
          connectivityStatus: ConnectivityStatus.offline,
        ),
      );

      await tester.pump();

      expect(find.text('Sin conexión'), findsOneWidget);
      expect(find.textContaining('Datos locales'), findsOneWidget);
    });

    testWidgets('muestra cuando el servicio no está disponible',
            (tester) async {
          await tester.pumpWidget(
            buildBanner(
              connectivityStatus: ConnectivityStatus.serviceUnavailable,
            ),
          );

          await tester.pump();

          expect(find.text('Servicio no disponible'), findsOneWidget);
          expect(find.textContaining('API sin respuesta'), findsOneWidget);
        });

    testWidgets('muestra el indicador durante la sincronización',
            (tester) async {
          await tester.pumpWidget(
            buildBanner(
              connectivityStatus: ConnectivityStatus.online,
              syncStatus: const CatalogSyncInProgress(),
            ),
          );

          await tester.pump();

          expect(find.text('Sincronizando...'), findsOneWidget);
          expect(find.byType(LinearProgressIndicator), findsOneWidget);
        });

    testWidgets('muestra la fecha de la última sincronización',
            (tester) async {
          await tester.pumpWidget(
            buildBanner(
              connectivityStatus: ConnectivityStatus.offline,
              lastSyncAt: DateTime(2026, 11, 10, 9, 15),
            ),
          );

          await tester.pump();

          expect(find.text('Sin conexión'), findsOneWidget);
          expect(find.textContaining('10/11 · 09:15'), findsOneWidget);
        });

    testWidgets('muestra el mensaje cuando falla la sincronización',
            (tester) async {
          await tester.pumpWidget(
            buildBanner(
              connectivityStatus: ConnectivityStatus.offline,
              syncStatus: const CatalogSyncFailed(
                CatalogSyncFailureReason.noConnection,
              ),
            ),
          );

          await tester.pump();

          expect(find.text('Sin conexión'), findsOneWidget);
          expect(
            find.textContaining('No se pudo sincronizar'),
            findsOneWidget,
          );
        });

    testWidgets('expone el estado mediante Semantics', (tester) async {
      await tester.pumpWidget(
        buildBanner(
          connectivityStatus: ConnectivityStatus.online,
        ),
      );

      await tester.pump();

      final semanticsFinder = find.byWidgetPredicate(
            (widget) =>
        widget is Semantics &&
            widget.properties.liveRegion == true &&
            widget.properties.label?.contains('En línea') == true,
      );

      expect(semanticsFinder, findsOneWidget);
    });
  });
}