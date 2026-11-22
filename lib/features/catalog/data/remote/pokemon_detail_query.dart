import 'package:graphql/client.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_pokemon_fields.dart';

const _pokemonDetailOperation = r'''
  query PokemonDetail($id: Int!) {
    pokemon(where: { id: { _eq: $id } }) {
      ...CatalogPokemonFields
      pokemonabilities(order_by: { slot: asc }) {
        slot
        is_hidden
        ability {
          id
          name
          abilitynames(where: { language: { name: { _in: ["es", "en"] } } }) {
            name
            language {
              name
            }
          }
          abilityeffecttexts(where: { language: { name: { _eq: "en" } } }) {
            short_effect
          }
          abilityflavortexts(
            where: { language: { name: { _eq: "es" } } }
            order_by: { versiongroup: { order: desc } }
            limit: 1
          ) {
            flavor_text
          }
        }
      }
      pokemonmoves(
        where: {
          movelearnmethod: {
            name: { _in: ["level-up", "machine", "tutor", "egg"] }
          }
        }
      ) {
        level
        movelearnmethod {
          name
        }
        versiongroup {
          name
          order
        }
        move {
          id
          name
          type {
            name
          }
          movenames(where: { language: { name: { _in: ["es", "en"] } } }) {
            name
            language {
              name
            }
          }
        }
      }
      pokemongameindices {
        version {
          name
        }
      }
      pokemonspecy {
        name
        pokemonegggroups {
          egggroup {
            name
          }
        }
        pokemons(order_by: { id: asc }) {
          ...CatalogPokemonFields
        }
        evolutionchain {
          id
          pokemonspecies(order_by: { order: asc }) {
            id
            name
            generation_id
            evolves_from_species_id
            pokemonevolutions(
              where: { is_default: { _eq: true } }
              order_by: { id: asc }
            ) {
              id
              evolved_species_id
              min_level
              min_happiness
              time_of_day
              evolutiontrigger {
                name
              }
              item {
                name
              }
              ItemByHeldItemId {
                name
              }
              location {
                name
              }
              type {
                name
              }
            }
          }
        }
      }
    }
  }
''';

final pokemonDetailQuery = gql(
  '$_pokemonDetailOperation$catalogPokemonFieldsFragment',
);
