// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get viewFavorites => 'View favorites';

  @override
  String get noFavoritesTitle => 'You don\'t have any favorites yet';

  @override
  String get noFavoritesMessage => 'Tap the heart on a Pokémon to add it here.';

  @override
  String get favoritePokemonNotFound =>
      'Favorite Pokémon data could not be found.';

  @override
  String get favoritePokemonLoadError => 'Could not load favorite Pokémon.';

  @override
  String get favoritesLoadError => 'Could not retrieve favorites.';

  @override
  String get favoriteUpdateError => 'Could not update favorite';

  @override
  String get favoriteLoadError => 'Error loading favorite';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageDescription => 'Select the application language';

  @override
  String get themeTitle => 'Theme';

  @override
  String get themeDescription => 'Select the application appearance';

  @override
  String get systemOption => 'Automatic (system)';

  @override
  String get spanishOption => 'Spanish';

  @override
  String get englishOption => 'English';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get languageChangeError => 'Could not change the language';

  @override
  String get themeChangeError => 'Could not change the theme';

  @override
  String get catalogSyncOfflineError => 'No connection: showing saved Pokémon.';

  @override
  String get catalogSyncError =>
      'Could not sync the catalog. Please try again.';

  @override
  String get previousPage => 'Previous page';

  @override
  String get nextPage => 'Next page';

  @override
  String get catalogLoading => 'Loading catalog';

  @override
  String get catalogLoadError => 'Could not load the catalog';

  @override
  String get catalogEmpty => 'No Pokémon available';

  @override
  String get catalogConnectionError => 'Check your connection and try again.';

  @override
  String get catalogEmptyMessage =>
      'There are no Pokémon saved in the catalog yet.';

  @override
  String get retry => 'Retry';

  @override
  String get catalogSyncing => 'Syncing...';

  @override
  String get syncCatalog => 'Sync catalog';

  @override
  String get pokemonTypeNormal => 'Normal';

  @override
  String get pokemonTypeFire => 'Fire';

  @override
  String get pokemonTypeWater => 'Water';

  @override
  String get pokemonTypeElectric => 'Electric';

  @override
  String get pokemonTypeGrass => 'Grass';

  @override
  String get pokemonTypeIce => 'Ice';

  @override
  String get pokemonTypeFighting => 'Fighting';

  @override
  String get pokemonTypePoison => 'Poison';

  @override
  String get pokemonTypeGround => 'Ground';

  @override
  String get pokemonTypeFlying => 'Flying';

  @override
  String get pokemonTypePsychic => 'Psychic';

  @override
  String get pokemonTypeBug => 'Bug';

  @override
  String get pokemonTypeRock => 'Rock';

  @override
  String get pokemonTypeGhost => 'Ghost';

  @override
  String get pokemonTypeDragon => 'Dragon';

  @override
  String get pokemonTypeDark => 'Dark';

  @override
  String get pokemonTypeSteel => 'Steel';

  @override
  String get pokemonTypeFairy => 'Fairy';

  @override
  String get bannerNoPreviousSync => 'No previous synchronizations';

  @override
  String bannerLastSync(String date) {
    return 'Last sync: $date';
  }

  @override
  String get bannerSyncing => 'Syncing...';

  @override
  String get bannerOnline => 'Online';

  @override
  String get bannerOffline => 'Offline';

  @override
  String get bannerServiceUnavailable => 'Service unavailable';

  @override
  String get bannerContinueBrowsing => 'Online · You can keep browsing';

  @override
  String get bannerUpdatingLocal => 'Updating local information';

  @override
  String bannerOnlineDetails(String lastSync) {
    return 'API available · local data · $lastSync';
  }

  @override
  String bannerOfflineDetails(String lastSync) {
    return 'Local data · $lastSync';
  }

  @override
  String bannerServiceUnavailableDetails(String lastSync) {
    return 'Network active, API not responding · local data · $lastSync';
  }

  @override
  String get bannerSyncFailedOffline => 'Sync failed · No connection';

  @override
  String get bannerSyncFailedLocal => 'Sync failed · Local data preserved';

  @override
  String get navigationCatalog => 'Catalog';

  @override
  String get navigationFavorites => 'Favorites';

  @override
  String get navigationTrivia => 'Trivia';

  @override
  String get navigationSettings => 'Settings';

  @override
  String get triviaComingSoon => 'Coming soon';

  @override
  String get detailTabInfo => 'Info';

  @override
  String get detailTabStats => 'Stats';

  @override
  String get detailTabEvolutions => 'Evolutions';

  @override
  String get detailTabMoves => 'Moves';

  @override
  String get detailTabMatchups => 'Matchups';

  @override
  String get detailShowShiny => 'Show shiny version';

  @override
  String get detailShowNormal => 'Show normal version';

  @override
  String get detailShinyUnavailable => 'No shiny artwork available';

  @override
  String get detailShare => 'Share';

  @override
  String get detailLoadError => 'Couldn\'t load the detail';

  @override
  String get detailSectionPending => 'It will download when online';

  @override
  String get detailNoData => 'No data';

  @override
  String get detailFreshJustNow => 'Updated from PokeAPI just now';

  @override
  String detailFreshMinutesAgo(int minutes) {
    return 'Updated from PokeAPI $minutes min ago';
  }

  @override
  String detailFreshHoursAgo(int hours) {
    return 'Updated from PokeAPI $hours h ago';
  }

  @override
  String detailLocalData(String date) {
    return 'Local data from $date';
  }

  @override
  String get detailNotStored =>
      'No saved detail · it will download when online';

  @override
  String get detailForms => 'Forms';

  @override
  String get detailHeight => 'Height';

  @override
  String get detailWeight => 'Weight';

  @override
  String get detailEggGroups => 'Egg groups';

  @override
  String get detailAbilities => 'Abilities';

  @override
  String get detailHiddenAbility => 'Hidden';

  @override
  String get detailGames => 'Games';

  @override
  String get detailStatTotal => 'Total';

  @override
  String get detailNoEvolutions => 'Does not evolve';

  @override
  String detailMovesOf(String versionGroup) {
    return 'Moves from $versionGroup';
  }

  @override
  String detailMoveLevel(int level) {
    return 'Lv. $level';
  }

  @override
  String get detailMoveOnEvolution => 'Evo.';

  @override
  String get detailSortByLevel => 'By level';

  @override
  String get detailSortByName => 'By name';

  @override
  String get detailNoMoves => 'No moves recorded';

  @override
  String get detailTypeTablePending => 'Type table pending';

  @override
  String detailShareBaseTotal(int total) {
    return 'Base stat total: $total';
  }

  @override
  String pokemonArtworkLabel(String name) {
    return 'Image of $name';
  }

  @override
  String pokemonShinyArtworkLabel(String name) {
    return 'Shiny image of $name';
  }

  @override
  String detailNumberLabel(int number) {
    return 'Number $number';
  }

  @override
  String detailStatSemantics(
    String stat,
    int value,
    int maximum,
    String percent,
  ) {
    return '$stat: $value of $maximum, $percent';
  }

  @override
  String detailStatTotalSemantics(int total) {
    return 'Total: $total';
  }

  @override
  String get detailCurrentEvolution => 'Current';

  @override
  String detailCurrentEvolutionSemantics(String name) {
    return '$name, current';
  }

  @override
  String detailMoveLevelSpoken(int level) {
    return 'Level $level';
  }

  @override
  String get detailMoveOnEvolutionSpoken => 'On evolution';

  @override
  String detailMoveTypeSemantics(String move, String type) {
    return '$move, $type type';
  }

  @override
  String get detailLoading => 'Loading';

  @override
  String get statHp => 'HP';

  @override
  String get statAttack => 'Attack';

  @override
  String get statDefense => 'Defense';

  @override
  String get statSpecialAttack => 'Sp. Atk';

  @override
  String get statSpecialDefense => 'Sp. Def';

  @override
  String get statSpeed => 'Speed';

  @override
  String get moveMethodLevelUp => 'Level';

  @override
  String get moveMethodMachine => 'TM';

  @override
  String get moveMethodTutor => 'Tutor';

  @override
  String get moveMethodEgg => 'Egg';

  @override
  String get eggGroupMonster => 'Monster';

  @override
  String get eggGroupWater1 => 'Water 1';

  @override
  String get eggGroupWater2 => 'Water 2';

  @override
  String get eggGroupWater3 => 'Water 3';

  @override
  String get eggGroupBug => 'Bug';

  @override
  String get eggGroupFlying => 'Flying';

  @override
  String get eggGroupField => 'Field';

  @override
  String get eggGroupFairy => 'Fairy';

  @override
  String get eggGroupGrass => 'Grass';

  @override
  String get eggGroupHumanLike => 'Human-Like';

  @override
  String get eggGroupMineral => 'Mineral';

  @override
  String get eggGroupAmorphous => 'Amorphous';

  @override
  String get eggGroupDitto => 'Ditto';

  @override
  String get eggGroupDragon => 'Dragon';

  @override
  String get eggGroupUndiscovered => 'Undiscovered';

  @override
  String evolutionLevel(int level) {
    return 'Level $level';
  }

  @override
  String get evolutionLevelUp => 'Level up';

  @override
  String get evolutionTrade => 'Trade';

  @override
  String get evolutionFriendship => 'Friendship';

  @override
  String evolutionHolding(String item) {
    return 'holding $item';
  }

  @override
  String evolutionKnowingMoveType(String type) {
    return 'knowing a $type move';
  }

  @override
  String get evolutionOther => 'Other method';

  @override
  String get timeOfDayDay => 'During the day';

  @override
  String get timeOfDayNight => 'At night';

  @override
  String get timeOfDayDusk => 'At dusk';

  @override
  String get matchupQuadrupleWeakness => 'Very weak · ×4';

  @override
  String get matchupWeakness => 'Weak · ×2';

  @override
  String get matchupResistance => 'Resists · ×0.5';

  @override
  String get matchupDoubleResistance => 'Strongly resists · ×0.25';

  @override
  String get matchupImmunity => 'Immune · ×0';

  @override
  String get imagesTitle => 'Images';

  @override
  String imagesSavedSize(String size) {
    return 'Saved images: $size';
  }

  @override
  String get imagesSaveAll => 'Save images for offline use';

  @override
  String get imagesNeedConnection => 'Offline: connect to download them';

  @override
  String imagesSaveProgress(int saved, int total) {
    return '$saved of $total saved';
  }

  @override
  String imagesSaveIncomplete(int saved, int total, int missing) {
    return '$saved of $total saved · $missing not downloaded';
  }

  @override
  String get imagesSaveNoCatalog => 'No catalog saved yet';

  @override
  String get imagesSaveFailed => 'Images could not be saved';

  @override
  String get imagesDelete => 'Delete images';

  @override
  String get imagesDeleteQuestion => 'Delete saved images?';

  @override
  String get imagesDeleteExplanation =>
      'They will download again when viewed online.';

  @override
  String get imagesDeleteConfirm => 'Delete';

  @override
  String get imagesDeleteFailed => 'Images could not be deleted';

  @override
  String get demoToolsTitle => 'Demo tools';

  @override
  String get demoToolsDescription => 'Only in debug and profile builds';

  @override
  String get simulateApiOutage => 'Simulate PokeAPI outage';

  @override
  String get simulateApiOutageDescription =>
      'Answers HTTP 503 without using the network';

  @override
  String get simulateApiOutageSaveError =>
      'The setting could not be saved; it lasts until the app closes';

  @override
  String get catalogSearchHint => 'Search by name or number';

  @override
  String get catalogTypeFilter => 'Types';

  @override
  String get catalogAllTypes => 'All types';

  @override
  String get catalogSortBy => 'Sort by';

  @override
  String get catalogSortNumberAsc => 'Number (ascending)';

  @override
  String get catalogSortNumberDesc => 'Number (descending)';

  @override
  String get catalogSortNameAsc => 'Name (A-Z)';

  @override
  String get catalogSortNameDesc => 'Name (Z-A)';

  @override
  String get catalogSortStatsAsc => 'Base stats (low to high)';

  @override
  String get catalogSortStatsDesc => 'Base stats (high to low)';

  @override
  String get catalogNoResults => 'No Pokémon found';

  @override
  String get catalogNoResultsMessage =>
      'Try another search or change the filters.';

  @override
  String get catalogClearFilters => 'Clear filters';

  @override
  String get catalogShowSearch => 'Show search';

  @override
  String get catalogHideSearch => 'Hide search';

  @override
  String get catalogGenerationFilter => 'Generations';

  @override
  String get catalogAllGenerations => 'All generations';

  @override
  String get catalogSelectTypes => 'Select types';

  @override
  String get catalogSelectGenerations => 'Select generations';

  @override
  String get catalogApplySelection => 'Apply';

  @override
  String get catalogCancelSelection => 'Cancel';

  @override
  String get catalogClearSelection => 'Clear selection';

  @override
  String catalogSelectedCount(int count) {
    return 'Selected: $count';
  }

  @override
  String catalogGenerationLabel(String number) {
    return 'Generation $number';
  }

  @override
  String catalogPartialNotice(int savedCount, int totalCount) {
    return 'Local catalog: $savedCount of $totalCount Pokémon; results may be incomplete.';
  }

  @override
  String catalogPartialNoticeUnknownTotal(int savedCount) {
    return 'Local catalog: $savedCount Pokémon saved; results may be incomplete.';
  }
}
