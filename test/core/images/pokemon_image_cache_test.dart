import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokedex_flutter/core/images/pokemon_image_cache.dart';

const pikachuUrl = 'https://example.com/official-artwork/25.png';
const eeveeUrl = 'https://example.com/official-artwork/133.png';
const missingUrl = 'https://example.com/official-artwork/99999.png';

const imagesOnGitHub = {
  pikachuUrl: [1, 2, 3],
  eeveeUrl: [4, 5, 6, 7, 8],
};

final gitHub = MockClient((request) async {
  final bytes = imagesOnGitHub[request.url.toString()];
  if (bytes == null) {
    return http.Response('Not Found', 404);
  }
  return http.Response.bytes(
    bytes,
    200,
    headers: {'content-type': 'image/png', 'cache-control': 'max-age=300'},
  );
});

Future<Config> configInMemory(String cacheKey) async {
  return Config(
    cacheKey,
    maxNrOfCacheObjects: pokemonImageCacheCapacity,
    stalePeriod: pokemonImageMaxIdle,
    repo: JsonCacheInfoRepository.withFile(
      await MemoryCacheSystem().createFile('$cacheKey.json'),
    ),
    fileSystem: MemoryCacheSystem(),
    fileService: HttpFileService(httpClient: gitHub),
  );
}

class PackageDefaultCacheInMemory {
  PackageDefaultCacheInMemory(this.manager);

  final CacheManager manager;
  var creations = 0;

  BaseCacheManager create() {
    creations++;
    return manager;
  }
}

Future<PackageDefaultCacheInMemory> packageDefaultCacheInMemory() async {
  return PackageDefaultCacheInMemory(
    CacheManager(await configInMemory('libCachedImageData')),
  );
}

Future<PokemonImageCache> imageCacheInMemory({
  PackageDefaultCacheInMemory? packageDefaultCache,
}) async {
  final defaultCache =
      packageDefaultCache ?? await packageDefaultCacheInMemory();
  return PokemonImageCache(
    config: await configInMemory(pokemonImageCacheKey),
    packageDefaultCache: defaultCache.create,
  );
}

void main() {
  test('la caché propia guarda hasta 2500 imágenes y 180 días sin uso', () {
    expect(pokemonImageCacheKey, 'pokemonImages');
    expect(pokemonImageCacheCapacity, 2500);
    expect(pokemonImageMaxIdle, const Duration(days: 180));
  });

  test('una imagen descargada queda guardada y las demás no', () async {
    final images = await imageCacheInMemory();

    await images.save(pikachuUrl);

    expect(await images.isSaved(pikachuUrl), isTrue);
    expect(await images.isSaved(eeveeUrl), isFalse);
  });

  test('solo informa las URL pedidas que están guardadas', () async {
    final images = await imageCacheInMemory();
    await images.save(pikachuUrl);
    await images.save(eeveeUrl);

    final saved = await images.savedUrlsAmong({pikachuUrl, missingUrl});

    expect(saved, {pikachuUrl});
  });

  test('suma los bytes de las imágenes guardadas', () async {
    final images = await imageCacheInMemory();
    await images.save(pikachuUrl);
    await images.save(eeveeUrl);

    expect(await images.savedBytes(), 8);
  });

  test(
    'una imagen cuyo archivo borró el sistema ya no cuenta como guardada',
    () async {
      final images = await imageCacheInMemory();
      await images.save(pikachuUrl);
      await images.save(eeveeUrl);
      final pikachuFile = await images.manager.getFileFromCache(pikachuUrl);

      await pikachuFile!.file.delete();

      expect(await images.isSaved(pikachuUrl), isFalse);
      expect(await images.savedUrlsAmong({pikachuUrl, eeveeUrl}), {eeveeUrl});
      expect(await images.savedBytes(), 5);
    },
  );

  test('una descarga fallida no guarda nada', () async {
    final images = await imageCacheInMemory();

    await expectLater(images.save(missingUrl), throwsA(anything));

    expect(await images.isSaved(missingUrl), isFalse);
    expect(await images.savedBytes(), 0);
  });

  test('borrar las imágenes deja la caché vacía', () async {
    final images = await imageCacheInMemory();
    await images.save(pikachuUrl);
    await images.save(eeveeUrl);

    await images.deleteAll();

    expect(await images.savedUrlsAmong({pikachuUrl, eeveeUrl}), isEmpty);
    expect(await images.savedBytes(), 0);
  });

  test('borrar también vacía la caché por defecto que usaban las versiones anteriores', () async {
    final packageDefaultCache = await packageDefaultCacheInMemory();
    await packageDefaultCache.manager.downloadFile(eeveeUrl);
    final images = await imageCacheInMemory(
      packageDefaultCache: packageDefaultCache,
    );

    await images.deleteAll();

    expect(
      await packageDefaultCache.manager.getFileFromCache(eeveeUrl),
      isNull,
    );
  });

  test('solo crea la caché por defecto del paquete al borrar', () async {
    final packageDefaultCache = await packageDefaultCacheInMemory();
    final images = await imageCacheInMemory(
      packageDefaultCache: packageDefaultCache,
    );

    await images.save(pikachuUrl);
    await images.isSaved(pikachuUrl);
    await images.savedUrlsAmong({pikachuUrl});
    await images.savedBytes();
    expect(packageDefaultCache.creations, 0);

    await images.deleteAll();
    expect(packageDefaultCache.creations, 1);
  });

  test('las imágenes guardadas no pasan por la caché por defecto', () async {
    final packageDefaultCache = await packageDefaultCacheInMemory();
    final images = await imageCacheInMemory(
      packageDefaultCache: packageDefaultCache,
    );

    await images.save(pikachuUrl);

    expect(
      await packageDefaultCache.manager.getFileFromCache(pikachuUrl),
      isNull,
    );
    expect(await images.isSaved(pikachuUrl), isTrue);
  });
}
