class CatalogProgress {
  const CatalogProgress({required this.savedCount, this.totalCount});

  final int savedCount;
  final int? totalCount;

  bool get isComplete => switch (totalCount) {
    final total? => savedCount >= total,
    null => false,
  };

  @override
  bool operator ==(Object other) =>
      other is CatalogProgress &&
      other.savedCount == savedCount &&
      other.totalCount == totalCount;

  @override
  int get hashCode => Object.hash(savedCount, totalCount);

  @override
  String toString() =>
      'CatalogProgress(savedCount: $savedCount, totalCount: $totalCount)';
}
