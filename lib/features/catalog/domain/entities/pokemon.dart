class Pokemon {
  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.typeNames,
  });

  final int id;
  final String name;
  final String imageUrl;
  final List<String> typeNames;
}
