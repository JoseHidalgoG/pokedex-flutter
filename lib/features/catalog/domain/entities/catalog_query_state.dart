import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query.dart';

class CatalogQueryState {
  const CatalogQueryState({required this.query, this.page = 0});

  factory CatalogQueryState.initial() {
    return CatalogQueryState(query: CatalogQuery());
  }

  final CatalogQuery query;
  final int page;

  CatalogQueryState copyWith({CatalogQuery? query, int? page}) {
    return CatalogQueryState(
      query: query ?? this.query,
      page: page ?? this.page,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CatalogQueryState &&
            other.query == query &&
            other.page == page;
  }

  @override
  int get hashCode => Object.hash(query, page);
}
