import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query.dart';

class CatalogPageRequest {
  const CatalogPageRequest({
    required this.page,
    required this.pageSize,
    required this.query,
  });

  final int page;
  final int pageSize;
  final CatalogQuery query;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CatalogPageRequest &&
            other.page == page &&
            other.pageSize == pageSize &&
            other.query == query;
  }

  @override
  int get hashCode => Object.hash(page, pageSize, query);
}
