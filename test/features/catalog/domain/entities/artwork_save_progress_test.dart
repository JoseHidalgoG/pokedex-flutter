import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/artwork_save_progress.dart';

void main() {
  test('cada descarga suma un guardado o un fallo', () {
    const progress = ArtworkSaveProgress(saved: 10, failed: 0, total: 12);

    expect(
      progress.afterDownload(succeeded: true),
      const ArtworkSaveProgress(saved: 11, failed: 0, total: 12),
    );
    expect(
      progress.afterDownload(succeeded: false),
      const ArtworkSaveProgress(saved: 10, failed: 1, total: 12),
    );
  });

  test('termina cuando guardados y fallos cubren el total', () {
    expect(
      const ArtworkSaveProgress(saved: 11, failed: 0, total: 12).isDone,
      isFalse,
    );
    expect(
      const ArtworkSaveProgress(saved: 11, failed: 1, total: 12).isDone,
      isTrue,
    );
    expect(
      const ArtworkSaveProgress(saved: 0, failed: 0, total: 0).isDone,
      isTrue,
    );
  });
}
