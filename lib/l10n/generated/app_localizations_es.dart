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

  @override
  String get catalogSyncOfflineError =>
      'Sin conexión: se muestran los Pokémon guardados.';

  @override
  String get catalogSyncError =>
      'No se pudo sincronizar el catálogo. Inténtalo nuevamente.';

  @override
  String get previousPage => 'Página anterior';

  @override
  String get nextPage => 'Página siguiente';

  @override
  String get catalogLoading => 'Cargando catálogo';

  @override
  String get catalogLoadError => 'No se pudo cargar el catálogo';

  @override
  String get catalogEmpty => 'No hay Pokémon disponibles';

  @override
  String get catalogConnectionError =>
      'Comprueba tu conexión e inténtalo nuevamente.';

  @override
  String get catalogEmptyMessage =>
      'Todavía no hay Pokémon guardados en el catálogo.';

  @override
  String get retry => 'Reintentar';

  @override
  String get catalogSyncing => 'Sincronizando...';

  @override
  String get syncCatalog => 'Sincronizar catálogo';

  @override
  String get pokemonTypeNormal => 'Normal';

  @override
  String get pokemonTypeFire => 'Fuego';

  @override
  String get pokemonTypeWater => 'Agua';

  @override
  String get pokemonTypeElectric => 'Eléctrico';

  @override
  String get pokemonTypeGrass => 'Planta';

  @override
  String get pokemonTypeIce => 'Hielo';

  @override
  String get pokemonTypeFighting => 'Lucha';

  @override
  String get pokemonTypePoison => 'Veneno';

  @override
  String get pokemonTypeGround => 'Tierra';

  @override
  String get pokemonTypeFlying => 'Volador';

  @override
  String get pokemonTypePsychic => 'Psíquico';

  @override
  String get pokemonTypeBug => 'Bicho';

  @override
  String get pokemonTypeRock => 'Roca';

  @override
  String get pokemonTypeGhost => 'Fantasma';

  @override
  String get pokemonTypeDragon => 'Dragón';

  @override
  String get pokemonTypeDark => 'Siniestro';

  @override
  String get pokemonTypeSteel => 'Acero';

  @override
  String get pokemonTypeFairy => 'Hada';

  @override
  String get bannerNoPreviousSync => 'Sin sincronizaciones anteriores';

  @override
  String bannerLastSync(String date) {
    return 'Última sync: $date';
  }

  @override
  String get bannerSyncing => 'Sincronizando...';

  @override
  String get bannerOnline => 'En línea';

  @override
  String get bannerOffline => 'Sin conexión';

  @override
  String get bannerServiceUnavailable => 'Servicio no disponible';

  @override
  String get bannerContinueBrowsing => 'En línea · Puedes seguir navegando';

  @override
  String get bannerUpdatingLocal => 'Actualizando información local';

  @override
  String bannerOnlineDetails(String lastSync) {
    return 'API disponible · datos locales · $lastSync';
  }

  @override
  String bannerOfflineDetails(String lastSync) {
    return 'Datos locales · $lastSync';
  }

  @override
  String bannerServiceUnavailableDetails(String lastSync) {
    return 'Red activa, API sin respuesta · datos locales · $lastSync';
  }

  @override
  String get bannerSyncFailedOffline => 'No se pudo sincronizar · Sin conexión';

  @override
  String get bannerSyncFailedLocal =>
      'No se pudo sincronizar · Se conservan los datos locales';

  @override
  String get navigationCatalog => 'Catálogo';

  @override
  String get navigationFavorites => 'Favoritos';

  @override
  String get navigationTrivia => 'Trivia';

  @override
  String get navigationSettings => 'Ajustes';

  @override
  String get triviaComingSoon => 'Próximamente';
}
