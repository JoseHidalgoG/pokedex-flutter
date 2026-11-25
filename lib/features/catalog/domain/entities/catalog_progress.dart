class CatalogProgress {
  const CatalogProgress({
    required this.savedCount,
    this.totalCount,
    required this.isComplete,
  });

  final int savedCount;
  final int? totalCount;
  final bool isComplete;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogProgress &&
          other.savedCount == savedCount &&
          other.totalCount == totalCount &&
          other.isComplete == isComplete;

  @override
  int get hashCode => Object.hash(savedCount, totalCount, isComplete);

  @override
  String toString() =>
      'CatalogProgress(savedCount: $savedCount, '
      'totalCount: $totalCount, '
      'isComplete: $isComplete)';
}
