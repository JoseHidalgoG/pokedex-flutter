import 'dart:async';

import 'package:pokedex_flutter/features/catalog/domain/entities/detail_freshness.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_detail.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/type_matchups.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/pokemon_detail_repository.dart';

class FakePokemonDetailRepository implements PokemonDetailRepository {
  final _details = <int, PokemonDetail?>{};
  final _freshness = <int, DetailFreshness>{};
  List<TypeEfficacy> _typeEfficacy = const [];

  final _detailChanges = StreamController<int>.broadcast(sync: true);
  final _freshnessChanges = StreamController<int>.broadcast(sync: true);
  final _typeEfficacyChanges = StreamController<void>.broadcast(sync: true);

  final revalidations = <({int id, bool force})>[];
  final stoppedIds = <int>[];
  final idsSavedForOffline = <int>[];

  void emitDetail(int pokemonId, PokemonDetail? detail) {
    _details[pokemonId] = detail;
    _detailChanges.add(pokemonId);
  }

  void emitFreshness(int pokemonId, DetailFreshness freshness) {
    _freshness[pokemonId] = freshness;
    _freshnessChanges.add(pokemonId);
  }

  void emitTypeEfficacy(List<TypeEfficacy> rows) {
    _typeEfficacy = rows;
    _typeEfficacyChanges.add(null);
  }

  @override
  Stream<PokemonDetail?> watchPokemonDetail(int pokemonId) async* {
    if (_details.containsKey(pokemonId)) {
      yield _details[pokemonId];
    }
    await for (final changedId in _detailChanges.stream) {
      if (changedId == pokemonId) {
        yield _details[pokemonId];
      }
    }
  }

  @override
  Stream<DetailFreshness> watchPokemonDetailFreshness(int pokemonId) async* {
    yield _freshness[pokemonId] ?? const LocalData();
    await for (final changedId in _freshnessChanges.stream) {
      if (changedId == pokemonId) {
        yield _freshness[pokemonId]!;
      }
    }
  }

  @override
  Stream<List<TypeEfficacy>> watchTypeEfficacy() async* {
    yield _typeEfficacy;
    await for (final _ in _typeEfficacyChanges.stream) {
      yield _typeEfficacy;
    }
  }

  @override
  Future<void> revalidatePokemonDetail(
    int pokemonId, {
    bool force = false,
  }) async {
    revalidations.add((id: pokemonId, force: force));
  }

  @override
  void stopRevalidatingPokemonDetail(int pokemonId) {
    stoppedIds.add(pokemonId);
  }

  @override
  Future<void> saveDetailForOffline(int pokemonId) async {
    idsSavedForOffline.add(pokemonId);
  }

  Future<void> dispose() async {
    await _detailChanges.close();
    await _freshnessChanges.close();
    await _typeEfficacyChanges.close();
  }
}
