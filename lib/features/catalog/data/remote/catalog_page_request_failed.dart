class CatalogPageRequestFailed implements Exception {
  const CatalogPageRequestFailed(this.cause);

  final Object cause;

  @override
  String toString() => 'CatalogPageRequestFailed: $cause';
}
