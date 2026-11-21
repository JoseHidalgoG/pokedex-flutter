sealed class DetailFreshness {
  const DetailFreshness();
}

final class FreshFromPokeApi extends DetailFreshness {
  const FreshFromPokeApi(this.at);

  final DateTime at;

  @override
  bool operator ==(Object other) => other is FreshFromPokeApi && other.at == at;

  @override
  int get hashCode => Object.hash(FreshFromPokeApi, at);

  @override
  String toString() => 'FreshFromPokeApi($at)';
}

final class LocalData extends DetailFreshness {
  const LocalData({this.savedAt});

  final DateTime? savedAt;

  bool get hasStoredDetail => savedAt != null;

  @override
  bool operator ==(Object other) =>
      other is LocalData && other.savedAt == savedAt;

  @override
  int get hashCode => Object.hash(LocalData, savedAt);

  @override
  String toString() => 'LocalData(savedAt: $savedAt)';
}

DetailFreshness detailFreshnessOf({
  required DateTime? revalidatedThisSessionAt,
  required DateTime? savedAt,
}) {
  if (revalidatedThisSessionAt != null) {
    return FreshFromPokeApi(revalidatedThisSessionAt);
  }
  return LocalData(savedAt: savedAt);
}
