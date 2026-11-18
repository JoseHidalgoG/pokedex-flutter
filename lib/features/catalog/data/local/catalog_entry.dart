class CatalogEntry {
  const CatalogEntry({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.typeNames,
    this.speciesId,
    this.generationId,
    this.isDefault = true,
    this.heightDm,
    this.weightHg,
    this.baseStats = const {},
  });

  final int id;
  final String name;
  final String imageUrl;
  final List<String> typeNames;
  final int? speciesId;
  final int? generationId;
  final bool isDefault;
  final int? heightDm;
  final int? weightHg;
  final Map<String, int> baseStats;

  int? get baseStatTotal {
    if (baseStats.isEmpty) {
      return null;
    }
    return baseStats.values.fold<int>(0, (total, baseStat) => total + baseStat);
  }
}
