import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pokedex_flutter/features/connectivity/presentation/connectivity_banner.dart';

import 'package:pokedex_flutter/features/catalog/data/catalog_data_providers.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_providers.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        catalogRepositoryProvider.overrideWith(
              (ref) => ref.watch(offlineFirstCatalogRepositoryProvider),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Column(
          children: [
            const ConnectivityBanner(),
            Expanded(
              child: child ?? const SizedBox.shrink(),
            ),
          ],
        );
      },
      home: const Scaffold(
        body: Center(
          child: Text('Pokédex'),
        ),
      ),
    );
  }
}