import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/detail_freshness.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_detail.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/type_matchups.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/pokemon_detail_repository.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/revalidate_pokemon_detail.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/stop_revalidating_pokemon_detail.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/watch_pokemon_detail.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/watch_pokemon_detail_freshness.dart';
import 'package:pokedex_flutter/features/catalog/domain/usecases/watch_type_efficacy.dart';

final pokemonDetailRepositoryProvider = Provider<PokemonDetailRepository>(
  (ref) => throw UnimplementedError(
    'pokemonDetailRepositoryProvider debe sobrescribirse en ProviderScope',
  ),
);

final watchPokemonDetailProvider = Provider<WatchPokemonDetail>(
  (ref) => WatchPokemonDetail(ref.watch(pokemonDetailRepositoryProvider)),
);

final watchPokemonDetailFreshnessProvider =
    Provider<WatchPokemonDetailFreshness>(
      (ref) => WatchPokemonDetailFreshness(
        ref.watch(pokemonDetailRepositoryProvider),
      ),
    );

final watchTypeEfficacyProvider = Provider<WatchTypeEfficacy>(
  (ref) => WatchTypeEfficacy(ref.watch(pokemonDetailRepositoryProvider)),
);

final revalidatePokemonDetailProvider = Provider<RevalidatePokemonDetail>(
  (ref) => RevalidatePokemonDetail(ref.watch(pokemonDetailRepositoryProvider)),
);

final stopRevalidatingPokemonDetailProvider =
    Provider<StopRevalidatingPokemonDetail>(
      (ref) => StopRevalidatingPokemonDetail(
        ref.watch(pokemonDetailRepositoryProvider),
      ),
    );

final pokemonDetailProvider = StreamProvider.autoDispose
    .family<PokemonDetail?, int>((ref, pokemonId) {
      final revalidatePokemonDetail = ref.watch(
        revalidatePokemonDetailProvider,
      );
      final stopRevalidatingPokemonDetail = ref.watch(
        stopRevalidatingPokemonDetailProvider,
      );
      var hasEmitted = false;

      void revalidateDetail() {
        unawaited(revalidatePokemonDetail(pokemonId));
      }

      ref
        ..onResume(revalidateDetail)
        ..onDispose(() => stopRevalidatingPokemonDetail(pokemonId));

      return ref.watch(watchPokemonDetailProvider)(pokemonId).map((detail) {
        if (!hasEmitted) {
          hasEmitted = true;
          revalidateDetail();
        }
        return detail;
      });
    });

final pokemonDetailFreshnessProvider = StreamProvider.autoDispose
    .family<DetailFreshness, int>(
      (ref, pokemonId) =>
          ref.watch(watchPokemonDetailFreshnessProvider)(pokemonId),
    );

final typeEfficacyProvider = StreamProvider.autoDispose<List<TypeEfficacy>>(
  (ref) => ref.watch(watchTypeEfficacyProvider)(),
);
