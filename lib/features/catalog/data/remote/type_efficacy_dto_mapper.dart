import 'package:pokedex_flutter/features/catalog/data/local/type_efficacy_entry.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/type_efficacy_dto.dart';

extension TypeEfficacyDtoToEntry on TypeEfficacyDto {
  TypeEfficacyEntry toTypeEfficacyEntry() {
    return TypeEfficacyEntry(
      attackingType: attackingType,
      defendingType: defendingType,
      damageFactor: damageFactor,
    );
  }
}
