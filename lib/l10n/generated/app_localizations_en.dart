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
  String get catalogSearchHint => 'Search by name or number';

  @override
  String get catalogTypeFilter => 'Type';

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
}
