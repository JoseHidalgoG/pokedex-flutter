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
- **cached_network_image:** almacenamiento temporal de imágenes descargadas.
- **crypto:** huella SHA-256 de cada Pokémon, para detectar datos alterados en la base local.
- **share_plus:** compartir un Pokémon como texto desde su detalle.
- **flutter_test y mocktail:** pruebas automatizadas.
- **http (solo en pruebas):** `MockClient` detrás de un `HttpLink` real, para comprobar cómo se traducen las respuestas HTTP de PokeAPI a fallos de sincronización.

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

El servicio de sincronización descarga el catálogo en lotes de 100 Pokémon y omite la descarga cuando la última pasada completa tiene menos de 1 hora. Con cada Pokémon guarda la huella SHA-256 de sus datos tal como llegaron de PokeAPI.

Con servicio, la página que se está viendo se revalida aparte: si alguno de sus Pokémon se guardó hace más de 15 minutos, la app los pide de nuevo a PokeAPI en una sola consulta y la lista se actualiza sola. Sin conexión no se hace ninguna llamada, y la revalidación se repite al recuperar la conexión.

El detalle de un Pokémon se pide a PokeAPI en una sola consulta cada vez que se abre con servicio, salvo que se haya descargado hace menos de 5 minutos. Si los datos locales de ese Pokémon fueron alterados, se pide siempre. La tabla de tipos, que la app usa para calcular los matchups, se descarga al iniciar o reconectar si tiene más de 24 horas, o al abrir un detalle si todavía no está guardada.

Cada consulta a PokeAPI queda registrada en la consola de depuración (VS Code o DevTools) con sus variables, su prioridad y su duración, por ejemplo `[pokeapi] PokemonDetail {"id":25} (user) 812 ms`. Las decisiones de la sincronización se registran como `[sync]`.

### Detección y restauración de datos alterados

Con cada Pokémon se guarda una huella SHA-256 de sus datos tal como llegaron de PokeAPI. Al iniciar, al reconectar y cada 60 segundos mientras hay servicio, la app recalcula la huella con los datos locales y la compara con la guardada, sin llamar a PokeAPI.

Si alguien cambió un dato local, por ejemplo con el inspector de Drift en DevTools, la app vuelve a pedir a PokeAPI solo los Pokémon alterados y los guarda en una transacción. La consola muestra cada cambio: `[sync] restauración #25 name: pikachux → pikachu`. Abrir el detalle de un Pokémon alterado también lo restaura. Los favoritos, la trivia, los logros y las preferencias nunca se tocan. Los detalles de la decisión están en el [ADR-0005](docs/adr/0005-deteccion-de-alteraciones-y-restauracion.md).

### Caché de imágenes

Las imágenes se muestran mediante `CachedNetworkImage`.

Las imágenes descargadas pueden reutilizarse sin Internet, tanto en el listado como en la pantalla de detalles.

**Limitación:** las imágenes se almacenan en una caché temporal. Las imágenes que nunca se descargaron o que fueron eliminadas de la caché podrían no estar disponibles sin conexión.

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
- La caché de imágenes no garantiza almacenamiento permanente.
- Los datos locales se conservan ante fallos de sincronización.
- El tiempo de sincronización depende de la conexión y de la disponibilidad de PokéAPI.
- PokeAPI permite 100 llamadas por hora. La app se detiene en 80 y lleva la cuenta en memoria, así que la cuenta vuelve a cero si se cierra la app, aunque PokeAPI siga contando las llamadas anteriores.
- Los estados de sincronización guardados en `sync_metadata` no se restauran al reiniciar: la app vuelve a decidir desde cero qué sincronizar.
- La pestaña de movimientos muestra un solo juego: el version group más reciente que tenga movimientos por nivel, sin contar los juegos Legends salvo que sean los únicos. Para Pikachu es Scarlet/Violet. Los motivos están en el [ADR-0006](docs/adr/0006-preferencia-online-dentro-del-presupuesto.md).
- Sin conexión, un detalle que nunca se abrió con servicio muestra solo los datos del catálogo (nombre, tipos, imagen, estadísticas, altura y peso) y los matchups, si la tabla de tipos ya está guardada. Las habilidades, los movimientos y las evoluciones se descargan la primera vez que se abre con servicio.
- Las tablas del detalle (habilidades, movimientos, evoluciones) no tienen huella propia: si se alteran, se corrigen la siguiente vez que el detalle se descarga.
- Los objetos, juegos, version groups y métodos de evolución poco comunes se muestran con el identificador de PokeAPI en inglés, formateado (por ejemplo `thunder-stone` → «Thunder Stone»), porque la app no descarga sus nombres traducidos. Los tipos, grupos huevo, métodos de aprendizaje, momentos del día y triggers habituales sí están traducidos.

## Proyecto académico

Aplicación desarrollada como proyecto académico de Flutter, con responsabilidades distribuidas entre los integrantes del equipo.