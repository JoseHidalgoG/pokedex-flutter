import 'dart:async';

import 'package:pokedex_flutter/core/sync/domain/call_budget.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_batch.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_remote_data_source.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_detail_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/type_efficacy_dto.dart';

import '../../../fixtures/pokemon_detail_fixture.dart';

class PokeApiDetails implements CatalogRemoteDataSource {
  PokeApiDetails({List<TypeEfficacyDto>? typeTable})
    : typeTable = typeTable ?? savedTypeTable();

  List<TypeEfficacyDto> typeTable;
  Completer<void>? heldDetails;
  final detailRequests = <int>[];
  final typeTableRequests = <CallPriority>[];

  static List<TypeEfficacyDto> savedTypeTable() => [
    for (final row in savedTypeEfficacyRows()) TypeEfficacyDto.fromJson(row),
  ];

  @override
  Future<PokemonDetailDto?> fetchPokemonDetail(int id) async {
    detailRequests.add(id);
    await heldDetails?.future;
    return switch (id) {
      25 => PokemonDetailDto.fromJson(savedPokemonDetailJson('pikachu')),
      133 => PokemonDetailDto.fromJson(savedPokemonDetailJson('eevee')),
      _ => null,
    };
  }

  @override
  Future<List<TypeEfficacyDto>> fetchTypeEfficacy({
    CallPriority priority = CallPriority.background,
  }) async {
    typeTableRequests.add(priority);
    return typeTable;
  }

  @override
  Future<CatalogBatch> fetchCatalogPage({
    required int limit,
    required int offset,
    bool withTotal = false,
  }) {
    throw UnimplementedError('el detalle no pide páginas del catálogo');
  }

  @override
  Future<List<PokemonDto>> fetchPokemonByIds(
    List<int> ids, {
    CallPriority priority = CallPriority.user,
  }) {
    throw UnimplementedError('el detalle no pide Pokémon por ids');
  }
}
