enum CatalogSort {
  numberAscending,
  numberDescending,
  nameAscending,
  nameDescending,
  baseStatTotalAscending,
  baseStatTotalDescending,
}

class CatalogQuery {
  const CatalogQuery({
    this.search = '',
    this.type,
    this.sort = CatalogSort.numberAscending,
  });

  final String search;
  final String? type;
  final CatalogSort sort;

  CatalogQuery copyWith({
    String? search,
    String? type,
    bool clearType = false,
    CatalogSort? sort,
  }) {
    return CatalogQuery(
      search: search ?? this.search,
      type: clearType ? null : (type ?? this.type),
      sort: sort ?? this.sort,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CatalogQuery &&
            other.search == search &&
            other.type == type &&
            other.sort == sort;
  }

  @override
  int get hashCode => Object.hash(search, type, sort);
}
