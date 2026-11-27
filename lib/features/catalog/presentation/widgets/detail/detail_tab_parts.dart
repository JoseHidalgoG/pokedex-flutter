import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_detail.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

class DetailRefreshableList extends StatelessWidget {
  const DetailRefreshableList({
    super.key,
    required this.onRefresh,
    required this.children,
  });

  final RefreshCallback onRefresh;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: children,
      ),
    );
  }
}

class DetailSection extends StatelessWidget {
  const DetailSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            container: true,
            header: true,
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class DetailMessage extends StatelessWidget {
  const DetailMessage({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(icon, size: 40, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class DetailLoading extends StatelessWidget {
  const DetailLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: CircularProgressIndicator(
          semanticsLabel: AppLocalizations.of(context)!.detailLoading,
        ),
      ),
    );
  }
}

class MissingDetailData extends StatelessWidget {
  const MissingDetailData({
    super.key,
    required this.detail,
    this.storedButEmptyText,
  });

  final PokemonDetail detail;
  final String? storedButEmptyText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = detail.hasStoredDetail
        ? storedButEmptyText ?? l10n.detailNoData
        : l10n.detailSectionPending;

    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium
          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}

List<Widget> detailChildrenOf(
  BuildContext context,
  AsyncValue<PokemonDetail?> detailState,
  List<Widget> Function(PokemonDetail detail) childrenOf,
) {
  final l10n = AppLocalizations.of(context)!;
  if (detailState.value case final detail?) {
    return childrenOf(detail);
  }
  if (detailState.hasError) {
    return [
      DetailMessage(icon: Icons.error_outline, text: l10n.detailLoadError),
    ];
  }
  if (detailState.isLoading) {
    return const [DetailLoading()];
  }
  return [
    DetailMessage(
      icon: Icons.cloud_download_outlined,
      text: l10n.detailSectionPending,
    ),
  ];
}
