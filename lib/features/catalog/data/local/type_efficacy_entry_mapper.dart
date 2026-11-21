import 'package:pokedex_flutter/features/catalog/data/local/type_efficacy_entry.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/type_matchups.dart';

extension TypeEfficacyEntryToTypeEfficacy on TypeEfficacyEntry {
  TypeEfficacy toTypeEfficacy() {
    return TypeEfficacy(
      attackingType: attackingType,
      defendingType: defendingType,
      damageFactor: damageFactor,
    );
  }
}
