import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_sync_status.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:pokedex_flutter/features/catalog/presentation/screens/pokemon_detail_screen.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/catalog_empty_state.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/pokemon_list_item.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_pagination.dart';

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

  Future<void> _retrySync() async {
    try {
      await ref.read(syncCatalogProvider)();
    } catch (_) {
      // El servicio de sincronización reporta el error
      // mediante catalogSyncStatusProvider.
    }
  }

  void _onSyncStatusChanged(CatalogSyncStatus? status) {
    if (status is CatalogSyncInProgress) {
      _syncFailureReported = false;
    }
    _reportSyncFailureOverVisibleCatalog();
  }

  void _reportSyncFailureOverVisibleCatalog() {
    final syncStatus = ref.read(catalogSyncStatusProvider).asData?.value;
    final visiblePokemon =
        ref.read(catalogPageProvider(_currentPage)).asData?.value ?? const [];

    if (_syncFailureReported ||
        syncStatus is! CatalogSyncFailed ||
        visiblePokemon.isEmpty) {
      return;
    }

    _syncFailureReported = true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_syncFailureMessage(syncStatus.reason))),
    );
  }

  String _syncFailureMessage(CatalogSyncFailureReason reason) {
    return switch (reason) {
      CatalogSyncFailureReason.noConnection =>
        'Sin conexión: se muestran los Pokémon guardados.',
      CatalogSyncFailureReason.requestFailed =>
        'No se pudo sincronizar el catálogo. Inténtalo nuevamente.',
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
                tooltip: 'Página anterior',
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
                tooltip: 'Página siguiente',
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
    final widthForPageButtons =
        availableWidth - 2 * kMinInteractiveDimension;
    final fittingPageButtons =
        widthForPageButtons ~/ (kMinInteractiveDimension + _pageButtonSpacing);

    return fittingPageButtons
        .clamp(1, math.min(_maxVisiblePageButtons, totalPages))
        .toInt();
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando catálogo'),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref, {
    required bool hasError,
  }) {
    return CatalogEmptyState(
      icon: hasError ? Icons.cloud_off : Icons.catching_pokemon,
      title: hasError
          ? 'No se pudo cargar el catálogo'
          : 'No hay Pokémon disponibles',
      message: hasError
          ? 'Comprueba tu conexión e inténtalo nuevamente.'
          : 'Todavía no hay Pokémon guardados en el catálogo.',
      actionLabel: 'Reintentar',
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
    ref.listen<AsyncValue<CatalogSyncStatus>>(
      catalogSyncStatusProvider,
      (_, next) => _onSyncStatusChanged(next.asData?.value),
    );
    ref.listen<AsyncValue<List<Pokemon>>>(
      catalogPageProvider(_currentPage),
      (_, _) => _reportSyncFailureOverVisibleCatalog(),
    );

    final catalogAsync = ref.watch(catalogPageProvider(_currentPage));

    final countAsync = ref.watch(catalogCountProvider);
    countAsync.whenData(_ensureValidPage);
    final syncStatusAsync = ref.watch(catalogSyncStatusProvider);

    final syncStatus = syncStatusAsync.when(
      data: (status) => status,
      loading: () => const CatalogSyncInProgress(),
      error: (_, _) =>
          const CatalogSyncFailed(CatalogSyncFailureReason.requestFailed),
    );

    final isSyncing = syncStatus is CatalogSyncInProgress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: isSyncing ? 'Sincronizando...' : 'Sincronizar catálogo',
            onPressed: isSyncing ? null : _retrySync,
            icon: isSyncing
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : const Icon(Icons.sync),
          ),
        ],
      ),
      body: catalogAsync.when(
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

          if (syncStatus is CatalogSyncInProgress) {
            return _buildLoading();
          }

          if (syncStatus is CatalogSyncFailed) {
            return _buildEmptyState(context, ref, hasError: true);
          }

          return _buildEmptyState(context, ref, hasError: false);
        },
        loading: () => _buildLoading(),
        error: (error, stackTrace) {
          return _buildEmptyState(context, ref, hasError: true);
        },
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
}
