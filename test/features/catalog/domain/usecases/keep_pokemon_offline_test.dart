import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/keep_pokemon_offline.dart';

import '../../fakes/fake_pokemon_detail_repository.dart';
import '../../fakes/fake_pokemon_image_repository.dart';

void main() {
  late FakePokemonImageRepository images;
  late FakePokemonDetailRepository details;
  late KeepPokemonOffline keepPokemonOffline;

  setUp(() {
    images = FakePokemonImageRepository();
    details = FakePokemonDetailRepository();
    addTearDown(details.dispose);
    keepPokemonOffline = KeepPokemonOffline(images: images, details: details);
  });

  test('guarda el artwork y el detalle del mismo Pokémon', () async {
    await keepPokemonOffline(25);

    expect(images.artworkRequests, [25]);
    expect(images.savedIds, {25});
    expect(details.idsSavedForOffline, [25]);
  });

  test(
    'si el artwork no se descarga igual guarda el detalle y no lanza',
    () async {
      images.artworkDownloadsFail = true;

      await keepPokemonOffline(133);

      expect(images.savedIds, isEmpty);
      expect(details.idsSavedForOffline, [133]);
    },
  );
}
