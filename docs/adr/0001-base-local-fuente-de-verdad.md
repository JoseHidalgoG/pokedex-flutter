# ADR-0001: Base de datos local como única fuente de verdad

- **Estado:** Propuesto
- **Fecha:** 2026-11-04

## Contexto

La aplicación debe funcionar sin conexión, también después de reiniciarse (OF-05, OF-10), y abrir de inmediato sin bloquear la interfaz mientras carga (OF-03). Además, ningún widget puede consumir respuestas GraphQL directamente; la interfaz debe observar la base local (OF-16, OF-17, OF-18).

La API GraphQL de PokeAPI (`https://graphql.pokeapi.co/v1beta2`) tiene límite de peticiones y su propia documentación advierte que el endpoint puede cambiar. Depender de ella en tiempo real haría que la app fallara justo en los escenarios que el proyecto exige cubrir.

## Decisión

La base SQLite local, gestionada con Drift, es la única fuente de datos de la interfaz.

- La capa `presentation` solo lee `Stream`s expuestos por los casos de uso del dominio, que a su vez leen de la base local.
- Un servicio de sincronización (`CatalogSyncService`) descarga el catálogo por páginas desde GraphQL y lo guarda en la base con upsert por `id`, en una transacción por página.
- El progreso de la sincronización se guarda en la tabla `sync_metadata`, para reanudarla tras un reinicio.
- La sincronización se dispara al abrir la app, al recuperar la conexión y al pulsar «Reintentar», siempre en segundo plano.

## Alternativas consideradas

- **Consultar GraphQL directamente desde la interfaz y usar la caché del cliente.** Más simple al principio, pero la caché de `graphql` no sustituye un modelo de datos propio, no permite relacionar favoritos con el catálogo y viola OF-16.
- **Descargar el catálogo completo en una sola petición al primer arranque.** Evita la paginación, pero bloquea la primera carga, choca con el límite de peticiones y pierde todo el progreso si la descarga se corta.
- **Repositorio que decide en cada lectura si ir a la red o a la base.** Habitual, pero reparte la lógica de origen de datos y hace que la interfaz dependa del estado de la red.

## Consecuencias

- La interfaz se comporta igual con o sin conexión; solo cambia si llegan datos nuevos.
- Los datos pueden quedar desactualizados entre sincronizaciones; se acepta porque el catálogo de Pokémon cambia muy poco.
- Se necesitan migraciones de esquema (`MigrationStrategy`) cuando se añadan columnas en la entrega final.
- La lógica de sincronización queda aislada en un solo servicio, lo que facilita añadir reintentos con backoff y el estado «Sincronizando» más adelante.
