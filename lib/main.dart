import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pokedex_flutter/core/sync/sync_providers.dart';
import 'package:pokedex_flutter/features/connectivity/presentation/connectivity_banner.dart';

import 'package:pokedex_flutter/features/catalog/data/catalog_data_providers.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/pokemon_detail_providers.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';
import 'package:pokedex_flutter/features/settings/presentation/providers/settings_providers.dart';
import 'package:pokedex_flutter/features/navigation/presentation/screens/main_navigation_screen.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        catalogRepositoryProvider.overrideWith(
          (ref) => ref.watch(offlineFirstCatalogRepositoryProvider),
        ),
        pokemonDetailRepositoryProvider.overrideWith(
          (ref) => ref.watch(offlineFirstPokemonDetailRepositoryProvider),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider).value ?? 'system';
    final theme = ref.watch(themeProvider).value ?? 'system';

    final locale = switch (language) {
      'es' => const Locale('es'),
      'en' => const Locale('en'),
      _ => null,
    };

    final themeMode = switch (theme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return MaterialApp(
      locale: locale,
      themeMode: themeMode,

      title: 'Pokédex',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Material(
          color: Theme.of(context).colorScheme.surface,
          child: SafeArea(
            top: true,
            bottom: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ConnectivityBanner(),
                Expanded(child: child ?? const SizedBox.shrink()),
              ],
            ),
          ),
        );
      },

      home: const SyncLifecycle(child: MainNavigationScreen()),
    );
  }
}

class SyncLifecycle extends ConsumerWidget {
  const SyncLifecycle({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(syncSchedulerProvider);
    ref.watch(catalogSyncTriggersProvider);
    return child;
  }
}
