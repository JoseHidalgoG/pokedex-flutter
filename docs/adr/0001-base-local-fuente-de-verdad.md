# ADR-0001: Base de datos local como única fuente de verdad

- **Estado:** Aceptado
- **Fecha:** 2026-11-04
- **Aceptado:** 2026-11-10

## Contexto

La aplicación debe funcionar sin conexión, también después de reiniciarse (OF-05, OF-10), y abrir de inmediato sin bloquear la interfaz mientras carga (OF-03). Además, ningún widget puede consumir respuestas GraphQL directamente; la interfaz debe observar la base local (OF-16, OF-17, OF-18).

La API GraphQL de PokeAPI (`https://graphql.pokeapi.co/v1beta2`) tiene límite de peticiones y su propia documentación advierte que el endpoint puede cambiar. Depender de ella en tiempo real haría que la app fallara justo en los escenarios que el proyecto exige cubrir.

## Decisión

La base SQLite local, gestionada con Drift, es la única fuente de datos de la interfaz.

- La capa `presentation` solo conoce los casos de uso y el contrato `CatalogRepository` del dominio; nunca importa `data` ni `graphql`. Los datos del catálogo le llegan como `Stream`s que leen de la base local.
- `CatalogSyncService` descarga el catálogo por páginas de 50 (`catalogPageSize`) desde GraphQL y lo guarda con upsert por `id`, en una transacción por página (`CatalogDao.saveCatalogPage`).
- El progreso se guarda en la tabla `sync_metadata` (`nextOffset`, `isComplete`, `lastSyncedAt`, `lastError`), para reanudar la descarga tras un corte o un reinicio.
- Si el catálogo está completo y se sincronizó hace menos de 24 horas (`catalogFreshnessWindow`), la sincronización no descarga nada.
- Si llegan varias peticiones de sincronización a la vez, todas esperan a la misma ejecución en curso.
- El servicio publica su estado como `CatalogSyncStatus`: `CatalogSyncIdle`, `CatalogSyncInProgress`, `CatalogSyncSucceeded` o `CatalogSyncFailed`, este último con el motivo `noConnection` o `requestFailed`.
- La sincronización se dispara siempre en segundo plano:
  - al abrir la app, desde `CatalogSyncCoordinator`;
  - al recuperar la conexión, cuando `connectivityStatusProvider` pasa de un estado distinto de `online` a `online`;
  - al pulsar «Reintentar» en `CatalogScreen`.

## Alternativas consideradas

- **Consultar GraphQL directamente desde la interfaz y usar la caché del cliente.** Más simple al principio, pero la caché de `graphql` no sustituye un modelo de datos propio, no permite relacionar favoritos con el catálogo y viola OF-16.
- **Descargar el catálogo completo en una sola petición al primer arranque.** Evita la paginación, pero bloquea la primera carga, choca con el límite de peticiones y pierde todo el progreso si la descarga se corta.
- **Repositorio que decide en cada lectura si ir a la red o a la base.** Habitual, pero reparte la lógica de origen de datos y hace que la interfaz dependa del estado de la red.

## Consecuencias

- La interfaz se comporta igual con o sin conexión; solo cambia si llegan datos nuevos.
- Si la sincronización falla y ya hay datos guardados, la lista sigue visible y un `SnackBar` avisa del fallo; sin datos, se muestra el estado de error con «Reintentar».
- Los datos pueden quedar desactualizados hasta 24 horas; se acepta porque el catálogo de Pokémon cambia muy poco.
- Se necesitan migraciones de esquema (`MigrationStrategy`) cuando se añadan columnas en la entrega final.
- La lógica de sincronización queda aislada en un solo servicio, lo que facilita añadir reintentos con backoff más adelante.
