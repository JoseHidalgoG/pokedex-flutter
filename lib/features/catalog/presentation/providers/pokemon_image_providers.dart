import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/pokemon_image_repository.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/delete_saved_images.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/get_pokemon_ids_with_saved_artwork.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/get_saved_images_size.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/keep_pokemon_offline.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/save_all_artwork.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/save_artwork_of.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/pokemon_detail_providers.dart';

final pokemonImageRepositoryProvider = Provider<PokemonImageRepository>(
  (ref) => throw UnimplementedError(
    'pokemonImageRepositoryProvider debe sobrescribirse en ProviderScope',
  ),
);

final getPokemonIdsWithSavedArtworkProvider =
    Provider<GetPokemonIdsWithSavedArtwork>(
      (ref) => GetPokemonIdsWithSavedArtwork(
        ref.watch(pokemonImageRepositoryProvider),
      ),
    );

final saveArtworkOfProvider = Provider<SaveArtworkOf>(
  (ref) => SaveArtworkOf(ref.watch(pokemonImageRepositoryProvider)),
);

final saveAllArtworkProvider = Provider<SaveAllArtwork>(
  (ref) => SaveAllArtwork(ref.watch(pokemonImageRepositoryProvider)),
);

final getSavedImagesSizeProvider = Provider<GetSavedImagesSize>(
  (ref) => GetSavedImagesSize(ref.watch(pokemonImageRepositoryProvider)),
);

final deleteSavedImagesProvider = Provider<DeleteSavedImages>(
  (ref) => DeleteSavedImages(ref.watch(pokemonImageRepositoryProvider)),
);

final keepPokemonOfflineProvider = Provider<KeepPokemonOffline>(
  (ref) => KeepPokemonOffline(
    images: ref.watch(pokemonImageRepositoryProvider),
    details: ref.watch(pokemonDetailRepositoryProvider),
  ),
);
