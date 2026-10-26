# Auditoría de la feature de comentarios

Fecha: 2026-10-26 · Alcance: **solo comentarios** (`POST /posts/:slug/comentarios`, `DELETE` y `PATCH /comentarios/:id`,
los comentarios del detalle del post, los recuentos `num_comentarios` y `Comentarios.jsx`). Ninguna otra feature.

## Cómo se ordena

1. **Precedencia primero**: lo que abarata o desbloquea a otro hallazgo va antes.
2. Dentro de cada nivel, **daño ÷ radio**.
3. Si un hallazgo tiene el daño más alto y la precedencia más baja a la vez, se parte en dos filas: una **contención** que corta el daño hoy y el **arreglo de fondo** que espera su turno (filas 2 y 3 frente a 5 y 6).
4. Las propuestas que nadie ha medido van **fuera de la tabla**, con lo que habría que medir.

Una fila por hallazgo. «Sitios» está contado con `grep`/`sed` sobre el repo, no estimado. Todo es lectura del código: no se ha ejecutado
ninguna petición contra la API, salvo la consulta a la SQLite que se cita. Según `CLAUDE.md`, **ninguna fila se corrige de tapadillo dentro de un refactor**:
primero se caracteriza (fila 1), luego se decide y se corrige con su propio test.

Datos reales de la semilla (9 comentarios, `backend/tmp/db.sqlite3`): `aprobado` 4, `Aprobado` 2, `ok` 1, `pendiente` 2.

---

## Nivel 0 — desbloquea a todos los demás

| # | Qué es | Dónde | Qué se rompe y quién lo nota | Sitios | ¿Revert? | ¿Bloquea / desbloquea? |
|---|---|---|---|---|---|---|
| 1 | Toda la feature tiene un único test, el camino feliz del `POST`. | `backend/tests/functional/comentarios.spec.ts:15-43` (el propio archivo lo admite en las líneas 5-11). | Nadie todavía: se nota con el primer cambio, porque ningún arreglo de esta tabla se puede verificar ni refactorizar sin red (`CLAUDE.md`: caracterizar antes de refactorizar). | 1 archivo; **23 casos** por escribir según la matriz: POST 7 (4 entradas inválidas, 404, `pendiente`, sin `autor_email` en la respuesta), DELETE 5, PATCH 5, detalle 4, recuentos 2. | Sí. | **Desbloquea a todos** (en especial al 13, que `CLAUDE.md` condiciona a esta caracterización). |

## Nivel 1 — contención y decisiones que abaratan lo demás

| # | Qué es | Dónde | Qué se rompe y quién lo nota | Sitios | ¿Revert? | ¿Bloquea / desbloquea? |
|---|---|---|---|---|---|---|
| 2 | **Contención.** La clave de moderación es una constante escrita en el código (`'dev-secret-cambiar'`) y basta una cabecera para borrar cualquier comentario. | `backend/start/routes.ts:25` (definición), `:349` (lee `x-clave-moderacion`), `:351` (`clave === SECRETO_SESION`). | Cualquiera con acceso al repo o a su historial puede borrar cualquier comentario con una cabecera. Nadie lo ha explotado. El comentario de `:21-24` dice que firma sesiones; en el código solo se usa en `:25` y `:351`, así que no firma nada. No está en `.env.example` ni en `start/env.ts`. | 3 archivos: `routes.ts` (2 usos del identificador: `:25`, `:351`), `start/env.ts` y `.env.example` (0 menciones hoy). | **Parcial**: el código sí, pero la clave ya está en el historial de git y hay que rotarla. | A ninguno. Su arreglo de fondo (moderación real) va dentro del 6. |
| 3 | **Contención.** El detalle del post devuelve cada comentario aprobado con su `autor_email`. | `backend/start/routes.ts:152-153` (`select *`) y `:171` (`comentarios: comentarios`). | Rompe la regla 6 de `CLAUDE.md`: con la semilla salen 4 correos públicos. El frontend no lo lee (`autor_email` aparece una sola vez en `frontend/src`, `Comentarios.jsx:33`, y es para enviarlo), así que solo lo ve quien mire la pestaña Red o consuma la API. Es además el dato que sirve de contraseña en el 6. | 1 archivo, 2 líneas. | Sí. | **Desbloquea el 6**: sin el correo público, el borrado por correo deja de ser trivial. Es la misma fuga que el 5 en otro endpoint. |
| 4 | Hay que decidir qué significan `Aprobado` y `ok` en `estado`, y no existe ningún endpoint que apruebe un comentario. | `backend/database/seeders/blog_seeder.ts:510` (`Aprobado`), `:522` (`ok`), `:575` (`Aprobado`); `…_create_comentarios_table.ts:18` (texto libre, sin CHECK); único escritor de `estado`: `routes.ts:326` (siempre `'pendiente'`). | Nadie decide hoy y 3 de los 7 comentarios no pendientes no salen nunca en el detalle (ver 7). Un comentario nuevo se queda `pendiente` para siempre salvo que se edite la base a mano; lo notan quien comenta y el moderador. | 3 sitios con valor sucio (2 `Aprobado`, 1 `ok`) en 1 semilla; 1 migración; 4 comparaciones de `estado` en `routes.ts` (`:153`, `:379`, y los `<> 'pendiente'` de `:75-76` y `:223`). | **No** si se normaliza (`UPDATE` o migración sobre datos ya escritos); sí si solo se decide. | **Bloquea el 7**: no se puede unificar el criterio de recuento sin esta decisión. |

## Nivel 2 — daño alto, ya desbloqueado

| # | Qué es | Dónde | Qué se rompe y quién lo nota | Sitios | ¿Revert? | ¿Bloquea / desbloquea? |
|---|---|---|---|---|---|---|
| 5 | **Fondo de la fuga.** El `POST` y el `PATCH` devuelven la fila cruda con `autor_email`, y el `POST` relee con `order by id desc limit 1`, sin filtro. | `backend/start/routes.ts:329-331` (relectura) y `:333` (respuesta del POST); `:389-392` (respuesta del PATCH). | Filtra `autor_email`, `post_id`, `estado` y `padre_id` en lugar de un contrato propio. La relectura devuelve el último comentario de la tabla, no el insertado: con dos `POST` concurrentes puede devolver el de otra persona (deducido del código, **no reproducido**). Se nota en la pestaña Red. | 1 archivo, 2 respuestas crudas (POST `:333`, PATCH `:392`; la del detalle es el 3) y 2 relecturas (`:329` y `:389`). | Sí. | Misma fuga que el 3. Su arreglo de fondo es el transformer del 13. |
| 6 | El correo, que la API publica (3), es la única credencial para borrar o editar un comentario ajeno. | `backend/start/routes.ts:350-353` (DELETE) y `:378-379` (PATCH). | Quien lea un correo en el detalle puede borrar ese comentario aprobado con `DELETE` y `{autor_email}`. El `PATCH` solo edita `pendiente`, que no sale en el detalle, así que el riesgo es menor. Ni el frontend llama a estos endpoints (0 ocurrencias de `method: 'DELETE'` o `'PATCH'` en `frontend/src`). | 1 archivo, 2 endpoints. | Sí en el código; el arreglo real (token de autoría devuelto en el `POST`) cambia el contrato. | **Lo desbloquea el 3.** Con el 3 hecho y sin tocar esto solo se esconde el problema. Se une al 11. |
| 7 | Tres criterios distintos de «comentario aprobado»: el recuento cuenta `<> 'pendiente'` y el detalle filtra `= 'aprobado'`. | `backend/start/routes.ts:75-76` (listado y búsqueda), `:223` (relacionados), `:153` (detalle). Consumidores en el frontend: `ListaPosts.jsx:57`, `PostsRelacionados.jsx:32`, `DetallePost.jsx:71`. | Datos reales: el post 1 dice 4 comentarios en la tarjeta y 2 en el detalle; el post 6 dice 1 y 0. Lo notan los lectores, y quien comentó no sabe por qué no sale. Contradice la regla 5 («solo los aprobados»). | 2 ocurrencias de `<> 'pendiente'` y 1 de `= 'aprobado'`, todas en `routes.ts`; 3 consumidores en 3 archivos del frontend. | Unificar el criterio en código, sí. Normalizar los datos (fila 4), **no**. | **Lo bloquea el 4.** Se arregla con el 14 (el frontend recalcula el total). |

## Nivel 3 — consistencia (se arregla junto al introducir validador y handler)

| # | Qué es | Dónde | Qué se rompe y quién lo nota | Sitios | ¿Revert? | ¿Bloquea / desbloquea? |
|---|---|---|---|---|---|---|
| 8 | El `POST` responde con cinco formas de error distintas, una de ellas un `200`. | `backend/start/routes.ts:301` (404 `{error}`), `:311` (400 `{error}`), `:314` (422 `{message}`), `:317` (400 `{errores}`), `:320` (**200** `{ok:false, motivo}`); `backend/app/exceptions/handler.ts:15-17` solo delega en `super.handle`. | Un cuerpo corto devuelve `200`, así que un cliente que mire el código cree que fue bien. El frontend cubre `error`, `message` y `motivo` (`Comentarios.jsx:44`) pero no `errores`: quien escribe un correo sin `@` ve «No se ha podido enviar.» sin motivo. | 1 archivo de rutas con 5 formas en el `POST` (más 3 respuestas de error en DELETE y PATCH); 1 línea en el frontend. | Sí, pero **qué códigos se quieren es una decisión de contrato**, no mecánica. | Se hace junto al 9 (el validador VineJS añadiría una sexta forma si no se centraliza). Lo absorbe el 13. |
| 9 | La validación de entrada es débil: sin longitud máxima, el correo solo se comprueba con `indexOf('@')` y no se comprueban tipos. | `backend/start/routes.ts:310-322` (POST), `:384` (PATCH, solo `!cuerpo`); referencia correcta: `backend/app/validators/user.ts:6`. | `'@'` es un correo válido; un nombre de espacios pasa; el `PATCH` permite dejar un comentario de 1 carácter frente al mínimo de 5 del `POST` (`:319`); un cuerpo enorme se guarda entero y vuelve en el detalle. Qué pasa con un `autor_nombre` que no sea cadena no se ha probado. | 1 archivo, 2 bloques (POST y PATCH); 0 validadores de comentarios en `backend/app/validators/` (solo `user.ts`). | Sí. | Va con el 8 y lo absorbe el 13. |
| 10 | `padre_id` se guarda tal cual lo manda el cliente. | `backend/start/routes.ts:308` (`request.input('padre_id', null)`) y `:326` (se inserta sin comprobar). | No se comprueba que el padre exista ni que sea del mismo post: un comentario puede colgar de uno de otro post y no se pinta nunca (ver 16). El frontend no envía `padre_id` (`Comentarios.jsx:33`), así que hoy solo lo provoca quien llama a la API a mano. | 1 archivo, 2 líneas. | Sí en el código; los datos huérfanos ya escritos, no. | Relacionado con el 12 y el 16. |
| 11 | `DELETE` y `PATCH` aplican reglas de autorización distintas. | `backend/start/routes.ts:351-353` (DELETE: admite moderador, compara el correo sin mayúsculas ni espacios, no mira el estado) frente a `:378-379` (PATCH: sin moderador, correo exacto, exige `pendiente`). El comentario de `:375-377` lo reconoce. | `Ana@x.es` puede borrar pero no editar lo que escribió como `ana@x.es`; el moderador borra pero no edita. Nadie todavía (el frontend no llama a ninguno). | 1 archivo, 2 bloques. | Sí. | Se arregla junto al 6. |
| 12 | `comentarios` no tiene clave foránea ni índice, y borrar un comentario deja a sus respuestas colgadas. | `backend/database/migrations/1769000000005_create_comentarios_table.ts:14` (`post_id`), `:20` (`padre_id`); `backend/start/routes.ts:359` (`delete` sin tocar hijos). | Las respuestas de un comentario borrado no se pintan (ver 16). No hay endpoint que borre posts, así que los huérfanos por `post_id` solo ocurren con acceso directo a la base. | 1 migración; 3 consultas filtran por `post_id` (`routes.ts:75`, `:153`, `:223`). | **No**: añadir una FK en SQLite exige reconstruir la tabla. | Relacionado con el 10. |

## Nivel 4 — estructura

| # | Qué es | Dónde | Qué se rompe y quién lo nota | Sitios | ¿Revert? | ¿Bloquea / desbloquea? |
|---|---|---|---|---|---|---|
| 13 | Todo el recurso vive en las rutas, con SQL crudo y sin controlador, validador, servicio, repositorio ni transformer. | `backend/start/routes.ts:295-393` (8 `db.rawQuery` en los tres endpoints; la cabecera del archivo lo admite en `:6-12`). Referencia: `backend/app/controllers/new_account_controller.ts`, `validators/user.ts`, `transformers/user_transformer.ts`. | Nada funcional. Es la causa de 3, 5, 8, 9 y 11. | 3 endpoints más el detalle (`:150-171`); `backend/app/` no tiene `services/` ni `repositories/`, y `package.json` no tiene el alias `#repositories/*`. | Sí. | **Lo bloquea el 1** (caracterizar antes de refactorizar). Absorbe 5, 8, 9 y 11. |

## Nivel 5 — frontend y marginales

| # | Qué es | Dónde | Qué se rompe y quién lo nota | Sitios | ¿Revert? | ¿Bloquea / desbloquea? |
|---|---|---|---|---|---|---|
| 14 | Dos componentes guardan su propio recuento de comentarios y el segundo suma 1 aunque el comentario queda pendiente. | `Comentarios.jsx:11` (`total`), `:23` (se fija), `:39` (`setTotal(total + 1)`), `:54` (se pinta); `DetallePost.jsx:30` (`numComentarios`), `:38`, `:71`. | Justo tras comentar, el lector ve «N+1 comentarios» abajo y «N» en la cabecera, y el comentario no aparece. Contradice la regla 5. | 2 archivos, 7 líneas. | Sí. | Se arregla junto al 15. |
| 15 | El mismo `GET /posts/:slug` se pide dos veces y la URL base está copiada en seis archivos. | `DetallePost.jsx:34` y `Comentarios.jsx:19` (doble fetch); `const API` en `App.jsx:7`, `BarraLateral.jsx:4`, `ListaPosts.jsx:4`, `PostsRelacionados.jsx:4`, `DetallePost.jsx:7`, `Comentarios.jsx:4`. | Nada visible. Cambiar de entorno obliga a editar 6 sitios (el comentario de `Comentarios.jsx:3` dice «cuarta copia» y son seis). | 6 archivos, 6 `const API`; para comentarios, 2 archivos. | Sí. | Se arregla con el 14. |
| 16 | Las respuestas anidadas a más de un nivel, o con padre ausente, no se pintan. | `Comentarios.jsx:50` (`filter(!c.padre_id)`) y `:64` (`filter(r.padre_id === c.id)`). | Con la semilla no pasa (solo hay un nivel: el comentario 2, padre 1). Si `padre_id` llegara como texto, `===` fallaría. Nadie todavía. | 1 archivo, 2 líneas. | Sí. | Se agrava con el 10 y el 12. |
| 17 | Las listas usan el índice como `key`, el fallo de red se traga y el botón no se deshabilita al enviar. | `Comentarios.jsx:57` y `:66` (`key={index}`, `key={i}`), `:25` (`.catch(() => {})`), `:86` (botón sin `disabled`). | Hoy las listas son estáticas. Un fallo de red deja la sección vacía sin aviso. | 1 archivo, 4 líneas. | Sí. | A ninguno. |
| 18 | El texto siempre dice «comentarios», también con 1 o 0. | `ListaPosts.jsx:57`, `PostsRelacionados.jsx:32`, `DetallePost.jsx:71`, `Comentarios.jsx:54`. | «1 comentarios» en los posts 2, 4 y 6 del listado. Cosmético. | 4 archivos, 4 líneas. | Sí. | A ninguno. |
| 19 | En desarrollo CORS acepta cualquier origen con credenciales y `.env.example` apunta a puertos que no son los del proyecto. | `backend/config/cors.ts:21` (`origin: app.inDev ? true : []`), `:42` (`credentials: true`); `backend/.env.example:18` (`localhost:5173,…:3000`). | Solo en dev: cualquier página puede llamar a `DELETE` y `PATCH` con la cabecera de moderación. Producción no está desplegada. | 2 archivos, 3 líneas. | Sí. | Relacionado con el 2. |

---

## Propuestas sin medir (fuera de la tabla)

Con 9 comentarios cualquier medición actual es ruido. No son hallazgos hasta que se mida lo de la columna derecha.

| Sospecha | Dónde | Qué habría que medir |
|---|---|---|
| La subconsulta correlacionada del listado se ejecuta por fila sin índice en `post_id`. | `backend/start/routes.ts:75-76` | `EXPLAIN QUERY PLAN` y p95 de `GET /posts` con 10.000 comentarios, con y sin índice. |
| Dos consultas extra por cada relacionado (N+1). | `routes.ts:220-232` | Número de consultas y latencia por petición frente a una consulta agregada. |
| El detalle devuelve todos los comentarios sin paginar. | `routes.ts:152-155` | Tamaño de respuesta y tiempo con un post de 500 comentarios, con y sin límite. |
| El doble fetch de `/posts/:slug` cuesta algo. | `DetallePost.jsx:34`, `Comentarios.jsx:19` | Bytes transferidos y tiempo hasta pintar, con y sin caché del navegador. |
| No hay tope práctico al tamaño del cuerpo de un comentario. | `routes.ts:319`, `backend/config/bodyparser.ts` (**no leído**) | Límite real del bodyparser y tiempo de inserción con cuerpos de 1 MB. |
| Carrera de la relectura del `POST` (fila 5). | `routes.ts:329-331` | N `POST` concurrentes; contar cuántas respuestas devuelven un `autor_email` distinto del enviado. |
