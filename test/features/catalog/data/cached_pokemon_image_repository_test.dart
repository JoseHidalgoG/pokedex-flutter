import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/core/images/image_file_cache.dart';
import 'package:pokedex_flutter/features/catalog/data/cached_pokemon_image_repository.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/artwork_save_progress.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_artwork.dart';

class FakeImageFileCache implements ImageFileCache {
  FakeImageFileCache({
    Set<String> savedUrls = const {},
    this.failingUrls = const {},
    this.bytes = 0,
  }) : savedUrls = {...savedUrls};

  final Set<String> savedUrls;
  final Set<String> failingUrls;
  final int bytes;
  final requestedSaves = <String>[];
  var _savesInFlight = 0;
  var mostSavesAtOnce = 0;

  @override
  Future<bool> isSaved(String url) async => savedUrls.contains(url);

  @override
  Future<Set<String>> savedUrlsAmong(Set<String> urls) async =>
      savedUrls.intersection(urls);

  @override
  Future<void> save(String url) async {
    requestedSaves.add(url);
    _savesInFlight++;
    if (_savesInFlight > mostSavesAtOnce) {
      mostSavesAtOnce = _savesInFlight;
    }
    await Future<void>.delayed(Duration.zero);
    _savesInFlight--;
    if (failingUrls.contains(url)) {
      throw Exception('raw.githubusercontent.com no responde');
    }
    savedUrls.add(url);
  }

  @override
  Future<int> savedBytes() async => bytes;

  @override
  Future<void> deleteAll() async => savedUrls.clear();
}

String artworkUrl(int id) => 'https://example.com/official-artwork/$id.png';

CatalogEntry pokemonWithArtwork(int id, {bool isDefault = true}) {
  return CatalogEntry(
    id: id,
    name: 'pokemon-$id',
    imageUrl: artworkUrl(id),
    typeNames: const ['normal'],
    isDefault: isDefault,
  );
}

void main() {
  late AppDatabase database;
  final savedAt = DateTime(2026, 11, 24, 9);

  setUp(() => database = AppDatabase(NativeDatabase.memory()));

  tearDown(() => database.close());

  Future<void> saveCatalog(List<CatalogEntry> entries) {
    return database.catalogDao.saveCatalogPage(
      entries: entries,
      nextOffset: entries.length,
      isComplete: true,
      savedAt: savedAt,
      totalCount: entries.length,
    );
  }

  CachedPokemonImageRepository repositoryWith(FakeImageFileCache images) {
    return CachedPokemonImageRepository(
      catalogDao: database.catalogDao,
      images: images,
    );
  }

  group('Pokémon con la imagen guardada', () {
    test(
      'solo cuenta los Pokémon por defecto cuyo artwork está guardado',
      () async {
        await saveCatalog([
          pokemonWithArtwork(1),
          pokemonWithArtwork(4),
          pokemonWithArtwork(7),
          pokemonWithArtwork(10100, isDefault: false),
        ]);
        final images = FakeImageFileCache(
          savedUrls: {artworkUrl(1), artworkUrl(7), artworkUrl(10100)},
        );

        final ids = await repositoryWith(images).pokemonIdsWithSavedArtwork();

        expect(ids, {1, 7});
      },
    );

    test('sin catálogo no hay ninguno', () async {
      final images = FakeImageFileCache(savedUrls: {artworkUrl(25)});

      final ids = await repositoryWith(images).pokemonIdsWithSavedArtwork();

      expect(ids, isEmpty);
    });
  });

  group('guardar todas las imágenes', () {
    test('descarga solo las que faltan e informa el avance', () async {
      await saveCatalog([
        pokemonWithArtwork(1),
        pokemonWithArtwork(4),
        pokemonWithArtwork(7),
      ]);
      final images = FakeImageFileCache(savedUrls: {artworkUrl(1)});

      final progress = await repositoryWith(images).saveAllArtwork().toList();

      expect(
        images.requestedSaves,
        unorderedEquals([artworkUrl(4), artworkUrl(7)]),
      );
      expect(
        progress.first,
        const ArtworkSaveProgress(saved: 1, failed: 0, total: 3),
      );
      expect(
        progress.last,
        const ArtworkSaveProgress(saved: 3, failed: 0, total: 3),
      );
      expect(progress.last.isDone, isTrue);
    });

    test('con todo guardado termina sin descargar nada', () async {
      await saveCatalog([pokemonWithArtwork(1), pokemonWithArtwork(4)]);
      final images = FakeImageFileCache(
        savedUrls: {artworkUrl(1), artworkUrl(4)},
      );

      final progress = await repositoryWith(images).saveAllArtwork().toList();

      expect(images.requestedSaves, isEmpty);
      expect(progress, [
        const ArtworkSaveProgress(saved: 2, failed: 0, total: 2),
      ]);
    });

    test('cuenta las descargas fallidas y sigue con las demás', () async {
      await saveCatalog([
        pokemonWithArtwork(1),
        pokemonWithArtwork(4),
        pokemonWithArtwork(7),
      ]);
      final images = FakeImageFileCache(failingUrls: {artworkUrl(4)});

      final progress = await repositoryWith(images).saveAllArtwork().toList();

      expect(
        progress.last,
        const ArtworkSaveProgress(saved: 2, failed: 1, total: 3),
      );
      expect(progress.last.isDone, isTrue);
    });

    test('se detiene tras 10 fallos seguidos porque no hay red', () async {
      final catalog = [for (var id = 1; id <= 40; id++) pokemonWithArtwork(id)];
      await saveCatalog(catalog);
      final images = FakeImageFileCache(
        failingUrls: {for (final entry in catalog) entry.imageUrl},
      );

      final progress = await repositoryWith(images).saveAllArtwork().toList();

      expect(progress.last.saved, 0);
      expect(
        progress.last.failed,
        inInclusiveRange(
          artworkFailuresInARowBeforeStopping,
          artworkFailuresInARowBeforeStopping + artworkDownloadsAtOnce,
        ),
      );
      expect(progress.last.isDone, isFalse);
      expect(
        images.requestedSaves.length,
        lessThanOrEqualTo(
          artworkFailuresInARowBeforeStopping + artworkDownloadsAtOnce,
        ),
      );
    });

    test('nunca descarga más de 4 imágenes a la vez', () async {
      await saveCatalog([
        for (var id = 1; id <= 12; id++) pokemonWithArtwork(id),
      ]);
      final images = FakeImageFileCache();

      final progress = await repositoryWith(images).saveAllArtwork().toList();

      expect(images.mostSavesAtOnce, artworkDownloadsAtOnce);
      expect(
        progress.last,
        const ArtworkSaveProgress(saved: 12, failed: 0, total: 12),
      );
    });
  });

  group('guardar la imagen de un Pokémon', () {
    test('descarga la URL guardada en el catálogo', () async {
      await saveCatalog([pokemonWithArtwork(25)]);
      final images = FakeImageFileCache();

      await repositoryWith(images).saveArtworkOf(25);

      expect(images.requestedSaves, [artworkUrl(25)]);
    });

    test('no vuelve a descargar una imagen ya guardada', () async {
      await saveCatalog([pokemonWithArtwork(25)]);
      final images = FakeImageFileCache(savedUrls: {artworkUrl(25)});

      await repositoryWith(images).saveArtworkOf(25);

      expect(images.requestedSaves, isEmpty);
    });

    test('sin el Pokémon en el catálogo usa el official-artwork', () async {
      final images = FakeImageFileCache();

      await repositoryWith(images).saveArtworkOf(133);

      expect(images.requestedSaves, [officialArtworkUrlFor(133)]);
    });
  });

  test('el espacio y el borrado pasan a la caché de imágenes', () async {
    final images = FakeImageFileCache(savedUrls: {artworkUrl(1)}, bytes: 4096);
    final repository = repositoryWith(images);

    expect(await repository.savedImagesBytes(), 4096);
    await repository.deleteSavedImages();
    expect(images.savedUrls, isEmpty);
  });
}
