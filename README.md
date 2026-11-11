# Pokédex Flutter — Offline First

Aplicación móvil desarrollada con Flutter que permite consultar un catálogo de Pokémon utilizando la API GraphQL de PokéAPI y una base de datos local SQLite.

La aplicación sigue una arquitectura **offline-first**, por lo que los Pokémon previamente sincronizados pueden consultarse incluso cuando el dispositivo no dispone de conexión a Internet.

## Tecnologías utilizadas

- **Flutter y Dart:** desarrollo de la aplicación móvil.
- **Riverpod:** gestión del estado e inyección de dependencias.
- **Drift y SQLite:** almacenamiento persistente del catálogo.
- **GraphQL:** comunicación con la API de PokéAPI.
- **connectivity_plus:** detección de cambios de conectividad.
- **internet_connection_checker_plus:** comprobación de acceso a Internet.
- **cached_network_image:** almacenamiento temporal de imágenes descargadas.
- **flutter_test y mocktail:** pruebas automatizadas.

## Funcionalidades principales

### Catálogo de Pokémon

- Visualización del número, nombre, imagen y tipos de cada Pokémon.
- Paginación del catálogo en grupos de 50 elementos.
- Pantalla de detalles con información básica del Pokémon.
- Estados visuales de carga, error y catálogo vacío.
- Botón para reintentar la sincronización cuando sea necesario.

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

El servicio de sincronización comprueba la antigüedad de los datos y puede omitir descargas innecesarias cuando el catálogo ya se encuentra actualizado dentro de un período de 24 horas.

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

## Proyecto académico

Aplicación desarrollada como proyecto académico de Flutter, con responsabilidades distribuidas entre los integrantes del equipo.