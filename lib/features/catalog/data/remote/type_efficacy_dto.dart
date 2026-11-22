class TypeEfficacyDto {
  const TypeEfficacyDto({
    required this.attackingType,
    required this.defendingType,
    required this.damageFactor,
  });

  factory TypeEfficacyDto.fromJson(Object? json) {
    if (json case {
      'damage_factor': final int damageFactor,
      'type': {'name': final String attackingType},
      'TypeByTargetTypeId': {'name': final String defendingType},
    }) {
      return TypeEfficacyDto(
        attackingType: attackingType,
        defendingType: defendingType,
        damageFactor: damageFactor,
      );
    }
    throw FormatException(
      'Fila de la tabla de tipos con formato inesperado',
      json,
    );
  }

  final String attackingType;
  final String defendingType;
  final int damageFactor;
}
