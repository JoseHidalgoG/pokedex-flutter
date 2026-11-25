import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

class CatalogPartialNotice extends ConsumerWidget {
  const CatalogPartialNotice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(catalogProgressProvider);

    final progress = progressAsync.asData?.value;

    if (progress == null || progress.isComplete) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final totalCount = progress.totalCount;

    final message = totalCount == null
        ? l10n.catalogPartialNoticeUnknownTotal(progress.savedCount)
        : l10n.catalogPartialNotice(progress.savedCount, totalCount);

    return Container(
      key: const ValueKey('catalog-partial-notice'),
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: colorScheme.onTertiaryContainer,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
