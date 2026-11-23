import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_detail.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

String prettifiedIdentifier(String identifier) {
  return identifier
      .split('-')
      .where((word) => word.isNotEmpty)
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

String displayNameOf(String pokemonName) => prettifiedIdentifier(pokemonName);

String pokedexNumberOf(int pokemonId) {
  return '#${pokemonId.toString().padLeft(4, '0')}';
}

String formLabelOf(String formName, {required String baseFormName}) {
  final baseFormPrefix = '$baseFormName-';
  return prettifiedIdentifier(
    formName.startsWith(baseFormPrefix)
        ? formName.substring(baseFormPrefix.length)
        : formName,
  );
}

String localizedTypeName(String typeName, AppLocalizations l10n) {
  return switch (typeName) {
    'normal' => l10n.pokemonTypeNormal,
    'fire' => l10n.pokemonTypeFire,
    'water' => l10n.pokemonTypeWater,
    'electric' => l10n.pokemonTypeElectric,
    'grass' => l10n.pokemonTypeGrass,
    'ice' => l10n.pokemonTypeIce,
    'fighting' => l10n.pokemonTypeFighting,
    'poison' => l10n.pokemonTypePoison,
    'ground' => l10n.pokemonTypeGround,
    'flying' => l10n.pokemonTypeFlying,
    'psychic' => l10n.pokemonTypePsychic,
    'bug' => l10n.pokemonTypeBug,
    'rock' => l10n.pokemonTypeRock,
    'ghost' => l10n.pokemonTypeGhost,
    'dragon' => l10n.pokemonTypeDragon,
    'dark' => l10n.pokemonTypeDark,
    'steel' => l10n.pokemonTypeSteel,
    'fairy' => l10n.pokemonTypeFairy,
    _ => prettifiedIdentifier(typeName),
  };
}

String localizedEggGroup(String eggGroup, AppLocalizations l10n) {
  return switch (eggGroup) {
    'monster' => l10n.eggGroupMonster,
    'water1' => l10n.eggGroupWater1,
    'water2' => l10n.eggGroupWater2,
    'water3' => l10n.eggGroupWater3,
    'bug' => l10n.eggGroupBug,
    'flying' => l10n.eggGroupFlying,
    'ground' => l10n.eggGroupField,
    'fairy' => l10n.eggGroupFairy,
    'plant' => l10n.eggGroupGrass,
    'humanshape' => l10n.eggGroupHumanLike,
    'mineral' => l10n.eggGroupMineral,
    'indeterminate' => l10n.eggGroupAmorphous,
    'ditto' => l10n.eggGroupDitto,
    'dragon' => l10n.eggGroupDragon,
    'no-eggs' => l10n.eggGroupUndiscovered,
    _ => prettifiedIdentifier(eggGroup),
  };
}

String localizedStatName(PokemonStat stat, AppLocalizations l10n) {
  return switch (stat) {
    PokemonStat.hp => l10n.statHp,
    PokemonStat.attack => l10n.statAttack,
    PokemonStat.defense => l10n.statDefense,
    PokemonStat.specialAttack => l10n.statSpecialAttack,
    PokemonStat.specialDefense => l10n.statSpecialDefense,
    PokemonStat.speed => l10n.statSpeed,
  };
}

String localizedLearnMethod(MoveLearnMethod method, AppLocalizations l10n) {
  return switch (method) {
    MoveLearnMethod.levelUp => l10n.moveMethodLevelUp,
    MoveLearnMethod.machine => l10n.moveMethodMachine,
    MoveLearnMethod.tutor => l10n.moveMethodTutor,
    MoveLearnMethod.egg => l10n.moveMethodEgg,
  };
}
