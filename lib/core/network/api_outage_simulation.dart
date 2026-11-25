import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/features/settings/domain/repositories/settings_repository.dart';
import 'package:pokedex_flutter/features/settings/presentation/providers/settings_providers.dart';

enum ApiOutageSimulationMode { unavailable, fromSettings, forcedAtLaunch }

const simulateApiOutageDefine = 'SIMULATE_API_OUTAGE';

const apiOutageSimulationModeOfThisBuild = kReleaseMode
    ? ApiOutageSimulationMode.unavailable
    : bool.fromEnvironment(simulateApiOutageDefine)
    ? ApiOutageSimulationMode.forcedAtLaunch
    : ApiOutageSimulationMode.fromSettings;

final apiOutageSimulationModeProvider = Provider<ApiOutageSimulationMode>(
  (ref) => apiOutageSimulationModeOfThisBuild,
);

final apiOutageSimulationProvider =
    AsyncNotifierProvider<ApiOutageSimulation, bool>(ApiOutageSimulation.new);

class ApiOutageSimulation extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    return switch (ref.watch(apiOutageSimulationModeProvider)) {
      ApiOutageSimulationMode.unavailable => false,
      ApiOutageSimulationMode.forcedAtLaunch => true,
      ApiOutageSimulationMode.fromSettings => await _savedSimulationIn(
        ref.watch(settingsRepositoryProvider),
      ),
    };
  }

  void switchTo(bool isSimulated) {
    state = AsyncData(isSimulated);
  }

  static Future<bool> _savedSimulationIn(SettingsRepository settings) async {
    try {
      return await settings.isApiOutageSimulated();
    } on Exception {
      return false;
    }
  }
}
