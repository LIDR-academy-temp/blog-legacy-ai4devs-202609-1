# Auditoría de la feature «comentarios»

**Alcance:** crear, editar, borrar y listar comentarios en sus tres capas:

- **API:** `backend/start/routes.ts`: `POST /posts/:slug/comentarios`, `PATCH /comentarios/:id`, `DELETE /comentarios/:id`, el bloque de comentarios de `GET /posts/:slug` y el recuento `num_comentarios` de `GET /posts` y de `/relacionados`.
- **Base de datos:** la migración `1769000000005_create_comentarios_table.ts` y las filas `COMENTARIOS` de la semilla.
- **Web:** `frontend/src/componentes/Comentarios.jsx`, más el recuento de comentarios de `DetallePost.jsx`.

Nada más se ha revisado. Las reglas de negocio con las que se contrasta son las del `README.md` (§ Reglas de negocio), citadas como **R1…R6**.

**Cómo se comprobó:** todo se ha leído en el archivo y la línea que se citan. Las filas marcadas con ▶ además se han ejecutado con `curl` contra la API en marcha (`localhost:3401`, semilla limpia), usando solo peticiones que no escriben en la base. Lo que habría borrado o insertado filas **no** se ha ejecutado, y la fila lo dice.

---

## Orden

1. **Precedencia (orden topológico).** Si arreglar A abarata arreglar B, A va antes. Los niveles salen del grafo de abajo, no de una opinión.
2. **Dentro de cada nivel: daño ÷ radio.** Daño: 3 = alto, 2 = medio, 1 = bajo, 0 = nadie todavía. Radio: los sitios que hay que tocar (columna 4). Si empatan, va antes el de menor radio.
3. **Partido en dos:** **C2 (borrar con el correo de otro)** tiene a la vez el daño más alto y la precedencia más baja (su arreglo de fondo, cuentas reales, necesita las capas y una regla de autoría única). Por eso va en dos filas: **C2a**, la contención de hoy, en el nivel 0, y **C2b**, el arreglo de fondo, en el nivel 3.
4. Las contenciones del nivel 0 llevan su propio test (TDD) y no esperan a la caracterización completa (C5).

```
N0  C1  C2a  C3  C4  C5
         │        │   └──► C6, C8 (toda la suite)
         │        └──► C7
N1  C6 ──────────► C9
    C7
    C8 ──► C10 C11 C12 C13 C14 C15 C16 C17 C18 C19 C20 C21
N2  C9 C10 C11 C12 C13 C14 C15 C16 C17 C18 C19 C20 C21
                    C14 (padre) ─┐   C11 (huérfanas) ─┐
                    C20 (regla) ─┼──► C2b             ├──► C22
N3  C2b  C22                     └────────────────────┘
```

## Hallazgos

| Qué es | Dónde está (la línea que lo demuestra) | Qué se rompe, y quién lo nota | Sitios a tocar | ¿Se deshace con un revert? | ¿Bloquea o desbloquea a otro? |
|---|---|---|---|---|---|
| **C1** · N0 · 3/1. `GET /posts/:slug` devuelve el correo de cada comentarista aprobado, porque hace `select *` y entrega la fila cruda (incumple R6). ▶ | `backend/start/routes.ts:153` `"select * from comentarios where post_id = ? and estado = 'aprobado' …"` y `:171` `comentarios: comentarios`. ▶ La respuesta del post 1 trae `"autor_email":"ana.cortes@ejemplo.es"`. | Cualquier visitante o *scraper* lee el correo de todas las personas que comentan. Además, ese correo es la «llave» de C2a. Ningún comentarista lo ha visto todavía: la web no pinta el correo, pero va en el JSON. | 1 (la lista de columnas de `:153`). | Sí: es una lista de columnas. Lo que ya se ha servido no se recupera. | A ninguno que lo bloquee. Corta con **C2a** la misma cadena (leer correo → borrar) por el otro extremo. **C12** es su arreglo de fondo. |
| **C2a** · N0 · 3/1 · *contención*. `DELETE /comentarios/:id` deja borrar a quien envíe el correo del autor en el cuerpo de la petición. | `backend/start/routes.ts:350-353` `const email = request.input('autor_email', '')` … `const esAutor = String(comentario.autor_email)… === String(email)…`. ▶ Con un correo ajeno devuelve `403`. Con el correcto **no se ha ejecutado** porque borra. | Cualquiera que lea un correo en C1 (o en `post.autor_email` de la misma respuesta ▶ `marta.ruiz@corriente.es`, que coincide con el del comentario 2) borra ese comentario para siempre con un `curl`. Lo nota la persona que comentó, cuando su comentario desaparece. | 1 (quitar la vía `esAutor` de `:352-355` y dejar solo la clave de moderación). La web no ofrece borrar (en `Comentarios.jsx` no hay ningún `DELETE`), así que no pierde nada. | Sí, el código. Los comentarios que se borren mientras tanto no: es un `delete` físico (`:359`). | A ninguno que lo bloquee, aunque sin **C3** sigue abierta la vía de la clave pública. **C2b** es su arreglo de fondo. |
| **C3** · N0 · 3/4. La clave de moderación está escrita en el código fuente, que es un repositorio público con forks. | `backend/start/routes.ts:25` `const SECRETO_SESION = 'dev-secret-cambiar'` y `:351` `const esModerador = clave === SECRETO_SESION`. | Cualquiera que haya visto el repo borra cualquier comentario con la cabecera `x-clave-moderacion: dev-secret-cambiar`. Lo nota la persona que comentó y quien modera. Nadie todavía, que conste. | 4: `routes.ts:25`, `routes.ts:351`, `start/env.ts` (declarar la variable) y `.env.example`. Además, rotar el valor fuera del código. | **No.** El valor ya está en el historial de git y en cada fork. Un revert lo vuelve a poner en vigor, y quitarlo del código no lo despublica: hay que rotarlo. | Desbloquea **C10** (el endpoint de aprobar necesita una credencial que no sea pública). |
| **C4** · N0 · 1/2. La página del post pide el detalle dos veces y guarda dos recuentos de comentarios que no se hablan. | `frontend/src/componentes/DetallePost.jsx:34-38` (`fetch` + `setNumComentarios`) y `frontend/src/componentes/Comentarios.jsx:19-23` (`fetch` del mismo endpoint + `setTotal`). | Al enviar un comentario, la cabecera del artículo (`DetallePost.jsx:71`) y la sección (`Comentarios.jsx:54`) muestran números distintos. Lo ve quien acaba de comentar. Además, cada visita hace una petición de más (eso no lo nota nadie). | 2 (los dos componentes: subir el dato a `DetallePost` y pasárselo a `Comentarios` por props). | Sí. | Desbloquea **C7**: con una sola fuente, el `+1` local desaparece. |
| **C5** · N0 · 0/6. La feature tiene un solo test, y ese test afirma un estado y un campo. | `backend/tests/functional/comentarios.spec.ts:41-42` `respuesta.assertStatus(201)` / `assert.equal(…autor_nombre, 'Lucía Ferrer')`. | Nadie todavía. Lo que se rompe es la red: cualquier cambio de C6–C22 puede alterar el contrato sin que nada falle. | 6 endpoints que caracterizar: POST, PATCH, DELETE, el bloque de comentarios de `GET /posts/:slug` y `num_comentarios` en `GET /posts` y en `/relacionados`. | Sí: solo añade tests. | Desbloquea **C6** y **C8**, y con ellos todo el nivel 2. |
| **C6** · N1 · 2/4. `comentarios.estado` es texto libre, y hay 3 comentarios aprobados guardados como `'Aprobado'` u `'ok'`. ▶ | `backend/database/migrations/1769000000005_create_comentarios_table.ts:18` `table.string('estado')` (sin CHECK ni enum). Semilla: `backend/database/seeders/blog_seeder.ts:510` `'Aprobado'`, `:522` `'ok'` y `:575` `'Aprobado'`. ▶ El detalle del post 1 solo devuelve los ids 1 y 2, y el del post 6 devuelve 0 comentarios. | El detalle filtra por `= 'aprobado'` exacto (`routes.ts:153`), así que los comentarios de Rubén Lima y Silvia Peña (post 1) y de Paula Merino (post 6), ya aprobados, no se ven nunca. Lo notan ellos y cualquier lector. | 4: 1 migración nueva (`UPDATE` de las 3 filas + `CHECK`, que en SQLite obliga a reconstruir la tabla) y 3 filas de la semilla (ids 3, 4 y 9). | **No.** El `UPDATE` pierde el valor original (`'Aprobado'` frente a `'ok'`), y el `down` no sabe qué tenía cada fila salvo que se guarde antes. | Desbloquea **C9** (unificar la regla sin que cambie ningún número) y **C10** (aprobar con un conjunto cerrado de estados). |
| **C7** · N1 · 1/1. Al enviar un comentario, la web suma 1 al recuento aunque ese comentario esté pendiente y no se vea (incumple R5). | `frontend/src/componentes/Comentarios.jsx:39` `setTotal(total + 1)`. | Quien acaba de comentar ve «3 comentarios» encima de una lista con 2. | 1. | Sí. | Bloqueado por **C4**: si se arregla C4, esta línea desaparece. |
| **C8** · N1 · 0/4. Toda la lógica de comentarios (SQL, validación, autorización y forma de la respuesta) vive en el archivo de rutas, sin controlador, validador, servicio, repositorio ni transformer. | `backend/start/routes.ts:295-393` (los tres handlers) y `:152-155` (el bloque del detalle). Son 9 `db.rawQuery` en total. | Nadie todavía. Es lo que hace caros C10–C21. | 4 bloques que mover. Salen 5 archivos nuevos (controlador, validador, servicio, repositorio y transformer) y el alias `#repositories/*` en `backend/package.json`. | Sí, si se hace con C5 en verde (el comportamiento queda idéntico). | Bloqueado por **C5**. Desbloquea **C10–C21**. |
| **C9** · N2 · 2/2. «Visible» y «contable» son dos reglas distintas: el recuento cuenta todo lo que no sea `'pendiente'` y el detalle solo `'aprobado'` (incumple R5). ▶ | `backend/start/routes.ts:75-76` `c.estado <> 'pendiente'` y `:223` `estado <> 'pendiente'`, frente a `:153` `estado = 'aprobado'`. ▶ El listado dice `num_comentarios = 4` para el post 1 y su detalle trae 2. Para el post 6 dice 1 y el detalle trae 0. | El lector ve «4 comentarios» en la portada y encuentra 2 al entrar. Cualquier estado futuro (`'rechazado'`, `'spam'`) se contaría como visible. | 2 (`:76` y `:223`). | Sí. | Bloqueado por **C6**: si se hace antes, los recuentos públicos bajan (post 1: 4→2; post 6: 1→0). Si se hace después, no cambia ningún número. |
| **C10** · N2 · 2/5. No hay forma de aprobar un comentario: todo lo que entra por la web nace `'pendiente'` y ningún código cambia nunca `estado`. | `backend/start/routes.ts:326` `[post.id, nombre, email, cuerpo, 'pendiente', …]`. El único `update comentarios` del backend es `:388`, y solo toca `cuerpo`. | Todo el que comenta desde la web: su comentario no aparece nunca, salvo que alguien lo apruebe a mano en la base (en el repo no hay rastro de que se haga). | 5: 1 ruta nueva + 1 método en el controlador, el validador, el servicio y el repositorio. | Sí. | Bloqueado por **C8**, **C6** y **C3**. |
| **C11** · N2 · 2/2. Borrar un comentario no hace nada con sus respuestas, que se quedan con un `padre_id` que ya no existe. | `backend/start/routes.ts:359` `delete from comentarios where id = ?` y la migración `:20` `table.integer('padre_id').nullable()` (sin clave foránea). No se ha ejecutado, porque borra. | Si se borra el comentario 1 (Ana), la respuesta 2 (Marta, la autora del post) desaparece de la web por C22. La nota Marta. | 2: el servicio de borrado (decidir entre cascada, borrado lógico o reasignar) y la migración con la clave foránea. | El arreglo sí. Lo que ya se haya borrado no: es borrado físico, sin papelera. | Bloqueado por **C8**. Desbloquea **C22**. |
| **C12** · N2 · 1/3. Ninguna respuesta de comentarios pasa por un transformer: las tres devuelven la fila cruda con `autor_email`. | `backend/start/routes.ts:171` `comentarios: comentarios`, `:333` `{ comentario: nuevos[0] }` y `:392` `{ comentario: actualizados[0] }`. | En POST y PATCH el correo es el de quien pide. Combinado con C13, puede ser el de otra persona. Sin transformer, C1 vuelve a abrirse en cuanto alguien escriba otro `select *`. | 3 (las tres respuestas). | Sí. | Bloqueado por **C8**. Hace permanente **C1**. |
| **C13** · N2 · 0/1. Tras insertar, `POST` devuelve el último comentario de toda la tabla, no el que acaba de crear. | `backend/start/routes.ts:329-331` `select * from comentarios order by id desc limit 1`. | Con dos envíos simultáneos, cada persona puede recibir el comentario (y el correo) de la otra. Nadie todavía. | 1. | Sí. | Bloqueado por **C8**: el `create` del repositorio devuelve la fila propia y lo resuelve sin coste. |
| **C14** · N2 · 0/2. `padre_id` se guarda sin comprobar que exista, que sea del mismo post o que sea una raíz. | `backend/start/routes.ts:308` `const padre = request.input('padre_id', null)` → `:326`. | Nadie todavía: la web no envía `padre_id` (`Comentarios.jsx:33`), así que solo se llega por la API. Una respuesta mal colgada queda invisible por C22. | 2 (regla del validador + comprobación en el servicio de que es del mismo post). | Sí. | Bloqueado por **C8**. Desbloquea **C22**. |
| **C15** · N2 · 0/1. Un cuerpo de 5 espacios pasa la validación. | `backend/start/routes.ts:319` `String(cuerpo).length < 5` (sin `trim`). | Nadie todavía: entra como pendiente y, por C10, nadie lo ve. | 1 (la regla del validador). | Sí. | Bloqueado por **C8**. Comparte validador con C16, C17, C18 y C19. |
| **C16** · N2 · 0/1. La validación del correo acepta cualquier cadena con una `@`. ▶ | `backend/start/routes.ts:316` `String(email).indexOf('@') === -1`. ▶ `"a@b"` pasa esa comprobación. | Nadie todavía. El correo solo se usa como prueba de autoría (C2a, C21). | 1. | Sí. | Bloqueado por **C8**. |
| **C17** · N2 · 0/1. `PATCH` acepta un cuerpo de 1 carácter, mientras que `POST` exige 5. | `backend/start/routes.ts:384` `if (!cuerpo)` frente a `:319` `String(cuerpo).length < 5`. | Nadie todavía: la web no ofrece editar. | 1. | Sí. | Bloqueado por **C8**. |
| **C18** · N2 · 0/2. Un cuerpo demasiado corto responde `200` con `{ok:false}` en vez de un error. ▶ | `backend/start/routes.ts:320` `return response.send({ ok: false, motivo: … })`. ▶ `HTTP/1.1 200 OK {"ok":false,"motivo":"comentario demasiado corto"}`. | Nadie en la web, que lee `d.motivo` (`Comentarios.jsx:44`). Un cliente de la API que mire el código de estado lo toma por éxito. | 2 (`routes.ts:320` y `Comentarios.jsx:44`, que tendría que leer el error nuevo). | Sí. | Bloqueado por **C8**. Es un cambio de contrato: necesita una decisión explícita y su propio test. |
| **C19** · N2 · 1/5. Las cuatro validaciones de `POST` devuelven cuatro formas de error distintas. ▶ | `backend/start/routes.ts:311` `400 {error}`, `:314` `422 {message}`, `:317` `400 {errores:[…]}` y `:320` `200 {ok,motivo}`. ▶ Las cuatro, reproducidas. | Quien escribe mal su correo ve «No se ha podido enviar.» en lugar de «email no válido», porque `Comentarios.jsx:44` no lee `errores`. | 5 (los 4 `return` y `Comentarios.jsx:44`). | Sí. | Bloqueado por **C8**. Va en el mismo cambio que C18. |
| **C20** · N2 · 0/2. `PATCH` y `DELETE` comprueban la autoría con reglas distintas, escritas dos veces a mano. | `backend/start/routes.ts:353` (minúsculas + `trim` + clave) frente a `:379` `comentario.autor_email !== email \|\| comentario.estado !== 'pendiente'` (exacta, sin clave, solo pendientes). | Nadie todavía: la web no ofrece editar ni borrar. Por la API, quien puede borrar un comentario no siempre puede editarlo. | 2. | Sí. | Bloqueado por **C8**. Desbloquea **C2b** (una sola regla que sustituir). |
| **C21** · N2 · 0/1. `PATCH` deja editar un comentario pendiente a cualquiera que conozca el correo de su autor. | `backend/start/routes.ts:378-379` `request.input('autor_email', '')` … `comentario.autor_email !== email`. | Nadie todavía: el correo de un pendiente no sale en ningún `GET`, pero el de la autora del post sí (`post.autor_email`, ver C2a). Quien modera aprobaría un texto que no escribió su autor. | 1. | Sí. | Bloqueado por **C8**. Se resuelve con **C2b**. |
| **C2b** · N3 · 1/5 · *fondo*. La autoría de un comentario se demuestra con un correo y no con una cuenta (el starter de auth ya existe y no se usa). | `backend/start/routes.ts:350-353` y `:378-379`. La migración `1769000000005_…:15-16` solo guarda `autor_nombre`/`autor_email`, sin usuario. | Tras C2a, el daño residual es C21 y que los autores no puedan borrar lo suyo. | 5: migración nueva (`usuario_id`), POST (guardarlo), PATCH, DELETE y el formulario de `Comentarios.jsx` (enviar el token). | **No del todo.** El `down` de la migración tira la columna y, con ella, quién escribió qué. Además es una decisión de producto (¿comentar exige cuenta?). | Bloqueado por **C8**, **C20** y **C2a**. |
| **C22** · N3 · 0/1. La web solo pinta raíces y sus respuestas directas, y descarta en silencio cualquier comentario cuyo padre no esté en la lista. | `frontend/src/componentes/Comentarios.jsx:50` `filter((c) => !c.padre_id)` y `:63-64` `filter((r) => r.padre_id === c.id)`. | Nadie todavía (la única respuesta de la semilla cuelga de un padre visible). Desaparecería la respuesta a una respuesta, la de un padre borrado (C11), la de un padre en `'Aprobado'` (C6) y la que cuelga de otro post (C14). | 1. | Sí. | Bloqueado por **C14** y **C11**, que reducen los casos a uno. |

### Resumen del orden

| Nivel | Orden (daño/radio) |
|---|---|
| N0 | C1 (3/1) · C2a (3/1) · C3 (3/4) · C4 (1/2) · C5 (0/6) |
| N1 | C6 (2/4) · C7 (1/1) · C8 (0/4) |
| N2 | C9 (2/2) · C11 (2/2) · C10 (2/5) · C12 (1/3) · C19 (1/5) · C13 (0/1) · C15 (0/1) · C16 (0/1) · C17 (0/1) · C21 (0/1) · C14 (0/2) · C18 (0/2) · C20 (0/2) |
| N3 | C2b (1/5) · C22 (0/1) |

C9 va antes que C11 aunque empatan a 2/2 porque su efecto ya se ve hoy (▶). El de C11 solo aparece cuando alguien borra.

---

## Fuera de la tabla: propuestas que nadie ha medido

- **Índice y clave foránea en `comentarios.post_id`** (migración `:14`). Con 9 filas no hay coste medible. Habría que medirlo antes de proponerlo como hallazgo.
- **`key={index}`** en `Comentarios.jsx:57` y `:66`. La lista no se reordena en el cliente, así que no se ha observado ningún efecto.
- **Antispam / límite de envíos** en `POST`. Hay spam en la semilla (id 7), pero está pendiente y no se ha medido el volumen.
- **Responder, editar y borrar desde la web.** Hoy no existen (no hay `padre_id`, `PATCH` ni `DELETE` en `Comentarios.jsx`). Es alcance de producto, no un defecto.
- **`type="email"` / `required`** en el formulario (`Comentarios.jsx:78-79`).
- **Zona horaria de `creado_en`** (`routes.ts:323`, UTC sin marca). La web solo enseña la fecha (`:59`), y no se ha visto ningún desfase.
- **Comparar la clave en tiempo constante** (`routes.ts:351`). Pierde sentido si se hace C2b.

## Comprobado y descartado

- **R2 se cumple:** el comentario pendiente 5 no sale en el detalle del post 1 (`routes.ts:153`) ▶.
- **No hay XSS en el cuerpo del comentario:** se pinta como texto (`Comentarios.jsx:61`, `{c.cuerpo}`) y React lo escapa. No hay `dangerouslySetInnerHTML` en el componente.
- **Comentar en un post inexistente o en borrador → 404** (`routes.ts:296-301`) ▶.

---

## Parte B: las tres líneas

*(Las rellena quien audita: hablan de lo que comprobaste tú, no de lo que dice el agente.)*

1. Hallazgos que devolvió el agente: **23 filas (22 hallazgos, C2 partido en dos)**. Comprobados por mí 6 abriendo el archivo: …
2. El hallazgo del que no supe decidir la prioridad: El hallazgo C2a creo que debería ser el primero ya que es el más puede doler a los usuarios finales. El C1 si que puede mostrar información delicada (correo) pero eso solo si el acceso es por directo por API si solo se puede acceder a el por el front no sería tan grave.
3. Algo que el agente afirmó y no pude verificar: Por temas de tiempo no he podido comprobar muchos de los hallazgos. 
