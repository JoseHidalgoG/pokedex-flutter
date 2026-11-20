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
}
