import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_detail.dart';
import 'package:pokedex_flutter/features/catalog/presentation/texts/pokemon_texts.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

void main() {
  final spanish = lookupAppLocalizations(const Locale('es'));
  final english = lookupAppLocalizations(const Locale('en'));

  test(
    'prettifiedIdentifier convierte identificadores de PokeAPI en texto',
    () {
      expect(prettifiedIdentifier('thunder-stone'), 'Thunder Stone');
      expect(prettifiedIdentifier('scarlet-violet'), 'Scarlet Violet');
      expect(prettifiedIdentifier('red'), 'Red');
      expect(prettifiedIdentifier(''), '');
    },
  );

  test('pokedexNumberOf rellena con ceros hasta cuatro cifras', () {
    expect(pokedexNumberOf(25), '#0025');
    expect(pokedexNumberOf(1025), '#1025');
    expect(pokedexNumberOf(10080), '#10080');
  });

  test('formLabelOf quita el nombre de la forma base', () {
    expect(formLabelOf('pikachu', baseFormName: 'pikachu'), 'Pikachu');
    expect(
      formLabelOf('pikachu-rock-star', baseFormName: 'pikachu'),
      'Rock Star',
    );
    expect(
      formLabelOf('deoxys-attack', baseFormName: 'deoxys-normal'),
      'Deoxys Attack',
    );
  });

  test('traduce los grupos huevo con los nombres de PokeAPI', () {
    final expectedNames = {
      'monster': ('Monstruo', 'Monster'),
      'water1': ('Agua 1', 'Water 1'),
      'water2': ('Agua 2', 'Water 2'),
      'water3': ('Agua 3', 'Water 3'),
      'bug': ('Bicho', 'Bug'),
      'flying': ('Volador', 'Flying'),
      'ground': ('Campo', 'Field'),
      'fairy': ('Hada', 'Fairy'),
      'plant': ('Planta', 'Grass'),
      'humanshape': ('Humanoide', 'Human-Like'),
      'mineral': ('Mineral', 'Mineral'),
      'indeterminate': ('Amorfo', 'Amorphous'),
      'ditto': ('Ditto', 'Ditto'),
      'dragon': ('Dragón', 'Dragon'),
      'no-eggs': ('Desconocido', 'Undiscovered'),
    };

    for (final MapEntry(key: eggGroup, value: (spanishName, englishName))
        in expectedNames.entries) {
      expect(localizedEggGroup(eggGroup, spanish), spanishName);
      expect(localizedEggGroup(eggGroup, english), englishName);
    }
    expect(localizedEggGroup('new-group', spanish), 'New Group');
  });

  test('traduce tipos, estadísticas y métodos de aprendizaje', () {
    expect(localizedTypeName('electric', spanish), 'Eléctrico');
    expect(localizedTypeName('stellar', spanish), 'Stellar');
    expect(localizedStatName(PokemonStat.hp, spanish), 'PS');
    expect(localizedStatName(PokemonStat.specialAttack, english), 'Sp. Atk');
    expect(localizedLearnMethod(MoveLearnMethod.machine, spanish), 'MT');
    expect(localizedLearnMethod(MoveLearnMethod.machine, english), 'TM');
  });
}
