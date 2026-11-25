import 'package:intl/intl.dart';
import 'package:pokedex_flutter/features/settings/presentation/providers/image_storage_providers.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

const bytesPerMegabyte = 1000 * 1000;

String megabytesTextOf(int bytes, String localeName) {
  final megabytes = NumberFormat.decimalPatternDigits(
    locale: localeName,
    decimalDigits: 1,
  ).format(bytes / bytesPerMegabyte);
  return '$megabytes MB';
}

String? imageActivityTextOf(
  ImageStorageActivity activity,
  AppLocalizations l10n,
) {
  return switch (activity) {
    SavingImages(:final progress?) => l10n.imagesSaveProgress(
      progress.saved,
      progress.total,
    ),
    ImagesSaved(:final progress) when progress.total == 0 =>
      l10n.imagesSaveNoCatalog,
    ImagesSaved(:final progress) when progress.saved < progress.total =>
      l10n.imagesSaveIncomplete(
        progress.saved,
        progress.total,
        progress.total - progress.saved,
      ),
    ImagesSaved(:final progress) => l10n.imagesSaveProgress(
      progress.saved,
      progress.total,
    ),
    ImageSaveFailed() => l10n.imagesSaveFailed,
    ImageDeleteFailed() => l10n.imagesDeleteFailed,
    SavingImages() || DeletingImages() || NoImageActivity() => null,
  };
}
