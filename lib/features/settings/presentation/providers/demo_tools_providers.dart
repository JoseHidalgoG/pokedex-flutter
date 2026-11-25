import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/core/network/api_outage_simulation.dart';
import 'package:pokedex_flutter/features/connectivity/connectivity_providers.dart';
import 'package:pokedex_flutter/features/settings/presentation/providers/settings_providers.dart';

final simulateApiOutageProvider = Provider<Future<void> Function(bool)>(
  (ref) => (isSimulated) async {
    ref.read(apiOutageSimulationProvider.notifier).switchTo(isSimulated);
    ref.invalidate(connectivityStatusProvider);
    await ref
        .read(settingsRepositoryProvider)
        .setApiOutageSimulated(isSimulated);
  },
);
