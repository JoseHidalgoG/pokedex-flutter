import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @favoritesTitle.
  ///
  /// In es, this message translates to:
  /// **'Favoritos'**
  String get favoritesTitle;

  /// No description provided for @addToFavorites.
  ///
  /// In es, this message translates to:
  /// **'Agregar a favoritos'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In es, this message translates to:
  /// **'Quitar de favoritos'**
  String get removeFromFavorites;

  /// No description provided for @viewFavorites.
  ///
  /// In es, this message translates to:
  /// **'Ver favoritos'**
  String get viewFavorites;

  /// No description provided for @noFavoritesTitle.
  ///
  /// In es, this message translates to:
  /// **'Todavía no tienes favoritos'**
  String get noFavoritesTitle;

  /// No description provided for @noFavoritesMessage.
  ///
  /// In es, this message translates to:
  /// **'Marca un Pokémon con el corazón para agregarlo aquí.'**
  String get noFavoritesMessage;

  /// No description provided for @favoritePokemonNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron los datos de los Pokémon favoritos.'**
  String get favoritePokemonNotFound;

  /// No description provided for @favoritePokemonLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los Pokémon favoritos.'**
  String get favoritePokemonLoadError;

  /// No description provided for @favoritesLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron consultar los favoritos.'**
  String get favoritesLoadError;

  /// No description provided for @favoriteUpdateError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo actualizar el favorito'**
  String get favoriteUpdateError;

  /// No description provided for @favoriteLoadError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar favorito'**
  String get favoriteLoadError;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @languageTitle.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get languageTitle;

  /// No description provided for @languageDescription.
  ///
  /// In es, this message translates to:
  /// **'Selecciona el idioma de la aplicación'**
  String get languageDescription;

  /// No description provided for @themeTitle.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get themeTitle;

  /// No description provided for @themeDescription.
  ///
  /// In es, this message translates to:
  /// **'Selecciona la apariencia de la aplicación'**
  String get themeDescription;

  /// No description provided for @systemOption.
  ///
  /// In es, this message translates to:
  /// **'Automático (sistema)'**
  String get systemOption;

  /// No description provided for @spanishOption.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanishOption;

  /// No description provided for @englishOption.
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get englishOption;

  /// No description provided for @lightTheme.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get darkTheme;

  /// No description provided for @languageChangeError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cambiar el idioma'**
  String get languageChangeError;

  /// No description provided for @themeChangeError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cambiar el tema'**
  String get themeChangeError;

  /// No description provided for @catalogSyncOfflineError.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión: se muestran los Pokémon guardados.'**
  String get catalogSyncOfflineError;

  /// No description provided for @catalogSyncError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo sincronizar el catálogo. Inténtalo nuevamente.'**
  String get catalogSyncError;

  /// No description provided for @previousPage.
  ///
  /// In es, this message translates to:
  /// **'Página anterior'**
  String get previousPage;

  /// No description provided for @nextPage.
  ///
  /// In es, this message translates to:
  /// **'Página siguiente'**
  String get nextPage;

  /// No description provided for @catalogLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando catálogo'**
  String get catalogLoading;

  /// No description provided for @catalogLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el catálogo'**
  String get catalogLoadError;

  /// No description provided for @catalogEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay Pokémon disponibles'**
  String get catalogEmpty;

  /// No description provided for @catalogConnectionError.
  ///
  /// In es, this message translates to:
  /// **'Comprueba tu conexión e inténtalo nuevamente.'**
  String get catalogConnectionError;

  /// No description provided for @catalogEmptyMessage.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay Pokémon guardados en el catálogo.'**
  String get catalogEmptyMessage;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @catalogSyncing.
  ///
  /// In es, this message translates to:
  /// **'Sincronizando...'**
  String get catalogSyncing;

  /// No description provided for @syncCatalog.
  ///
  /// In es, this message translates to:
  /// **'Sincronizar catálogo'**
  String get syncCatalog;

  /// No description provided for @pokemonTypeNormal.
  ///
  /// In es, this message translates to:
  /// **'Normal'**
  String get pokemonTypeNormal;

  /// No description provided for @pokemonTypeFire.
  ///
  /// In es, this message translates to:
  /// **'Fuego'**
  String get pokemonTypeFire;

  /// No description provided for @pokemonTypeWater.
  ///
  /// In es, this message translates to:
  /// **'Agua'**
  String get pokemonTypeWater;

  /// No description provided for @pokemonTypeElectric.
  ///
  /// In es, this message translates to:
  /// **'Eléctrico'**
  String get pokemonTypeElectric;

  /// No description provided for @pokemonTypeGrass.
  ///
  /// In es, this message translates to:
  /// **'Planta'**
  String get pokemonTypeGrass;

  /// No description provided for @pokemonTypeIce.
  ///
  /// In es, this message translates to:
  /// **'Hielo'**
  String get pokemonTypeIce;

  /// No description provided for @pokemonTypeFighting.
  ///
  /// In es, this message translates to:
  /// **'Lucha'**
  String get pokemonTypeFighting;

  /// No description provided for @pokemonTypePoison.
  ///
  /// In es, this message translates to:
  /// **'Veneno'**
  String get pokemonTypePoison;

  /// No description provided for @pokemonTypeGround.
  ///
  /// In es, this message translates to:
  /// **'Tierra'**
  String get pokemonTypeGround;

  /// No description provided for @pokemonTypeFlying.
  ///
  /// In es, this message translates to:
  /// **'Volador'**
  String get pokemonTypeFlying;

  /// No description provided for @pokemonTypePsychic.
  ///
  /// In es, this message translates to:
  /// **'Psíquico'**
  String get pokemonTypePsychic;

  /// No description provided for @pokemonTypeBug.
  ///
  /// In es, this message translates to:
  /// **'Bicho'**
  String get pokemonTypeBug;

  /// No description provided for @pokemonTypeRock.
  ///
  /// In es, this message translates to:
  /// **'Roca'**
  String get pokemonTypeRock;

  /// No description provided for @pokemonTypeGhost.
  ///
  /// In es, this message translates to:
  /// **'Fantasma'**
  String get pokemonTypeGhost;

  /// No description provided for @pokemonTypeDragon.
  ///
  /// In es, this message translates to:
  /// **'Dragón'**
  String get pokemonTypeDragon;

  /// No description provided for @pokemonTypeDark.
  ///
  /// In es, this message translates to:
  /// **'Siniestro'**
  String get pokemonTypeDark;

  /// No description provided for @pokemonTypeSteel.
  ///
  /// In es, this message translates to:
  /// **'Acero'**
  String get pokemonTypeSteel;

  /// No description provided for @pokemonTypeFairy.
  ///
  /// In es, this message translates to:
  /// **'Hada'**
  String get pokemonTypeFairy;

  /// No description provided for @bannerNoPreviousSync.
  ///
  /// In es, this message translates to:
  /// **'Sin sincronizaciones anteriores'**
  String get bannerNoPreviousSync;

  /// No description provided for @bannerLastSync.
  ///
  /// In es, this message translates to:
  /// **'Última sync: {date}'**
  String bannerLastSync(String date);

  /// No description provided for @bannerSyncing.
  ///
  /// In es, this message translates to:
  /// **'Sincronizando...'**
  String get bannerSyncing;

  /// No description provided for @bannerOnline.
  ///
  /// In es, this message translates to:
  /// **'En línea'**
  String get bannerOnline;

  /// No description provided for @bannerOffline.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión'**
  String get bannerOffline;

  /// No description provided for @bannerServiceUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Servicio no disponible'**
  String get bannerServiceUnavailable;

  /// No description provided for @bannerContinueBrowsing.
  ///
  /// In es, this message translates to:
  /// **'En línea · Puedes seguir navegando'**
  String get bannerContinueBrowsing;

  /// No description provided for @bannerUpdatingLocal.
  ///
  /// In es, this message translates to:
  /// **'Actualizando información local'**
  String get bannerUpdatingLocal;

  /// No description provided for @bannerOnlineDetails.
  ///
  /// In es, this message translates to:
  /// **'API disponible · datos locales · {lastSync}'**
  String bannerOnlineDetails(String lastSync);

  /// No description provided for @bannerOfflineDetails.
  ///
  /// In es, this message translates to:
  /// **'Datos locales · {lastSync}'**
  String bannerOfflineDetails(String lastSync);

  /// No description provided for @bannerServiceUnavailableDetails.
  ///
  /// In es, this message translates to:
  /// **'Red activa, API sin respuesta · datos locales · {lastSync}'**
  String bannerServiceUnavailableDetails(String lastSync);

  /// No description provided for @bannerSyncFailedOffline.
  ///
  /// In es, this message translates to:
  /// **'No se pudo sincronizar · Sin conexión'**
  String get bannerSyncFailedOffline;

  /// No description provided for @bannerSyncFailedLocal.
  ///
  /// In es, this message translates to:
  /// **'No se pudo sincronizar · Se conservan los datos locales'**
  String get bannerSyncFailedLocal;

  /// No description provided for @navigationCatalog.
  ///
  /// In es, this message translates to:
  /// **'Catálogo'**
  String get navigationCatalog;

  /// No description provided for @navigationFavorites.
  ///
  /// In es, this message translates to:
  /// **'Favoritos'**
  String get navigationFavorites;

  /// No description provided for @navigationTrivia.
  ///
  /// In es, this message translates to:
  /// **'Trivia'**
  String get navigationTrivia;

  /// No description provided for @navigationSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get navigationSettings;

  /// No description provided for @triviaComingSoon.
  ///
  /// In es, this message translates to:
  /// **'Próximamente'**
  String get triviaComingSoon;

  /// No description provided for @catalogSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar por nombre o número'**
  String get catalogSearchHint;

  /// No description provided for @catalogTypeFilter.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get catalogTypeFilter;

  /// No description provided for @catalogAllTypes.
  ///
  /// In es, this message translates to:
  /// **'Todos los tipos'**
  String get catalogAllTypes;

  /// No description provided for @catalogSortBy.
  ///
  /// In es, this message translates to:
  /// **'Ordenar por'**
  String get catalogSortBy;

  /// No description provided for @catalogSortNumberAsc.
  ///
  /// In es, this message translates to:
  /// **'Número (ascendente)'**
  String get catalogSortNumberAsc;

  /// No description provided for @catalogSortNumberDesc.
  ///
  /// In es, this message translates to:
  /// **'Número (descendente)'**
  String get catalogSortNumberDesc;

  /// No description provided for @catalogSortNameAsc.
  ///
  /// In es, this message translates to:
  /// **'Nombre (A-Z)'**
  String get catalogSortNameAsc;

  /// No description provided for @catalogSortNameDesc.
  ///
  /// In es, this message translates to:
  /// **'Nombre (Z-A)'**
  String get catalogSortNameDesc;

  /// No description provided for @catalogSortStatsAsc.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas base (menor a mayor)'**
  String get catalogSortStatsAsc;

  /// No description provided for @catalogSortStatsDesc.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas base (mayor a menor)'**
  String get catalogSortStatsDesc;

  /// No description provided for @catalogNoResults.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron Pokémon'**
  String get catalogNoResults;

  /// No description provided for @catalogNoResultsMessage.
  ///
  /// In es, this message translates to:
  /// **'Prueba con otra búsqueda o cambia los filtros.'**
  String get catalogNoResultsMessage;

  /// No description provided for @catalogClearFilters.
  ///
  /// In es, this message translates to:
  /// **'Limpiar filtros'**
  String get catalogClearFilters;

  /// No description provided for @catalogShowSearch.
  ///
  /// In es, this message translates to:
  /// **'Mostrar búsqueda'**
  String get catalogShowSearch;

  /// No description provided for @catalogHideSearch.
  ///
  /// In es, this message translates to:
  /// **'Ocultar búsqueda'**
  String get catalogHideSearch;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
