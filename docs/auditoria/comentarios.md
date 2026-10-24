# Auditoría de la feature «comentarios»

Alcance: crear, editar, borrar y listar comentarios, en sus tres capas: API (`backend/start/routes.ts`),
tabla (`comentarios`) y web (`frontend/src/componentes/`). Nada más.

**Orden.** Primero la precedencia (lo que abarata o desbloquea otro hallazgo va antes). Dentro de cada
nivel, daño dividido por radio: daño A/M/B (alto/medio/bajo) entre los sitios contados. Los hallazgos
con daño alto y precedencia baja se parten en dos filas: contención hoy, arreglo de fondo en su turno.

**Cómo se comprobó.** Cada fila cita una línea que se leyó en el archivo. Las marcadas con ✔ se
comprobaron además con peticiones `GET` a la API en marcha (sin escribir nada). Las que se leyeron
pero no se ejecutaron llevan «solo lectura».

## Nivel 1: abaratan o desbloquean al resto

| # | Qué es | Dónde (línea que lo demuestra) | Qué se rompe y quién lo nota | Sitios | ¿Revert? | ¿Bloquea / desbloquea? |
|---|---|---|---|---|---|---|
| 1 | **Contención.** El detalle del post devuelve el correo de quien comenta (daño A) ✔ | `routes.ts:152` `select * from comentarios …` | Cualquier visitante o scraper lee los correos de los comentaristas (los 2 comentarios visibles del post 1 salen con `autor_email`). Incumple la regla 6 y es dato personal (RGPD). | 1 (la consulta de `:152`) | El código, sí. **Lo ya servido, no**: un correo que salió no se recupera. | **Desbloquea el 5**: sin correos públicos, el borrado por correo deja de ser explotable a la ligera. Su arreglo de fondo es el 9. |
| 2 | Un solo test, del camino feliz del `POST`; el resto de la feature no tiene red | `tests/functional/comentarios.spec.ts:15` (único `test(` del archivo) | Nadie todavía. Pero `CLAUDE.md` exige caracterizar antes de tocar, así que ningún arreglo de abajo puede empezar sin esto. | 18 tests por escribir en 1 archivo: `POST` 6, `DELETE` 4, `PATCH` 5, lectura 3 | Sí (solo añade tests) | **Desbloquea 3, 4, 5, 6, 7, 8, 9, 10, 11 y 12.** |

## Nivel 2: arreglos de código pequeños y aislados

| # | Qué es | Dónde | Qué se rompe y quién lo nota | Sitios | ¿Revert? | ¿Bloquea / desbloquea? |
|---|---|---|---|---|---|---|
| 3 | La clave de moderación está escrita en el código y es la misma que la «clave de sesión» (daño A) | `routes.ts:25` `const SECRETO_SESION = '<valor literal, omitido aquí>'` y `:351` `clave === SECRETO_SESION` | Cualquiera con acceso al repo (el del curso y los forks son públicos) puede borrar cualquier comentario con la cabecera `x-clave-moderacion`. Nadie lo ha notado todavía. | 2 (`:25` y `:351`), más sacarla a `start/env.ts` | **No**: la clave ya está en el historial de git; hay que rotarla, no revertir. | A ninguno. |
| 4 | `estado` es texto libre y la lectura y el recuento lo comparan de formas distintas (daño M) ✔ | Migración `…_create_comentarios_table.ts:18` (`string('estado')` sin CHECK); detalle `routes.ts:153` `estado = 'aprobado'`; recuentos `routes.ts:75-76` y `:223` `estado <> 'pendiente'` | El post 1 anuncia **4 comentarios** en el listado y muestra **2** en el detalle: `Aprobado` (id 3) y `ok` (id 4) cuentan pero no se ven. El comentario 9 (`Aprobado`, post 6) está igual. Lo nota cualquier lector, y el comentarista cree que lo han ocultado. | 7: 3 consultas (`:75`, `:153`, `:223`) + 3 filas del seeder (ids 3, 4, 9) + 1 migración | Las consultas, sí. La normalización de datos **no**: pasar `ok` a `aprobado` pierde el valor original, y no hay forma de saber qué significó. | **Desbloquea el 8** (los dos recuentos del front solo pueden coincidir cuando el servidor sea coherente). |

## Nivel 3: dependen de la arquitectura o de una decisión

| # | Qué es | Dónde | Qué se rompe y quién lo nota | Sitios | ¿Revert? | ¿Bloquea / desbloquea? |
|---|---|---|---|---|---|---|
| 5 | **Fondo.** Se borra y se edita «autenticando» con un correo que manda el cliente (daño A) | `routes.ts:350-353` (`request.input('autor_email')` frente a `comentario.autor_email`) y `:378-379` | Quien conoce el correo de un comentarista (el 1 lo expone) borra o edita su comentario sin ninguna otra prueba. Nadie lo ha explotado todavía que se sepa. | 2 (`:353`, `:379`) más decidir el mecanismo (token de edición al crear, o usuario autenticado) | Sí en el código, pero cambia el contrato de la API para los clientes ya hechos. | **Bloqueado por el 2.** Al resolverlo, **desbloquea el 6**. |
| 6 | `DELETE` y `PATCH` aplican reglas distintas sobre el mismo recurso | `routes.ts:351-356` (admite moderador, compara en minúsculas y recortando) frente a `:379` (sin moderador, compara el correo literal, exige `pendiente`) | Un autor que escribió su correo con otras mayúsculas puede borrar y no editar. Un moderador puede borrar y no editar. Lo notaría el primer autor que lo intente. | 2 (`:351-356`, `:379`) | Sí | **Bloqueado por el 5**: no tiene sentido igualar reglas que se van a reemplazar. |
| 7 | Cuatro formas de error en el `POST`, una de ellas con `200` para un fallo | `routes.ts:311` (`400 {error}`), `:314` (`422 {message}`), `:317` (`400 {errores}`), `:320` (`200 {ok:false, motivo}`) | Un cliente que mire solo el código HTTP da por bueno un comentario demasiado corto. La web lo parchea leyendo tres claves (`Comentarios.jsx:44`: `d.error \|\| d.message \|\| d.motivo`). | 5 (4 respuestas + `Comentarios.jsx:44`) | Sí, pero cambia el contrato: según `CLAUDE.md`, se caracteriza primero y la corrección es otra tarea con su decisión. | **Bloqueado por el 2.** |
| 8 | La web guarda dos recuentos independientes y al comentar solo sube uno | `Comentarios.jsx:11` y `:39` (`setTotal(total + 1)`), `:54`; `DetallePost.jsx:30`, `:38` y `:71` | Tras enviar, el pie dice «N+1 comentarios» y la cabecera sigue en «N». El +1 cuenta además un comentario `pendiente` que no se muestra. Lo nota cualquier lector que comente. | 2 componentes (`Comentarios.jsx`, `DetallePost.jsx`) | Sí | **Bloqueado por el 4**: mientras el servidor cuente distinto, un front «arreglado» seguiría discrepando. |
| 9 | **Fondo del 1.** Todas las respuestas de comentarios son la fila cruda de la base de datos | `routes.ts:152-155` (`select *`), `:329-333` (`select * … limit 1`) y `:389-392` | Una columna nueva en la tabla (`ip`, `notas_moderacion`) saldría a la web sin que nadie lo decida. Nadie todavía. | 3 respuestas (`:152`, `:333`, `:392`) + crear transformer, validador, servicio y repositorio (arquitectura de `CLAUDE.md`) | Sí | **Bloqueado por el 2.** Cierra el 1 de forma definitiva. |
| 10 | `padre_id` se acepta sin comprobar que existe ni que es del mismo post, y borrar un padre deja huérfanas a sus respuestas | `routes.ts:308` y `:326` (se inserta tal cual); `:359` (`delete` sin tocar hijos); migración `:20` (`integer('padre_id')` sin clave foránea) | Una respuesta apuntando a otro post o a un id inexistente queda guardada. Un hijo huérfano deja de mostrarse (la web solo pinta raíces y sus hijos) pero sigue contando. Nadie todavía (solo hay una respuesta en los datos). | 3 (`:308/:326`, `:359`, migración `:20`) | El código, sí. Los datos huérfanos que ya existan, no. | **Bloqueado por el 2.** |
| 11 | La respuesta del `POST` es «el último comentario de la tabla», no el que se acaba de insertar | `routes.ts:329-331` `select * from comentarios order by id desc limit 1` | Si otra petición inserta entre el `insert` y el `select`, la persona recibe el comentario de otra, con su correo. Nadie todavía; solo lectura, **no se reprodujo**. | 1 (`:329-331`) | Sí | A ninguno. |
| 12 | Para pintar los comentarios, la web descarga el post entero y la API no tiene ruta de lectura de comentarios | `Comentarios.jsx:19` (`fetch(API + '/posts/' …)` «solo para sacar los comentarios») y `DetallePost.jsx:34` (la misma petición, otra vez) | Dos descargas idénticas del post por visita. Nadie lo nota con 9 comentarios. | 2 (`Comentarios.jsx:19`, `DetallePost.jsx:34`) + una ruta `GET /posts/:slug/comentarios` | Sí | **Bloqueado por el 9** (conviene que la ruta nueva nazca ya con transformer). |

## Fuera de la tabla: propuestas sin medir

Nadie ha medido todavía estos puntos. Esto es lo que habría que medir:

- **Tope de longitud del cuerpo y límite de envíos** (`routes.ts:319` solo comprueba mínimo de 5). Medir: cuántos comentarios de spam llegan (el id 7 de la semilla es uno) y de qué tamaño.
- **Índice o clave foránea en `post_id`** (migración, comentario de `:6`). Medir: tiempo del listado `GET /posts` (`routes.ts:75`) con miles de comentarios, que hoy lanza una subconsulta por post.
- **Paginar comentarios.** Medir: el máximo real de comentarios por post.
- **Ruta de moderación.** No existe ninguna ruta que ponga un comentario en `aprobado` (`routes.ts` solo tiene `POST`, `DELETE` y un `PATCH` que solo cambia el cuerpo). Lo que habría que medir es cómo se aprueban hoy: si es a mano en la base de datos, o si falta una función de producto.

---

# Parte B: las tres líneas

1. **Hallazgos devueltos y comprobados.** El agente devolvió 12 hallazgos. Comprobados abriendo el archivo por mí: 12 de 12, y lo que comprobé fue que cada línea citada dice lo que la tabla le atribuye. No comprobé las afirmaciones que dependen de algo fuera del código (que los repos sean públicos, el efecto de la condición de carrera del 11, el contenido del comentario 7). Una segunda lectura del código, hecha por un agente distinto, confirmó los 12, y los hallazgos 1 y 4 se contrastaron además con `GET` a la API en marcha.
2. **Hallazgo del que no supe decidir la prioridad: el 5.** Es de los más graves (con el correo que expone el hallazgo 1 se borra o edita el comentario de cualquiera), pero no se puede arreglar hasta decidir token de edición o cuentas, y esa decisión es de producto.
3. **Algo que el agente afirmó y no pude verificar:** la condición de carrera del hallazgo 11, donde el `POST` devuelve «el último comentario de la tabla» y podría entregar el de otra persona. El código lo permite (`routes.ts:329-331`), pero no se reprodujo, así que no puedo confirmarla ni descartarla.
