const _spritesBaseUrl =
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon';

String officialArtworkUrlFor(int pokemonId) {
  return '$_spritesBaseUrl/other/official-artwork/$pokemonId.png';
}

String shinyArtworkUrlFor(int pokemonId) {
  return '$_spritesBaseUrl/other/official-artwork/shiny/$pokemonId.png';
}

String frontSpriteUrlFor(int pokemonId) {
  return '$_spritesBaseUrl/$pokemonId.png';
}
