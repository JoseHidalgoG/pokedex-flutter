import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/core/network/api_outage_simulation.dart';
import 'package:pokedex_flutter/features/settings/presentation/providers/demo_tools_providers.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

class DemoToolsSection extends ConsumerWidget {
  const DemoToolsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final simulationMode = ref.watch(apiOutageSimulationModeProvider);
    if (simulationMode == ApiOutageSimulationMode.unavailable) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context)!;
    final isOutageSimulated = ref.watch(apiOutageSimulationProvider);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(l10n.demoToolsTitle),
            subtitle: Text(l10n.demoToolsDescription),
          ),
          SwitchListTile(
            title: Text(l10n.simulateApiOutage),
            subtitle: Text(l10n.simulateApiOutageDescription),
            value: isOutageSimulated.value ?? false,
            onChanged: isOutageSimulated.hasValue
                ? (isSimulated) => _simulateApiOutage(context, ref, isSimulated)
                : null,
          ),
        ],
      ),
    );
  }

  static Future<void> _simulateApiOutage(
    BuildContext context,
    WidgetRef ref,
    bool isSimulated,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(simulateApiOutageProvider)(isSimulated);
    } on Exception {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.simulateApiOutageSaveError)));
    }
  }
}
