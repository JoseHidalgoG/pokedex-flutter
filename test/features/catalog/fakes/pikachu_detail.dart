import 'package:pokedex_flutter/features/catalog/domain/entities/evolution_tree.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/localized_text.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_detail.dart';

const pikachu = Pokemon(
  id: 25,
  name: 'pikachu',
  imageUrl: '',
  typeNames: ['electric'],
);

const pikachuRockStar = Pokemon(
  id: 10080,
  name: 'pikachu-rock-star',
  imageUrl: '',
  typeNames: ['electric'],
);

const thunderShock = PokemonMove(
  id: 84,
  name: LocalizedText(english: 'Thunder Shock', spanish: 'Impactrueno'),
  method: MoveLearnMethod.levelUp,
  level: 1,
  typeName: 'electric',
);

const quickAttack = PokemonMove(
  id: 98,
  name: LocalizedText(english: 'Quick Attack', spanish: 'Ataque Rápido'),
  method: MoveLearnMethod.levelUp,
  level: 6,
  typeName: 'normal',
);

const thunderbolt = PokemonMove(
  id: 85,
  name: LocalizedText(english: 'Thunderbolt', spanish: 'Rayo'),
  method: MoveLearnMethod.machine,
  level: 0,
  typeName: 'electric',
);

const voltTackle = PokemonMove(
  id: 344,
  name: LocalizedText(english: 'Volt Tackle', spanish: 'Placaje Eléc.'),
  method: MoveLearnMethod.egg,
  level: 0,
  typeName: 'electric',
);

final pikachuSavedAt = DateTime(2026, 11, 10, 9, 15);

final pikachuDetail = PokemonDetail(
  pokemon: pikachu,
  heightInMeters: 0.4,
  weightInKilograms: 6,
  baseStats: const [
    BaseStat(PokemonStat.hp, 35),
    BaseStat(PokemonStat.attack, 55),
    BaseStat(PokemonStat.defense, 40),
    BaseStat(PokemonStat.specialAttack, 50),
    BaseStat(PokemonStat.specialDefense, 50),
    BaseStat(PokemonStat.speed, 90),
  ],
  eggGroups: const ['ground', 'fairy'],
  abilities: const [
    PokemonAbility(
      id: 9,
      name: LocalizedText(english: 'Static', spanish: 'Electricidad Estática'),
      slot: 1,
      isHidden: false,
      effect: LocalizedText(
        english: 'Has a 30% chance of paralyzing attacking Pokémon on contact.',
        spanish: 'Puede paralizar al Pokémon que lo ataque con contacto.',
      ),
    ),
    PokemonAbility(
      id: 31,
      name: LocalizedText(english: 'Lightning Rod', spanish: 'Pararrayos'),
      slot: 3,
      isHidden: true,
    ),
  ],
  moveVersionGroup: 'scarlet-violet',
  moves: const [quickAttack, thunderShock, thunderbolt, voltTackle],
  forms: const [pikachu, pikachuRockStar],
  games: const ['red', 'scarlet'],
  evolutionTree: const EvolutionNode(
    speciesId: 172,
    speciesName: 'pichu',
    evolutions: [
      EvolutionNode(
        speciesId: 25,
        speciesName: 'pikachu',
        trigger: FriendshipTrigger(),
        evolutions: [
          EvolutionNode(
            speciesId: 26,
            speciesName: 'raichu',
            trigger: ItemTrigger('thunder-stone'),
          ),
        ],
      ),
    ],
  ),
  detailSyncedAt: pikachuSavedAt,
);
