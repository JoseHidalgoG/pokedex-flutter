import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:pokedex_flutter/features/catalog/presentation/screens/pokemon_detail_screen.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/pokemon_list_item.dart';
import 'package:pokedex_flutter/features/favorites/presentation/providers/favorites_providers.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;
  bool _showSearch = false;
  String _search = '';

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    setState(() {});

    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      setState(() {
        _search = value.trim().toLowerCase();
      });
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();

    setState(() {
      _search = '';
    });
  }

  List<Pokemon> _filterFavorites(List<Pokemon> pokemon) {
    if (_search.isEmpty) {
      return pokemon;
    }

    return pokemon.where((item) {
      final nameMatches = item.name.toLowerCase().contains(_search);

      final numberMatches = int.tryParse(_search) == item.id;

      return nameMatches || numberMatches;
    }).toList();
  }

  Widget _buildNoResults() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 56),
            const SizedBox(height: 16),
            Text(
              l10n.catalogNoResults,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(l10n.catalogNoResultsMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _clearSearch,
              child: Text(l10n.catalogClearFilters),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final favoriteIdsAsync = ref.watch(favoriteIdsProvider);
    final catalogAsync = ref.watch(catalogProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.favoritesTitle),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: _showSearch
                ? l10n.catalogHideSearch
                : l10n.catalogShowSearch,
            icon: Icon(_showSearch ? Icons.search_off : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: l10n.catalogSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          tooltip: l10n.catalogClearFilters,
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.close),
                        )
                      : null,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          Expanded(
            child: favoriteIdsAsync.when(
              data: (ids) {
                if (ids.isEmpty) {
                  return const _FavoritesEmptyState();
                }

                return catalogAsync.when(
                  data: (catalog) {
                    final favoriteIds = ids.toSet();

                    final favoritePokemon = catalog
                        .where((pokemon) => favoriteIds.contains(pokemon.id))
                        .toList();

                    if (favoritePokemon.isEmpty) {
                      return Center(
                        child: Text(
                          l10n.favoritePokemonNotFound,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final filteredPokemon = _filterFavorites(favoritePokemon);

                    if (filteredPokemon.isEmpty) {
                      return _buildNoResults();
                    }

                    return _FavoritesList(pokemonList: filteredPokemon);
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) =>
                      Center(child: Text(l10n.favoritePokemonLoadError)),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text(l10n.favoritesLoadError)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}

class _FavoritesList extends StatelessWidget {
  const _FavoritesList({required this.pokemonList});

  final List<Pokemon> pokemonList;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: pokemonList.length,
      itemBuilder: (context, index) {
        final pokemon = pokemonList[index];

        return PokemonListItem(
          pokemon: pokemon,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PokemonDetailScreen(pokemon: pokemon),
              ),
            );
          },
        );
      },
    );
  }
}

class _FavoritesEmptyState extends StatelessWidget {
  const _FavoritesEmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border,
              size: 72,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noFavoritesTitle,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(l10n.noFavoritesMessage, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
