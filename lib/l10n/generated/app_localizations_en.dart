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
}
