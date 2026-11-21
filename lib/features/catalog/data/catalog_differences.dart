import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';

const missingValue = '∅';

List<String> catalogDifferencesBetween(
  CatalogEntry local,
  CatalogEntry remote,
) {
  return [
    ?_differenceIn('name', local.name, remote.name),
    ?_differenceIn('types', _joinedTypesOf(local), _joinedTypesOf(remote)),
    ?_differenceIn('generation', local.generationId, remote.generationId),
    ?_differenceIn('species', local.speciesId, remote.speciesId),
    for (final statName in _statNamesIn(local, remote))
      ?_differenceIn(
        'stats.$statName',
        local.baseStats[statName],
        remote.baseStats[statName],
      ),
    ?_differenceIn('height', local.heightDm, remote.heightDm),
    ?_differenceIn('weight', local.weightHg, remote.weightHg),
  ];
}

String? _differenceIn(String field, Object? local, Object? remote) {
  if (local == remote) {
    return null;
  }
  return '$field: ${local ?? missingValue} → ${remote ?? missingValue}';
}

String? _joinedTypesOf(CatalogEntry entry) {
  return entry.typeNames.isEmpty ? null : entry.typeNames.join(',');
}

List<String> _statNamesIn(CatalogEntry local, CatalogEntry remote) {
  return {...local.baseStats.keys, ...remote.baseStats.keys}.toList()..sort();
}
