import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';

String catalogFingerprintOf(CatalogEntry entry) {
  return sha256.convert(utf8.encode(_canonicalTextOf(entry))).toString();
}

bool differsFromStoredFingerprint(
  CatalogEntry entry, {
  required String? stored,
}) {
  return stored != null && stored != catalogFingerprintOf(entry);
}

List<int> idsWithDifferentStoredFingerprint(
  List<CatalogEntry> freshEntries, {
  required Map<int, String?> storedFingerprints,
}) {
  return [
    for (final entry in freshEntries)
      if (differsFromStoredFingerprint(
        entry,
        stored: storedFingerprints[entry.id],
      ))
        entry.id,
  ];
}

String _canonicalTextOf(CatalogEntry entry) {
  final statNames = entry.baseStats.keys.toList()..sort();
  final stats = [
    for (final statName in statNames) '$statName:${entry.baseStats[statName]}',
  ];
  return [
    'name=${entry.name}',
    'types=${entry.typeNames.join(',')}',
    'generation=${entry.generationId ?? ''}',
    'species=${entry.speciesId ?? ''}',
    'stats=${stats.join(',')}',
    'height=${entry.heightDm ?? ''}',
    'weight=${entry.weightHg ?? ''}',
  ].join('\n');
}
