# ADR-0002: Drift sobre SQLite como base de datos local

- **Estado:** Aceptado
- **Fecha:** 2026-11-07
- **Aceptado:** 2026-11-10

## Contexto

El ADR-0001 hace de la base local la única fuente de datos de la interfaz. Esa base tiene que:

- Relacionar datos: cada Pokémon tiene uno o dos tipos en orden, y los favoritos se guardan aparte del catálogo.
- Guardar una página completa de forma atómica, sin duplicados aunque la misma página llegue dos veces.
- Emitir los cambios como `Stream`, para que la interfaz se actualice sola cuando la sincronización escribe.
- Admitir migraciones de esquema, porque la entrega final añade columnas para el detalle y la restauración de datos (OF-19 a OF-21).

## Decisión

Se usa Drift sobre SQLite, abierto con `drift_flutter` en un isolate de fondo.

- `AppDatabase` vive en `lib/core/database/` y es el único punto que reúne las tablas de todas las funcionalidades. Cada funcionalidad declara sus propias tablas en su capa `data`.
- Tablas del avance: `pokemon`, `pokemon_types`, `favorites` y `sync_metadata`. El número nacional del Pokémon es la clave primaria de `pokemon`.
- `CatalogDao.saveCatalogPage` guarda la página en una transacción: upsert de `pokemon`, reemplazo de los tipos de esos Pokémon y avance de `sync_metadata`.
- La interfaz pagina con `CatalogDao.watchCatalogPage` (`LIMIT` y `OFFSET` ordenados por `id`) y `CatalogDao.watchCatalogCount`.
- `pokemon_types` borra en cascada con su Pokémon; las claves foráneas se activan con `PRAGMA foreign_keys = ON` al abrir la base.
- `favorites` no tiene clave foránea hacia `pokemon`, para que ninguna operación sobre el catálogo pueda borrar lo que marcó el usuario.
- `schemaVersion = 1` con `MigrationStrategy` desde el primer día.

## Alternativas consideradas

- **Hive.** Almacén clave-valor muy rápido, pero sin relaciones, sin consultas con join y sin transacciones entre cajas. El paquete original dejó de mantenerse y su continuidad depende de un fork de la comunidad.
- **Isar.** Base NoSQL con consultas reactivas, pero su autor abandonó el desarrollo y la versión 4 nunca salió de prerelease; también depende de un fork de la comunidad.
- **sqflite directamente.** Es SQLite igual que Drift, pero con SQL en cadenas sin comprobar, filas como `Map<String, Object?>`, sin `Stream`s y con migraciones escritas a mano.

## Consecuencias

- Las consultas y las filas están tipadas; un error de columna se detecta al compilar.
- La interfaz puede observar consultas con join gracias a `watch()`, que vuelve a emitir tras cada escritura.
- Una clave primaria entera simple es un alias de `rowid` en SQLite, así que en los companions de `.insert` el `id` es `Value<int>` opcional; el número de la Pokédex se pasa siempre de forma explícita para que SQLite no invente uno.
- Se depende de generación de código: tras cambiar una tabla hay que ejecutar `dart run build_runner build`. Los archivos `*.g.dart` se suben al repositorio para que `main` compile sin ese paso.
- Las pruebas usan `NativeDatabase.memory()`, una base SQLite real en memoria, sin mocks.
- `lib/core/database/` importa las tablas de cada funcionalidad; es la única excepción a que `core` no conozca las funcionalidades.
