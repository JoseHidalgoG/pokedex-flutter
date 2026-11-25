import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/core/images/pokemon_image_cache_providers.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/artwork_save_progress.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/pokemon_image_providers.dart';

sealed class ImageStorageActivity {
  const ImageStorageActivity();

  bool get isBusy => switch (this) {
    SavingImages() || DeletingImages() => true,
    _ => false,
  };
}

final class NoImageActivity extends ImageStorageActivity {
  const NoImageActivity();
}

final class SavingImages extends ImageStorageActivity {
  const SavingImages([this.progress]);

  final ArtworkSaveProgress? progress;
}

final class ImagesSaved extends ImageStorageActivity {
  const ImagesSaved(this.progress);

  final ArtworkSaveProgress progress;
}

final class ImageSaveFailed extends ImageStorageActivity {
  const ImageSaveFailed();
}

final class DeletingImages extends ImageStorageActivity {
  const DeletingImages();
}

final class ImageDeleteFailed extends ImageStorageActivity {
  const ImageDeleteFailed();
}

final savedImagesSizeProvider = FutureProvider<int>(
  (ref) => ref.watch(getSavedImagesSizeProvider)(),
);

final imageStorageProvider =
    NotifierProvider<ImageStorageNotifier, ImageStorageActivity>(
      ImageStorageNotifier.new,
    );

class ImageStorageNotifier extends Notifier<ImageStorageActivity> {
  StreamSubscription<ArtworkSaveProgress>? _saving;

  @override
  ImageStorageActivity build() {
    ref.onDispose(() => _saving?.cancel());
    return const NoImageActivity();
  }

  void saveAll() {
    if (state.isBusy) {
      return;
    }
    state = const SavingImages();
    var lastProgress = const ArtworkSaveProgress(saved: 0, failed: 0, total: 0);
    _saving = ref
        .read(saveAllArtworkProvider)()
        .listen(
          (progress) {
            lastProgress = progress;
            state = SavingImages(progress);
          },
          onError: (Object _) {
            state = const ImageSaveFailed();
            ref.invalidate(savedImagesSizeProvider);
          },
          onDone: () {
            state = ImagesSaved(lastProgress);
            ref.invalidate(savedImagesSizeProvider);
          },
          cancelOnError: true,
        );
  }

  Future<void> deleteAll() async {
    if (state.isBusy) {
      return;
    }
    state = const DeletingImages();
    final isDeleted = await _deleteSavedImages();
    if (!ref.mounted) {
      return;
    }
    ref.read(clearDecodedImagesProvider)();
    state = isDeleted ? const NoImageActivity() : const ImageDeleteFailed();
    ref.invalidate(savedImagesSizeProvider);
  }

  Future<bool> _deleteSavedImages() async {
    try {
      await ref.read(deleteSavedImagesProvider)();
      return true;
    } on Exception {
      return false;
    }
  }
}
