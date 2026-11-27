# Pokédex Flutter — Offline First

Aplicación móvil desarrollada con Flutter que permite consultar un catálogo de Pokémon utilizando la API GraphQL de PokéAPI y una base de datos local SQLite.

La aplicación sigue una arquitectura **offline-first**, por lo que los Pokémon previamente sincronizados pueden consultarse incluso cuando el dispositivo no dispone de conexión a Internet.

## Tecnologías utilizadas

- **Flutter y Dart:** desarrollo de la aplicación móvil.
- **Riverpod:** gestión del estado e inyección de dependencias.
- **Drift y SQLite:** almacenamiento persistente del catálogo.
- **GraphQL:** comunicación con la API de PokéAPI.
- **gql:** lectura del nombre de cada operación GraphQL, para registrarla en consola con sus variables y su duración.
- **connectivity_plus:** detección de cambios de conectividad.
- **internet_connection_checker_plus:** comprobación de acceso a Internet.
- **cached_network_image:** muestra las imágenes de los Pokémon desde la caché de imágenes propia.
- **flutter_cache_manager:** caché de imágenes propia y acotada (2500 archivos, 180 días sin uso), con su espacio y su borrado en Ajustes. Ya llegaba con `cached_network_image`; se declara directa porque la app crea su propio gestor ([ADR-0007](docs/adr/0007-cache-de-imagenes-propia-y-acotada.md)).
- **crypto:** huella SHA-256 de cada Pokémon, para detectar datos alterados en la base local.
- **share_plus:** compartir un Pokémon como texto desde su detalle.
- **http:** cliente HTTP de las consultas a PokeAPI. En debug y profile lo envuelve la simulación de caída, que responde HTTP 503 sin salir a la red. En las pruebas, su `MockClient` detrás de un `HttpLink` real comprueba cómo se traducen las respuestas HTTP a fallos de sincronización.
- **flutter_test y mocktail:** pruebas automatizadas.

## Funcionalidades principales

### Catálogo de Pokémon

- Visualización del número, nombre, imagen y tipos de cada Pokémon.
- Paginación del catálogo en grupos de 50 elementos.
- Estados visuales de carga, error y catálogo vacío.
- Botón para reintentar la sincronización cuando sea necesario.

### Detalle de un Pokémon

- Encabezado con nombre, número, tipos y official-artwork (o el sprite `front_default` si falta), interruptor shiny, favorito y botón para compartir el Pokémon como texto.
- El encabezado se pinta al instante con los datos del catálogo y se completa cuando llega el detalle guardado.
- Una línea bajo el nombre dice de cuándo son los datos: «Actualizado desde PokeAPI hace 3 min» solo si el detalle se revalidó en esta sesión; si no, «Datos locales del 10/11 · 09:15», o «Sin detalle guardado · se descargará con conexión».
- El color del detalle sale del tipo principal del Pokémon: la pantalla usa un esquema de Material 3 generado desde el color del tipo (`ColorScheme.fromSeed` con la variante `fidelity`), en claro u oscuro según el tema de la app. Se ve en el círculo detrás de la imagen, la pestaña activa, las barras de estadísticas y los controles seleccionados; al elegir una forma con otro tipo principal (Marowak de Alola) el color cambia con una transición. Una prueba comprueba el contraste AA de cada par de colores que usa la pantalla en los 18 tipos y los dos temas.
- Los chips de tipo son del color del tipo con el texto en negro o blanco, el que más contraste dé; así cumplen 4,5:1 en los dos temas.
- Pestañas:
  - **Información:** altura, peso, grupos huevo, habilidades (con «Oculta» y el efecto recortado), juegos y selector de formas.
  - **Estadísticas:** barras con el valor y el porcentaje sobre 255, y el total.
  - **Evoluciones:** árbol desde la especie base con el trigger de cada paso.
  - **Movimientos:** los del version group más reciente, por nivel, MT, tutor o huevo, ordenados por nivel o por nombre.
  - **Matchups:** debilidades, resistencias e inmunidades según la tabla de tipos guardada.
- Deslizar hacia abajo en cualquier pestaña fuerza la descarga del detalle.

### Funcionamiento offline-first

La base de datos local es la fuente principal de información del catálogo.

Cuando la aplicación sincroniza con PokéAPI, los datos recibidos se almacenan en SQLite mediante Drift. La interfaz consulta los registros locales, permitiendo que permanezcan disponibles aunque posteriormente se pierda la conexión.

Si falla una sincronización, los datos previamente almacenados no se eliminan.

### Conectividad y sincronización

La aplicación dispone de un banner que informa sobre el estado de conectividad:

- **En línea:** existe acceso al servicio.
- **Sin conexión:** no se dispone de conectividad.
- **Servicio no disponible:** existe conectividad de red, pero la API no responde.
- **Sincronizando:** se está ejecutando una sincronización del catálogo.

Para evitar cambios visuales demasiado frecuentes, el estado de conectividad utiliza un debounce de 800 milisegundos.

La aplicación solicita una sincronización al iniciarse y cuando detecta que se ha recuperado la conexión.

El servicio de sincronización descarga el catálogo en lotes de 100 Pokémon y omite la descarga cuando la última pasada completa tiene menos de 1 hora. Mientras hay servicio, repite la pasada cada hora, contada desde la última descarga. Con cada Pokémon guarda la huella SHA-256 de sus datos tal como llegaron de PokeAPI.

Con servicio, la página que se está viendo se revalida aparte: si alguno de sus Pokémon se guardó hace más de 15 minutos, la app los pide de nuevo a PokeAPI en una sola consulta y la lista se actualiza sola. Sin conexión no se hace ninguna llamada, y la revalidación se repite al recuperar la conexión.

El detalle de un Pokémon se pide a PokeAPI en una sola consulta cada vez que se abre con servicio, salvo que se haya descargado hace menos de 5 minutos. Si los datos locales de ese Pokémon fueron alterados, se pide siempre. La tabla de tipos, que la app usa para calcular los matchups, se descarga al iniciar o reconectar si tiene más de 24 horas, o al abrir un detalle si todavía no está guardada.

Cada consulta a PokeAPI queda registrada en la consola de depuración (VS Code o DevTools) con sus variables, su prioridad y su duración, por ejemplo `[pokeapi] PokemonDetail {"id":25} (user) 812 ms`. Las decisiones de la sincronización se registran como `[sync]`.

Si una sincronización falla por culpa de PokeAPI, por ejemplo con un HTTP 503 o un tiempo agotado, se reintenta a los 2, 4, 8, 16 y 32 segundos, con un ±20 % de variación. Los reintentos siguen también mientras el banner dice «Servicio no disponible», porque la API puede volver sin que cambie la red. Cada espera aparece en la consola, por ejemplo `[sync] catalog: reintento 3/5 en 8,4 s (ServerError(503))`. Tras el quinto reintento la sincronización queda en fallo y se repite al volver a «En línea» o con «Reintentar». Sin red no se gastan reintentos: la sincronización espera a la reconexión. En ningún caso se borran los datos guardados. Los detalles están en el [ADR-0004](docs/adr/0004-reintentos-presupuesto-y-una-sincronizacion-por-recurso.md).

Si la app se cierra a mitad de la descarga del catálogo, al volver a abrirla la consola dice dónde se quedó, por ejemplo `[sync] catalog: la pasada anterior se interrumpió en 400 de 1025; se reanuda`. La descarga sigue desde ese punto sin repetir los lotes ya guardados, porque cada lote se guarda en una transacción junto con su posición.

### Detección y restauración de datos alterados

Con cada Pokémon se guarda una huella SHA-256 de sus datos tal como llegaron de PokeAPI. Al iniciar, al reconectar y cada 60 segundos mientras hay servicio, la app recalcula la huella con los datos locales y la compara con la guardada, sin llamar a PokeAPI.

Si alguien cambió un dato local, por ejemplo con el inspector de Drift en DevTools, la app vuelve a pedir a PokeAPI solo los Pokémon alterados y los guarda en una transacción. La consola muestra cada cambio: `[sync] restauración #25 name: pikachux → pikachu`. Abrir el detalle de un Pokémon alterado también lo restaura. Los favoritos, la trivia, los logros y las preferencias nunca se tocan. Los detalles de la decisión están en el [ADR-0005](docs/adr/0005-deteccion-de-alteraciones-y-restauracion.md).

### Caché de imágenes

Las imágenes de los Pokémon se guardan en una caché propia, separada de la base de datos, con hasta 2500 archivos que se borran tras 180 días sin usarse. Una imagen vista una vez con conexión se muestra después sin conexión y tras reiniciar la app, en la lista, en favoritos y en el detalle. Cada imagen se decodifica al tamaño en que se pinta, para no ocupar más memoria de la necesaria.

En **Ajustes › Imágenes**:

- **Imágenes guardadas** muestra el espacio que ocupan, por ejemplo «Imágenes guardadas: 132,7 MB».
- **Guardar imágenes para usar sin conexión** descarga el official-artwork de todos los Pokémon del catálogo guardado, de 4 en 4, y muestra el avance («412 de 1025 guardadas»). Necesita red, pero no PokeAPI: las imágenes vienen de GitHub y no gastan el límite de llamadas. Si se sale de Ajustes, la descarga sigue. En el emulador tardó unos 60 segundos y ocupó 132,7 MB.
- **Borrar imágenes** vacía la caché, después de pedir confirmación.

Sin conexión, una imagen que no está guardada muestra un icono en su lugar; en el detalle, antes se prueba el sprite pequeño del Pokémon. Los motivos de cada decisión están en el [ADR-0007](docs/adr/0007-cache-de-imagenes-propia-y-acotada.md).

## Instalación y ejecución

### Requisitos

- Flutter SDK compatible con el proyecto.
- Dart SDK compatible con `pubspec.yaml`.
- Android Studio o Visual Studio Code.
- Emulador Android o dispositivo físico.
- Conexión a Internet para la primera sincronización.

### Pasos

1. Clonar el repositorio:

   ```bash
   git clone https://github.com/JoseHidalgoG/pokedex-flutter.git
   ```

2. Entrar al directorio:

   ```bash
   cd pokedex-flutter
   ```

3. Instalar las dependencias:

   ```bash
   flutter pub get
   ```

4. Verificar los dispositivos disponibles:

   ```bash
   flutter devices
   ```

5. Ejecutar la aplicación:

   ```bash
   flutter run
   ```

Durante la primera ejecución, la aplicación necesita Internet para descargar los Pokémon. Posteriormente, los datos sincronizados permanecen almacenados localmente.

## Pruebas y análisis

Para ejecutar las pruebas automatizadas:

```bash
flutter test
```

Para verificar el análisis estático:

```bash
flutter analyze
```

En la última validación realizada durante el desarrollo se obtuvieron los siguientes resultados:

- **63 pruebas automatizadas aprobadas.**
- **0 problemas de análisis estático.**

Las pruebas incluyen validaciones de sincronización, proveedores, presentación del catálogo, paginación, navegación y coordinación de sincronizaciones.

## Pruebas manuales de funcionamiento offline

Se comprobó el siguiente escenario en un dispositivo Android:

1. Abrir la aplicación con Internet.
2. Esperar a que se descarguen los Pokémon y sus imágenes.
3. Consultar el catálogo y abrir pantallas de detalles.
4. Desactivar la conexión a Internet.
5. Cerrar completamente la aplicación.
6. Volver a abrirla sin Internet.
7. Verificar que los Pokémon y las imágenes previamente descargadas sigan disponibles.

**Resultado:** las imágenes permanecieron visibles después de reiniciar la aplicación sin Internet, tanto en el catálogo como en los detalles.

## Arquitectura general

El proyecto organiza sus funcionalidades en capas:

- **Data:** acceso a GraphQL, persistencia mediante Drift y servicios de sincronización.
- **Domain:** entidades, contratos de repositorios y casos de uso.
- **Presentation:** pantallas, widgets y proveedores de estado.

El flujo principal de información es:

```text
PokéAPI (GraphQL)
       |
       v
Servicio de sincronización
       |
       v
Drift / SQLite
       |
       v
Repositorio offline-first
       |
       v
Proveedores Riverpod
       |
       v
Catálogo y pantalla de detalles
```

La conectividad se supervisa de forma independiente y permite solicitar una nueva sincronización cuando vuelve a estar disponible el servicio.

## Consideraciones

- La primera descarga requiere acceso a Internet.
- Los Pokémon no sincronizados previamente no estarán disponibles offline.
- Las imágenes se guardan en la carpeta de caché del sistema. Android puede vaciarla si le falta espacio, y el usuario puede hacerlo con «Borrar caché» en los ajustes del sistema. Las imágenes que falten muestran el icono hasta que se vean otra vez con conexión o se vuelvan a guardar.
- Guardar las imágenes de los 1025 Pokémon ocupa unos 133 MB (132,7 MB medidos en el emulador). Si el límite de 2500 archivos se llenara con imágenes shiny y de formas, serían unos 320 MB.
- Una imagen que no se pudo cargar sin conexión no se vuelve a pedir sola al recuperar la conexión: aparece al cambiar de página o al volver a abrir la pantalla.
- Los datos locales se conservan ante fallos de sincronización.
- El tiempo de sincronización depende de la conexión y de la disponibilidad de PokéAPI.
- PokeAPI permite 100 llamadas por hora. La app se detiene en 80 y lleva la cuenta en memoria, así que la cuenta vuelve a cero si se cierra la app, aunque PokeAPI siga contando las llamadas anteriores.
- Las llamadas de la simulación de caída no llegan a PokeAPI, pero cuentan en el presupuesto de la app. Al desactivarla, la sincronización que falló se repite de verdad, así que cada ensayo de PA-08 gasta unas 13 llamadas reales a PokeAPI.
- Los estados de sincronización guardados en `sync_metadata` no se restauran al reiniciar: la app vuelve a decidir qué sincronizar. La excepción es una sincronización que quedó a medias porque la app se cerró: se informa en la consola y la descarga del catálogo sigue desde donde se quedó.
- La pestaña de movimientos muestra un solo juego: el version group más reciente que tenga movimientos por nivel, sin contar los juegos Legends salvo que sean los únicos. Para Pikachu es Scarlet/Violet. Los motivos están en el [ADR-0006](docs/adr/0006-preferencia-online-dentro-del-presupuesto.md).
- Sin conexión, un detalle que nunca se abrió con servicio muestra solo los datos del catálogo (nombre, tipos, imagen, estadísticas, altura y peso) y los matchups, si la tabla de tipos ya está guardada. Las habilidades, los movimientos y las evoluciones se descargan la primera vez que se abre con servicio.
- Las tablas del detalle (habilidades, movimientos, evoluciones) no tienen huella propia: si se alteran, se corrigen la siguiente vez que el detalle se descarga.
- Los objetos, juegos, version groups y métodos de evolución poco comunes se muestran con el identificador de PokeAPI en inglés, formateado (por ejemplo `thunder-stone` → «Thunder Stone»), porque la app no descarga sus nombres traducidos. Los tipos, grupos huevo, métodos de aprendizaje, momentos del día y triggers habituales sí están traducidos.

## Cómo provocar los estados durante la demo

Pasos para provocar en vivo los escenarios que usan la simulación de caída de PokeAPI y el inspector de la base de datos. La simulación y el inspector solo existen en las compilaciones debug y profile.

### Preparación

- **Consola.** Ejecutar la app desde VS Code (Run › Start Debugging). Las líneas `[sync]` y `[pokeapi]` salen en la Debug Console de VS Code y en la vista Logging de DevTools; la terminal de `flutter run` no las muestra.
- **Inspector.** Abrir DevTools desde la sesión de depuración (en VS Code, el comando «Dart: Open DevTools») y entrar en la pestaña **drift**, que solo aparece con DevTools conectado a la app. Las consultas se escriben con el lápiz: una sentencia por ejecución, sin punto y coma.
- Una escritura hecha con el inspector no avisa a la app, así que la pantalla no se repinta sola.
- **Nunca pulsar «Clear database»:** borra toda la base del dispositivo.
- **Presupuesto.** Cada sincronización forzada (deslizar hacia abajo en Catálogo) gasta 11 de las 100 llamadas por hora a PokeAPI. Conviene no repetir PA-08, PA-12 y PA-13 más de lo necesario en la misma hora.

### Simulación de caída de PokeAPI

Mientras está activa, toda petición a PokeAPI recibe un HTTP 503 «Servicio no disponible (simulado)» sin salir a la red. La consulta de salud falla, el banner pasa a «Servicio no disponible» y las sincronizaciones se reintentan como en una caída real. Se activa de dos formas:

- **Desde la app:** Ajustes › Herramientas de demostración › **Simular caída de PokeAPI**. El valor se guarda y se conserva al reiniciar.
- **Al lanzar la app:**

  ```bash
  flutter run --dart-define=SIMULATE_API_OUTAGE=true
  ```

  El interruptor aparece activado desde el arranque, sea cual sea el valor guardado, y la primera consulta de salud ya está simulada. Para ver la consola con este comando, abrir la URL de DevTools que imprime `flutter run` y usar su vista Logging. Desde VS Code, el mismo argumento va en `"args"` de una configuración de `.vscode/launch.json`.

### PA-08: fallo de GraphQL con la red activa

1. En el inspector, ejecutar la consulta de conteos (ver «Consultas preparadas»).
2. Activar **Simular caída de PokeAPI**. En uno o dos segundos el banner dice «Servicio no disponible» y «Red activa, API sin respuesta · datos locales · Última sync: …».
3. En Catálogo, deslizar hacia abajo, o pulsar el botón de sincronizar de la barra superior. La consola muestra cada intento y cada espera; los segundos varían un ±20 %:

   ```text
   [sync] presupuesto 5/80 (background)
   [pokeapi] CatalogPage {"limit":100,"offset":0,"withTotal":true} (background) falló en 3 ms: ResponseFormatException(…)
   [sync] catalog: reintento 1/5 en 1,8 s (ServerError(503))
   …
   [sync] catalog: reintento 5/5 en 33,1 s (ServerError(503))
   [sync] catalog: falló tras 5 reintentos (ServerError(503))
   ```

   En cada intento el banner muestra un momento «Sincronizando...». Al final dice «No se pudo sincronizar · Se conservan los datos locales». Son 6 llamadas simuladas: 1 intento y 5 reintentos.
4. Repetir la consulta de conteos: los números no cambian.
5. Desactivar el interruptor. El banner vuelve a «En línea» y la sincronización que falló corre una vez, ya contra PokeAPI.

### PA-12: indicador en cuatro estados

El banner está encima de todas las pestañas, así que cada estado se ve igual en Catálogo y en Favoritos.

| Estado | Cómo provocarlo | Qué dice el banner |
| --- | --- | --- |
| En línea | Wi-Fi o datos, sin simulación | «En línea» · «API disponible · datos locales · Última sync: …» |
| Sin conexión | Modo avión | «Sin conexión» · «Datos locales · Última sync: …» |
| Servicio no disponible | Activar la simulación de caída | «Servicio no disponible» · «Red activa, API sin respuesta · datos locales · Última sync: …» |
| Sincronizando | Con servicio, deslizar hacia abajo en Catálogo | «Sincronizando...» · «En línea · Puedes seguir navegando», con una barra de progreso |

### PA-10: imágenes sin conexión

1. Con red: Ajustes › Imágenes › **Guardar imágenes para usar sin conexión**, hasta «1025 de 1025 guardadas» (unos 60 s).
2. Activar el modo avión, cerrar la app desde recientes y volver a abrirla.
3. Cualquier página del catálogo y cualquier detalle muestran su imagen.

Sin el paso 1 solo se muestran las imágenes ya vistas; las demás muestran un icono.

### PA-09: interrupción durante la sincronización

En un emulador, para no borrar los datos del teléfono de la demo:

1. Borrar los datos de la app y abrirla desde VS Code con la Debug Console visible:

   ```bash
   adb shell pm clear com.example.pokedex_flutter
   ```

2. La primera pasada descarga 11 lotes y tarda unos 10 a 15 s. Después de 3 o 4 líneas `[sync] presupuesto n/80 (background)`, cerrar la app a la fuerza, o desde recientes:

   ```bash
   adb shell am force-stop com.example.pokedex_flutter
   ```

3. Activar el modo avión del emulador y volver a abrir la app desde VS Code; los datos se conservan. La consola dice dónde se quedó, y el intento de arranque falla por falta de red y espera la reconexión:

   ```text
   [sync] catalog: la pasada anterior se interrumpió en 400 de 1025; se reanuda
   [sync] catalog: se reanuda desde 400 de 1025
   ```

   Si otra sincronización estaba en curso, por ejemplo `type_efficacy`, aparece una línea más que dice que se repite con su disparador habitual.
4. En el inspector, `SELECT key, status, next_offset, total_count, is_complete FROM sync_metadata` muestra `catalog` en `pending`, con `next_offset` 400, `total_count` 1025 e `is_complete` 0. `SELECT COUNT(*) FROM pokemon WHERE is_default = 1` da 400, lo mismo que `next_offset`, porque cada lote se guarda entero o no se guarda.
5. Quitar el modo avión. La consola vuelve a decir «se reanuda desde 400 de 1025» y solo aparecen los lotes que faltan: 7 en este ejemplo, en lugar de 11.
6. Repetir las dos consultas: `catalog` en `idle`, `is_complete` 1 y 1025 Pokémon por defecto.

### PA-16: restauración de datos alterados

1. En el inspector: `UPDATE pokemon SET name = 'pikachux' WHERE id = 25`.
2. La consulta de Pikachu (ver «Consultas preparadas») muestra `pikachux`. La lista de la app sigue mostrando el nombre anterior, porque la escritura del inspector no avisa a la app.
3. Con servicio, esperar hasta 60 s o abrir el detalle de Pikachu. La consola muestra `[sync] restauración #25 name: pikachux → pikachu`, o `[sync] detalle #25 restaurado …` si se abrió el detalle, y la consulta vuelve a dar `pikachu`.

### PA-13: sin duplicados

1. Ejecutar la consulta de conteos.
2. Deslizar hacia abajo en Catálogo tres veces, esperando a que termine cada sincronización.
3. Repetir la consulta de conteos: los números son los mismos.

### Consultas preparadas

Una por ejecución, sin punto y coma.

Conteos de las tablas del catálogo y de favoritos:

```sql
SELECT 'pokemon', COUNT(*) FROM pokemon
UNION ALL SELECT 'pokemon_types', COUNT(*) FROM pokemon_types
UNION ALL SELECT 'pokemon_stats', COUNT(*) FROM pokemon_stats
UNION ALL SELECT 'favorites', COUNT(*) FROM favorites
```

Estado de cada sincronización:

```sql
SELECT key, status, next_offset, total_count, is_complete, attempt, last_synced_at, last_error_kind FROM sync_metadata
```

Pokémon por defecto guardados:

```sql
SELECT COUNT(*) FROM pokemon WHERE is_default = 1
```

Alterar a Pikachu, su nombre o su primer tipo:

```sql
UPDATE pokemon SET name = 'pikachux' WHERE id = 25
```

```sql
UPDATE pokemon_types SET type_name = 'fire' WHERE pokemon_id = 25 AND slot = 1
```

Ver a Pikachu:

```sql
SELECT p.id, p.name, t.type_name FROM pokemon p JOIN pokemon_types t ON t.pokemon_id = p.id WHERE p.id = 25
```

## Proyecto académico

Aplicación desarrollada como proyecto académico de Flutter, con responsabilidades distribuidas entre los integrantes del equipo.