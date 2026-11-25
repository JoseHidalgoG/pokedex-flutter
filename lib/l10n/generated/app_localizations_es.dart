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

  @override
  String get detailTabInfo => 'Información';

  @override
  String get detailTabStats => 'Estadísticas';

  @override
  String get detailTabEvolutions => 'Evoluciones';

  @override
  String get detailTabMoves => 'Movimientos';

  @override
  String get detailTabMatchups => 'Matchups';

  @override
  String get detailShowShiny => 'Ver versión shiny';

  @override
  String get detailShowNormal => 'Ver versión normal';

  @override
  String get detailShinyUnavailable => 'No hay imagen shiny disponible';

  @override
  String get detailShare => 'Compartir';

  @override
  String get detailLoadError => 'No se pudo cargar el detalle';

  @override
  String get detailSectionPending => 'Se descargará con conexión';

  @override
  String get detailNoData => 'Sin datos';

  @override
  String get detailFreshJustNow => 'Actualizado desde PokeAPI hace un momento';

  @override
  String detailFreshMinutesAgo(int minutes) {
    return 'Actualizado desde PokeAPI hace $minutes min';
  }

  @override
  String detailFreshHoursAgo(int hours) {
    return 'Actualizado desde PokeAPI hace $hours h';
  }

  @override
  String detailLocalData(String date) {
    return 'Datos locales del $date';
  }

  @override
  String get detailNotStored =>
      'Sin detalle guardado · se descargará con conexión';

  @override
  String get detailForms => 'Formas';

  @override
  String get detailHeight => 'Altura';

  @override
  String get detailWeight => 'Peso';

  @override
  String get detailEggGroups => 'Grupos huevo';

  @override
  String get detailAbilities => 'Habilidades';

  @override
  String get detailHiddenAbility => 'Oculta';

  @override
  String get detailGames => 'Juegos';

  @override
  String get detailStatTotal => 'Total';

  @override
  String get detailNoEvolutions => 'No evoluciona';

  @override
  String detailMovesOf(String versionGroup) {
    return 'Movimientos de $versionGroup';
  }

  @override
  String detailMoveLevel(int level) {
    return 'Nv. $level';
  }

  @override
  String get detailMoveOnEvolution => 'Evo.';

  @override
  String get detailSortByLevel => 'Por nivel';

  @override
  String get detailSortByName => 'Por nombre';

  @override
  String get detailNoMoves => 'Sin movimientos registrados';

  @override
  String get detailTypeTablePending => 'Tabla de tipos pendiente';

  @override
  String detailShareBaseTotal(int total) {
    return 'Total base: $total';
  }

  @override
  String get statHp => 'PS';

  @override
  String get statAttack => 'Ataque';

  @override
  String get statDefense => 'Defensa';

  @override
  String get statSpecialAttack => 'At. esp.';

  @override
  String get statSpecialDefense => 'Def. esp.';

  @override
  String get statSpeed => 'Velocidad';

  @override
  String get moveMethodLevelUp => 'Nivel';

  @override
  String get moveMethodMachine => 'MT';

  @override
  String get moveMethodTutor => 'Tutor';

  @override
  String get moveMethodEgg => 'Huevo';

  @override
  String get eggGroupMonster => 'Monstruo';

  @override
  String get eggGroupWater1 => 'Agua 1';

  @override
  String get eggGroupWater2 => 'Agua 2';

  @override
  String get eggGroupWater3 => 'Agua 3';

  @override
  String get eggGroupBug => 'Bicho';

  @override
  String get eggGroupFlying => 'Volador';

  @override
  String get eggGroupField => 'Campo';

  @override
  String get eggGroupFairy => 'Hada';

  @override
  String get eggGroupGrass => 'Planta';

  @override
  String get eggGroupHumanLike => 'Humanoide';

  @override
  String get eggGroupMineral => 'Mineral';

  @override
  String get eggGroupAmorphous => 'Amorfo';

  @override
  String get eggGroupDitto => 'Ditto';

  @override
  String get eggGroupDragon => 'Dragón';

  @override
  String get eggGroupUndiscovered => 'Desconocido';

  @override
  String evolutionLevel(int level) {
    return 'Nivel $level';
  }

  @override
  String get evolutionLevelUp => 'Subir de nivel';

  @override
  String get evolutionTrade => 'Intercambio';

  @override
  String get evolutionFriendship => 'Amistad';

  @override
  String evolutionHolding(String item) {
    return 'con $item equipado';
  }

  @override
  String evolutionKnowingMoveType(String type) {
    return 'con un movimiento de tipo $type';
  }

  @override
  String get evolutionOther => 'Otro método';

  @override
  String get timeOfDayDay => 'De día';

  @override
  String get timeOfDayNight => 'De noche';

  @override
  String get timeOfDayDusk => 'Al anochecer';

  @override
  String get matchupQuadrupleWeakness => 'Muy débil · ×4';

  @override
  String get matchupWeakness => 'Débil · ×2';

  @override
  String get matchupResistance => 'Resiste · ×0,5';

  @override
  String get matchupDoubleResistance => 'Resiste mucho · ×0,25';

  @override
  String get matchupImmunity => 'Inmune · ×0';

  @override
  String get imagesTitle => 'Imágenes';

  @override
  String imagesSavedSize(String size) {
    return 'Imágenes guardadas: $size';
  }

  @override
  String get imagesSaveAll => 'Guardar imágenes para usar sin conexión';

  @override
  String get imagesNeedConnection =>
      'Sin conexión: conéctate para descargarlas';

  @override
  String imagesSaveProgress(int saved, int total) {
    return '$saved de $total guardadas';
  }

  @override
  String imagesSaveIncomplete(int saved, int total, int missing) {
    return '$saved de $total guardadas · $missing sin descargar';
  }

  @override
  String get imagesSaveNoCatalog => 'Todavía no hay catálogo guardado';

  @override
  String get imagesSaveFailed => 'No se pudieron guardar las imágenes';

  @override
  String get imagesDelete => 'Borrar imágenes';

  @override
  String get imagesDeleteQuestion => '¿Borrar las imágenes guardadas?';

  @override
  String get imagesDeleteExplanation =>
      'Se volverán a descargar al verlas con conexión.';

  @override
  String get imagesDeleteConfirm => 'Borrar';

  @override
  String get imagesDeleteFailed => 'No se pudieron borrar las imágenes';
}
