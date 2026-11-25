class ArtworkSaveProgress {
  const ArtworkSaveProgress({
    required this.saved,
    required this.failed,
    required this.total,
  });

  final int saved;
  final int failed;
  final int total;

  bool get isDone => saved + failed >= total;

  ArtworkSaveProgress afterDownload({required bool succeeded}) {
    return ArtworkSaveProgress(
      saved: succeeded ? saved + 1 : saved,
      failed: succeeded ? failed : failed + 1,
      total: total,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ArtworkSaveProgress &&
      other.saved == saved &&
      other.failed == failed &&
      other.total == total;

  @override
  int get hashCode => Object.hash(saved, failed, total);

  @override
  String toString() =>
      'ArtworkSaveProgress(saved: $saved, failed: $failed, total: $total)';
}
