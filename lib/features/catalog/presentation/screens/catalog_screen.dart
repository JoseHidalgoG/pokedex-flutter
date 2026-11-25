import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_page_request.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_pagination.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:pokedex_flutter/features/catalog/presentation/screens/pokemon_detail_screen.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/catalog_empty_state.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/catalog_filter_bar.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/pokemon_list_item.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query_state.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_query_controller_provider.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/catalog_partial_notice.dart';
import 'package:flutter/foundation.dart' show setEquals;

const _maxVisiblePageButtons = 5;
const _pageButtonSpacing = 6.0;

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  bool _syncFailureReported = false;
  bool _showFilters = false;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController(
    keepScrollOffset: false,
  );

  Timer? _searchDebounce;
  bool _searchControllerInitialized = false;

  CatalogQueryState get _queryState =>
      ref.read(catalogQueryControllerProvider).requireValue;

  CatalogQuery get _query => _queryState.query;

  int get _currentPage => _queryState.page;

  String get _search => _query.search;

  Set<String> get _selectedTypes => _query.types;

  Set<int> get _selectedGenerations => _query.generations;

  CatalogSort get _selectedSort => _query.sort;

  CatalogPageRequest get _pageRequest => CatalogPageRequest(
    page: _currentPage,
    pageSize: catalogPageSize,
    query: _query,
  );

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
    if (!mounted) return;

    final syncStatus = ref.read(catalogSyncStatusProvider).asData?.value;

    final visiblePokemon =
        ref.read(filteredCatalogPageProvider(_pageRequest)).asData?.value ??
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

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;

    _scrollController.jumpTo(0);
  }

  void _changePage(int page) {
    if (page == _currentPage || page < 0) return;

    _scrollToTop();

    unawaited(ref.read(catalogQueryControllerProvider.notifier).setPage(page));
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
                    ? () => _changePage(_currentPage - 1)
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              for (var page = startPage; page < endPage; page++)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _pageButtonSpacing / 2,
                  ),
                  child: TextButton(
                    onPressed: () => _changePage(page),
                    style: TextButton.styleFrom(
                      backgroundColor: page == _currentPage
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      foregroundColor: page == _currentPage
                          ? Theme.of(context).colorScheme.onPrimary
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
                    ? () => _changePage(_currentPage + 1)
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

  Widget _buildEmptyState({required bool hasError}) {
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
            ),
            const SizedBox(height: 8),
            Text(l10n.catalogNoResultsMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _clearFilters,
              child: Text(l10n.catalogClearFilters),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPokemonList(
    List<Pokemon> pokemonList,
    AsyncValue<int> countAsync,
  ) {
    final totalItems = countAsync.asData?.value;
    final totalPages = totalItems == null
        ? 0
        : (totalItems / catalogPageSize).ceil();

    final showPagination = totalPages > 1;
    final showCountLoading = countAsync.isLoading && totalItems == null;

    final extraItemCount = showPagination || showCountLoading ? 1 : 0;

    return ListView.builder(
      key: const ValueKey('catalog-pokemon-list'),
      controller: _scrollController,
      itemCount: pokemonList.length + extraItemCount,
      itemBuilder: (context, index) {
        if (index == pokemonList.length) {
          if (showPagination) {
            return _buildPagination(totalItems!);
          }

          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

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

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;

      final search = value.trim();

      if (search == _search) return;

      _scrollToTop();

      unawaited(
        ref.read(catalogQueryControllerProvider.notifier).setSearch(search),
      );
    });
  }

  void _onTypesChanged(Set<String> types) {
    if (setEquals(_selectedTypes, types)) return;

    _scrollToTop();

    unawaited(
      ref.read(catalogQueryControllerProvider.notifier).setTypes(types),
    );
  }

  void _onGenerationsChanged(Set<int> generations) {
    if (setEquals(_selectedGenerations, generations)) return;

    _scrollToTop();

    unawaited(
      ref
          .read(catalogQueryControllerProvider.notifier)
          .setGenerations(generations),
    );
  }

  void _onSortChanged(CatalogSort sort) {
    if (_selectedSort == sort) return;

    _scrollToTop();

    unawaited(ref.read(catalogQueryControllerProvider.notifier).setSort(sort));
  }

  void _clearFilters() {
    _searchDebounce?.cancel();
    _searchController.clear();

    _scrollToTop();

    unawaited(ref.read(catalogQueryControllerProvider.notifier).clearFilters());
  }

  @override
  Widget build(BuildContext context) {
    final queryStateAsync = ref.watch(catalogQueryControllerProvider);

    final queryState = queryStateAsync.asData?.value;

    if (queryState == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pokédex'), centerTitle: true),
        body: _buildLoading(),
      );
    }

    if (!_searchControllerInitialized) {
      _searchController.text = queryState.query.search;
      _searchControllerInitialized = true;
    }

    final query = queryState.query;
    final pageRequest = CatalogPageRequest(
      page: queryState.page,
      pageSize: catalogPageSize,
      query: query,
    );

    ref.listen<AsyncValue<SyncStatus>>(
      catalogSyncStatusProvider,
      (_, next) => _onSyncStatusChanged(next.asData?.value),
    );

    ref.listen<AsyncValue<List<Pokemon>>>(
      filteredCatalogPageProvider(pageRequest),
      (_, _) => _reportSyncFailureOverVisibleCatalog(),
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
            tooltip: _showFilters
                ? l10n.catalogHideSearch
                : l10n.catalogShowSearch,
            icon: Icon(_showFilters ? Icons.search_off : Icons.search),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
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
          const CatalogPartialNotice(),
          if (_showFilters)
            CatalogFilterBar(
              searchController: _searchController,
              selectedTypes: _selectedTypes,
              selectedGenerations: _selectedGenerations,
              selectedSort: _selectedSort,
              onSearchChanged: _onSearchChanged,
              onTypesChanged: _onTypesChanged,
              onGenerationsChanged: _onGenerationsChanged,
              onSortChanged: _onSortChanged,
            ),
          Expanded(
            child: catalogAsync.when(
              data: (pokemonList) {
                if (pokemonList.isNotEmpty) {
                  return _buildPokemonList(pokemonList, countAsync);
                }

                final hasActiveFilters =
                    _search.isNotEmpty ||
                    _selectedTypes.isNotEmpty ||
                    _selectedGenerations.isNotEmpty;

                if (hasActiveFilters) {
                  if (countAsync.isLoading && countAsync.asData == null) {
                    return _buildLoading();
                  }

                  if (countAsync.asData?.value == 0) {
                    return _buildNoResults();
                  }

                  if (countAsync.hasError) {
                    return _buildEmptyState(hasError: true);
                  }

                  return _buildLoading();
                }

                if (syncStatus is SyncFullPassInProgress ||
                    syncStatus is SyncWaitingRetry) {
                  return _buildLoading();
                }

                if (syncStatus is SyncFailed) {
                  return _buildEmptyState(hasError: true);
                }

                return _buildEmptyState(hasError: false);
              },
              loading: () => _buildLoading(),
              error: (error, stackTrace) {
                return _buildEmptyState(hasError: true);
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

    final checkedState = _queryState;

    if (checkedState.page <= lastValidPage) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final currentState = ref
          .read(catalogQueryControllerProvider)
          .asData
          ?.value;

      if (currentState == null || currentState != checkedState) {
        return;
      }

      _changePage(lastValidPage);
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
