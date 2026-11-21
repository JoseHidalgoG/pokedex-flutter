# Arquitectura

La app sigue una arquitectura por capas dentro de cada funcionalidad: `presentation` → `domain` ← `data`. La base SQLite local es la única fuente de datos de la interfaz; la red solo sirve para llenarla. Las decisiones que llevan a esto están en los ADRs:

- [ADR-0001: Base de datos local como única fuente de verdad](adr/0001-base-local-fuente-de-verdad.md)
- [ADR-0002: Drift sobre SQLite como base de datos local](adr/0002-drift-como-base-local.md)
- [ADR-0003: Riverpod para el estado y la inyección de dependencias](adr/0003-riverpod-para-estado-e-inyeccion.md)

## Estructura de carpetas

```text
lib/
  main.dart        arranque, MainApp y SyncLifecycle
  core/
    database/      AppDatabase y su provider
    network/       cliente GraphQL de PokeAPI, CallBudgetLink y su provider
    sync/          SyncScheduler y sus providers
      domain/      SyncFailure, SyncStatus, SyncJob, RetryPolicy, CallBudget
      data/        tabla sync_metadata, SyncMetadataDao, traductor de fallos
  features/
    catalog/
      data/        local (Drift), remote (GraphQL), sync, repositorio
      domain/      entidades, contrato CatalogRepository, casos de uso
      presentation/ pantallas, widgets, providers
    connectivity/
      data/        ConnectivityService y repositorio
      domain/      ConnectivityStatus y contrato
      presentation/ ConnectivityBanner
    favorites/
      data/        tabla favorites (la interfaz llega en la entrega final)
```

## Capas y componentes

La interfaz nunca habla con la red. Lee `Stream`s que salen de `CatalogDao`, y la única pieza del catálogo que toca GraphQL es `CatalogSyncService`, que escribe en la base. `SyncScheduler` decide cuándo corre cada sincronización y `CallBudgetLink` cuenta cada llamada antes de que salga a PokeAPI. `main.dart` une `presentation` con `data` sobrescribiendo `catalogRepositoryProvider`.

```mermaid
flowchart LR
  subgraph presentation
    Screen[CatalogScreen]
    Banner[ConnectivityBanner]
    Lifecycle[SyncLifecycle]
  end

  subgraph domain
    UseCases["WatchCatalogPage · WatchCatalogCount<br/>WatchPokemonByIds · WatchCatalogSyncStatus<br/>SyncCatalog · RevalidatePokemon"]
    Contract[["CatalogRepository"]]
  end

  subgraph data
    Repo[OfflineFirstCatalogRepository]
    Sync[CatalogSyncService]
    Dao[CatalogDao]
    Remote[CatalogRemoteDataSource]
  end

  subgraph core
    Scheduler[SyncScheduler]
    Db[(AppDatabase<br/>SQLite)]
    Client["PokeAPI GraphQLClient<br/>con CallBudgetLink"]
  end

  Screen --> UseCases
  Lifecycle -- arranca --> Scheduler
  Banner --> UseCases
  Banner -- getLastSyncedAt --> Contract
  UseCases --> Contract
  Repo -. implementa .-> Contract
  Repo -- lee --> Dao
  Repo -- encola --> Scheduler
  Scheduler -- ejecuta --> Sync
  Sync -- escribe --> Dao
  Sync --> Remote
  Remote --> Client
  Dao --> Db
```

## Sincronización al abrir la app

`main` llama a `runApp` sin esperar a la red. `SyncLifecycle` arranca `SyncScheduler`, que lanza la pasada completa del catálogo al iniciar y otra vez cada vez que el estado pasa a `online`. Si al iniciar no hay conexión, la pasada queda pendiente hasta la reconexión; la pantalla se redibuja sola cada vez que se guarda un lote.

```mermaid
sequenceDiagram
  participant Connectivity as connectivityStatusProvider
  participant Scheduler as SyncScheduler
  participant Sync as CatalogSyncService
  participant Dao as CatalogDao
  participant Remote as CatalogRemoteDataSource
  participant Screen as CatalogScreen

  Connectivity->>Scheduler: arranque de la app, o paso a online
  Scheduler->>Dao: sync_metadata.status = in_progress
  Scheduler->>Sync: perform() de la pasada completa
  Sync->>Dao: readCatalogSyncProgress()
  Dao-->>Sync: sync_metadata
  alt catálogo completo y última pasada hace menos de 1 h
    Sync-->>Scheduler: upToDate, sin llamar a PokeAPI
  else falta descargar
    loop hasta llegar al total o recibir menos de 100 Pokémon
      Sync->>Remote: fetchCatalogPage(limit: 100, offset, withTotal)
      Remote-->>Sync: CatalogBatch, con el total solo en el primer lote
      Sync->>Dao: saveCatalogPage() con huella, en una transacción
      Dao-->>Screen: watchCatalogPage emite la lista nueva
    end
    Sync-->>Scheduler: revalidated
  end
  Scheduler->>Dao: sync_metadata.status = idle
  Scheduler-->>Screen: SyncRevalidated(ahora) o el estado anterior
```

Si la descarga se corta, `sync_metadata.next_offset` guarda dónde se quedó y la siguiente sincronización continúa desde ahí.

## Revalidación de lo visible

La pasada completa solo corre si la última tiene más de 1 h, así que la página que se está viendo se revalida aparte. `catalogPageProvider` llama a `RevalidatePokemon` con los ids de la página la primera vez que la página trae Pokémon y cada vez que vuelve a mostrarse. No espera la respuesta: si llegan datos nuevos, entran por la base y `watchCatalogPage` vuelve a emitir.

- **Sin conexión** no se hace nada. El repositorio deja la petición registrada con `runOnEachReconnect` y `SyncScheduler` la repite en la siguiente reconexión.
- **Con servicio** solo se llama si algún id tiene `pokemon.updated_at` de hace más de 15 min (`visibleFreshnessWindow`). Si todos están frescos, no hay llamada ni cambio de estado.
- **Una sola consulta** `PokemonByIds` trae los ids vencidos con prioridad de usuario, bajo la clave `catalog:visible`. `saveRevalidated` los guarda en una transacción con `_upsertEntries`, sin tocar el progreso de la pasada completa.
- **`force`** (deslizar para actualizar, en la fase 2) pide todos los ids aunque estén frescos.
- **`runLatest`**: si llega una petición mientras otra de lo visible está en curso, espera a que termine, y una más nueva la reemplaza. Así, al pasar páginas rápido solo se descarga la última.

```mermaid
sequenceDiagram
  participant Page as catalogPageProvider
  participant Repo as OfflineFirstCatalogRepository
  participant Scheduler as SyncScheduler
  participant Sync as CatalogSyncService
  participant Dao as CatalogDao
  participant Remote as CatalogRemoteDataSource

  Page->>Repo: revalidatePokemon(ids de la página), sin esperar
  Repo->>Scheduler: runOnEachReconnect(catalog:visible)
  alt sin conexión
    Repo-->>Page: nada; la reconexión lo retoma
  else con servicio
    Repo->>Sync: hasStalePokemonAmong(ids)
    Sync->>Dao: staleIdsAmong(ids, hace 15 min)
    alt todos frescos
      Repo-->>Page: nada, sin llamadas
    else alguno vencido
      Repo->>Scheduler: runLatest(catalog:visible)
      Scheduler->>Sync: perform(), con SyncRevalidating
      Sync->>Remote: fetchPokemonByIds(ids vencidos), prioridad user
      Remote-->>Sync: Pokémon de PokeAPI
      Sync->>Dao: saveRevalidated() en una transacción
      Dao-->>Page: watchCatalogPage emite los datos nuevos
      Sync-->>Scheduler: revalidated
      Scheduler-->>Repo: SyncRevalidated(ahora)
    end
  end
```

## Estados de la sincronización

`SyncScheduler` publica un `SyncStatus` por recurso, un tipo sellado en Dart puro de `core/sync/domain`. La pantalla y el banner leen el del catálogo para mostrar «Cargando catálogo», «Sincronizando...», el estado de error o el `SnackBar` de fallo. Ese estado junta las claves `catalog` y `catalog:visible` con `mostRelevantSyncStatus`, que elige, en este orden: pasada completa en curso, revalidando, esperando reintento, en pausa, fallo, revalidado (la hora más reciente) y reposo. El mismo estado queda en `sync_metadata.status` (`in_progress`, `waiting_retry`, `paused`, `pending`, `failed` o `idle`), con el intento, la hora del próximo reintento y el tipo del último fallo.

`SyncRevalidated` solo aparece cuando los datos acaban de llegar de PokeAPI en esta sesión. Si el catálogo está fresco y no hace falta llamar, el estado vuelve a `SyncIdle`, o a la última revalidación si ya hubo una.

Un fallo reintentable espera 2, 4, 8, 16 y 32 s (`RetryPolicy`) y después queda en `SyncFailed` hasta la siguiente reconexión o «Reintentar». Un 429 bloquea el presupuesto durante su `Retry-After`, o 10 min si no lo trae. Si se pierde la conexión durante una espera, el temporizador se cancela y la reconexión retoma el trabajo. Cada clave tiene un solo intento en curso: dos peticiones de la pasada completa comparten la misma descarga, y lo visible usa `runLatest` para que la petición más nueva espere a la que está en curso.

```mermaid
stateDiagram-v2
  [*] --> SyncIdle
  SyncIdle --> SyncFullPassInProgress: arranque, reconexión o syncCatalog()
  SyncFullPassInProgress --> SyncIdle: catálogo fresco, sin llamadas
  SyncFullPassInProgress --> SyncRevalidated: descarga completa
  SyncFullPassInProgress --> SyncWaitingRetry: fallo reintentable en línea
  SyncWaitingRetry --> SyncFullPassInProgress: vence la espera
  SyncFullPassInProgress --> SyncPaused: CallBudgetExhausted
  SyncPaused --> SyncFullPassInProgress: se libera un hueco
  SyncFullPassInProgress --> SyncFailed: QueryError, 5 reintentos o sin conexión
  SyncWaitingRetry --> SyncFailed: se pierde la conexión
  SyncRevalidated --> SyncFullPassInProgress: reconexión o Reintentar
  SyncFailed --> SyncFullPassInProgress: reconexión o Reintentar
  SyncIdle --> SyncRevalidating: página con datos de más de 15 min
  SyncRevalidated --> SyncRevalidating: página con datos de más de 15 min
  SyncRevalidating --> SyncRevalidated: PokemonByIds guardado
```

La revalidación de lo visible pasa por los mismos reintentos, pausas y fallos que la pasada completa, con su propia clave.

`SyncFailed` lleva el `SyncFailure` que explica el fallo. `data` lo traduce desde las excepciones de GraphQL, así que ni `presentation` ni `domain` conocen `OperationException`.

| Fallo | Cuándo ocurre | `isRetryable` |
| --- | --- | --- |
| `NoConnection` | No llega ninguna respuesta HTTP: sin red, DNS o conexión cortada | `false`; espera la reconexión |
| `RequestTimeout` | PokeAPI no responde dentro del límite de la consulta | `true` |
| `RateLimited` | HTTP 429, con su `Retry-After` en segundos si lo trae | `true` |
| `ServerError` | HTTP 5xx, aunque el cuerpo no sea JSON | `true` |
| `PartialResponse` | Llegan `data` y `errors` a la vez; no se guarda nada | `true` |
| `QueryError` | Llegan `errors` sin `data`, un HTTP 4xx o un error inesperado | `false` |
| `InvalidResponse` | El cuerpo no se puede leer o no trae la lista esperada | `true` |
| `CallBudgetExhausted` | `CallBudgetLink` no deja salir la llamada; nunca llega a la red | `true`; se pausa hasta que se libera un hueco |

`CallBudget` cuenta las llamadas de los últimos 60 min. Cada consulta lleva su prioridad en el `Context` de GraphQL: la salud y lo que pide el usuario pueden gastar hasta 80, las restauraciones hasta 70 y la pasada completa hasta 60, así que el catálogo nunca deja sin llamadas al usuario. Una consulta sin prioridad cuenta como segundo plano. El presupuesto vive en memoria y se reinicia si se cierra la app.

## Conectividad

`ConnectivityService` no se fía solo del sistema operativo: tener Wi-Fi no garantiza que la API responda. Por eso distingue tres estados. `connectivityStatusProvider` ignora los cambios que duran menos de 800 ms, y `SyncScheduler` relanza la pasada completa, los trabajos pendientes y la última revalidación de lo visible cuando el estado pasa a `online`.

Mientras el estado es `serviceUnavailable`, el servicio repite la consulta de prueba, porque la API puede volver sin que cambie la red. La espera crece con cada fallo seguido: 15, 30, 60 y 120 s, y luego cada 5 min. Así, una hora sin servicio gasta 16 de las 100 llamadas por hora que permite PokeAPI, en vez de 240. Un cambio de red vuelve a empezar en 15 s. En cuanto la API responde, el estado pasa a `online` y el catálogo se sincroniza sin reiniciar la aplicación. En `online` y `offline` no repite la consulta.

La consulta de prueba espera como máximo 5 s, para que el banner reaccione rápido. Cada lote del catálogo espera hasta 30 s (`catalogPageRequestTimeout`), porque trae 100 Pokémon con sus tipos y estadísticas y puede tardar más en una red móvil. La consulta de salud gasta del presupuesto con prioridad de usuario.

```mermaid
flowchart TD
  Change[connectivity_plus avisa de un cambio] --> Network{¿Hay alguna red?}
  Network -- no --> Offline[offline]
  Network -- sí --> Health["Consulta GraphQL de prueba<br/>pokemon(limit: 1), máximo 5 s"]
  Health -- responde --> Online[online]
  Health -- error o tiempo agotado --> Unavailable[serviceUnavailable]
  Unavailable -.->|15, 30, 60, 120 s y luego cada 5 min| Health
  Offline --> Debounce[Debounce de 800 ms]
  Online --> Debounce
  Unavailable --> Debounce
  Debounce --> Banner[ConnectivityBanner]
  Debounce --> Transition{¿Pasó de otro estado a online?}
  Transition -- sí --> Scheduler[SyncScheduler]
```

## Modelo de datos

`pokemon_types` se borra en cascada con su Pokémon. `favorites` no tiene clave foránea hacia `pokemon` a propósito, para que ninguna operación sobre el catálogo borre lo que marcó el usuario. `sync_metadata` tiene una fila por proceso de sincronización.

```mermaid
erDiagram
  pokemon ||--|{ pokemon_types : "tiene 1 o 2"
  pokemon {
    int id PK "número de la Pokédex"
    string name
    string image_url
    datetime updated_at
  }
  pokemon_types {
    int pokemon_id PK, FK
    int slot PK
    string type_name
  }
  favorites {
    int pokemon_id PK "sin FK"
    datetime created_at
  }
  sync_metadata {
    string key PK
    int next_offset
    int total_count
    bool is_complete
    datetime last_synced_at
    string last_error
  }
```
