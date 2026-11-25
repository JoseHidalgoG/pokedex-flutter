import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokedex_flutter/core/network/api_outage_simulation.dart';
import 'package:pokedex_flutter/core/network/pokeapi_graphql_client_provider.dart';
import 'package:pokedex_flutter/features/connectivity/connectivity_providers.dart';
import 'package:pokedex_flutter/features/connectivity/data/connectivity_service.dart';
import 'package:pokedex_flutter/features/connectivity/domain/connectivity_status.dart';
import 'package:pokedex_flutter/features/settings/presentation/providers/demo_tools_providers.dart';
import 'package:pokedex_flutter/features/settings/presentation/providers/settings_providers.dart';

import '../../../../core/network/fakes/fake_pokeapi_network.dart';
import '../../fakes/fake_settings_repository.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late FakeSettingsRepository settings;
  late FakePokeApiNetwork network;
  late MockConnectivity wifi;

  setUp(() {
    settings = FakeSettingsRepository();
    network = FakePokeApiNetwork();
    wifi = MockConnectivity();
    when(() => wifi.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.wifi]);
    when(() => wifi.onConnectivityChanged)
        .thenAnswer((_) => const Stream.empty());
  });

  tearDown(() async {
    await settings.dispose();
  });

  ProviderContainer watchingConnectivity() {
    final container = ProviderContainer.test(
      overrides: [
        apiOutageSimulationModeProvider.overrideWithValue(
          ApiOutageSimulationMode.fromSettings,
        ),
        settingsRepositoryProvider.overrideWithValue(settings),
        pokeApiHttpClientProvider.overrideWithValue(network.client),
        connectivityServiceProvider.overrideWith(
          (ref) => ConnectivityService(
            connectivity: wifi,
            graphQLClient: ref.watch(pokeApiGraphQLClientProvider),
          ),
        ),
      ],
    );
    container.listen(connectivityStatusProvider, (_, _) {});
    return container;
  }

  Future<ConnectivityStatus> statusIn(ProviderContainer container) {
    return container.read(connectivityStatusProvider.future);
  }

  test('activarla vuelve a comprobar la salud y PokeAPI deja de estar '
      'disponible sin tocar la red', () async {
    final container = watchingConnectivity();
    expect(await statusIn(container), ConnectivityStatus.online);
    expect(network.requests, 1);

    await container.read(simulateApiOutageProvider)(true);

    expect(await statusIn(container), ConnectivityStatus.serviceUnavailable);
    expect(network.requests, 1);
    expect(settings.apiOutageSimulated, isTrue);
  });

  test('apagarla vuelve a En línea con una comprobación real', () async {
    settings.apiOutageSimulated = true;
    final container = watchingConnectivity();
    expect(await statusIn(container), ConnectivityStatus.serviceUnavailable);
    expect(network.requests, 0);

    await container.read(simulateApiOutageProvider)(false);

    expect(await statusIn(container), ConnectivityStatus.online);
    expect(network.requests, 1);
    expect(settings.apiOutageSimulated, isFalse);
  });

  test('si no se puede guardar, la simulación se aplica igual y el error '
      'llega a quien la cambió', () async {
    settings.apiOutageSaveError = Exception('disco lleno');
    final container = watchingConnectivity();
    expect(await statusIn(container), ConnectivityStatus.online);

    await expectLater(
      container.read(simulateApiOutageProvider)(true),
      throwsException,
    );

    expect(container.read(apiOutageSimulationProvider).value, isTrue);
    expect(await statusIn(container), ConnectivityStatus.serviceUnavailable);
    expect(settings.apiOutageSimulated, isFalse);
  });
}
