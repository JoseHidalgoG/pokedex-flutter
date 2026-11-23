# ADR-0005: Detección de alteraciones por huella y restauración desde PokeAPI

- **Estado:** Aceptado
- **Fecha:** 2026-11-23

## Contexto

El enunciado exige que la app detecte cuándo alguien cambió los datos locales y que vuelva a los valores de PokeAPI sin tocar lo que hizo el usuario (OF-19 a OF-21, PS-12). Es uno de los requisitos indispensables (§17.3). En la demo (PA-16) se cambia el nombre de Pikachu con la extensión de Drift para DevTools. Esa escritura no pasa por la app: ninguna sincronización la registra y los `Stream`s de Drift no se enteran.

Comparar contra PokeAPI descargando el catálogo choca con el límite de 100 llamadas por hora (ADR-0004). El catálogo cuesta 11 llamadas; comprobarlo una vez por minuto costaría 660 por hora.

## Decisión

Cada Pokémon se guarda con una huella de sus datos tal como llegaron de PokeAPI. La verificación compara esa huella con los datos locales sin salir a la red, y solo se llama a PokeAPI por los Pokémon que no coinciden.

- **Huella.** `catalogFingerprintOf` calcula el SHA-256 de un texto canónico con el nombre, los tipos en orden de slot, la generación, la especie, las estadísticas ordenadas por nombre, la altura y el peso. `CatalogDao.upsertEntries` la guarda en `pokemon.remote_fingerprint` cada vez que escribe un Pokémon que llegó de PokeAPI.
- **Verificación sin llamadas (OF-19).** `CatalogRestorationService` lee los Pokémon guardados con `readEntriesWithFingerprint`, recalcula la huella de cada fila y la compara con la guardada. Usa lecturas `get()` y no `watch()`, porque la escritura del inspector no avisa a los `Stream`s. Anota la hora en `sync_metadata.last_verified_at`, en la fila `catalog:restore`. Si todo coincide, termina sin llamar a PokeAPI.
- **Cuándo se verifica.** Al iniciar la app, en cada reconexión y cada 60 s mientras hay servicio (`runEveryWhileOnline` con `fingerprintVerificationInterval`). Sin conexión el temporizador se cancela, y la reconexión lo vuelve a arrancar.
- **Restauración (OF-20).** Los ids alterados se piden con `PokemonByIds` en grupos de 100, con prioridad `restoration`, y `saveRevalidated` guarda cada grupo en una transacción. El valor de PokeAPI siempre gana: no se fusiona nada. La consola registra cada cambio, por ejemplo `[sync] restauración #25 name: pikachux → pikachu`. Si PokeAPI no devuelve un id, se deja como está y no se vuelve a pedir en esa sesión.
- **Lo del usuario queda intacto (OF-21).** La restauración solo escribe `pokemon`, `pokemon_types` y `pokemon_stats`, siempre con `ON CONFLICT DO UPDATE`. `favorites`, `trivia_results`, `trivia_answers`, `achievements` y `user_preferences` no tienen clave foránea hacia el catálogo; una prueba del DAO comprueba que quedan idénticas fila por fila.
- **Al abrir un detalle.** `PokemonDetailSyncService` compara la huella del Pokémon antes de mirar su ventana de 5 min. Si no coincide, descarga el detalle aunque sea reciente, y `saveDetail` reescribe el Pokémon y sus formas. La consola dice `[sync] detalle #25 restaurado name: pikachux → pikachu`.
- **Red de seguridad (PS-12).** La pasada completa, que corre al iniciar la app y en cada reconexión si la última tiene más de 1 h, y cada hora mientras hay servicio, calcula la huella de lo que llega y la compara con la guardada antes de escribir. Registra los ids distintos (`pasada completa: huella distinta en #25; se guarda lo de PokeAPI`) y escribe siempre lo de PokeAPI. Así se corrigen también una huella cambiada a mano y los cambios hechos en PokeAPI.
- **Fuera del banner.** El estado del catálogo que lee el banner junta solo `catalog` y `catalog:visible`. Restaurar el #25 no es «lo que se está viendo» (P-06), y una verificación por minuto haría parpadear el banner. La prueba de PA-16 es la consola, junto con el inspector.

El costo en llamadas es 0 si nada cambió, y 1 por cada 100 Pokémon alterados. El tope de la restauración es 70, así que nunca deja sin llamadas al usuario, que llega hasta 80. Un `UPDATE` sobre los 1025 Pokémon cuesta 11 llamadas.

## Alternativas consideradas

- **Descargar el catálogo en cada comprobación.** No necesita huella, pero cuesta 11 llamadas por comprobación: 660 por hora a una por minuto.
- **Triggers de SQLite que marquen las filas modificadas.** Verían también las escrituras del inspector, porque viven en la misma base. Pero marcan cualquier `UPDATE`, aunque deje el mismo valor, y se disparan con las escrituras de la propia app, que habría que distinguir. Quien edita la base puede editar también la marca o borrar el trigger. Además pedirían un esquema 3. La huella compara directamente contra lo que llegó de PokeAPI.
- **Comparar fechas (`updated_at`).** Una fecha no dice si el contenido cambió, y el inspector puede cambiar un nombre sin tocarla.
- **Guardar una copia de lo que llegó de PokeAPI y comparar campo a campo.** Duplica el catálogo. La huella ocupa 64 caracteres por fila y dice lo mismo: si algo cambió.

## Consecuencias

- PA-16 no gasta llamadas hasta que hay algo que restaurar. Tras el `UPDATE` en el inspector, la consola muestra la restauración en menos de 60 s, o al abrir el detalle de ese Pokémon.
- Las filas con huella nula, guardadas antes del esquema 2, no se verifican hasta que la pasada completa las rellena.
- Las tablas del detalle (habilidades, movimientos, evoluciones, grupos huevo, juegos) no tienen huella propia. Un cambio en ellas se corrige cuando el detalle se vuelve a descargar: al abrirlo pasados 5 min, o al deslizar hacia abajo para forzar la descarga.
- La escritura del inspector no avisa a los `Stream`s de Drift, así que la pantalla no se repinta con el valor alterado. La escritura de la restauración sí avisa. En la demo, el cambio se enseña con un `SELECT` en el inspector y la restauración en la consola.
- La URL de la imagen, `updated_at` y `base_stat_total` no entran en la huella. Un cambio en ellos no se detecta; lo corrige la siguiente pasada completa, que los reescribe: con servicio, como mucho una hora después.
- Si alguien cambia a la vez un dato y su huella para que coincidan, la verificación no lo ve. Lo corrige la siguiente pasada completa: con servicio, como mucho una hora después.
