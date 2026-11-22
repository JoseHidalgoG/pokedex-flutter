import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:pokedex_flutter/features/catalog/presentation/screens/pokemon_detail_screen.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/catalog_empty_state.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/pokemon_list_item.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_pagination.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

import 'dart:async';

import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_page_request.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/catalog_filter_bar.dart';

const _maxVisiblePageButtons = 5;
const _pageButtonSpacing = 6.0;

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  int _currentPage = 0;
  bool _syncFailureReported = false;

  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;
  String _search = '';
  String? _selectedType;
  CatalogSort _selectedSort = CatalogSort.numberAscending;

  Future<void> _retrySync() async {
    try {
      await ref.read(syncCatalogProvider)(force: true);
    } catch (_) {}
  }

  void _onSyncStatusChanged(SyncStatus? status) {
    if (status is SyncFullPassInProgress) {
      _syncFailureReported = false;
    }
    _reportSyncFailureOverVisibleCatalog();
  }

  void _reportSyncFailureOverVisibleCatalog() {
    final syncStatus = ref.read(catalogSyncStatusProvider).asData?.value;
    final query = CatalogQuery(
      search: _search,
      type: _selectedType,
      sort: _selectedSort,
    );

    final request = CatalogPageRequest(
      page: _currentPage,
      pageSize: catalogPageSize,
      query: query,
    );

    final visiblePokemon =
        ref.read(filteredCatalogPageProvider(request)).asData?.value ??
        const <Pokemon>[];

    if (_syncFailureReported ||
        syncStatus is! SyncFailed ||
        visiblePokemon.isEmpty) {
      return;
    }

    _syncFailureReported = true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_syncFailureMessage(syncStatus.failure))),
    );
  }

  String _syncFailureMessage(SyncFailure failure) {
    final l10n = AppLocalizations.of(context)!;

    return switch (failure) {
      NoConnection() => l10n.catalogSyncOfflineError,
      _ => l10n.catalogSyncError,
    };
  }

  Widget _buildPagination(int totalItems) {
    final totalPages = (totalItems / catalogPageSize).ceil();

    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final visiblePageButtons = _visiblePageButtonsFor(
            availableWidth: constraints.maxWidth,
            totalPages: totalPages,
          );

          final startPage = (_currentPage - visiblePageButtons ~/ 2)
              .clamp(0, totalPages - visiblePageButtons)
              .toInt();

          final endPage = startPage + visiblePageButtons;

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: AppLocalizations.of(context)!.previousPage,
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage--)
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              for (var page = startPage; page < endPage; page++)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _pageButtonSpacing / 2,
                  ),
                  child: TextButton(
                    onPressed: () {
                      setState(() => _currentPage = page);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: page == _currentPage
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      foregroundColor: page == _currentPage
                          ? Colors.white
                          : null,
                      minimumSize: const Size(40, 40),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text('${page + 1}'),
                  ),
                ),
              IconButton(
                tooltip: AppLocalizations.of(context)!.nextPage,
                onPressed: _currentPage < totalPages - 1
                    ? () => setState(() => _currentPage++)
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          );
        },
      ),
    );
  }

  int _visiblePageButtonsFor({
    required double availableWidth,
    required int totalPages,
  }) {
    final widthForPageButtons = availableWidth - 2 * kMinInteractiveDimension;
    final fittingPageButtons =
        widthForPageButtons ~/ (kMinInteractiveDimension + _pageButtonSpacing);

    return fittingPageButtons
        .clamp(1, math.min(_maxVisiblePageButtons, totalPages))
        .toInt();
  }

  Widget _buildLoading() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(l10n.catalogLoading),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref, {
    required bool hasError,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return CatalogEmptyState(
      icon: hasError ? Icons.cloud_off : Icons.catching_pokemon,
      title: hasError ? l10n.catalogLoadError : l10n.catalogEmpty,
      message: hasError
          ? l10n.catalogConnectionError
          : l10n.catalogEmptyMessage,
      actionLabel: l10n.retry,
      onAction: _retrySync,
    );
  }

  Widget _buildPokemonList(BuildContext context, List<Pokemon> pokemonList) {
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

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<SyncStatus>>(
      catalogSyncStatusProvider,
      (_, next) => _onSyncStatusChanged(next.asData?.value),
    );
    final currentRequest = CatalogPageRequest(
      page: _currentPage,
      pageSize: catalogPageSize,
      query: CatalogQuery(
        search: _search,
        type: _selectedType,
        sort: _selectedSort,
      ),
    );

    ref.listen<AsyncValue<List<Pokemon>>>(
      filteredCatalogPageProvider(currentRequest),
      (_, _) => _reportSyncFailureOverVisibleCatalog(),
    );

    final query = CatalogQuery(
      search: _search,
      type: _selectedType,
      sort: _selectedSort,
    );

    final pageRequest = CatalogPageRequest(
      page: _currentPage,
      pageSize: catalogPageSize,
      query: query,
    );

    final catalogAsync = ref.watch(filteredCatalogPageProvider(pageRequest));

    final countAsync = ref.watch(filteredCatalogCountProvider(query));

    countAsync.whenData(_ensureValidPage);
    final syncStatusAsync = ref.watch(catalogSyncStatusProvider);

    final syncStatus = syncStatusAsync.when(
      data: (status) => status,
      loading: () => const SyncFullPassInProgress(),
      error: (error, _) => SyncFailed(QueryError('$error')),
    );

    final isSyncing = syncStatus is SyncFullPassInProgress;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: isSyncing ? l10n.catalogSyncing : l10n.syncCatalog,
            onPressed: isSyncing ? null : _retrySync,
            icon: isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
          ),
        ],
      ),

      body: Column(
        children: [
          CatalogFilterBar(
            searchController: _searchController,
            selectedType: _selectedType,
            selectedSort: _selectedSort,
            onSearchChanged: _onSearchChanged,
            onTypeChanged: _onTypeChanged,
            onSortChanged: _onSortChanged,
          ),
          Expanded(
            child: catalogAsync.when(
              data: (pokemonList) {
                if (pokemonList.isNotEmpty) {
                  return Column(
                    children: [
                      Expanded(child: _buildPokemonList(context, pokemonList)),
                      countAsync.when(
                        data: (totalItems) => _buildPagination(totalItems),
                        loading: () => const SizedBox(
                          height: 64,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                    ],
                  );
                }

                final hasActiveFilters =
                    _search.isNotEmpty || _selectedType != null;

                if (hasActiveFilters) {
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
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.catalogNoResultsMessage,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () {
                              _searchDebounce?.cancel();
                              _searchController.clear();

                              setState(() {
                                _search = '';
                                _selectedType = null;
                                _selectedSort = CatalogSort.numberAscending;
                                _currentPage = 0;
                              });
                            },
                            child: Text(l10n.catalogClearFilters),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (syncStatus is SyncFullPassInProgress ||
                    syncStatus is SyncWaitingRetry) {
                  return _buildLoading();
                }

                if (syncStatus is SyncFailed) {
                  return _buildEmptyState(context, ref, hasError: true);
                }

                return _buildEmptyState(context, ref, hasError: false);
              },
              loading: () => _buildLoading(),
              error: (error, stackTrace) {
                return _buildEmptyState(context, ref, hasError: true);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _ensureValidPage(int totalItems) {
    final totalPages = (totalItems / catalogPageSize).ceil();

    final lastValidPage = totalPages > 0 ? totalPages - 1 : 0;

    if (_currentPage > lastValidPage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        setState(() {
          _currentPage = lastValidPage;
        });
      });
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      setState(() {
        _search = value.trim();
        _currentPage = 0;
      });
    });
  }

  void _onTypeChanged(String? type) {
    setState(() {
      _selectedType = type;
      _currentPage = 0;
    });
  }

  void _onSortChanged(CatalogSort sort) {
    setState(() {
      _selectedSort = sort;
      _currentPage = 0;
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}
