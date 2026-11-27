import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/core/share/share_text_provider.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/pokemon_detail_providers.dart';
import 'package:pokedex_flutter/features/catalog/presentation/texts/detail_texts.dart';
import 'package:pokedex_flutter/features/catalog/presentation/texts/pokemon_texts.dart';
import 'package:pokedex_flutter/features/catalog/presentation/theme/detail_color_scheme.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/detail/detail_evolutions_tab.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/detail/detail_header.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/detail/detail_info_tab.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/detail/detail_matchups_tab.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/detail/detail_moves_tab.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/detail/detail_stats_tab.dart';
import 'package:pokedex_flutter/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

class PokemonDetailScreen extends ConsumerStatefulWidget {
  const PokemonDetailScreen({super.key, required this.pokemon});

  final Pokemon pokemon;

  @override
  ConsumerState<PokemonDetailScreen> createState() =>
      _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends ConsumerState<PokemonDetailScreen> {
  late Pokemon _selectedForm = widget.pokemon;
  bool _showsShiny = false;

  Future<void> _refresh() {
    return ref.read(revalidatePokemonDetailProvider)(
      _selectedForm.id,
      force: true,
    );
  }

  void _selectForm(Pokemon form) {
    if (form.id == _selectedForm.id) {
      return;
    }
    setState(() {
      _selectedForm = form;
      _showsShiny = false;
    });
  }

  void _toggleShiny() {
    setState(() => _showsShiny = !_showsShiny);
  }

  void _showShinyUnavailable() {
    if (!mounted || !_showsShiny) {
      return;
    }
    setState(() => _showsShiny = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.detailShinyUnavailable),
        ),
      );
  }

  Future<void> _share(
    BuildContext buttonContext,
    Pokemon pokemon,
    int? baseStatTotal,
  ) {
    final button = buttonContext.findRenderObject() as RenderBox?;
    return ref.read(shareTextProvider)(
      shareTextOf(
        pokemon,
        baseStatTotal: baseStatTotal,
        l10n: AppLocalizations.of(context)!,
      ),
      subject: displayNameOf(pokemon.name),
      origin: button == null
          ? null
          : button.localToGlobal(Offset.zero) & button.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shownId = _selectedForm.id;
    final detailState = ref.watch(pokemonDetailProvider(shownId));
    final freshness = ref.watch(pokemonDetailFreshnessProvider(shownId)).value;
    final forms =
        ref.watch(pokemonDetailProvider(widget.pokemon.id)).value?.forms ??
        const <Pokemon>[];
    final detail = detailState.value;
    final pokemon = detail?.pokemon ?? _selectedForm;

    return AnimatedTheme(
      data: detailThemeOf(Theme.of(context), pokemon.typeNames),
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                tooltip: _showsShiny
                    ? l10n.detailShowNormal
                    : l10n.detailShowShiny,
                isSelected: _showsShiny,
                icon: const Icon(Icons.auto_awesome_outlined),
                selectedIcon: const Icon(Icons.auto_awesome),
                onPressed: _toggleShiny,
              ),
              FavoriteButton(pokemonId: pokemon.id),
              Builder(
                builder: (buttonContext) => IconButton(
                  tooltip: l10n.detailShare,
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () =>
                      _share(buttonContext, pokemon, detail?.baseStatTotal),
                ),
              ),
            ],
          ),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: DetailHeader(
                  pokemon: pokemon,
                  freshness: freshness,
                  showsShiny: _showsShiny,
                  onShinyUnavailable: _showShinyUnavailable,
                ),
              ),
            ],
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    Tab(text: l10n.detailTabInfo),
                    Tab(text: l10n.detailTabStats),
                    Tab(text: l10n.detailTabEvolutions),
                    Tab(text: l10n.detailTabMoves),
                    Tab(text: l10n.detailTabMatchups),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      DetailInfoTab(
                        detailState: detailState,
                        forms: forms,
                        selectedFormId: shownId,
                        onFormSelected: _selectForm,
                        onRefresh: _refresh,
                      ),
                      DetailStatsTab(
                        detailState: detailState,
                        onRefresh: _refresh,
                      ),
                      DetailEvolutionsTab(
                        detailState: detailState,
                        onRefresh: _refresh,
                      ),
                      DetailMovesTab(
                        detailState: detailState,
                        onRefresh: _refresh,
                      ),
                      DetailMatchupsTab(
                        typeNames: pokemon.typeNames,
                        typeEfficacyState: ref.watch(typeEfficacyProvider),
                        onRefresh: _refresh,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
