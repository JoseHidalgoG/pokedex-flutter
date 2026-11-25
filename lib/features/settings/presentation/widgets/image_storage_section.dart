import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/artwork_save_progress.dart';
import 'package:pokedex_flutter/features/connectivity/connectivity_providers.dart';
import 'package:pokedex_flutter/features/connectivity/domain/connectivity_status.dart';
import 'package:pokedex_flutter/features/settings/presentation/providers/image_storage_providers.dart';
import 'package:pokedex_flutter/features/settings/presentation/texts/image_storage_texts.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

const unknownImagesSize = '—';
const measuringImagesSize = '…';

class ImageStorageSection extends ConsumerStatefulWidget {
  const ImageStorageSection({super.key});

  @override
  ConsumerState<ImageStorageSection> createState() =>
      _ImageStorageSectionState();
}

class _ImageStorageSectionState extends ConsumerState<ImageStorageSection> {
  var _wasVisible = false;
  var _hasBeenShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isVisible = Visibility.of(context);
    if (isVisible && !_wasVisible && _hasBeenShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.invalidate(savedImagesSizeProvider);
        }
      });
    }
    _hasBeenShown = _hasBeenShown || isVisible;
    _wasVisible = isVisible;
  }

  @override
  Widget build(BuildContext context) {
    if (!Visibility.of(context)) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context)!;
    final savedBytes = ref.watch(savedImagesSizeProvider);
    final sizeText = switch (savedBytes) {
      AsyncValue(:final value?) => megabytesTextOf(value, l10n.localeName),
      AsyncError() => unknownImagesSize,
      _ => measuringImagesSize,
    };
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(l10n.imagesTitle),
            subtitle: Text(l10n.imagesSavedSize(sizeText)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: savedBytes.hasValue
                ? const _ImageStorageActions()
                : const _ImageStorageButtons(),
          ),
        ],
      ),
    );
  }
}

class _ImageStorageActions extends ConsumerWidget {
  const _ImageStorageActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final activity = ref.watch(imageStorageProvider);
    final isOffline =
        ref.watch(connectivityStatusProvider).value ==
        ConnectivityStatus.offline;
    final activityText = imageActivityTextOf(activity, l10n);
    return _ImageStorageButtons(
      onSaveAll: isOffline || activity.isBusy
          ? null
          : () => ref.read(imageStorageProvider.notifier).saveAll(),
      onDelete: activity.isBusy ? null : () => _confirmDeletion(context, ref),
      status: [
        if (isOffline) _StatusText(l10n.imagesNeedConnection),
        if (activity case SavingImages(:final progress))
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: LinearProgressIndicator(
              value: _completedFractionOf(progress),
              semanticsLabel: l10n.imagesSaveAll,
            ),
          ),
        if (activity is DeletingImages)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: LinearProgressIndicator(),
          ),
        if (activityText != null) _StatusText(activityText),
      ],
    );
  }

  static double? _completedFractionOf(ArtworkSaveProgress? progress) {
    return switch (progress) {
      ArtworkSaveProgress(:final saved, :final failed, :final total)
          when total > 0 =>
        (saved + failed) / total,
      _ => null,
    };
  }

  static Future<void> _confirmDeletion(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.imagesDeleteQuestion),
        content: Text(l10n.imagesDeleteExplanation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              MaterialLocalizations.of(dialogContext).cancelButtonLabel,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.imagesDeleteConfirm),
          ),
        ],
      ),
    );
    if (isConfirmed != true || !context.mounted) {
      return;
    }
    await ref.read(imageStorageProvider.notifier).deleteAll();
  }
}

class _ImageStorageButtons extends StatelessWidget {
  const _ImageStorageButtons({
    this.onSaveAll,
    this.onDelete,
    this.status = const [],
  });

  final VoidCallback? onSaveAll;
  final VoidCallback? onDelete;
  final List<Widget> status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.tonalIcon(
          onPressed: onSaveAll,
          icon: const Icon(Icons.download_for_offline_outlined),
          label: Text(l10n.imagesSaveAll),
        ),
        ...status,
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
          label: Text(l10n.imagesDelete),
        ),
      ],
    );
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
