import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/data/catalog_data_providers.dart';
import 'package:pokedex_flutter/features/connectivity/connectivity_providers.dart';
import 'package:pokedex_flutter/features/connectivity/domain/connectivity_repository.dart';
import 'package:pokedex_flutter/features/connectivity/domain/connectivity_status.dart';

class FixedConnectivityRepository implements ConnectivityRepository {
  FixedConnectivityRepository(this.status);

  final ConnectivityStatus status;

  @override
  Future<ConnectivityStatus> checkStatus() async => status;

  @override
  Stream<ConnectivityStatus> watchStatus() => Stream.value(status);
}

void main() {
  Future<bool> catalogSeesInternetWhen(ConnectivityStatus status) {
    final container = ProviderContainer(
      overrides: [
        connectivityRepositoryProvider.overrideWithValue(
          FixedConnectivityRepository(status),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container.read(catalogInternetAccessCheckProvider)();
  }

  test('la sincronización usa la misma comprobación que el banner', () async {
    expect(await catalogSeesInternetWhen(ConnectivityStatus.online), isTrue);
    expect(await catalogSeesInternetWhen(ConnectivityStatus.offline), isFalse);
  });

  test(
    'intenta sincronizar cuando hay red aunque el servicio no responda',
    () async {
      expect(
        await catalogSeesInternetWhen(ConnectivityStatus.serviceUnavailable),
        isTrue,
      );
    },
  );
}
