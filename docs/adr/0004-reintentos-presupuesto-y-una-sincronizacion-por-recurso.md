# ADR-0004: Reintentos con backoff, presupuesto de llamadas y una sola sincronización por recurso

- **Estado:** Aceptado
- **Fecha:** 2026-11-21

## Contexto

La API GraphQL de PokeAPI admite 100 llamadas por hora y por IP. En el avance, la app no llevaba la cuenta. La consulta de salud se repetía cada 15 s mientras la API fallaba, es decir, 240 llamadas por hora. Un fallo pasajero dejaba el catálogo en `CatalogSyncFailed` hasta que el usuario pulsaba «Reintentar», y ese estado solo distinguía dos motivos: `noConnection` y `requestFailed`.

La versión final sincroniza varios recursos que compiten por las mismas 100 llamadas: la pasada completa del catálogo, la página visible y, desde la fase 2, el detalle y la restauración de datos alterados. La rúbrica pide, además, reintentos con backoff, control de concurrencia y escrituras transaccionales documentados en un ADR (ENT-10, RNF-RES-01 a RNF-RES-06).

## Decisión

Una sola pieza, `SyncScheduler` en `lib/core/sync/`, decide cuándo corre cada sincronización y cuántas llamadas puede gastar. Los servicios de cada recurso solo descargan, validan y guardan.

- **Trabajos por clave.** Cada sincronización es un `SyncJob` con una clave (`catalog`, `catalog:visible`), una prioridad, el estado que publica mientras corre y su `perform`, que devuelve `SyncOutcome.revalidated` o `SyncOutcome.upToDate`.
- **Un solo intento en curso por clave (RNF-RES-03).** Dos `run` de la misma clave comparten el mismo `Future`. Claves distintas corren a la vez y el presupuesto decide quién gasta. Cuando cambia lo que se pide, como los ids de la página visible, `runLatest` deja la petición en espera hasta que termine la que está en curso, y una más nueva reemplaza a la que esperaba.
- **Fallos tipados.** `SyncFailure` es un tipo sellado en Dart puro con ocho casos y la propiedad `isRetryable`. La capa `data` lo traduce desde las excepciones de `graphql` con `syncFailureFrom`, así que ni `domain` ni `presentation` conocen `OperationException`.
- **Reintentos con backoff (RNF-RES-01).** `RetryPolicy` espera 2 s × 2^(intento − 1), con ±20 % de variación y un tope de 60 s, durante 5 reintentos como máximo: 2, 4, 8, 16 y 32 s. La espera es un `Timer`; nadie espera con `await` a que pase. Tras el quinto reintento el recurso queda en `failed` y vuelve a intentarse en la siguiente reconexión o con «Reintentar». `QueryError` no se reintenta.
- **Sin conexión.** Si el estado de conectividad no es `online`, un `NoConnection` no gasta reintentos: el trabajo espera a la reconexión. Si el estado sigue en `online` (un cambio de Wi-Fi a datos puede cortar una petición sin que cambie el estado), se reintenta como cualquier otro fallo. Si la conexión se pierde durante una espera, el temporizador se cancela y la reconexión retoma el trabajo.
- **Presupuesto de llamadas.** `CallBudget` cuenta las llamadas de los últimos 60 minutos con tres topes: 80 para el usuario y la salud, 70 para las restauraciones y 60 para la pasada completa. `CallBudgetLink`, delante de `HttpLink`, reserva un hueco antes de cada consulta, también la de salud. Si el tope de su prioridad está lleno, lanza `CallBudgetExhausted(until)` sin salir a la red, y el trabajo pasa a `SyncPaused(until)` hasta que se libera el hueco. Una respuesta 429 bloquea el presupuesto durante su `Retry-After`, o 10 minutos si no lo trae.
- **Estado observable.** `SyncScheduler` publica un `SyncStatus` por clave: `SyncIdle`, `SyncFullPassInProgress`, `SyncRevalidating`, `SyncRevalidated(at)`, `SyncWaitingRetry(attempt, maxAttempts, retryAt, failure)`, `SyncPaused(until)` o `SyncFailed(failure)`. El mismo estado queda en `sync_metadata`: `status`, `attempt`, `next_retry_at`, `last_error_kind` y `last_error`.
- **Escrituras transaccionales (RNF-RES-04).** Cada lote se guarda en una transacción junto con su fila de `sync_metadata`. Si un lote falla, los anteriores quedan guardados y la siguiente pasada sigue desde `next_offset`.
- **Salud con espera creciente.** Mientras la API no responde, `ConnectivityService` repite la consulta de prueba a los 15, 30, 60 y 120 s y luego cada 5 min. Una hora sin servicio gasta 16 llamadas en lugar de 240.

`SyncStatus` y `SyncFailure` sustituyen a `CatalogSyncStatus` y a sus dos motivos, descritos en el ADR-0001. El ADR-0001 se conserva tal como se escribió.

## Alternativas consideradas

- **Un bucle de reintentos dentro de cada servicio.** Es lo más directo, pero repite la lógica en cada recurso, obliga a quien llama a esperar el backoff y no da una vista común del presupuesto.
- **Reintentos con espera fija.** Es más simple, pero si la API cae, todos los recursos reintentan a la vez y al mismo ritmo, y gastan el límite justo cuando la API se está recuperando.
- **Reaccionar solo a los 429.** Ahorra el contador propio, pero el primer 429 ya penaliza y PokeAPI puede bloquear la IP. Contar antes de llamar evita llegar al límite.
- **Un paquete de reintentos o de tareas en segundo plano (`retry`, `workmanager`).** Añade dependencias y código ajeno que defender. Las tareas con la app cerrada piden configuración nativa y quedan fuera del alcance: la app solo sincroniza mientras está abierta.

## Consecuencias

- Un fallo pasajero se recupera sin que el usuario haga nada. El banner puede decir en qué intento está y cuándo vuelve a intentarlo, y hasta cuándo dura una pausa por presupuesto.
- La pasada completa nunca deja sin llamadas al usuario: se detiene en 60, y lo que el usuario pide puede llegar hasta 80.
- Cada recurso nuevo (detalle, restauración, tabla de tipos) es otro `SyncJob` con su clave y su prioridad, y recibe reintentos, presupuesto y estado sin código propio.
- El presupuesto vive en memoria y se reinicia si se cierra la app, mientras que el contador real de PokeAPI sigue corriendo. El margen de 20 llamadas y el manejo de los 429 cubren ese caso.
- Los estados guardados en `sync_metadata` no se restauran al reiniciar: el planificador empieza en `SyncIdle`. Retomar una pasada interrumpida (`in_progress`, PA-09) llega en la fase 3.
- El backoff y el presupuesto se prueban con `fake_async` en pruebas unitarias. En el dispositivo se demuestran con la simulación de caída de la fase 3.
