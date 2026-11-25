import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/images/pokemon_image_cache_providers.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/artwork_save_progress.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/pokemon_image_providers.dart';
import 'package:pokedex_flutter/features/settings/presentation/providers/image_storage_providers.dart';

import '../../../catalog/fakes/fake_pokemon_image_repository.dart';

void main() {
  late FakePokemonImageRepository images;
  late ProviderContainer container;
  late int decodedImageClears;

  setUp(() {
    images = FakePokemonImageRepository(savedBytes: 1200000);
    decodedImageClears = 0;
    container = ProviderContainer.test(
      overrides: [
        pokemonImageRepositoryProvider.overrideWithValue(images),
        clearDecodedImagesProvider.overrideWithValue(
          () => decodedImageClears++,
        ),
      ],
    );
  });

  ImageStorageNotifier storage() =>
      container.read(imageStorageProvider.notifier);

  ImageStorageActivity activity() => container.read(imageStorageProvider);

  Future<int> savedBytes() => container.read(savedImagesSizeProvider.future);

  group('guardar todas las imágenes', () {
    test('publica el avance y al terminar vuelve a medir el espacio', () async {
      expect(await savedBytes(), 1200000);

      storage().saveAll();
      expect(
        activity(),
        isA<SavingImages>().having((s) => s.progress, 'progress', isNull),
      );

      const halfway = ArtworkSaveProgress(saved: 412, failed: 0, total: 1025);
      images.reportProgress(halfway);
      await pumpEventQueue();
      expect(
        activity(),
        isA<SavingImages>().having((s) => s.progress, 'progress', halfway),
      );

      const finished = ArtworkSaveProgress(saved: 1025, failed: 0, total: 1025);
      images
        ..reportProgress(finished)
        ..savedBytes = 164000000
        ..finishSaving();
      await pumpEventQueue();

      expect(
        activity(),
        isA<ImagesSaved>().having((s) => s.progress, 'progress', finished),
      );
      expect(await savedBytes(), 164000000);
      expect(images.sizeReads, 2);
    });

    test('no arranca otra descarga mientras una sigue en curso', () async {
      storage()
        ..saveAll()
        ..saveAll();

      expect(images.saveAllRuns, 1);
    });

    test('sigue aunque nadie mire Ajustes', () async {
      final subscription = container.listen(imageStorageProvider, (_, _) {});
      storage().saveAll();
      subscription.close();
      await pumpEventQueue();

      images
        ..reportProgress(
          const ArtworkSaveProgress(saved: 3, failed: 0, total: 3),
        )
        ..finishSaving();
      await pumpEventQueue();

      expect(activity(), isA<ImagesSaved>());
    });

    test('un error al recorrer el catálogo queda como fallo', () async {
      storage().saveAll();
      images.failSaving();
      await pumpEventQueue();

      expect(activity(), isA<ImageSaveFailed>());
      expect(activity().isBusy, isFalse);
    });
  });

  group('borrar las imágenes', () {
    test('vacía la caché, olvida las decodificadas y vuelve a medir', () async {
      expect(await savedBytes(), 1200000);
      storage().saveAll();
      images.finishSaving();
      await pumpEventQueue();
      expect(activity(), isA<ImagesSaved>());

      await storage().deleteAll();

      expect(images.deletions, 1);
      expect(decodedImageClears, 1);
      expect(activity(), isA<NoImageActivity>());
      expect(await savedBytes(), 0);
    });

    test('si falla lo informa y conserva el espacio medido', () async {
      images.deletionFails = true;

      await storage().deleteAll();

      expect(activity(), isA<ImageDeleteFailed>());
      expect(await savedBytes(), 1200000);
    });

    test('no borra mientras se guardan las imágenes', () async {
      storage().saveAll();

      await storage().deleteAll();

      expect(images.deletions, 0);
      expect(activity(), isA<SavingImages>());
    });
  });
}
