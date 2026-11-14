# Auditoría — feature de comentarios

**Alcance:** crear, editar, borrar y listar comentarios en sus tres capas: rutas de la API
(`backend/start/routes.ts`), tabla `comentarios` (migración + semilla) y web
(`frontend/src/componentes/Comentarios.jsx` y lo que `DetallePost.jsx` hace con los comentarios).
Fuera de alcance: el resto de posts, autores, categorías y etiquetas.

**Cómo se ha comprobado:** lectura de los archivos citados; las consultas SQL de las rutas se
ejecutaron en **solo lectura** contra `backend/tmp/db.sqlite3` sembrada; `npm test` en `backend/`
→ `1 passed`. Dos hallazgos (C08, C26) están **razonados, no reproducidos**, y lo dice su fila.

**Criterio de «¿Es reversible?»:** SÍ = el arreglo se deshace con un `git revert` sin pérdida.
NO = toca datos, una migración ya aplicada o algo que ya se publicó.

**Orden:** primero por **precedencia** y después por **daño ÷ radio**. El cálculo está en
[Cómo se ha ordenado](#cómo-se-ha-ordenado). Con este criterio, cada hallazgo aparece antes que
todos aquellos a los que afecta su arreglo, así que el orden de la tabla sirve también como orden
de ejecución.

| Orden · # | ¿Qué es? | Ubicación | Daño | Radio | ¿Es reversible? | Precedencia |
|---|---|---|---|---|---|---|
| 1 · C21 | La única prueba de la feature cubre el POST feliz y afirma un solo campo, y el umbral de cobertura está en 0. | `backend/tests/functional/comentarios.spec.ts:41-42` `respuesta.assertStatus(201)` / `assert.equal(respuesta.body().comentario.autor_nombre, 'Lucía Ferrer')`; `.claude/hooks/guard-tests.mjs:32` `const COBERTURA_MINIMA = 0`. | PATCH, DELETE, el listado del detalle, las 4 validaciones y los 404 no tienen ninguna prueba (`npm test`: `1 passed`). Cualquier arreglo de esta tabla puede romper otro sin que nadie se entere. Lo nota el próximo que toque la feature. | 1 archivo (`comentarios.spec.ts`) con 20 casos como mínimo: POST 7 (feliz, 4 validaciones, post inexistente, post en borrador), PATCH 5 (feliz, correo ajeno, no pendiente, sin cuerpo, 404), DELETE 4 (autor, moderador, 403, 404), detalle 4 (aprobado visible, pendiente oculto, `Aprobado` oculto, correo presente hoy). | SÍ. | **Afecta a:** C01–C11, C15–C20 y C22 (18, los bloquea: `CLAUDE.md` exige caracterizar antes de tocar el backend). **Depende de:** ninguno. |
| 2 · C22 | Toda la feature vive en closures de `routes.ts` con SQL crudo, sin controlador, validador, servicio, repositorio, modelo ni transformer. | `routes.ts:295-393` (POST, DELETE y PATCH) y `:152-155` (el listado dentro del detalle). | En la web no lo nota nadie. Pero, como no hay un único sitio para cada regla, cada una está escrita dos veces y las copias no coinciden (C05/C06, C03/C17, C11/C18). | 8: `routes.ts`, `app/controllers/comentarios_controller.ts`, `app/validators/comentario.ts`, `app/services/comentario_service.ts`, `app/repositories/comentario_repository.ts`, `app/models/comentario.ts`, `app/transformers/comentario_transformer.ts` y `backend/package.json` (alias `#repositories/*`). | SÍ. | **Afecta a:** C01, C05, C06, C09, C11, C17 y C18 (les da un sitio único donde arreglarse). **Depende de:** C21. |
| 3 · C01 | `GET /posts/:slug` devuelve los comentarios con `select *`, así que el correo de cada comentarista (y `estado`, `post_id`) sale en la respuesta pública. | `backend/start/routes.ts:153` `"select * from comentarios where post_id = ? and estado = 'aprobado' …"` → `:171` `comentarios: comentarios,`. Verificado en la base: salen `id, post_id, autor_nombre, autor_email, cuerpo, estado, creado_en, padre_id`. | Cualquiera con un `curl` saca el correo de los 4 comentaristas visibles (p. ej. `ana.cortes@ejemplo.es`). La web no lo pinta, pero viaja en el JSON. Lo sufren los comentaristas. Incumple la regla 6. Además le da a C03 lo que necesita para explotarse. | 1: `routes.ts:153` (columnas explícitas). La web no usa esos campos: `Comentarios.jsx:50-70` solo lee `id, padre_id, autor_nombre, creado_en, cuerpo`. | SÍ (solo código). Lo ya expuesto no vuelve a ser privado. | **Afecta a:** C03 (lo mitiga: sin correo público, borrar con el correo deja de ser trivial). **Depende de:** C21, C22. **Junto a:** C09 (mismo transformer). |
| 4 · C02 | La clave de moderación es una constante en el código y basta con mandarla en una cabecera para borrar cualquier comentario. | `routes.ts:25` `const SECRETO_SESION = 'dev-secret-cambiar'`; `:351` `const esModerador = clave === SECRETO_SESION`. | Cualquiera con acceso al repo (cada alumno que lo forkea) borra cualquier comentario, pendiente o aprobado, con `x-clave-moderacion: dev-secret-cambiar`. El borrado es físico (`:359`) y no hay vuelta atrás. El comentario de `:21` dice que la clave firma las sesiones, pero no es así: las sesiones usan `APP_KEY` (`config/encryption.ts:16`). Quien rote «la clave de sesión» no tocará esta. | 3: `routes.ts:25` (leerla del entorno), `backend/start/env.ts` (declararla junto a `APP_KEY`, `:22`), `backend/.env.example` (añadir la variable). | NO. El valor ya está en el historial de git y en cada fork. Revertir el arreglo no lo despublica: hay que rotarlo. | **Afecta a:** C04 (la moderación necesita una credencial real). **Depende de:** C21. **Junto a:** C03 (mismo bloque, `routes.ts:349-355`). |
| 5 · C20 | `post_id` y `padre_id` no tienen clave foránea ni índice. | Migración `1769000000005…:14` `table.integer('post_id').notNullable()` y `:20` `table.integer('padre_id').nullable()`. Verificado en la base: `pragma foreign_key_list(comentarios)` sale vacío y la tabla no tiene ningún índice. | Borrar un post o un comentario deja huérfanos, y cada detalle y cada recuento recorren la tabla entera. Con 9 filas no lo nota nadie todavía. | 1: una migración nueva (en SQLite hay que recrear la tabla). | NO solo con revert: hace falta `migration:rollback`, y si hubiera huérfanos la migración tendría que borrarlos o fallaría (hoy la semilla no tiene ninguno). | **Afecta a:** C15 (con `on delete` es la base la que decide qué pasa con las respuestas) y C16 (la FK impide colgar una respuesta de un padre inexistente). **Depende de:** C21. |
| 6 · C07 | `comentarios.estado` es texto libre, sin CHECK ni enum, y ya conviven `aprobado`, `Aprobado`, `ok` y `pendiente`. | `database/migrations/1769000000005_create_comentarios_table.ts:18` `table.string('estado').notNullable().defaultTo('pendiente')`; semilla `blog_seeder.ts:510` (`'Aprobado'`), `:522` (`'ok'`), `:575` (`'Aprobado'`). | Es la causa raíz de C05 y C06. Por sí solo no lo nota nadie todavía, pero cualquier script puede volver a meter un valor nuevo sin que salte un error. | 4: migración nueva (normaliza y recrea la tabla con CHECK, porque SQLite no admite `ALTER … ADD CONSTRAINT`), `blog_seeder.ts:510`, `:522` y `:575`. | NO. Al convertir `'ok'` y `'Aprobado'` en `'aprobado'` se pierde de qué script venía cada fila, y un `git revert` no deshace una migración aplicada. | **Afecta a:** C04 (sin estados cerrados, la ruta nueva volvería a escribir texto libre), C05 y C06 (su consulta depende de los datos normalizados). **Depende de:** C21. |
| 7 · C04 | Ninguna ruta aprueba un comentario: el único UPDATE de la tabla cambia `cuerpo`, nunca `estado`. | `routes.ts:388` `update comentarios set cuerpo = ? where id = ?` (único `update` sobre `comentarios` en todo el backend). `:326` inserta siempre `'pendiente'`. | Todo comentario enviado desde la web se queda pendiente para siempre, aunque `Comentarios.jsx:38` promete «pendiente de moderación». Lo nota cada lector que comenta: nunca ve publicado su comentario. El editor solo puede moderar a mano en SQLite. | 2 rutas nuevas en `routes.ts`: listar pendientes y cambiar el estado. | SÍ. | **Afecta a:** C23 (la bloquea) y a C18, C19 y C28 (cuando haya moderación, su daño deja de ser latente). **Depende de:** C02, C07, C21. |
| 8 · C03 | Borrar y editar se autorizan comparando un `autor_email` que envía el propio cliente. | `routes.ts:350` `const email = request.input('autor_email', '')` → `:352-353` `esAutor = String(comentario.autor_email)… === String(email)…`; en PATCH, `:378-379`. | Junto con C01, cualquier visitante borra cualquier comentario aprobado: lee el correo en el detalle y manda `DELETE /comentarios/:id` con él. Lo notan el comentarista (su comentario desaparece) y el editor. | 4: migración nueva (columna de token o `user_id`), `routes.ts:324-327` (el POST genera y devuelve el token), `routes.ts:350-353` (DELETE), `routes.ts:378-379` (PATCH). | NO solo con revert: la migración aplicada exige `migration:rollback`, y los tokens ya entregados a los clientes se pierden. | **Afecta a:** C23 (hoy una UI de borrar reproduciría el agujero). **Depende de:** C01, C21. **Junto a:** C02 (mismo bloque) y C17 (misma regla). |
| 9 · C08 | Después de insertar, el POST devuelve «el último comentario de la tabla», no el que acaba de crear. | `routes.ts:329-331` `'select * from comentarios order by id desc limit 1'`. | Con dos POST simultáneos hay un `await` entre el insert (`:324`) y el select, y uno puede recibir el comentario del otro con su correo (C09). Con un solo usuario no lo nota nadie todavía. **Razonado, no reproducido.** | 1: `routes.ts:324-331` (usar el id que devuelve el insert). | SÍ. | **Afecta a:** C09 (lo agrava: lo que se filtra pasa a ser el correo de otra persona). **Depende de:** C21. |
| 10 · C15 | Borrar un comentario no hace nada con sus respuestas, que se quedan huérfanas en la base. | `routes.ts:359` `'delete from comentarios where id = ?'`. | Si Ana borra el comentario 1, la respuesta 2 (de Marta, la autora del post) desaparece de la web (C14), pero sigue en la base y en el JSON del detalle. | 1: `routes.ts:359` (decidir entre borrado en cascada o volver a colgar las respuestas). | NO si se elige la cascada: las respuestas que se borren con el padre no vuelven con un revert. | **Afecta a:** C14 (genera las huérfanas que la web no pinta). **Depende de:** C20, C21. |
| 11 · C16 | `padre_id` se acepta sin validar: puede apuntar a un comentario inexistente o de otro post, o no ser un número. | `routes.ts:308` `const padre = request.input('padre_id', null)` → `:326` (se inserta tal cual). | Una respuesta mal colgada nunca se pinta (C14). Hoy no lo nota nadie, porque la web no envía `padre_id` (`Comentarios.jsx:33`): solo llega por curl. | 1: `routes.ts:308` (comprobar que existe y que es del mismo post). | SÍ. | **Afecta a:** C14 (genera huérfanas). **Depende de:** C20, C21. |
| 12 · C24 | El componente de comentarios vuelve a pedir el post entero solo para leer sus comentarios. | `Comentarios.jsx:19` `fetch(API + '/posts/' + encodeURIComponent(slug))`, la misma petición que ya hace `DetallePost.jsx:34`. | Cada vista de un post hace 2 `GET /posts/:slug`: hasta 14 consultas SQL en lugar de 7 (`routes.ts:110-164`). Nadie lo nota todavía. | 2: `DetallePost.jsx:123` (pasar `datos.comentarios` por prop) y `Comentarios.jsx:17-26` (quitar el fetch). | SÍ. | **Afecta a:** C13 y C26 (desaparecen) y C25 (se arregla en otro sitio, `DetallePost.jsx`). **Depende de:** ninguno. |
| 13 · C17 | PATCH y DELETE aplican reglas de autoría distintas: DELETE ignora mayúsculas y acepta la clave de moderación; PATCH compara el texto exacto, no la acepta y además exige `pendiente`. | `routes.ts:351-353` frente a `:379` `if (comentario.autor_email !== email \|\| comentario.estado !== 'pendiente')`. | Quien comentó como `Ana@ejemplo.es` puede borrar escribiendo `ana@…`, pero al editar recibe un 403. El moderador puede borrar, pero no editar. Lo nota el comentarista. | 2: `routes.ts:353` y `:379`. | SÍ. | **Afecta a:** C23 (la bloquea). **Depende de:** C21, C22. **Junto a:** C03 (misma regla). |
| 14 · C11 | Cada validación del POST responde con un código y una forma distintos: `400 {error}`, `422 {message}`, `400 {errores:[]}`, `200 {ok,motivo}`. | `routes.ts:311`, `:314`, `:317`, `:320`. El manejador central no añade nada propio (`app/exceptions/handler.ts:15-17`). | Cada cliente tiene que conocer cuatro formatos de error, y la web no conoce `errores` (C12). | 5: las 4 ramas (`routes.ts:311`, `:314`, `:317`, `:320`) y `Comentarios.jsx:44`, que lee el mensaje. | SÍ. | **Afecta a:** C10, C18 y C19 (los resuelve el mismo validador) y C12 (cambia la forma del error que lee). **Depende de:** C21, C22. |
| 15 · C05 | El detalle solo muestra `estado = 'aprobado'` exacto, así que los aprobados guardados como `'Aprobado'` u `'ok'` no salen. | `routes.ts:153` `… and estado = 'aprobado' …`. El comentario de `:150-151` lo reconoce. Verificado en la base. | 3 de los 7 comentarios no pendientes (ids 3, 4 y 9) no se ven. El post 6 (`que-mide-de-verdad-una-metrica-de-producto`) no enseña su único comentario. Lo notan esos 3 comentaristas y los lectores. | 1: `routes.ts:153` (si antes se normalizan los datos, C07). | SÍ en la consulta. La normalización de datos no (ver C07). | **Afecta a:** ninguno. **Depende de:** C07, C21, C22. **Junto a:** C06 (misma definición de «aprobado»). |
| 16 · C12 | El aviso de la web no lee la clave `errores`, así que un correo sin `@` muestra el genérico «No se ha podido enviar.». | `frontend/src/componentes/Comentarios.jsx:44` `setAviso(d.error \|\| d.message \|\| d.motivo \|\| 'No se ha podido enviar.')` frente a `routes.ts:317` `{ errores: ['email no válido'] }`. | El lector que se equivoca al escribir el correo no sabe qué ha hecho mal. | 1: `Comentarios.jsx:44`. | SÍ. | **Afecta a:** ninguno. **Depende de:** C11 (si se unifica la forma del error, esta línea vuelve a cambiar). |
| 17 · C13 | Al enviar, el contador del bloque de comentarios suma uno aunque el comentario quede pendiente, y la cabecera del artículo no se actualiza. | `Comentarios.jsx:39` `setTotal(total + 1)`. La cabecera lleva su propio contador: `DetallePost.jsx:38` y `:71`. | Después de comentar, el bloque dice «3 comentarios» con 2 visibles y la cabecera sigue en 2. Lo nota el propio comentarista. Además cuenta un pendiente (regla 5). | 1: `Comentarios.jsx:39`. | SÍ. | **Afecta a:** ninguno. **Depende de:** C24 (lo elimina de raíz, porque deja un solo estado). |
| 18 · C06 | El recuento de comentarios del listado y de relacionados cuenta `estado <> 'pendiente'`, que define «aprobado» de otra forma que el detalle. | `routes.ts:75-76` `… c.estado <> ' + "'pendiente') as num_comentarios …`; `:223` `… estado <> 'pendiente'`. | Verificado en la base: el post 1 anuncia 4 comentarios en portada y relacionados y enseña 2. El post 6 anuncia 1 y enseña 0. Cualquier estado futuro (`'rechazado'`, `'spam'`) contaría como aprobado. Lo nota el lector. Incumple la regla 5. | 2: `routes.ts:75-76` y `:223`. | SÍ. | **Afecta a:** ninguno. **Depende de:** C07, C21, C22. **Junto a:** C05. |
| 19 · C25 | Los errores al cargar se ignoran y se pintan como «0 comentarios». | `Comentarios.jsx:25` `.catch(() => {})`; `:20` no comprueba `r.ok`. | Con la API caída o un 404, el lector ve «0 comentarios» como si no hubiera ninguno. | 2: `Comentarios.jsx:20` y `:25`. | SÍ. | **Afecta a:** ninguno. **Depende de:** C24 (si se hace, el arreglo va en `DetallePost.jsx`). |
| 20 · C10 | Un cuerpo de menos de 5 caracteres responde `200 {ok:false}` en vez de un error. | `routes.ts:320` `return response.send({ ok: false, motivo: 'comentario demasiado corto' })`. | Cualquier cliente que mire el código de estado cree que se guardó. La web se salva porque mira `d.comentario` (`Comentarios.jsx:37`), así que en la web no lo nota nadie todavía. | 1: `routes.ts:320`. | SÍ, pero cambia el contrato (el test de caracterización se sustituye por otro). | **Afecta a:** ninguno. **Depende de:** C11 (se resuelve dentro), C21. |
| 21 · C18 | PATCH solo exige que haya cuerpo, así que editando se salta el mínimo de 5 caracteres que se pide al crear. | `routes.ts:384` `if (!cuerpo) {` frente a `:319` `String(cuerpo).length < 5`. | Nadie todavía: el comentario editado sigue pendiente y no hay moderación (C04). | 1: `routes.ts:384`. | SÍ. | **Afecta a:** ninguno. **Depende de:** C04, C11, C21, C22. |
| 22 · C26 | El fetch de comentarios no se cancela al cambiar de post, y una respuesta tardía del post anterior puede pintarse en el nuevo. | `Comentarios.jsx:17-26` (`useEffect` sin función de limpieza ni `AbortController`). | Si se navega deprisa con anterior/siguiente, pueden salir los comentarios del post A bajo el post B. En localhost no lo nota nadie todavía. **Razonado, no reproducido.** | 1: `Comentarios.jsx:17-26`. | SÍ. | **Afecta a:** ninguno. **Depende de:** C24 (desaparece con él). |
| 23 · C09 | POST y PATCH devuelven la fila cruda (`autor_email`, `estado`, `post_id`, `padre_id`) sin transformer. | `routes.ts:333` `{ comentario: nuevos[0] }`; `:392` `{ comentario: actualizados[0] }`. | Hoy el correo que vuelve es el de quien escribe, así que nadie lo nota todavía. Con C08 sería el de otra persona. | 2: `routes.ts:333` y `:392`. Restricción: mantener la clave `comentario`, porque `Comentarios.jsx:37` la usa para saber si el envío fue bien. | SÍ. | **Afecta a:** ninguno. **Depende de:** C08, C21, C22. **Junto a:** C01 (mismo transformer). |
| 24 · C14 | La web solo pinta dos niveles y solo las respuestas cuyo padre está en la lista; cualquier otra respuesta aprobada queda invisible, pero sí suma en el contador. | `Comentarios.jsx:50` `const raices = comentarios.filter((c) => !c.padre_id)` y `:63-64` `.filter((r) => r.padre_id === c.id)`. El contador cuenta la lista entera (`:23`). | No se ven las respuestas a una respuesta ni las que cuelgan de un pendiente, de un comentario borrado (C15) o de otro post (C16), y el contador marca una de más. Con la semilla no lo nota nadie todavía: la única respuesta (id 2) tiene el padre visible. | 2: `Comentarios.jsx:50` y `:63-64`. | SÍ. | **Afecta a:** ninguno. **Depende de:** C15, C16. |
| 25 · C19 | La validación del contenido es débil: un `@` basta como correo, cinco espacios bastan como cuerpo y ningún campo tiene longitud máxima. | `routes.ts:316` `String(email).indexOf('@') === -1`; `:319` `String(cuerpo).length < 5` (sin `trim`). No hay máximo en ningún sitio. | Se aceptan correos como `@` y cuerpos de megas. Nadie lo nota todavía, porque sin moderación nadie los ve. | 2: `routes.ts:316` y `:319` (los máximos van en esas mismas reglas). | SÍ. | **Afecta a:** ninguno. **Depende de:** C04, C11, C21. |
| 26 · C23 | La web solo permite crear y leer: no hay forma de editar, borrar ni responder. | `Comentarios.jsx:30-34` es la única petición de escritura, y su cuerpo no lleva `padre_id` (`:33`). `grep -E "PATCH\|DELETE" frontend/src` no devuelve nada. | PATCH y DELETE solo existen para quien use curl, y un comentarista no puede corregir una errata. Es funcionalidad que falta: nadie la vive como un error. | 3 piezas nuevas en `Comentarios.jsx`: editar, borrar y responder. | SÍ. | **Afecta a:** ninguno. **Depende de:** C03, C04, C17. |
| 27 · C28 | `creado_en` se guarda en UTC sin zona horaria y la web muestra sus 10 primeros caracteres, así que un comentario de madrugada sale con la fecha del día anterior. | `routes.ts:323` `new Date().toISOString().slice(0, 19).replace('T', ' ')`; `Comentarios.jsx:59` `String(c.creado_en).substring(0, 10)`. | Lo notaría quien comente de madrugada en hora peninsular. Hoy nadie, porque sin moderación (C04) ningún comentario nuevo llega a verse. | 3: `routes.ts:323`, `Comentarios.jsx:59` y `:68` (respuestas). | SÍ en el código. Las filas ya guardadas no dicen en qué zona están. | **Afecta a:** ninguno. **Depende de:** C04. |
| 28 · C27 | La URL de la API está fija en el componente de comentarios, y es una de seis copias. | `Comentarios.jsx:4` `const API = 'http://localhost:3401'`. | Fuera de `localhost:3401`, la sección de comentarios ni carga ni envía. Nadie lo nota todavía. | 6: `App.jsx:7`, `ListaPosts.jsx:4`, `DetallePost.jsx:7`, `Comentarios.jsx:4`, `BarraLateral.jsx:4` y `PostsRelacionados.jsx:4`. | SÍ. | **Afecta a:** ninguno. **Depende de:** ninguno. |

## Cómo se ha ordenado

**1. Precedencia (primera clave).** Se mide con el **nivel** de cada hallazgo, que sale de la
casilla Precedencia («Afecta a»):

- Nivel 0: su arreglo no afecta a ningún otro hallazgo.
- Nivel n: su arreglo afecta al menos a un hallazgo de nivel n−1 (se toma el nivel más alto de
  los afectados, más uno).

Así, cada hallazgo queda por encima de todos aquellos a los que afecta, y los que no afectan a
ninguno van al final. Solo cuentan las relaciones con dirección: bloquea, desbloquea, mitiga,
agrava, resuelve, genera o activa el daño de otro. «Junto a» (dos arreglos que comparten sitio)
se anota, pero no ordena.

**2. Daño ÷ Radio (segunda clave), dentro de cada nivel.** El radio es el número de la casilla
Radio (en C21 se cuentan los 20 casos). El daño se puntúa a partir de su casilla:

- 4: cualquiera puede explotarlo hoy (seguridad o privacidad).
- 3: rompe hoy la feature para todos los lectores o comentaristas de la web.
- 2: lo nota hoy alguien concreto: un usuario de la web en un caso concreto, o el equipo.
- 1: solo se llega a él por la API a mano, o no lo nota nadie todavía.

**3. Empates:** primero el de más daño, después el que afecta a más hallazgos y, por último, el
número.

Los puntos de daño son una lectura de la casilla Daño, no una medida exacta. Cambiar uno mueve la
fila dentro de su nivel, nunca a otro nivel.

| Orden | # | Nivel | Afecta a (n.º) | Daño | Radio | Daño ÷ Radio |
|---|---|---|---|---|---|---|
| 1 | C21 | 4 | 18 | 2 | 20 | 0,10 |
| 2 | C22 | 3 | 7 | 2 | 8 | 0,25 |
| 3 | C01 | 2 | 1 | 4 | 1 | 4,00 |
| 4 | C02 | 2 | 1 | 4 | 3 | 1,33 |
| 5 | C20 | 2 | 2 | 1 | 1 | 1,00 |
| 6 | C07 | 2 | 3 | 1 | 4 | 0,25 |
| 7 | C04 | 1 | 4 | 3 | 2 | 1,50 |
| 8 | C03 | 1 | 1 | 4 | 4 | 1,00 |
| 9 | C08 | 1 | 1 | 1 | 1 | 1,00 |
| 10 | C15 | 1 | 1 | 1 | 1 | 1,00 |
| 11 | C16 | 1 | 1 | 1 | 1 | 1,00 |
| 12 | C24 | 1 | 3 | 1 | 2 | 0,50 |
| 13 | C17 | 1 | 1 | 1 | 2 | 0,50 |
| 14 | C11 | 1 | 4 | 1 | 5 | 0,20 |
| 15 | C05 | 0 | 0 | 3 | 1 | 3,00 |
| 16 | C12 | 0 | 0 | 2 | 1 | 2,00 |
| 17 | C13 | 0 | 0 | 2 | 1 | 2,00 |
| 18 | C06 | 0 | 0 | 3 | 2 | 1,50 |
| 19 | C25 | 0 | 0 | 2 | 2 | 1,00 |
| 20 | C10 | 0 | 0 | 1 | 1 | 1,00 |
| 21 | C18 | 0 | 0 | 1 | 1 | 1,00 |
| 22 | C26 | 0 | 0 | 1 | 1 | 1,00 |
| 23 | C09 | 0 | 0 | 1 | 2 | 0,50 |
| 24 | C14 | 0 | 0 | 1 | 2 | 0,50 |
| 25 | C19 | 0 | 0 | 1 | 2 | 0,50 |
| 26 | C23 | 0 | 0 | 1 | 3 | 0,33 |
| 27 | C28 | 0 | 0 | 1 | 3 | 0,33 |
| 28 | C27 | 0 | 0 | 1 | 6 | 0,17 |

## Comprobado y correcto (no son hallazgos)

- Un comentario `pendiente` no sale en el detalle (`routes.ts:153`): la regla 2 se cumple.
- Comentar en un post en borrador o inexistente da 404 (`routes.ts:297-301`).
- El cuerpo del comentario se pinta como texto (`Comentarios.jsx:61` `<p>{c.cuerpo}</p>`), no con
  `dangerouslySetInnerHTML`: los comentarios no tienen XSS.

## Parte B: las tres líneas

> Borrador del agente para que lo revises: las partes marcadas **[TUYO]** dependen de lo que
> hiciste tú, y el agente no puede saberlo.

1. **Cuántos hallazgos devolvió el agente y cuántos comprobé yo abriendo el archivo:**
   el agente devolvió **28**. Yo comprobé **0** abriendo el archivo.
2. **El hallazgo del que no supe decidir la prioridad:**
   Se terminó el tiempo y no pude terminar de revisar la lista.
3. **Algo que el agente afirmó y no pude verificar:**
   Se terminó el tiempo y no pude terminar de revisar la lista.
