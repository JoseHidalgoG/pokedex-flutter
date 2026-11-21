import 'package:pokedex_flutter/features/catalog/data/remote/pokeapi_names.dart';

class MoveDto {
  const MoveDto({
    required this.id,
    required this.identifier,
    required this.learnMethod,
    required this.level,
    required this.versionGroup,
    required this.versionGroupOrder,
    this.typeName,
    this.namesByLanguage = const {},
  });

  factory MoveDto.fromJson(Object? json) {
    if (json case {
      'level': final int level,
      'movelearnmethod': {'name': final String learnMethod},
      'versiongroup': {
        'name': final String versionGroup,
        'order': final int versionGroupOrder,
      },
      'move': {
        'id': final int id,
        'name': final String identifier,
        'type': final Object? type,
        'movenames': final List<Object?> names,
      },
    }) {
      return MoveDto(
        id: id,
        identifier: identifier,
        learnMethod: learnMethod,
        level: level,
        versionGroup: versionGroup,
        versionGroupOrder: versionGroupOrder,
        typeName: optionalNameIn(type),
        namesByLanguage: namesByLanguageIn(names),
      );
    }
    throw FormatException('Movimiento con formato inesperado', json);
  }

  final int id;
  final String identifier;
  final String learnMethod;
  final int level;
  final String versionGroup;
  final int versionGroupOrder;
  final String? typeName;
  final Map<String, String> namesByLanguage;
}
