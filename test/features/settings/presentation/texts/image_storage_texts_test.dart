import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/artwork_save_progress.dart';
import 'package:pokedex_flutter/features/settings/presentation/providers/image_storage_providers.dart';
import 'package:pokedex_flutter/features/settings/presentation/texts/image_storage_texts.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

void main() {
  final spanish = lookupAppLocalizations(const Locale('es'));

  group('espacio en MB', () {
    test('usa megabytes de 1 000 000 bytes con un decimal', () {
      expect(megabytesTextOf(84300000, 'es'), '84,3 MB');
      expect(megabytesTextOf(84300000, 'en'), '84.3 MB');
    });

    test('sin imágenes muestra cero', () {
      expect(megabytesTextOf(0, 'es'), '0,0 MB');
    });

    test('agrupa los miles según el idioma', () {
      expect(megabytesTextOf(1234500000, 'es'), '1.234,5 MB');
      expect(megabytesTextOf(1234500000, 'en'), '1,234.5 MB');
    });
  });

  group('texto de la actividad', () {
    test('mientras guarda cuenta las guardadas sobre el total', () {
      expect(
        imageActivityTextOf(
          const SavingImages(
            ArtworkSaveProgress(saved: 412, failed: 3, total: 1025),
          ),
          spanish,
        ),
        '412 de 1025 guardadas',
      );
    });

    test('antes del primer avance no muestra texto', () {
      expect(imageActivityTextOf(const SavingImages(), spanish), isNull);
    });

    test('al terminar con todo guardado repite el total', () {
      expect(
        imageActivityTextOf(
          const ImagesSaved(
            ArtworkSaveProgress(saved: 1025, failed: 0, total: 1025),
          ),
          spanish,
        ),
        '1025 de 1025 guardadas',
      );
    });

    test('si se detuvo o fallaron algunas dice cuántas faltan', () {
      expect(
        imageActivityTextOf(
          const ImagesSaved(
            ArtworkSaveProgress(saved: 412, failed: 10, total: 1025),
          ),
          spanish,
        ),
        '412 de 1025 guardadas · 613 sin descargar',
      );
    });

    test('sin catálogo guardado lo dice', () {
      expect(
        imageActivityTextOf(
          const ImagesSaved(ArtworkSaveProgress(saved: 0, failed: 0, total: 0)),
          spanish,
        ),
        'Todavía no hay catálogo guardado',
      );
    });

    test('los fallos tienen su mensaje y el reposo ninguno', () {
      expect(
        imageActivityTextOf(const ImageSaveFailed(), spanish),
        'No se pudieron guardar las imágenes',
      );
      expect(
        imageActivityTextOf(const ImageDeleteFailed(), spanish),
        'No se pudieron borrar las imágenes',
      );
      expect(imageActivityTextOf(const NoImageActivity(), spanish), isNull);
      expect(imageActivityTextOf(const DeletingImages(), spanish), isNull);
    });
  });
}
