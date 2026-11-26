# ADR-0007: Caché de imágenes propia y acotada

- **Estado:** Aceptado
- **Fecha:** 2026-11-26

## Contexto

El enunciado pide que las imágenes ya vistas se muestren sin conexión y tras reiniciar la app (OF-08, PS-08, PA-10), con un límite y una limpieza. También pide no tener en memoria imágenes más grandes que su contenedor (RNF-REN-04).

En el avance, `CachedNetworkImage` usaba el gestor por defecto de `flutter_cache_manager`, que guarda 200 archivos durante 30 días. El catálogo tiene 1025 Pokémon por defecto, así que al recorrerlo se desechaban las primeras imágenes y PA-10 fallaba. Además, cada official-artwork mide 475 × 475 px y se decodificaba a ese tamaño, unos 0,9 MB en memoria, aunque la lista lo pinte a 76 dp.

Las imágenes vienen de `raw.githubusercontent.com`, el repositorio de sprites de PokeAPI, no de GraphQL. No gastan el límite de 100 llamadas por hora (ADR-0004), pero sí datos móviles.

## Decisión

Toda imagen de un Pokémon pasa por un gestor propio de `flutter_cache_manager`, en `lib/core/images/`, con su propia carpeta, un límite de archivos y un tiempo máximo sin uso.

- **Gestor.** `PokemonImageCache` crea un `CacheManager` con la clave `pokemonImages` (`pokemonImageCacheKey`), hasta 2500 archivos (`pokemonImageCacheCapacity`) y 180 días sin uso (`pokemonImageMaxIdle`). Los widgets lo leen con `pokemonImageCacheManagerProvider`.
- **Carpeta.** Los archivos van a una carpeta `pokemonImages` dentro de la carpeta de caché del sistema; en Android, `cache/pokemonImages`. El índice, con la URL, el archivo, el tamaño, la vigencia y la hora del último uso de cada imagen, es una base sqflite del propio paquete: `files/pokemonImages.db` en Android.
- **Limpieza.** Es la del paquete. Cada vez que se muestra una imagen se anota la hora, y unos segundos después se borran las que llevan más de 180 días sin usarse y, pasado el límite de 2500, las de uso menos reciente. Las usadas en el último día no se borran por el límite. 2500 archivos alcanzan para los 1025 artworks más sus shiny y las formas que se abran.
- **Decodificación al tamaño del contenedor (RNF-REN-04).** `PokemonCachedImage` (lista, favoritos y evoluciones) y `DetailArtwork` (artwork, shiny y sprite de respaldo del detalle) pasan `memCacheWidth` con `decodedPixelsFor(context, size)`: el lado en dp por `devicePixelRatio`. En el emulador, con una densidad de 2,625, la imagen de la lista se decodifica a 200 px, unos 160 KB en memoria en lugar de 0,9 MB. El archivo en disco no cambia. Flutter nunca agranda al decodificar, así que el sprite de 96 px se queda como está.
- **Respaldo.** Si el archivo no está y no hay red, se muestra el icono de respaldo. En el detalle, antes se prueba el sprite `front_default`.
- **Guardar todas.** En Ajustes, «Guardar imágenes para usar sin conexión» llama a `SaveAllArtwork`. `CachedPokemonImageRepository` lee las URLs de los Pokémon por defecto guardados (`CatalogDao.readArtworkUrls`), descarta las que ya están en disco y descarga el resto de 4 en 4 (`artworkDownloadsAtOnce`). Tras cada descarga emite el avance, que la sección muestra como «412 de 1025 guardadas». Se detiene tras 10 fallos seguidos (`artworkFailuresInARowBeforeStopping`), porque eso significa que la red se fue. El avance vive en un `Notifier` que no se descarta, así que salir de Ajustes no corta la descarga. El botón solo se desactiva sin red: con «Servicio no disponible» funciona, porque GitHub no es PokeAPI.
- **Espacio y borrado.** La misma sección muestra «Imágenes guardadas: 132,7 MB», la suma de los archivos que existen en disco, con 1 MB = 1 000 000 bytes. «Borrar imágenes» pide confirmación y vacía dos gestores: el propio y el gestor por defecto, que conserva en `cache/libCachedImageData` las imágenes de las versiones anteriores a esta caché. Después limpia las imágenes ya decodificadas en memoria (`imageCache`).
- **Contrato para la trivia.** `GetPokemonIdsWithSavedArtwork` devuelve los ids de los Pokémon por defecto cuyo artwork está en disco. Hace una sola lectura del índice (`getAllObjects`) y comprueba que cada archivo exista, porque el sistema puede vaciar la carpeta y dejar filas del índice sin su archivo. Sin conexión, la trivia elige sus preguntas entre esos ids, y pinta la silueta con `PokemonCachedImage` o con el gestor de `pokemonImageCacheManagerProvider`, para no saltarse el gestor acotado.
- **Contrato para los favoritos (RF-FAV-03).** `KeepPokemonOffline(id)` guarda el artwork del Pokémon y, si su detalle nunca se descargó, lo descarga una vez: en ese momento si hay servicio, o en la siguiente reconexión (`SyncScheduler.runWhenOnline`). No se registra para cada reconexión, así que 30 favoritos no cuestan 30 llamadas por reconexión. Cuesta como mucho una llamada de usuario por favorito nuevo.
- **Hero.** `pokemonArtworkHeroTag(id)` es la etiqueta que comparten la imagen de la lista y la del detalle. El detalle ya envuelve su imagen en `Hero`; mientras la lista no lo haga, no se anima nada.

Guardar las imágenes no gasta llamadas a PokeAPI.

### Espacio medido

Medido en el emulador el 2026-11-25 (Medium_Phone, Wi-Fi), partiendo de la caché vacía:

| Medida | Valor |
| --- | --- |
| Tiempo de «Guardar imágenes» para los 1025 artworks | unos 60 s |
| Espacio en disco | 132 662 089 bytes, que Ajustes muestra como «132,7 MB» |
| Tamaño de cada artwork | 129 KB de media, entre 38 y 268 KB |
| Segunda pulsación de «Guardar imágenes» | Termina al instante con «1025 de 1025» y no descarga nada |
| «Borrar imágenes» | Menos de 3 s; 0 archivos, «0,0 MB» y el índice en 16 KB |

El plan estimaba unos 160 MB a partir de las 8 primeras imágenes. Los archivos son los mismos en cualquier dispositivo, así que el teléfono de la demo ocupa lo mismo.

## Vigencia de los archivos

`raw.githubusercontent.com` responde con `Cache-Control: max-age=300` y un `ETag`, así que cada archivo vence 5 minutos después de descargarse. `flutter_cache_manager` 3.5.0 lo trata así:

- **Con red**, una imagen vencida se muestra al instante desde el disco y el gestor pregunta a GitHub con `If-None-Match`. Si no cambió, GitHub responde 304 sin cuerpo y solo se renueva la vigencia. Si responde 404, el archivo se borra.
- **Sin red**, la imagen vencida se muestra igual y el error de la descarga se descarta. Por eso PA-10 funciona con imágenes guardadas hace días.
- La limpieza por 180 días cuenta desde el último uso, no desde el vencimiento.

## Alternativas consideradas

- **El gestor por defecto.** No pide código propio, pero guarda 200 archivos durante 30 días. Al recorrer el catálogo se pierden las primeras imágenes y PA-10 falla.
- **Guardar las imágenes como blobs en Drift.** Todo quedaría en una sola base, pero la base crecería unos 130 MB, el inspector de Drift cargaría con ellas y la limpieza habría que escribirla a mano. `CachedNetworkImage` ya lee de un gestor de caché.
- **La carpeta de soporte de la app**, que Android no vacía. Haría falta un `FileSystem` propio y declarar `path_provider` y `file` como dependencias. Además, el sistema no podría liberar esos 130 MB cuando le falta espacio, y el usuario tampoco desde «Borrar caché». Son imágenes que se pueden volver a descargar, y la app ya tiene un respaldo si faltan, así que la carpeta de caché es su sitio.
- **Redimensionar en disco con `maxWidthDiskCache`.** Ahorra disco, pero el paquete guarda el original y además una copia reducida por cada tamaño, con otra clave (`resized_w200_…`). La misma imagen ocuparía varias entradas, y el índice ya no diría con una sola URL si el artwork de un Pokémon está guardado. RNF-REN-04 pide ahorrar memoria, y eso lo hace `memCacheWidth` sin tocar el disco.
- **Descargar todas las imágenes en la primera ejecución.** PA-10 no necesitaría ningún paso, pero se gastarían unos 130 MB de datos móviles sin preguntar. Por eso es un botón opcional en Ajustes.

## Consecuencias

- Una imagen vista una vez se muestra sin conexión y tras reiniciar mientras siga en la carpeta (PA-10). Después de «Guardar imágenes», también las que nunca se vieron.
- Android puede vaciar la carpeta de caché cuando le falta espacio, y el usuario puede hacerlo con «Borrar caché» en los ajustes del sistema. Las imágenes que se pierdan muestran el icono de respaldo hasta que se vean otra vez con red o se vuelvan a guardar.
- El índice puede sobrevivir a sus archivos, así que toda comprobación de «guardada» mira que el archivo exista.
- El índice está en la base del paquete, no en Drift. El inspector de Drift no ve las imágenes, y los conteos de PA-13 no las incluyen. El espacio se consulta en Ajustes.
- Con red, mostrar una imagen vencida cuesta una petición condicional a GitHub, normalmente un 304 sin cuerpo. Nunca gasta el presupuesto de PokeAPI.
- Si se llenara el límite de 2500 archivos con shiny y formas, a 129 KB de media serían unos 320 MB. Si hiciera falta, se baja la constante; no hay migración.
- Una imagen que falló sin conexión no se vuelve a pedir sola al reconectar: la pantalla ya pintada conserva el icono hasta que se reconstruye, por ejemplo al cambiar de página. De la misma forma, después de «Borrar imágenes» la página visible sigue mostrando sus imágenes hasta que se reconstruye.
- Sin conexión, la trivia solo puede preguntar por Pokémon con su artwork guardado.
