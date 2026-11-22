// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get favoritesTitle => 'Favoritos';

  @override
  String get addToFavorites => 'Agregar a favoritos';

  @override
  String get removeFromFavorites => 'Quitar de favoritos';

  @override
  String get viewFavorites => 'Ver favoritos';

  @override
  String get noFavoritesTitle => 'Todavía no tienes favoritos';

  @override
  String get noFavoritesMessage =>
      'Marca un Pokémon con el corazón para agregarlo aquí.';

  @override
  String get favoritePokemonNotFound =>
      'No se encontraron los datos de los Pokémon favoritos.';

  @override
  String get favoritePokemonLoadError =>
      'No se pudieron cargar los Pokémon favoritos.';

  @override
  String get favoritesLoadError => 'No se pudieron consultar los favoritos.';

  @override
  String get favoriteUpdateError => 'No se pudo actualizar el favorito';

  @override
  String get favoriteLoadError => 'Error al cargar favorito';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageDescription => 'Selecciona el idioma de la aplicación';

  @override
  String get themeTitle => 'Tema';

  @override
  String get themeDescription => 'Selecciona la apariencia de la aplicación';

  @override
  String get systemOption => 'Automático (sistema)';

  @override
  String get spanishOption => 'Español';

  @override
  String get englishOption => 'Inglés';

  @override
  String get lightTheme => 'Claro';

  @override
  String get darkTheme => 'Oscuro';

  @override
  String get languageChangeError => 'No se pudo cambiar el idioma';

  @override
  String get themeChangeError => 'No se pudo cambiar el tema';
}
