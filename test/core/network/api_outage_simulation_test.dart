import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:pokedex_flutter/core/network/api_outage_simulation.dart';
import 'package:pokedex_flutter/core/network/pokeapi_graphql_client_provider.dart';
import 'package:pokedex_flutter/core/sync/data/sync_failure_translator.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';
import 'package:pokedex_flutter/features/settings/presentation/providers/settings_providers.dart';

import '../../features/settings/fakes/fake_settings_repository.dart';
import 'fakes/fake_pokeapi_network.dart';

class SettingsLoadedLater extends FakeSettingsRepository {
  final savedOutageSimulation = Completer<bool>();

  @override
  Future<bool> isApiOutageSimulated() => savedOutageSimulation.future;
}

class UnreadableSettings extends FakeSettingsRepository {
  @override
  Future<bool> isApiOutageSimulated() async {
    throw Exception('no se pudo abrir la base de datos');
  }
}

void main() {
  late FakeSettingsRepository settings;
  late FakePokeApiNetwork network;

  setUp(() {
    settings = FakeSettingsRepository();
    network = FakePokeApiNetwork();
  });

  tearDown(() async {
    await settings.dispose();
  });

  ProviderContainer containerFor(
    ApiOutageSimulationMode mode, {
    FakeSettingsRepository? savedIn,
  }) {
    return ProviderContainer.test(
      overrides: [
        apiOutageSimulationModeProvider.overrideWithValue(mode),
        settingsRepositoryProvider.overrideWithValue(savedIn ?? settings),
        pokeApiHttpClientProvider.overrideWithValue(network.client),
      ],
    );
  }

  Future<bool> outageSimulatedIn(ProviderContainer container) {
    return container.read(apiOutageSimulationProvider.future);
  }

  Future<QueryResult> probeThrough(ProviderContainer container) {
    return probe(container.read(pokeApiGraphQLClientProvider));
  }

  group('valor de la simulación', () {
    test('toma el valor guardado en Ajustes', () async {
      settings.apiOutageSimulated = true;
      final container = containerFor(ApiOutageSimulationMode.fromSettings);

      expect(await outageSimulatedIn(container), isTrue);
    });

    test(
      'lanzada con SIMULATE_API_OUTAGE está activa aunque Ajustes diga que no',
      () async {
        final container = containerFor(ApiOutageSimulationMode.forcedAtLaunch);

        expect(await outageSimulatedIn(container), isTrue);
      },
    );

    test('en release está apagada aunque Ajustes diga que sí', () async {
      settings.apiOutageSimulated = true;
      final container = containerFor(ApiOutageSimulationMode.unavailable);

      expect(await outageSimulatedIn(container), isFalse);
    });

    test(
      'si Ajustes no se puede leer queda apagada y PokeAPI sigue al alcance',
      () async {
        final unreadable = UnreadableSettings();
        addTearDown(unreadable.dispose);
        final container = containerFor(
          ApiOutageSimulationMode.fromSettings,
          savedIn: unreadable,
        );

        final result = await probeThrough(container);

        expect(await outageSimulatedIn(container), isFalse);
        expect(result.hasException, isFalse);
        expect(network.requests, 1);
      },
    );

    test('switchTo cambia el valor en el acto', () async {
      final container = containerFor(ApiOutageSimulationMode.fromSettings);
      await outageSimulatedIn(container);

      container.read(apiOutageSimulationProvider.notifier).switchTo(true);

      expect(container.read(apiOutageSimulationProvider).value, isTrue);
    });
  });

  group('cliente de PokeAPI', () {
    test('la primera consulta espera el valor guardado y, si está activa, '
        'no sale a la red', () async {
      final settingsLoadedLater = SettingsLoadedLater();
      addTearDown(settingsLoadedLater.dispose);
      final container = containerFor(
        ApiOutageSimulationMode.fromSettings,
        savedIn: settingsLoadedLater,
      );
      var isAnswered = false;
      final answer = probeThrough(container)
          .whenComplete(() => isAnswered = true);

      await pumpEventQueue();
      expect(isAnswered, isFalse);

      settingsLoadedLater.savedOutageSimulation.complete(true);
      final result = await answer;
      expect(syncFailureFrom(result.exception!), const ServerError(503));
      expect(network.requests, 0);
    });

    test('con la simulación apagada la consulta llega a PokeAPI', () async {
      final container = containerFor(ApiOutageSimulationMode.fromSettings);

      final result = await probeThrough(container);

      expect(result.hasException, isFalse);
      expect(network.requests, 1);
    });

    test('tras switchTo(true) la siguiente consulta ya es simulada', () async {
      final container = containerFor(ApiOutageSimulationMode.fromSettings);
      await probeThrough(container);

      container.read(apiOutageSimulationProvider.notifier).switchTo(true);
      final result = await probeThrough(container);

      expect(syncFailureFrom(result.exception!), const ServerError(503));
      expect(network.requests, 1);
    });

    test(
      'en release la consulta va directa a PokeAPI aunque Ajustes diga que sí',
      () async {
        settings.apiOutageSimulated = true;
        final container = containerFor(ApiOutageSimulationMode.unavailable);

        final result = await probeThrough(container);

        expect(result.hasException, isFalse);
        expect(network.requests, 1);
      },
    );
  });
}
