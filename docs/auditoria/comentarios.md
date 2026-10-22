# Feature de comentarios

## Auditoría

Alcance: crear, editar, borrar y listar comentarios, en las tres capas (API, tabla y web). Nada más.

**Cómo se ordena la tabla**

- **Primero la precedencia.** Lo que desbloquea o abarata a otro hallazgo va antes. Hay cinco niveles:
  1. Desbloquea todo lo demás.
  2. Desbloquea o abarata a otros hallazgos.
  3. No depende de nadie.
  4. Lo abarata el nivel 2.
  5. Lo desbloquea un hallazgo del nivel 4.
- **Dentro de cada nivel, daño dividido por radio.**
  - Daño: escala de 1 a 5, criterio del auditor.
  - Radio: los sitios que hay que tocar, contados.
- **Fila partida.** El hallazgo 3 tiene el daño más alto y la precedencia más baja a la vez, así que son dos filas: 3a, la contención que corta el daño hoy, y 3b, el arreglo de fondo que espera su turno.

**Cómo leer la casilla «Dónde está»**

- Cada referencia lleva la ruta completa del archivo, aunque se repita: `ruta:líneas`.
- `backend/start/routes.ts:295-393` es un rango: de la línea 295 a la 393 de ese archivo, ambas incluidas.
- `backend/start/routes.ts:75` es una sola línea.
- `frontend/src/componentes/Comentarios.jsx:50,63-65` mezcla una línea suelta y un rango del mismo archivo, separados por coma.

Los recuentos de la semilla se han leído, no ejecutado.

| # | Nivel | Qué es | Dónde está | Qué se rompe y quién lo nota | Cuántos sitios | ¿Se deshace con un revert? | ¿Bloquea o desbloquea a otro? | Daño / radio |
|---|---|---|---|---|---|---|---|---|
| 1 | 1 | Solo hay un test para toda la feature: el camino feliz de crear un comentario. | `backend/tests/functional/comentarios.spec.ts:16-45` | Cualquier cambio puede romper PATCH, DELETE o el listado sin que nada avise. Lo nota quien refactorice. | 1 archivo, más casos nuevos para 4 endpoints | Sí, solo añade tests. | Desbloquea del 2 al 13: CLAUDE.md exige caracterizar antes de tocar. | n/a |
| 6 | 2 | `estado` es texto libre y las tres consultas lo comparan de forma distinta. | `backend/start/routes.ts:75` y `backend/start/routes.ts:223` (`<> 'pendiente'`), `backend/start/routes.ts:153` (`= 'aprobado'`); `backend/database/seeders/blog_seeder.ts:510` y `backend/database/seeders/blog_seeder.ts:575` (`'Aprobado'`, ids 3 y 9), `backend/database/seeders/blog_seeder.ts:522` (`'ok'`, id 4) | En el post 1 de la semilla, la lista cuenta 4 comentarios y el detalle muestra 2. Lo notan los lectores. | 5: 3 consultas, migración y semilla | Código sí. Datos no: normalizar los valores es irreversible. | Desbloquea el 7. | 3/5 = 0,6 |
| 2 | 2 | Toda la lógica está en la ruta, sin capas ni transformer. | `backend/start/routes.ts:295-393` (3 handlers) y las lecturas de `backend/start/routes.ts:75`, `backend/start/routes.ts:152` y `backend/start/routes.ts:222` | Nadie todavía. Encarece 3b y del 8 al 12, que se repetirían handler a handler. | 6 bloques en 1 archivo | Sí, si se hace en commits pequeños con la suite en verde. | Lo desbloquea el 1. Abarata 3b y del 8 al 12. | 3/6 = 0,5 |
| 5 | 3 | POST devuelve el último comentario de la tabla, no el que acaba de insertar. | `backend/start/routes.ts:329-331` | Con dos envíos simultáneos, cada autor puede recibir el comentario y el correo del otro. | 1 | Sí. | A ninguno. | 3/1 = 3,0 |
| 4 | 3 | La clave de moderación está escrita en el código. | `backend/start/routes.ts:25` y `backend/start/routes.ts:349-351` | Quien lea el repo borra cualquier comentario con una cabecera. | 2 | El código sí. La clave no: queda en el historial de git y hay que rotarla. | A ninguno. | 4/2 = 2,0 |
| 3a | 3 | **Contención:** dejar de devolver `autor_email` en las respuestas de comentarios. | `backend/start/routes.ts:152-153` (sale en `backend/start/routes.ts:171`), `backend/start/routes.ts:329-333` y `backend/start/routes.ts:389-392` | Hoy cualquier lector obtiene el correo de todos los que comentan. Ese correo es la única credencial para borrar (`backend/start/routes.ts:352`) y editar (`backend/start/routes.ts:379`). | 3 | El código sí. Los correos ya expuestos no se recuperan. | Lo desbloquea el 1, con su aserción negativa. Precede a 3b. | 5/3 = 1,67 |
| 7 | 3 | El recuento de comentarios está duplicado en la web. | `frontend/src/componentes/DetallePost.jsx:30,38,71` y `frontend/src/componentes/Comentarios.jsx:11,23,39,54` | Tras comentar, cabecera y sección muestran números distintos. Un comentario pendiente suma +1 aunque no se vea. | 2 archivos | Sí. | Lo desbloquea el 6. | 2/2 = 1,0 |
| 3b | 4 | **Arreglo de fondo:** autorizar editar y borrar con algo que no sea un correo público. | `backend/start/routes.ts:339-361` y `backend/start/routes.ts:366-393` | Es el origen real de 3a: mientras la autoría dependa del correo, el riesgo sigue aunque no se devuelva. | A concretar: depende del mecanismo, que está por decidir | A concretar: depende del mecanismo, que está por decidir. | Lo abarata el 2 y va después de 3a. Desbloquea el 13. | Daño 5, radio a concretar |
| 8 | 4 | DELETE borra un comentario raíz y deja sus respuestas huérfanas. | `backend/start/routes.ts:359`; `backend/database/migrations/1769000000005_create_comentarios_table.ts:20` (sin FK); `frontend/src/componentes/Comentarios.jsx:50,63-65` | Los lectores pierden respuestas aprobadas sin aviso. | 3 | El código sí. Lo borrado no. | Lo abarata el 2. | 3/3 = 1,0 |
| 9 | 4 | `padre_id` no se valida: puede apuntar a otro post o a un id que no existe. | `backend/start/routes.ts:308` y `backend/start/routes.ts:326` | Esa respuesta nunca se ve, ni siquiera cuando se aprueba. Lo nota quien comenta. | 2 | El código sí. Las filas ya insertadas no. | Lo abarata el 2. | 2/2 = 1,0 |
| 12 | 4 | PATCH acepta cuerpos de 1 carácter y POST exige 5. | `backend/start/routes.ts:384` frente a `backend/start/routes.ts:319` | Se puede editar un comentario hasta dejarlo casi vacío. Lo nota quien edita. | 1 | Sí. | Lo abarata el 2. | 1/1 = 1,0 |
| 11 | 4 | Las reglas de autoría de DELETE y PATCH no coinciden. | `backend/start/routes.ts:352-353` frente a `backend/start/routes.ts:379` | DELETE ignora mayúsculas y admite moderador. PATCH compara exacto y exige `pendiente`. Un autor puede borrar lo que no puede editar. | 2 | Sí. | Lo abarata el 2. | 2/3 = 0,67 |
| 10 | 4 | Hay cuatro formas distintas de error en POST. | `backend/start/routes.ts:311`, `backend/start/routes.ts:314`, `backend/start/routes.ts:317`, `backend/start/routes.ts:320` (este último es `200 {ok:false}`) y `frontend/src/componentes/Comentarios.jsx:44` | Cada cliente nuevo de la API tiene que adivinar el formato. La web lo compensa con `d.error \|\| d.message \|\| d.motivo`. | 5 | Sí, pero cambia el contrato: hay que caracterizar primero. | Lo abarata el 2, porque entra un validador. | 2/5 = 0,4 |
| 13 | 5 | La web no ofrece editar ni borrar comentarios, aunque la API sí. | `frontend/src/componentes/Comentarios.jsx:19` y `frontend/src/componentes/Comentarios.jsx:30-31`: las únicas llamadas son un GET y un POST; no hay PATCH ni DELETE en `frontend/src` | Nadie todavía. Quien comenta no puede corregir ni retirar su comentario desde la web. | 1 archivo | Sí. | Lo desbloquea 3b: sin mecanismo de autorización no hay qué enviar desde la web. | 2/1 = 2,0 |

## Fuera de la tabla: propuestas sin medir

| Propuesta | Dónde está | Qué habría que medir |
|---|---|---|
| Rendimiento del recuento de comentarios | `backend/start/routes.ts:75` (subconsulta por fila), `backend/start/routes.ts:217-232` (una consulta por relacionado); `backend/database/migrations/1769000000005_create_comentarios_table.ts:14` (`post_id` sin índice) | `EXPLAIN QUERY PLAN` y tiempo de `GET /posts` y de `/relacionados` con unos 10.000 comentarios |
| La web pide el post entero solo para sacar los comentarios | `frontend/src/componentes/Comentarios.jsx:19`; `frontend/src/componentes/DetallePost.jsx:34` ya lo había pedido | Bytes y latencia de la segunda petición |
| Sin máximo de longitud ni anti-spam | `backend/start/routes.ts:319` solo pone un mínimo; la semilla ya trae spam en los ids 5 y 7 | Cuántos pendientes son spam y cuál es el cuerpo más largo real |

## Observaciones

- Hallazgos devueltos por el agente: 13. Comprobados por mí: 5.
- No supe decidir la prioridad del hallazgo 10: tiene el cociente daño/radio más bajo, pero cambia el contrato.
- El hallazgo 5 (POST devuelve el último comentario de la tabla) no pude verificarlo en cuanto a la concurrencia: no hubo tiempo para probarlo mientras se redactaba el ejercicio.
