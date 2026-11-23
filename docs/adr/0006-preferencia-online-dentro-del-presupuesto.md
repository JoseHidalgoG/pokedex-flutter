# ADR-0006: Preferencia online dentro del presupuesto: catálogo ligero completo, detalle bajo demanda y revalidación de lo visible

- **Estado:** Aceptado
- **Fecha:** 2026-11-21
- **Actualizado:** 2026-11-23, con el detalle bajo demanda, la tabla de tipos y los movimientos

## Contexto

El enunciado pide preferir los datos de PokeAPI cuando hay servicio (P-02, OF-01, OF-02). El ADR-0001 exige, a la vez, que la interfaz lea solo de SQLite. En el avance, un catálogo completo con menos de 24 horas nunca volvía a pedirse: con servicio, la pantalla podía mostrar datos de ayer sin decirlo.

Pedir todo a PokeAPI cada vez no es posible. El límite es de 100 llamadas por hora (ADR-0004). El catálogo de 1025 Pokémon por defecto cuesta 11 llamadas en lotes de 100, y el detalle de cada Pokémon cuesta una llamada más, así que descargar todos los detalles pasaría de 1000 llamadas. Además, el indicador no puede presentar como fresco algo que no lo es (P-06, IND-04).

## Decisión

Cada recurso se pide a PokeAPI con una ventana de vigencia, y la pantalla nunca espera la respuesta: se pinta con lo que hay en SQLite y se actualiza cuando la escritura llega a la base.

| Recurso | Qué trae | Cuándo se pide | Llamadas | Vigencia |
| --- | --- | --- | --- | --- |
| `catalog`, pasada completa | Campos ligeros de los Pokémon por defecto: id, nombre, tipos, generación, especie, estadísticas, altura, peso e imagen | Primera ejecución, catálogo incompleto, o al iniciar o reconectar si la última pasada tiene más de 1 h | 11 | 1 h (`catalogFullPassFreshness`) |
| `catalog:visible` | Los mismos campos, solo de los ids en pantalla | Al mostrarse con servicio, si alguno se guardó hace más de 15 min | 1 por pantalla | 15 min (`visibleFreshnessWindow`) |
| `detail:{id}` | Especie, grupos huevo, habilidades, movimientos de un version group, cadena de evolución, formas con sus campos del catálogo y juegos | En cada apertura con servicio, salvo si se descargó hace menos de 5 min; siempre si falta o su huella no coincide | 1 | 5 min (`detailFreshnessWindow`) |
| `type_efficacy` | La tabla de tipos completa: 18 × 18 = 324 factores de daño | Al iniciar y al reconectar si tiene más de 24 h; al abrir un detalle si está vacía, con prioridad de usuario | 1 | 24 h (`typeEfficacyFreshness`) |

- **Catálogo ligero completo.** La pasada completa trae todo lo que necesitan sin red la lista, la búsqueda, los filtros y el orden.
- **Revalidación de lo visible.** `catalogPageProvider` llama a `RevalidatePokemon` con los ids de la página la primera vez que trae Pokémon y cada vez que vuelve a mostrarse. Si alguno tiene `pokemon.updated_at` de hace más de 15 min, una sola consulta `PokemonByIds` con prioridad de usuario trae los vencidos y `saveRevalidated` los guarda en una transacción. Sin conexión no se llama: el repositorio deja la petición registrada y `SyncScheduler` la repite en la siguiente reconexión. `force` (deslizar para actualizar) se salta la ventana. Los resultados de búsqueda y los favoritos usarán el mismo caso de uso.
- **Detalle bajo demanda.** El detalle de un Pokémon se descarga al abrirlo, nunca en bloque, en una sola consulta `PokemonDetail` con prioridad de usuario y un tiempo límite de 15 s. `pokemonDetailProvider` pide la revalidación la primera vez que el detalle emite y cada vez que la pantalla vuelve a mostrarse, y deja de pedirla al cerrarse (`StopRevalidatingPokemonDetail`). Sin conexión, la petición queda registrada para la siguiente reconexión mientras el detalle siga abierto. Deslizar hacia abajo fuerza la descarga. Elegir una forma en el selector descarga el detalle de esa forma, también bajo demanda.
- **Tabla de tipos.** Los matchups se calculan en el dominio con la tabla guardada, así que no gastan llamadas al abrir un detalle. Solo se guarda una tabla completa: si PokeAPI devuelve menos de 18 tipos o le falta alguna pareja, se descarta como `InvalidResponse` y se conserva la anterior.
- **Movimientos de un solo version group.** El detalle guarda los movimientos por nivel, MT, tutor y huevo de un solo version group: el más reciente, según `versiongroup.order`, que tenga movimientos por nivel. Los juegos Legends (`legends-arceus`, `legends-za` y su DLC `mega-dimension`) se saltan salvo que sean los únicos con movimientos por nivel. La sección siguiente explica por qué.
- **Origen honesto.** `SyncRevalidated(at)` solo se publica después de una descarga real en esta sesión. El estado del catálogo junta `catalog` y `catalog:visible` con `mostRelevantSyncStatus`, así que el banner solo puede decir «Datos de PokeAPI» cuando de verdad llegaron de PokeAPI. En el detalle, una línea bajo el nombre dice «Actualizado desde PokeAPI hace 3 min» solo si `detail:{id}` se descargó en esta sesión (`SyncScheduler.lastRevalidationOf`). Si no, dice «Datos locales del 10/11 · 09:15», o «Sin detalle guardado · se descargará con conexión».
- **Dentro del presupuesto.** La preferencia online gasta del tope del usuario (80). Una hora de uso normal cabe con margen: una pasada completa (11), 20 detalles (20), 10 pantallas revalidadas (10) y la salud (hasta 15) suman 56. La tabla de tipos añade 1 llamada al día, y la verificación de huellas (ADR-0005) no gasta ninguna si nada cambió. Si el presupuesto se agota, la preferencia online se pausa y la pantalla sigue con datos locales.

## Movimientos: por qué un solo version group

Un Pokémon aprende movimientos distintos en cada juego. Pikachu tiene 1124 filas de movimientos por nivel, MT, tutor y huevo repartidas entre todos los version groups. Guardarlas todas con un selector de juego pediría una columna de orden en `pokemon_moves` y un esquema 3, y el esquema 2 es el único cambio de esquema previsto. Por eso el detalle guarda un solo version group, sin selector.

La regla inicial era «el version group más reciente que tenga movimientos por nivel». Se comprobó contra PokeAPI el 2026-11-21 (6 llamadas desde la laptop). Pokémon con movimientos de cada método en los version groups desde Sword/Shield:

| `order` | Version group | Por nivel | MT | Tutor | Huevo |
| --- | --- | --- | --- | --- | --- |
| 22 | `sword-shield` | 750 | 747 | 637 | 276 |
| 23–24 | `the-isle-of-armor`, `the-crown-tundra` | 0 | 0 | 0 | 0 |
| 25 | `brilliant-diamond-shining-pearl` | 508 | 495 | 33 | 201 |
| 26 | `legends-arceus` | 261 | 0 | 254 | 0 |
| 27 | `scarlet-violet` | 870 | 865 | 0 | 305 |
| 28–29 | `the-teal-mask`, `the-indigo-disk` | 0 | 0 | 0 | 0 |
| 30 | `legends-za` | 512 | 512 | 0 | 0 |
| 31 | `mega-dimension` | 0 | 0 | 0 | 0 |
| 32 | `champions` | 0 | 0 | 0 | 0 |

`champions` solo tiene movimientos del método `train`, que no se guarda.

- **Sin la excepción, la regla elegía Legends Z-A** para Pikachu, Eevee, Bulbasaur, Meltan y Raichu de Alola: 13 movimientos por nivel en el caso de Pikachu, sin huevo ni tutor. Los juegos Legends no tienen crianza y sus listas de movimientos son recortadas.
- **Con la excepción**, Pikachu y Eevee quedan en `scarlet-violet`, y Caterpie, que no está en Scarlet/Violet, en `brilliant-diamond-shining-pearl`.
- **Los DLC no tienen grupo propio.** Los movimientos de Dipplin, Ogerpon y Terapagos, que llegaron con los DLC de Scarlet/Violet, están guardados bajo `scarlet-violet`.
- **Todos los Pokémon por defecto tienen movimientos por nivel en algún grupo.** 34 formas no por defecto, como `pikachu-gmax` (#10199), no tienen ninguno, y la pestaña muestra «Sin movimientos registrados».
- **Scarlet/Violet no tiene movimientos de tutor**, así que el chip de tutor queda en 0 y desactivado para cualquier Pokémon de ese grupo.

## Alternativas consideradas

- **Ir primero a la red en cada lectura y usar la base como respaldo.** Es el patrón «network-first». Hace que la interfaz dependa de la red, retrasa la primera pintura y gasta una llamada por pantalla, con o sin cambios. Rompe el ADR-0001.
- **Descargar el detalle de todos los Pokémon en la primera ejecución.** Daría todo sin conexión, pero pasa de 1000 llamadas: más de diez horas de presupuesto.
- **Solo la pasada completa por tiempo, como en el avance.** Es barata, pero con servicio la pantalla puede mostrar datos de horas atrás. No es preferencia online.
- **Revalidar la página visible siempre, sin ventana.** Pasar las 21 páginas del catálogo costaría 21 llamadas en un minuto. La ventana de 15 min evita repetir lo que acaba de llegar.
- **Descargar el detalle en cada apertura, sin ventana.** Abrir y cerrar el mismo detalle varias veces gastaría una llamada cada vez sin traer nada nuevo. La ventana de 5 min lo evita, y la huella obliga a descargar dentro de la ventana si el dato local cambió.
- **Guardar todos los version groups con un selector de juego.** Muestra cada juego, pero guarda unas 1100 filas por Pokémon y pide un esquema 3 con el orden de los grupos.
- **El version group más reciente sin excepción.** Es la regla más simple, pero hoy elige Legends Z-A para la mayoría, sin movimientos por huevo ni de tutor.

## Consecuencias

- Con servicio, lo que el usuario ve tiene como mucho 15 minutos de diferencia con PokeAPI. El resto del catálogo se renueva al iniciar la app y en cada reconexión si la última pasada tiene más de 1 h.
- La primera pintura nunca espera a la red (OF-03) y los datos nuevos llegan por el `Stream` de Drift (OF-16).
- Al abrir la app con datos viejos se gasta una llamada más: la página visible se revalida con prioridad de usuario mientras corre la pasada completa. En el emulador, un arranque con datos de dos días hizo 2 consultas de salud, 11 lotes y 1 consulta de la página visible.
- Al volver a una página que sigue dentro de su ventana no se llama, y el banner conserva la hora de la última revalidación real, aunque fuera de otra página.
- Las imágenes vienen de `raw.githubusercontent.com`, no de GraphQL, y no gastan el límite.
- Un detalle abierto por primera vez se pinta al instante con los campos del catálogo y se completa cuando llega su descarga. En el emulador, el 2026-11-23, abrir 3 detalles nuevos hizo 3 consultas `PokemonDetail` (la de Bulbasaur, en 937 ms), y volver a abrir uno antes de 5 min no hizo ninguna. En modo avión, tras reiniciar la app, un detalle ya visto se pintaba completo con la hora de su última descarga, y uno nunca abierto mostraba los campos del catálogo y avisaba de que no tenía detalle guardado.
- Un detalle nunca abierto no tiene habilidades, movimientos ni evoluciones sin conexión. Las estadísticas, la altura, el peso y los matchups sí están, porque vienen del catálogo y de la tabla de tipos.
- La pestaña de movimientos muestra un solo juego. Quien busque los movimientos de otro juego no los encuentra en la app.
