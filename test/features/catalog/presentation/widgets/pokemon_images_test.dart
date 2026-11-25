import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokedex_flutter/core/images/pokemon_image_cache_providers.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/detail/detail_artwork.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/pokemon_artwork_hero_tag.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/pokemon_cached_image.dart';

class MockCacheManager extends Mock implements BaseCacheManager {}

const pikachu = Pokemon(
  id: 25,
  name: 'pikachu',
  imageUrl: 'https://example.com/official-artwork/25.png',
  typeNames: ['electric'],
);

void main() {
  late MockCacheManager cacheManager;

  setUp(() {
    cacheManager = MockCacheManager();
    when(
      () => cacheManager.getFileStream(
        any(),
        key: any(named: 'key'),
        headers: any(named: 'headers'),
        withProgress: any(named: 'withProgress'),
      ),
    ).thenAnswer((_) => StreamController<FileResponse>().stream);
  });

  Future<void> pumpWithImages(
    WidgetTester tester,
    Widget child, {
    double devicePixelRatio = 3,
  }) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          pokemonImageCacheManagerProvider.overrideWithValue(cacheManager),
        ],
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(devicePixelRatio: devicePixelRatio),
            child: Scaffold(body: Center(child: child)),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'la imagen de la lista usa la caché propia y decodifica a su tamaño físico',
    (tester) async {
      await pumpWithImages(
        tester,
        const PokemonCachedImage(
          imageUrl: 'https://example.com/1.png',
          size: 76,
        ),
      );

      final image = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(image.cacheManager, same(cacheManager));
      expect(image.memCacheWidth, 228);
    },
  );

  testWidgets('sin URL muestra el icono sin pedir ninguna imagen', (
    tester,
  ) async {
    await pumpWithImages(
      tester,
      const PokemonCachedImage(imageUrl: '', size: 76),
    );

    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.byIcon(Icons.catching_pokemon), findsOneWidget);
  });

  testWidgets(
    'el artwork del detalle usa la caché propia, su tamaño físico y el Hero del Pokémon',
    (tester) async {
      await pumpWithImages(
        tester,
        DetailArtwork(
          pokemon: pikachu,
          showsShiny: false,
          onShinyUnavailable: () {},
        ),
        devicePixelRatio: 2,
      );

      final image = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(image.imageUrl, pikachu.imageUrl);
      expect(image.cacheManager, same(cacheManager));
      expect(image.memCacheWidth, 264);
      expect(
        tester.widget<Hero>(find.byType(Hero)).tag,
        pokemonArtworkHeroTag(25),
      );
    },
  );

  test('cada Pokémon tiene su propia etiqueta de Hero', () {
    expect(pokemonArtworkHeroTag(25), pokemonArtworkHeroTag(25));
    expect(pokemonArtworkHeroTag(25), isNot(pokemonArtworkHeroTag(26)));
  });
}
