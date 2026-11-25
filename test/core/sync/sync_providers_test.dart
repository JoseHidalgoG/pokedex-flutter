import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/core/database/app_database_provider.dart';
import 'package:pokedex_flutter/core/sync/sync_providers.dart';
import 'package:pokedex_flutter/features/connectivity/connectivity_providers.dart';
import 'package:pokedex_flutter/features/connectivity/domain/connectivity_status.dart';

void main() {
  late AppDatabase database;
  late StreamController<ConnectivityStatus> connectivity;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    connectivity = StreamController<ConnectivityStatus>();
  });

  tearDown(() async {
    await connectivity.close();
    await database.close();
  });

  test('el planificador sabe si hay red aunque PokeAPI no responda', () async {
    final container = ProviderContainer.test(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        connectivityStatusProvider.overrideWith((ref) => connectivity.stream),
      ],
    );
    final scheduler = container.listen(syncSchedulerProvider, (_, _) {}).read();

    Future<(bool, bool)> schedulerAfter(ConnectivityStatus status) async {
      connectivity.add(status);
      await pumpEventQueue();
      return (scheduler.isOnline, scheduler.hasNetwork);
    }

    expect(await schedulerAfter(ConnectivityStatus.serviceUnavailable), (
      false,
      true,
    ));
    expect(await schedulerAfter(ConnectivityStatus.offline), (false, false));
    expect(await schedulerAfter(ConnectivityStatus.online), (true, true));
  });
}
