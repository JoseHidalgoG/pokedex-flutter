# ADR-0006: Preferencia online dentro del presupuesto: catálogo ligero completo, detalle bajo demanda y revalidación de lo visible

- **Estado:** Aceptado
- **Fecha:** 2026-11-21

## Contexto

El enunciado pide preferir los datos de PokeAPI cuando hay servicio (P-02, OF-01, OF-02). El ADR-0001 exige, a la vez, que la interfaz lea solo de SQLite. En el avance, un catálogo completo con menos de 24 horas nunca volvía a pedirse: con servicio, la pantalla podía mostrar datos de ayer sin decirlo.

Pedir todo a PokeAPI cada vez no es posible. El límite es de 100 llamadas por hora (ADR-0004). El catálogo de 1025 Pokémon por defecto cuesta 11 llamadas en lotes de 100, y el detalle de cada Pokémon cuesta una llamada más, así que descargar todos los detalles pasaría de 1000 llamadas. Además, el indicador no puede presentar como fresco algo que no lo es (P-06, IND-04).

## Decisión

Cada recurso se pide a PokeAPI con una ventana de vigencia, y la pantalla nunca espera la respuesta: se pinta con lo que hay en SQLite y se actualiza cuando la escritura llega a la base.

| Recurso | Qué trae | Cuándo se pide | Llamadas | Vigencia |
| --- | --- | --- | --- | --- |
| `catalog`, pasada completa | Campos ligeros de los Pokémon por defecto: id, nombre, tipos, generación, especie, estadísticas, altura, peso e imagen | Primera ejecución, catálogo incompleto, o al iniciar o reconectar si la última pasada tiene más de 1 h | 11 | 1 h (`catalogFullPassFreshness`) |
| `catalog:visible` | Los mismos campos, solo de los ids en pantalla | Al mostrarse con servicio, si alguno se guardó hace más de 15 min | 1 por pantalla | 15 min (`visibleFreshnessWindow`) |
| `detail:{id}` (fase 2) | Habilidades, movimientos, evoluciones, especie, formas y juegos | En cada apertura con servicio, salvo si se revalidó hace menos de 5 min | 1 | 5 min |

- **Catálogo ligero completo.** La pasada completa trae todo lo que necesitan sin red la lista, la búsqueda, los filtros y el orden.
- **Revalidación de lo visible.** `catalogPageProvider` llama a `RevalidatePokemon` con los ids de la página la primera vez que trae Pokémon y cada vez que vuelve a mostrarse. Si alguno tiene `pokemon.updated_at` de hace más de 15 min, una sola consulta `PokemonByIds` con prioridad de usuario trae los vencidos y `saveRevalidated` los guarda en una transacción. Sin conexión no se llama: el repositorio deja la petición registrada y `SyncScheduler` la repite en la siguiente reconexión. `force` (deslizar para actualizar) se salta la ventana. Los resultados de búsqueda y los favoritos usarán el mismo caso de uso.
- **Detalle bajo demanda (fase 2).** El detalle de un Pokémon se descarga al abrirlo, nunca en bloque.
- **Origen honesto.** `SyncRevalidated(at)` solo se publica después de una descarga real en esta sesión. El estado del catálogo junta `catalog` y `catalog:visible` con `mostRelevantSyncStatus`, así que el banner solo puede decir «Datos de PokeAPI» cuando de verdad llegaron de PokeAPI.
- **Dentro del presupuesto.** La preferencia online gasta del tope del usuario (80). Una hora de uso normal cabe con margen: una pasada completa (11), 20 detalles (20), 10 pantallas revalidadas (10) y la salud (hasta 15) suman 56. Si el presupuesto se agota, la preferencia online se pausa y la pantalla sigue con datos locales.

## Alternativas consideradas

- **Ir primero a la red en cada lectura y usar la base como respaldo.** Es el patrón «network-first». Hace que la interfaz dependa de la red, retrasa la primera pintura y gasta una llamada por pantalla, con o sin cambios. Rompe el ADR-0001.
- **Descargar el detalle de todos los Pokémon en la primera ejecución.** Daría todo sin conexión, pero pasa de 1000 llamadas: más de diez horas de presupuesto.
- **Solo la pasada completa por tiempo, como en el avance.** Es barata, pero con servicio la pantalla puede mostrar datos de horas atrás. No es preferencia online.
- **Revalidar la página visible siempre, sin ventana.** Pasar las 21 páginas del catálogo costaría 21 llamadas en un minuto. La ventana de 15 min evita repetir lo que acaba de llegar.

## Consecuencias

- Con servicio, lo que el usuario ve tiene como mucho 15 minutos de diferencia con PokeAPI; el resto del catálogo, como mucho 1 hora.
- La primera pintura nunca espera a la red (OF-03) y los datos nuevos llegan por el `Stream` de Drift (OF-16).
- Al abrir la app con datos viejos se gasta una llamada más: la página visible se revalida con prioridad de usuario mientras corre la pasada completa. En el emulador, un arranque con datos de dos días hizo 2 consultas de salud, 11 lotes y 1 consulta de la página visible.
- Al volver a una página que sigue dentro de su ventana no se llama, y el banner conserva la hora de la última revalidación real, aunque fuera de otra página.
- Las imágenes vienen de `raw.githubusercontent.com`, no de GraphQL, y no gastan el límite.
- El detalle bajo demanda y su ventana de 5 min se implementan en la fase 2, con la clave `detail:{id}`.
