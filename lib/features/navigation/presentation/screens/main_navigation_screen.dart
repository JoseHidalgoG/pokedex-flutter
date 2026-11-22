import 'package:flutter/material.dart';

import 'package:pokedex_flutter/features/catalog/presentation/screens/catalog_screen.dart';
import 'package:pokedex_flutter/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:pokedex_flutter/features/settings/presentation/screens/settings_screen.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _selectedIndex == 0) return;

        setState(() {
          _selectedIndex = 0;
        });
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: const [
            CatalogScreen(),
            FavoritesScreen(),
            _TriviaPlaceholderScreen(),
            SettingsScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.catching_pokemon_outlined),
              selectedIcon: const Icon(Icons.catching_pokemon),
              label: l10n.navigationCatalog,
            ),
            NavigationDestination(
              icon: const Icon(Icons.favorite_border),
              selectedIcon: const Icon(Icons.favorite),
              label: l10n.navigationFavorites,
            ),
            NavigationDestination(
              icon: const Icon(Icons.quiz_outlined),
              selectedIcon: const Icon(Icons.quiz),
              label: l10n.navigationTrivia,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: l10n.navigationSettings,
            ),
          ],
        ),
      ),
    );
  }
}

class _TriviaPlaceholderScreen extends StatelessWidget {
  const _TriviaPlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navigationTrivia), centerTitle: true),
      body: Center(child: Text(l10n.triviaComingSoon)),
    );
  }
}
