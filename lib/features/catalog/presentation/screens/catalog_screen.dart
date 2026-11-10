import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_sync_status.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:pokedex_flutter/features/catalog/presentation/screens/pokemon_detail_screen.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/catalog_empty_state.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/pokemon_list_item.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_pagination.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  int _currentPage = 0;

  Future<void> _retrySync(
      BuildContext context,
      WidgetRef ref,
      ) async {
    try {
      await ref.read(syncCatalogProvider)();
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo sincronizar el catálogo. Inténtalo nuevamente.'),
        ),
      );
    }
  }

  Widget _buildPagination(int totalItems) {
    final totalPages =
    (totalItems / catalogPageSize).ceil();

    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    final maxStart = (totalPages - 5)
        .clamp(0, totalPages)
        .toInt();

    final startPage = (_currentPage - 2)
        .clamp(0, maxStart)
        .toInt();

    final endPage = (startPage + 5)
        .clamp(0, totalPages)
        .toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      child: Row(
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
              padding: const EdgeInsets.symmetric(horizontal: 3),
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
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
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
      onAction: () => _retrySync(context, ref),
    );
  }

  Widget _buildPokemonList(
      BuildContext context,
      List<Pokemon> pokemonList,
      ) {
    return ListView.builder(
      itemCount: pokemonList.length,
      itemBuilder: (context, index) {
        final pokemon = pokemonList[index];

        return PokemonListItem(
          pokemon: pokemon,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PokemonDetailScreen(
                  pokemon: pokemon,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(
      catalogPageProvider(_currentPage),
    );

    final countAsync = ref.watch(catalogCountProvider);
    countAsync.whenData(_ensureValidPage);
    final syncStatusAsync = ref.watch(catalogSyncStatusProvider);

    final syncStatus = syncStatusAsync.when(
      data: (status) => status,
      loading: () => const CatalogSyncInProgress(),
      error: (_, _) => const CatalogSyncFailed(
        CatalogSyncFailureReason.requestFailed,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        centerTitle: true,
      ),
      body: catalogAsync.when(
        data: (pokemonList) {
          if (pokemonList.isNotEmpty) {
            return Column(
              children: [
                Expanded(
                  child: _buildPokemonList(
                    context,
                    pokemonList,
                  ),
                ),
                countAsync.when(
                  data: (totalItems) =>
                      _buildPagination(totalItems),
                  loading: () => const SizedBox(
                    height: 64,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
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
            return _buildEmptyState(
              context,
              ref,
              hasError: true,
            );
          }

          return _buildEmptyState(
            context,
            ref,
            hasError: false,
          );
        },
        loading: () => _buildLoading(),
        error: (error, stackTrace) {
          return _buildEmptyState(
            context,
            ref,
            hasError: true,
          );
        },
      ),
    );
  }


  void _ensureValidPage(int totalItems) {
    final totalPages = (totalItems / catalogPageSize).ceil();

    final lastValidPage = totalPages > 0
        ? totalPages - 1
        : 0;

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