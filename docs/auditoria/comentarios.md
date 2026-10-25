


# Auditoría priorizada: feature de comentarios

Alcance: crear, editar, borrar y listar comentarios, en sus tres capas (API, tabla `comentarios`, web).
Nada más. Todo lo de abajo está **leído en el código, no ejecutado**.

Abreviaturas de ruta: `R` = `backend/start/routes.ts` · `Com` = `frontend/src/componentes/Comentarios.jsx` ·
`Det` = `frontend/src/componentes/DetallePost.jsx` · `mig` = `backend/database/migrations/1769000000005_create_comentarios_table.ts` ·
`seed` = `backend/database/seeders/blog_seeder.ts`.

## Cómo está ordenado

1. **Precedencia primero.** Nivel 0 = nada lo precede. Nivel N = depende de algo de nivel N-1. Lo que abarata o desbloquea a otro hallazgo va antes.
2. **Dentro de cada nivel: daño ÷ sitios**, de mayor a menor. Empate: menos sitios, luego número.
3. **Daño** es un juicio, no una medición. Escala: 5 filtración a terceros hoy · 4 borrado o acceso indebido · 3 dato incorrecto o pérdida irrecuperable · 2 degradación visible · 1 sin efecto visible hoy.
4. **Sitios** = ubicaciones distintas (línea o bloque contiguo) que hay que tocar, contadas con `grep -n`. Si no se pueden contar queda en blanco y la fila va la última de su nivel.
5. **Daño alto con precedencia baja → dos filas**: contención (corta el daño hoy) y arreglo de fondo (espera su turno). Solo el hallazgo de «email como credencial» cumple (filas 3 y 8).
6. **Las propuestas que nadie ha medido van fuera de la tabla**, con lo que habría que medir.

Dependencias: 1 → 8 · 2 → 8 · 4 → 7 · 5 → 6 · 7 abarata 9 y 10.

| # | Nivel | Daño | Sitios | Daño ÷ sitios |
|---|---|---|---|---|
| 1 | 0 | 5 | 2 | 2.50 |
| 2 | 0 | 4 | 2 | 2.00 |
| 3 | 0 | 4 | 2 | 2.00 |
| 4 | 0 | 2 | 1 | 2.00 |
| 5 | 0 | 3 | 7 | 0.43 |
| 6 | 1 | 3 | 3 | 1.00 |
| 7 | 1 | 1 | 4 | 0.25 |
| 8 | 1 | 4 | | sin calcular |
| 9 | 2 | 2 | 2 | 1.00 |
| 10 | 2 | 2 | 5 | 0.40 |
| 11 | 3 | 3 | 1 | 3.00 |
| 12 | 3 | 3 | 1 | 3.00 |
| 13 | 3 | 2 | 1 | 2.00 |
| 14 | 3 | 2 | 2 | 1.00 |
| 15 | 3 | 1 | 2 | 0.50 |
| 16 | 3 | 1 | 3 | 0.33 |
| 17 | 3 | 2 | 7 | 0.29 |

## Hallazgos

### Nivel 0 — nada los precede

| # | Qué es | Dónde está (línea que lo demuestra) | Qué se rompe, y quién lo nota | Cuántos sitios | ¿Se deshace con un revert? | ¿Bloquea o desbloquea? |
|---|---|---|---|---|---|---|
| 1 | El detalle del post devuelve los comentarios con `select *`, incluido el correo de quien comenta. | `R:153` `select * from comentarios where post_id = ? and estado = 'aprobado'…`; `R:171` `comentarios: comentarios`; `mig:16` la columna `autor_email` existe. | Cualquier visitante que abra un post lee el correo de cada comentarista (rompe la regla 6). Lo notan los comentaristas, cuando les llegue spam. | 2 (`R:153`, `R:171`) | Sí el código. Lo ya servido no se retira. | Desbloquea el 8. |
| 2 | La clave de moderación está escrita en el código. | `R:25` `const SECRETO_SESION = 'dev-secret-cambiar'`; `R:351` `esModerador = clave === SECRETO_SESION`. | Quien tenga acceso al repo borra cualquier comentario con la cabecera `x-clave-moderacion`. Lo notaría el autor al que le desaparece el comentario. | 2 (`R:25`, `R:351`) | No: el secreto ya está en el historial de git (`e0e0943`); revertir no lo retira, hay que rotarlo. | Desbloquea el 8. |
| 3 | **Contención de «email como credencial»:** hoy basta conocer el correo de alguien para borrar su comentario o editarlo. | `R:352-353` `esAutor = …autor_email…toLowerCase().trim() === …email…`; `R:379` `comentario.autor_email !== email`. | Un visitante que lea un correo (fila 1) borra ese comentario; lo nota el autor. Cortarlo exige **decisión explícita** porque cambia el contrato (CLAUDE.md: arreglar un bug es otra tarea). | 2 (`R:352-353`, `R:379`) | Sí. | A ninguno; la fila 8 la sustituye. |
| 4 | La feature tiene un solo test: el camino feliz de crear. Nada de editar, borrar ni listar, ni aserciones negativas. | `comentarios.spec.ts:15` único `test(`; el archivo entero son 44 líneas. | Nadie todavía; lo nota el siguiente que toque comentarios, que lo hace a ciegas. | 1 archivo | Sí, solo añade tests. | Desbloquea el 7 (CLAUDE.md exige caracterización antes de refactorizar). |
| 5 | `estado` es texto libre, sin CHECK ni enum. | `mig:18` `table.string('estado').notNullable().defaultTo('pendiente')`; valores sucios en `seed:510` (`'Aprobado'`), `seed:522` (`'ok'`), `seed:575` (`'Aprobado'`). | Los comentarios 3, 4 y 9 del seed conviven con valores que cada consulta interpreta distinto (fila 6). Lo nota el moderador y el lector. | 7 (`mig:18`, `seed:510`, `seed:522`, `seed:575`, `R:75`, `R:153`, `R:223`) | No, si se normalizan los valores: la migración tiene `down()` pero `'Aprobado'` y `'ok'` ya no se distinguen del original. | Desbloquea el 6. |

### Nivel 1

| # | Qué es | Dónde está (línea que lo demuestra) | Qué se rompe, y quién lo nota | Cuántos sitios | ¿Se deshace con un revert? | ¿Bloquea o desbloquea? |
|---|---|---|---|---|---|---|
| 6 | El recuento de comentarios y el detalle usan criterios distintos de «aprobado» (regla 5). | `R:75` y `R:223` cuentan `estado <> 'pendiente'`; `R:153` muestra `estado = 'aprobado'`. | Post 1 del seed: el listado cuenta 4 (ids 1, 2, 3, 4) y el detalle muestra 2 (ids 1, 2). Post 6: cuenta 1, muestra 0. Lo nota el lector. | 3 (`R:75`, `R:223`, `R:153`) | Sí. | Bloqueado por el 5. |
| 7 | Toda la lógica de comentarios vive en la ruta: SQL, validación, autorización y respuesta. Sin validador, servicio, repositorio ni transformer. | `R:295` POST, `R:339` DELETE, `R:366` PATCH (cada uno con `db.rawQuery` e `if` de validación); `R:153` en el detalle. | Nadie todavía; incumple CLAUDE.md y encarece cada arreglo de las filas 9 y 10. | 4 (`R:295`, `R:339`, `R:366`, `R:153`) | Sí (`git revert` del refactor). | Bloqueado por el 4. Abarata el 9 y el 10. |
| 8 | **Arreglo de fondo de «email como credencial»:** autoría comprobable de verdad, no por correo. | Mismas líneas que la fila 3: `R:352-353`, `R:379`. | Mismo daño que la fila 3 mientras no exista. El diseño de la autoría no está decidido. | | | Bloqueado por el 1 y el 2. Sustituye a la 3. |

### Nivel 2 — más baratos después del 7

| # | Qué es | Dónde está (línea que lo demuestra) | Qué se rompe, y quién lo nota | Cuántos sitios | ¿Se deshace con un revert? | ¿Bloquea o desbloquea? |
|---|---|---|---|---|---|---|
| 9 | DELETE y PATCH aplican reglas de autoría distintas. | `R:352-353` compara sin mayúsculas y admite la clave de moderación; `R:379` compara exacto, no admite moderador y exige `pendiente`. | Un autor que escribe su correo con otra capitalización borra pero no edita; el moderador borra pero no edita. Lo nota el autor al editar. | 2 (`R:352-353`, `R:379`) | Sí, pero cambia el contrato: caracterizar antes. | Abaratado por el 7. |
| 10 | Los errores de POST tienen cuatro formas y tres códigos. | `R:311` 400 `{error}`; `R:314` 422 `{message}`; `R:317` 400 `{errores:[…]}`; `R:320` 200 `{ok:false, motivo}`; `Com:44` lee `d.error \|\| d.message \|\| d.motivo`. | Con un correo sin `@`, la web muestra «No se ha podido enviar» (no lee `errores`). Un cuerpo corto responde 200. Lo nota el lector. | 5 (`R:311`, `R:314`, `R:317`, `R:320`, `Com:44`) | Sí, pero cambia el contrato: caracterizar antes. | Abaratado por el 7. |

### Nivel 3 — independientes

| # | Qué es | Dónde está (línea que lo demuestra) | Qué se rompe, y quién lo nota | Cuántos sitios | ¿Se deshace con un revert? | ¿Bloquea o desbloquea? |
|---|---|---|---|---|---|---|
| 11 | POST devuelve el último comentario de la tabla, no el que acaba de crear. | `R:329-331` `select * from comentarios order by id desc limit 1`. | Con dos envíos simultáneos, uno recibe el comentario (y el correo) del otro. No probado en concurrencia; lo notaría el lector. | 1 (`R:329-331`) | Sí. | A ninguno. |
| 12 | DELETE es físico y no trata las respuestas hijas. | `R:359` `delete from comentarios where id = ?`; `Com:50` y `Com:64` solo pintan respuestas bajo un padre existente. | Al borrar el comentario 1 del seed, el 2 (su respuesta) queda huérfano e invisible. Lo nota quien respondió. | 1 (`R:359`) | No: el código sí, pero los comentarios ya borrados no vuelven. | A ninguno. |
| 13 | PATCH acepta cuerpos de un carácter; POST exige 5. | `R:319` `String(cuerpo).length < 5`; `R:384` `if (!cuerpo)`. | Se puede editar a «a», saltando la regla de creación. Nadie todavía. | 1 (`R:384`) | Sí. | A ninguno. |
| 14 | Carga fallida silenciosa en la web. | `Com:25` `.catch(() => {})`; `Det:42` `.catch(() => setCargando(false))`. | Si la API cae, el lector ve «0 comentarios» sin error. | 2 (`Com:25`, `Det:42`) | Sí. | A ninguno. |
| 15 | La web solo pinta un nivel de respuestas. | `Com:50` `raices = …filter((c) => !c.padre_id)`; `Com:64` `.filter((r) => r.padre_id === c.id)`. | Una respuesta a una respuesta no se muestra. Nadie todavía: la web no envía `padre_id` y el seed no tiene ninguna. | 2 (`Com:50`, `Com:64`) | Sí. | A ninguno. |
| 16 | `padre_id` no se valida: ni que exista ni que sea del mismo post. | `R:308` `request.input('padre_id', null)`; `R:325` lo inserta tal cual; `mig:20` sin clave foránea. | Nadie todavía: solo por API directa se cuelga una respuesta de un comentario ajeno o inexistente. | 3 (`R:308`, `R:325`, `mig:20`) | Sí el código. Con clave foránea en migración: en blanco, no hay diseño. | A ninguno. |
| 17 | Dos recuentos de comentarios en la web que divergen entre sí. | `Det:30` y `Det:38` (cabecera) frente a `Com:11`, `Com:23`, `Com:39` `setTotal(total + 1)`, `Com:54` (pie). | Al comentar, el pie sube en 1 aunque el comentario esté pendiente y no se vea; la cabecera (`Det:71`) no cambia. Lo nota el lector. | 7 (`Det:30`, `Det:38`, `Det:71`, `Com:11`, `Com:23`, `Com:39`, `Com:54`) | Sí. | A ninguno. |

## Fuera de la tabla: sin medir

| Qué se sospecha | Dónde | Qué habría que medir |
|---|---|---|
| No hay forma de aprobar un comentario desde la API: el único insert es `'pendiente'` y el PATCH solo toca `cuerpo`. | `R:325`, `R:388` | Si existe un panel externo (`seed:509` habla de un «panel viejo de moderación») y cuántos comentarios pendientes hay en la base real. |
| Sin longitud máxima ni límite de envíos en POST. | `R:310-319` | Tamaños reales de `cuerpo`, peticiones por IP y proporción de spam (el comentario 7 del seed es spam). |
| El post entero se pide dos veces solo para sacar los comentarios. | `Det:34`, `Com:19` | Latencia y bytes de la segunda petición. |
| `post_id` sin índice ni clave foránea. | `mig:14` | Filas de la tabla, `EXPLAIN` de `R:153` y cuántos comentarios tienen un `post_id` sin post. |


## Mis 3 lineas 

1- El reporte genero 17 hayasgos. Solo pude comprobar 3
2- De las 4 que vi me parecieron bien las prioridades.
3- El hallasgo 3. Habla de que un vistante con el correo puede borrar un comentario de otro
