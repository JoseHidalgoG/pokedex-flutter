# ADR-0004: Reintentos con backoff, presupuesto de llamadas y una sola sincronización por recurso

- **Estado:** Aceptado
- **Fecha:** 2026-11-21
- **Actualizado:** 2026-11-26, con los reintentos durante una caída del servicio, la pasada interrumpida y la simulación de caída

## Contexto

La API GraphQL de PokeAPI admite 100 llamadas por hora y por IP. En el avance, la app no llevaba la cuenta. La consulta de salud se repetía cada 15 s mientras la API fallaba, es decir, 240 llamadas por hora. Un fallo pasajero dejaba el catálogo en `CatalogSyncFailed` hasta que el usuario pulsaba «Reintentar», y ese estado solo distinguía dos motivos: `noConnection` y `requestFailed`.

La versión final sincroniza varios recursos que compiten por las mismas 100 llamadas: la pasada completa del catálogo, la página visible y, desde la fase 2, el detalle y la restauración de datos alterados. La rúbrica pide, además, reintentos con backoff, control de concurrencia y escrituras transaccionales documentados en un ADR (ENT-10, RNF-RES-01 a RNF-RES-06).

## Decisión

Una sola pieza, `SyncScheduler` en `lib/core/sync/`, decide cuándo corre cada sincronización y cuántas llamadas puede gastar. Los servicios de cada recurso solo descargan, validan y guardan.

- **Trabajos por clave.** Cada sincronización es un `SyncJob` con una clave (`catalog`, `catalog:visible`), una prioridad, el estado que publica mientras corre y su `perform`, que devuelve `SyncOutcome.revalidated` o `SyncOutcome.upToDate`.
- **Un solo intento en curso por clave (RNF-RES-03).** Dos `run` de la misma clave comparten el mismo `Future`. Claves distintas corren a la vez y el presupuesto decide quién gasta. Cuando cambia lo que se pide, como los ids de la página visible, `runLatest` deja la petición en espera hasta que termine la que está en curso, y una más nueva reemplaza a la que esperaba.
- **Disparadores.** Además de `run` y `runLatest`, `runOnEachReconnect` registra un trabajo para cada paso a en línea, `runEveryWhileOnline` lo repite con un periodo mientras hay servicio, y `runWhenOnline` lo corre una sola vez: en ese momento si hay servicio o, si no, en la siguiente reconexión.
- **Fallos tipados.** `SyncFailure` es un tipo sellado en Dart puro con ocho casos y la propiedad `isRetryable`. La capa `data` lo traduce desde las excepciones de `graphql` con `syncFailureFrom`, así que ni `domain` ni `presentation` conocen `OperationException`. Un error inesperado que no sea un `SyncFailure`, en la práctica un fallo de la base, se registra en consola y se guarda como `QueryError`.
- **Reintentos con backoff (RNF-RES-01).** `RetryPolicy` espera 2 s × 2^(intento − 1), con ±20 % de variación y un tope de 60 s, durante 5 reintentos como máximo: 2, 4, 8, 16 y 32 s. La espera es un `Timer`; nadie espera con `await` a que pase. Cada espera se escribe en consola con un decimal, por ejemplo `[sync] catalog: reintento 3/5 en 8,4 s (ServerError(503))`. Tras el quinto reintento el recurso queda en `failed` y vuelve a intentarse en el siguiente paso a en línea o con «Reintentar». `QueryError` no se reintenta.
- **Sin red o sin servicio.** `syncSchedulerProvider` le pasa al planificador dos datos del estado de conectividad: si está en línea (`isOnline`) y si hay red (`hasNetwork`, todo menos `offline`).
  - **Servicio no disponible** (hay red, pero PokeAPI no responde). Los temporizadores periódicos se detienen, pero los reintentos y las pausas siguen su curso: un `ServerError(503)` espera 2, 4, 8, 16 y 32 s y después queda en `failed`. Los repositorios no empiezan revalidaciones nuevas de lo visible ni del detalle, porque solo lo hacen en línea.
  - **Sin red.** Un `NoConnection` no gasta reintentos: el trabajo queda `pending` y espera a la reconexión. Si la red se pierde durante una espera, el temporizador se cancela y el trabajo pasa a esperar la reconexión. Con red, un `NoConnection` se reintenta como cualquier otro fallo, porque un cambio de Wi-Fi a datos puede cortar una petición sin que cambie el estado.
  - **Al pasar a en línea.** Corren los trabajos de cada reconexión, los que esperaban una reconexión (también los que quedaron en `failed`) y los reintentos que aún esperaban su temporizador, si el presupuesto los deja salir ya.
- **Presupuesto de llamadas.** `CallBudget` cuenta las llamadas de los últimos 60 minutos con tres topes: 80 para el usuario y la salud, 70 para las restauraciones y 60 para la pasada completa. `CallBudgetLink`, delante de `HttpLink`, reserva un hueco antes de cada consulta, también la de salud. Si el tope de su prioridad está lleno, lanza `CallBudgetExhausted(until)` sin salir a la red, y el trabajo pasa a `SyncPaused(until)` hasta que se libera el hueco. Una respuesta 429 bloquea el presupuesto durante su `Retry-After`, o 10 minutos si no lo trae.
- **Estado observable.** `SyncScheduler` publica un `SyncStatus` por clave: `SyncIdle`, `SyncFullPassInProgress`, `SyncRevalidating`, `SyncRevalidated(at)`, `SyncWaitingRetry(attempt, maxAttempts, retryAt, failure)`, `SyncPaused(until)` o `SyncFailed(failure)`. El mismo estado queda en `sync_metadata`: `status`, `attempt`, `next_retry_at`, `last_error_kind` y `last_error`.
- **Escrituras transaccionales (RNF-RES-04).** Cada lote se guarda en una transacción junto con su fila de `sync_metadata`. Si un lote falla, los anteriores quedan guardados y la siguiente pasada sigue desde `next_offset`. Por eso, cuando la pasada está a medias, el número de Pokémon por defecto guardados es igual a `next_offset`.
- **Pasada interrumpida (PS-07, PA-09).** Antes de cada intento se guarda `in_progress`, y todo intento termina en `idle`, `waiting_retry`, `paused`, `pending` o `failed`, también con un error inesperado. Así, al arrancar, un `in_progress` solo puede significar que el proceso murió a mitad de una sincronización.
  - Antes de lanzar los trabajos de arranque, `InterruptedSyncReport` toma esas filas con `SyncMetadataDao.takeInterruptedSyncs()`, que en la misma transacción las deja en `pending`. Sin ese cambio, una fila `detail:25` que quedó `in_progress` se volvería a informar en cada arranque hasta que se abriera ese detalle.
  - Escribe una línea por fila: `[sync] catalog: la pasada anterior se interrumpió en 400 de 1025; se reanuda`. Las otras claves dicen que se repiten con su disparador habitual.
  - La pasada completa sigue desde `next_offset` y lo dice: `[sync] catalog: se reanuda desde 400 de 1025`. Solo descarga los lotes que faltan, 7 de 11 en este ejemplo.
- **Salud con espera creciente.** Mientras la API no responde, `ConnectivityService` repite la consulta de prueba a los 15, 30, 60 y 120 s y luego cada 5 min. Una hora sin servicio gasta 16 llamadas en lugar de 240.
- **Simulación de caída (PA-08).** En las compilaciones debug y profile, el `HttpLink` de PokeAPI usa como cliente HTTP un `SimulatedOutageHttpClient`. Mientras el interruptor de Ajustes, o `--dart-define=SIMULATE_API_OUTAGE=true`, la tiene activa, responde `503 text/plain` «Servicio no disponible (simulado)» sin salir a la red.
  - Como está debajo de `HttpLink`, el 503 recorre el mismo camino que una caída real: `LoggingLink` lo registra, `CallBudgetLink` lo cuenta, `syncFailureFrom` lo traduce a `ServerError(503)`, la consulta de salud falla y el estado pasa a `serviceUnavailable`.
  - Cada petición lee el valor del interruptor en ese momento, así que el cliente GraphQL no se reconstruye al cambiarlo. La primera petición espera a que se lea el valor guardado, para que la salud y la pasada del arranque no lleguen a PokeAPI antes de saber si la caída está simulada.
  - Al cambiar el interruptor se invalida `connectivityStatusProvider`, que repite la consulta de salud en ese momento. Sin eso, en línea nunca se volvería a comprobar.
  - En release, el interruptor no aparece y el cliente HTTP es el normal.

`SyncStatus` y `SyncFailure` sustituyen a `CatalogSyncStatus` y a sus dos motivos, descritos en el ADR-0001. El ADR-0001 se conserva tal como se escribió.

## Alternativas consideradas

- **Un bucle de reintentos dentro de cada servicio.** Es lo más directo, pero repite la lógica en cada recurso, obliga a quien llama a esperar el backoff y no da una vista común del presupuesto.
- **Reintentos con espera fija.** Es más simple, pero si la API cae, todos los recursos reintentan a la vez y al mismo ritmo, y gastan el límite justo cuando la API se está recuperando.
- **Reaccionar solo a los 429.** Ahorra el contador propio, pero el primer 429 ya penaliza y PokeAPI puede bloquear la IP. Contar antes de llamar evita llegar al límite.
- **Un paquete de reintentos o de tareas en segundo plano (`retry`, `workmanager`).** Añade dependencias y código ajeno que defender. Las tareas con la app cerrada piden configuración nativa y quedan fuera del alcance: la app solo sincroniza mientras está abierta.
- **Tratar «Servicio no disponible» como «Sin conexión».** Era el comportamiento hasta la fase 3: con la red activa y la API caída, los trabajos esperaban la reconexión y no había reintentos. Pero la API puede volver sin que cambie la red, y PA-08 pide ver las esperas de 2 a 32 s con la red activa.
- **Simular la caída con un `Link` que lance una excepción.** Es más simple, pero se salta `HttpLink`, el traductor y el presupuesto, así que la demo no probaría el mismo camino que una caída real. Cambiar el endpoint por una URL inválida tampoco sirve: falla el DNS y el fallo es `NoConnection`, no un 503.
- **Retomar la pasada interrumpida sin avisar.** Ya funcionaba, porque la pasada sigue desde `next_offset`. Pero nada lo hacía visible en la demo, y una fila podía quedarse en `in_progress` para siempre.

## Consecuencias

- Un fallo pasajero se recupera sin que el usuario haga nada. El banner puede decir en qué intento está y cuándo vuelve a intentarlo, y hasta cuándo dura una pausa por presupuesto.
- La pasada completa nunca deja sin llamadas al usuario: se detiene en 60, y lo que el usuario pide puede llegar hasta 80.
- Cada recurso nuevo (detalle, restauración, tabla de tipos) es otro `SyncJob` con su clave y su prioridad, y recibe reintentos, presupuesto y estado sin código propio.
- El presupuesto vive en memoria y se reinicia si se cierra la app, mientras que el contador real de PokeAPI sigue corriendo. El margen de 20 llamadas y el manejo de los 429 cubren ese caso.
- Los estados guardados en `sync_metadata` no se restauran al reiniciar: el planificador empieza en `SyncIdle` y los disparadores de arranque vuelven a decidir qué sincronizar. La excepción es `in_progress`, que se informa en consola y se retoma (PA-09).
- Mientras el servicio no está disponible, la verificación de huellas y la pasada de cada hora se detienen, y no empieza ninguna revalidación nueva. Una caída solo gasta los reintentos de lo que ya estaba en marcha y la salud: una pasada completa fallida gasta 6 llamadas `background` (1 intento y 5 reintentos).
- Las llamadas simuladas cuentan en el presupuesto de la app, aunque nunca llegan a PokeAPI. Al desactivar la simulación, la pasada forzada que había fallado corre una vez de verdad: en el emulador fueron 2 consultas de salud y 11 lotes. Un ensayo de PA-08 gasta así unas 13 llamadas reales y más de 20 del presupuesto de la app, y tras dos o tres ensayos en la misma hora la pasada completa, con tope 60, puede quedar en pausa.
- El backoff y el presupuesto se prueban con `fake_async` en pruebas unitarias. En el dispositivo se demuestran con la simulación de caída.
- En el emulador, el 2026-11-25, con la simulación activa el banner pasó a «Servicio no disponible» 1,5 s después de pulsar el interruptor. Forzar la sincronización hizo 1 intento y 5 reintentos y terminó en `falló tras 5 reintentos (ServerError(503))`, con los mismos conteos en la base antes y después. Al desactivarla, la salud volvió a «En línea» y la pasada que había fallado corrió una vez.
- También en el emulador, una pasada cortada con `am force-stop` en 100 de 1025 dejó `catalog` en `in_progress` con 100 Pokémon guardados. Al reabrir en modo avión se escribieron las dos líneas de consola y la fila pasó a `pending`. Al quitar el modo avión, la pasada pidió solo los lotes de 100 a 1000 (10 llamadas) y terminó en `idle`, completa, con 1025 Pokémon por defecto.
