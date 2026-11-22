const catalogPokemonFieldsFragment = r'''
  fragment CatalogPokemonFields on pokemon {
    id
    name
    height
    weight
    is_default
    pokemonspecy {
      id
      generation_id
    }
    pokemontypes(order_by: { slot: asc }) {
      slot
      type {
        name
      }
    }
    pokemonstats {
      base_stat
      stat {
        name
      }
    }
    pokemonsprites {
      sprites(path: "other.official-artwork.front_default")
    }
  }
''';
