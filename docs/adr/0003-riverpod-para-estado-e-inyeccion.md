# ADR-0003: Riverpod para el estado y la inyección de dependencias

- **Estado:** Aceptado
- **Fecha:** 2026-11-10

## Contexto

La arquitectura por capas del ADR-0001 necesita una forma de unir las piezas sin romper sus reglas:

- `presentation` no puede importar `data`, pero alguien tiene que entregarle una implementación de `CatalogRepository`.
- La base Drift expone `Stream`s, y los widgets tienen que redibujarse cuando emiten.
- El estado de conectividad lo leen varias partes de la app: el banner y el disparador de la sincronización.
- Las pruebas tienen que poder sustituir la base, la red y el repositorio por versiones falsas sin tocar el código de producción.

## Decisión

Se usa `flutter_riverpod` 3.x con providers escritos a mano, sin generación de código.

- Cada capa declara sus propios providers:
  - `core`: `appDatabaseProvider` y `pokeApiGraphQLClientProvider`.
  - `data` del catálogo, en `catalog_data_providers.dart`: `catalogSyncServiceProvider` y `offlineFirstCatalogRepositoryProvider`.
  - `presentation` del catálogo, en `catalog_providers.dart`: casos de uso y `StreamProvider`s que ve la interfaz.
  - `connectivity`, en `connectivity_providers.dart`: servicio, repositorio y `connectivityStatusProvider`.
- `catalogRepositoryProvider` lanza `UnimplementedError` hasta que alguien lo sobrescribe. `main.dart` lo sobrescribe en el `ProviderScope` con `offlineFirstCatalogRepositoryProvider`; es el único punto donde `presentation` y `data` se encuentran.
- Los `Stream`s de la base llegan a la interfaz como `StreamProvider`: `catalogCountProvider`, `catalogSyncStatusProvider` y `catalogPageProvider`, este último un `StreamProvider.family` por número de página.
- `connectivityStatusProvider` estabiliza la señal con un debounce de 800 ms, para que un cambio breve de red no haga parpadear el banner ni lance sincronizaciones de más.
- Los recursos con ciclo de vida se cierran con `ref.onDispose`: la base de datos y el `StreamController` del servicio de sincronización.

## Alternativas consideradas

- **`provider`.** Más conocido, pero depende de `BuildContext` para leer dependencias, no permite sobrescribir una dependencia por prueba con la misma facilidad y su autor recomienda Riverpod como sucesor.
- **Bloc / Cubit.** Buen modelo para pantallas con eventos, pero añade una clase de estado y otra de eventos por pantalla, y sigue necesitando otra herramienta (`get_it` o `RepositoryProvider`) para inyectar el repositorio.
- **`get_it` con `StreamBuilder`.** Sin dependencias extra de estado, pero el localizador es global, las pruebas tienen que reiniciarlo a mano y cada widget gestiona sus propias suscripciones.
- **`riverpod_generator`.** Menos código repetido, pero suma un segundo paso de `build_runner` a la generación que ya exige Drift; con una docena de providers no compensa.

## Consecuencias

- Las pruebas de widgets y providers usan `overrides` para fijar lo que necesitan: un repositorio falso, las páginas y el recuento del catálogo, el estado de sincronización, el caso de uso `SyncCatalog` o el estado de conectividad. Las pruebas de la capa `data` construyen `AppDatabase(NativeDatabase.memory())` directamente.
- Olvidar la sobrescritura de `catalogRepositoryProvider` hace fallar la app al arrancar, en lugar de usar en silencio una implementación equivocada.
- `ConnectivityBanner` lee `catalogSyncStatusProvider` y `lastCatalogSyncProvider` para mostrar «Sincronizando...» y la hora de la última sincronización. Es una dependencia entre funcionalidades (`connectivity` → `catalog`) aceptada a propósito, porque el banner resume el estado de los datos para el usuario.
- `lastCatalogSyncProvider` es un `FutureProvider` que vuelve a calcularse cada vez que cambia `catalogSyncStatusProvider`.
- Al no haber generación de código para los providers, sus nombres y tipos se escriben a mano; un error de tipo se detecta igualmente al compilar.
