import 'dart:convert';

import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query_state.dart';

class CatalogQueryCodec {
  const CatalogQueryCodec();

  static const _supportedTypes = {
    'normal',
    'fire',
    'water',
    'electric',
    'grass',
    'ice',
    'fighting',
    'poison',
    'ground',
    'flying',
    'psychic',
    'bug',
    'rock',
    'ghost',
    'dragon',
    'dark',
    'steel',
    'fairy',
  };

  String encode(CatalogQueryState state) {
    final query = state.query;

    final types = query.types.toList()..sort();
    final generations = query.generations.toList()..sort();

    return jsonEncode({
      'version': 1,
      'search': query.search,
      'types': types,
      'generations': generations,
      'sort': query.sort.name,
      'page': state.page,
    });
  }

  CatalogQueryState decode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return CatalogQueryState.initial();
    }

    try {
      final decoded = jsonDecode(value);

      if (decoded is! Map<String, dynamic>) {
        return CatalogQueryState.initial();
      }

      final version = decoded['version'];

      if (version != null && version != 1) {
        return CatalogQueryState.initial();
      }

      return CatalogQueryState(
        query: CatalogQuery(
          search: _decodeSearch(decoded['search']),
          types: _decodeTypes(decoded['types']),
          generations: _decodeGenerations(decoded['generations']),
          sort: _decodeSort(decoded['sort']),
        ),
        page: _decodePage(decoded['page']),
      );
    } on FormatException {
      return CatalogQueryState.initial();
    }
  }

  String _decodeSearch(Object? value) {
    return value is String ? value.trim() : '';
  }

  Set<String> _decodeTypes(Object? value) {
    if (value is! List) {
      return {};
    }

    return value
        .whereType<String>()
        .map((type) => type.trim().toLowerCase())
        .where(_supportedTypes.contains)
        .toSet();
  }

  Set<int> _decodeGenerations(Object? value) {
    if (value is! List) {
      return {};
    }

    return value
        .whereType<int>()
        .where((generation) => generation >= 1 && generation <= 9)
        .toSet();
  }

  CatalogSort _decodeSort(Object? value) {
    for (final sort in CatalogSort.values) {
      if (sort.name == value) {
        return sort;
      }
    }

    return CatalogSort.numberAscending;
  }

  int _decodePage(Object? value) {
    return value is int && value >= 0 ? value : 0;
  }
}
