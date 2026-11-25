enum CatalogSort {
  numberAscending,
  numberDescending,
  nameAscending,
  nameDescending,
  baseStatTotalAscending,
  baseStatTotalDescending,
}

class CatalogQuery {
  CatalogQuery({
    this.search = '',
    Set<String> types = const {},
    Set<int> generations = const {},
    this.sort = CatalogSort.numberAscending,
  }) : types = Set<String>.unmodifiable(types),
       generations = Set<int>.unmodifiable(generations);

  final String search;
  final Set<String> types;
  final Set<int> generations;
  final CatalogSort sort;

  CatalogQuery copyWith({
    String? search,
    Set<String>? types,
    Set<int>? generations,
    CatalogSort? sort,
  }) {
    return CatalogQuery(
      search: search ?? this.search,
      types: types ?? this.types,
      generations: generations ?? this.generations,
      sort: sort ?? this.sort,
    );
  }

  static bool _sameSet<T>(Set<T> first, Set<T> second) {
    return first.length == second.length && first.containsAll(second);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CatalogQuery &&
            other.search == search &&
            _sameSet(other.types, types) &&
            _sameSet(other.generations, generations) &&
            other.sort == sort;
  }

  @override
  int get hashCode => Object.hash(
    search,
    Object.hashAllUnordered(types),
    Object.hashAllUnordered(generations),
    sort,
  );
}
