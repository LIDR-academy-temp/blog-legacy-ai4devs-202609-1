# Auditoría priorizada — rebanada de COMENTARIOS

Auditoría de solo lectura de todo lo que toca comentarios: rutas (`backend/start/routes.ts`), base de
datos (migración, semilla, `database/schema.ts`) y frontend (`Comentarios.jsx`, `DetallePost.jsx`).
No se ha arreglado nada. El `#n` de cada fila es el número que tenía el hallazgo en la auditoría
original; se mantiene para poder rastrearlo.

Las casillas vacías están vacías a propósito: no se pueden responder leyendo el código de este
repositorio.

## Cómo se ha ordenado

Se descarta la criticidad original. El orden sale de dos claves, aplicadas en este orden:

1. **Precedencia (orden topológico).** Si el arreglo de A abarata el de B, A va antes. Las aristas
   salen de la columna «Bloquea / desbloquea». Cuando dos hallazgos solo «comparten bloque» o «se
   arreglan juntos», no hay arista. El nivel de cada hallazgo es la longitud del camino más largo
   desde una raíz.
2. **Daño ÷ radio, dentro de cada nivel.** El daño no es un número, así que se toma una escala
   ordinal según quién lo nota, sacada de la columna de daño:
   **A = 3**: terceros pierden datos o privacidad.
   **B = 2**: el lector o quien comenta ve algo mal.
   **C = 1**: solo lo nota quien desarrolla u opera, o nadie.
   El radio es el número de sitios contados en la columna de radio. Si el daño o el radio están en
   blanco, la división no se puede hacer: la fila va al final de su nivel, en el orden original.

Además se aplican dos decisiones tomadas fuera de esta auditoría:

- El hallazgo #1 se parte en **contención** (#1-C) y **arreglo** (#1-F). El arreglo espera al #6,
  la normalización del modelo.
- El hallazgo #19 (N+1) sale de la tabla porque es una propuesta sin medir. Está en un apartado
  aparte, más abajo.

| Orden | Hallazgo | Nivel | Daño | Radio | Daño ÷ radio |
|---|---|---|---|---|---|
| 1 | #16 | 0 | C (1) | 1 | 1,00 |
| 2 | #1-C | 1 | A (3) | 2 | 1,50 |
| 3 | #15 | 1 | C (1) | 1 | 1,00 |
| 4 | #3 | 1 | A (3) | 4 | 0,75 |
| 5 | #8 | 1 | B (2) | 3 | 0,67 |
| 6 | #20 | 1 | C (1) | 2 | 0,50 |
| 7 | #24 | 1 | C (1) | 3 | 0,33 |
| 8 | #6 | 1 | B (2) | 9 | 0,22 |
| 9 | #23 | 1 | C (1) | 6 | 0,17 |
| 10 | #17 | 1 | C (1) | 10 | 0,10 |
| 11 | #9 | 1 | | | |
| 12 | #22 | 1 | | 2 | |
| 13 | #25 | 1 | | 3 | |
| 14 | #2 | 2 | A (3) | 1 | 3,00 |
| 15 | #21 | 2 | B (2) | 1 | 2,00 |
| 16 | #10 | 2 | B (2) | 2 | 1,00 |
| 17 | #18 | 2 | B (2) | 2 | 1,00 |
| 18 | #5 | 2 | B (2) | 3 | 0,67 |
| 19 | #13 | 2 | C (1) | 2 | 0,50 |
| 20 | #11 | 2 | B (2) | 6 | 0,33 |
| 21 | #12 | 3 | B (2) | 1 | 2,00 |
| 22 | #4 | 3 | A (3) | 2 | 1,50 |
| 23 | #7 | 3 | B (2) | 2 | 1,00 |
| 24 | #14 | 3 | B (2) | 7 | 0,29 |
| 25 | #1-F | 3 | A (3) | | |

Precedencias usadas (A → B significa «A abarata B»):

- #16 → todos los demás.
- #1-C → #2.
- #6 → #5, #1-F.
- #8 → #18.
- #17 → #1-F, #4, #7, #10, #11, #13.
- #13 → #1-F, #4.
- #11 → #7, #12.
- #5 → #14.
- #20 → #21.

## Tabla

| # | Qué es | Dónde está | Qué se rompe y quién lo nota | Cuántos sitios hay que tocar | ¿Lo deshace un revert? | Bloquea / desbloquea |
|---|---|---|---|---|---|---|
| 1 | **#16** El test solo cubre el caso que funciona | `backend/tests/functional/comentarios.spec.ts:41-42` | Cualquier refactor puede romper los 404, la validación, la ocultación de pendientes o la filtración del correo sin que nada falle. Lo nota quien refactorice después. | 1 archivo: `backend/tests/functional/comentarios.spec.ts`. Las aserciones flojas están en las líneas 41-42. | Limpia. | Abarata todos los demás. `CLAUDE.md` exige además tests de caracterización antes del 17. |
| 2 | **#1-C (contención)** La respuesta pública devuelve la fila cruda y con ella sale el correo del autor en cada post y el de quien comenta en cada comentario. Contención: quitar esos campos de la respuesta. | `backend/start/routes.ts:152-155` (el `select *`), `:171` (lo que se envía) | Cualquier visitante o robot que pida `GET /posts/:slug` recibe el correo de cada comentarista aprobado. En la web no se nota, porque `Comentarios.jsx` no pinta el correo; solo lo ve quien mire la respuesta de la API. | 2 sitios: `backend/start/routes.ts:152-155` (el `select *`) y `backend/start/routes.ts:171` (lo que se envía). El frontend no lee `autor_email`, así que no hay que tocarlo. | Deshacer el arreglo es un revert limpio, porque no toca datos. Los correos que ya se hayan servido no se pueden retirar. | Arreglarlo abarata el hallazgo 2, porque deja de regalar la credencial que permite borrar. |
| 3 | **#15** `post_id` sin clave foránea ni índice | `backend/database/migrations/1769000000005_create_comentarios_table.ts:14` | Cuando se borre un post quedarán comentarios huérfanos. Cada recuento recorre la tabla entera; no sé cuánto cuesta eso con datos reales. | 1 migración nueva sobre `1769000000005_create_comentarios_table.ts:14`. En la configuración de base de datos no encuentro ningún `foreign_keys`/`pragma`. | No es limpia: reconstruir la tabla en SQLite toca datos. En la semilla todos los `post_id` (1, 2, 4 y 6) apuntan a posts que existen; no sé qué pasa en datos reales. | Hacerlo con el 8 abarata ambos. |
| 4 | **#3** Clave de moderación fija en el código | `backend/start/routes.ts:25` | Quien tenga acceso al repositorio puede borrar cualquier comentario enviando `x-clave-moderacion`. No sé quién puede leer el repo: el código no dice si es público. | 2 sitios existentes, `backend/start/routes.ts:25` y `:351`. Además habría que añadir líneas nuevas en `backend/start/env.ts` y en `backend/.env.example`. | Deshacer el arreglo es limpio, pero la clave queda en el historial de git (está desde el commit `e0e0943 initial import`), así que cambiarla de sitio no basta: habría que cambiar también su valor. | Comparte bloque con el 2 y el 10. |
| 5 | **#8** `padre_id` no se valida | `backend/start/routes.ts:308` | Una respuesta a un padre inexistente, de otro post o pendiente no se muestra nunca (`Comentarios.jsx:50,64`). La persona que respondió la ve desaparecer. | 2 sitios en rutas, `backend/start/routes.ts:308` y `:326`, más una migración nueva para la clave foránea, en paralelo a la de `1769000000005_...:20`. | No es limpia del todo. En SQLite, añadir una clave foránea exige reconstruir la tabla, y las respuestas huérfanas que ya existan se quedan. En la semilla no hay ninguna (la del id 2 apunta al id 1 del mismo post). No sé si hay alguna en datos reales. | Hacerlo en la misma migración que el 15 abarata ambos. Abarata el 18. |
| 6 | **#20** El componente vuelve a pedir el post entero solo para sacar los comentarios | `frontend/src/componentes/Comentarios.jsx:19` | Cada vez que alguien abre un post, la página pide el detalle dos veces. | 2 sitios: `Comentarios.jsx:17-26` y `DetallePost.jsx:123` (pasar los comentarios como props). | Limpia. | Se arregla en el mismo cambio que el 14. Abarata el 21 (el 21 desaparece si se hace el 20). |
| 7 | **#24** El formulario no tiene `type="email"` ni `required` | `frontend/src/componentes/Comentarios.jsx:79` | Todos los errores de formulario tienen que ir y volver al servidor. | 3 sitios: `Comentarios.jsx:78`, `:79` y `:80-85`. | Limpia. | Mitiga el 12 en el navegador, pero no lo sustituye. |
| 8 | **#6** `estado` es texto libre, sin CHECK ni enum | `backend/database/migrations/1769000000005_create_comentarios_table.ts:18`; `blog_seeder.ts:510` | En la semilla hay 3 comentarios aprobados que no se ven: los ids 3, 4 y 9. Lo notan sus autores. | Para la base de datos, 1 migración nueva más `backend/database/migrations/1769000000005_create_comentarios_table.ts:18`. En la semilla, 3 filas: `blog_seeder.ts:510`, `:522` y `:575`. En las rutas, 4 literales de estado: `routes.ts:75-76`, `:153`, `:223` y `:379`. | No es limpia. Normalizar `'Aprobado'` y `'ok'` reescribe filas guardadas, y un revert del código no las devuelve a su valor original. No sé qué otros valores de `estado` hay en datos reales; solo veo la semilla. | Abarata el 5. Desbloquea #1-F (el DTO espera al modelo normalizado). |
| 9 | **#23** La URL de la API está copiada en cada componente | `frontend/src/componentes/Comentarios.jsx:4` | Cambiar de entorno obliga a editar el código. Lo nota quien despliegue. | 6 sitios: `App.jsx:7`, `BarraLateral.jsx:4`, `ListaPosts.jsx:4`, `DetallePost.jsx:7`, `PostsRelacionados.jsx:4` y `Comentarios.jsx:4`. | Limpia. | |
| 10 | **#17** Toda la lógica está en el archivo de rutas | `backend/start/routes.ts:295-393` | Cada regla se reescribe a mano en cada ruta, que es de donde salen el 7, el 10 y el 11. Lo nota quien mantiene el código. | 3 manejadores: `backend/start/routes.ts:295-334`, `:339-361` y `:366-393`. Además, archivos nuevos (controlador, validador, servicio, repositorio, transformer y modelo) y el alias `#repositories/*` en `backend/package.json`. | Limpia, porque es solo código. | Abarata el 1, 4, 7, 10, 11 y 13. Requiere hacer antes el 16. |
| 11 | **#9** Comentar es anónimo y no tiene límite de envíos ni antispam | `backend/start/routes.ts:295` | La cola de pendientes se llena. En el código no existe ningún endpoint para aprobar comentarios, así que no puedo decir quién lo nota. | | Los comentarios de spam ya guardados se quedan en la tabla (el seeder trae uno en `blog_seeder.ts:548-556`). | |
| 12 | **#22** Las claves de React son el índice | `frontend/src/componentes/Comentarios.jsx:57` | | 2 sitios: `Comentarios.jsx:57` y `:66`. | Limpia. | |
| 13 | **#25** La fecha puede salir con el día equivocado | `backend/start/routes.ts:323` | | 3 sitios: `backend/start/routes.ts:323` y `Comentarios.jsx:59` y `:68`. | Cambiar cómo se guarda la fecha obliga a convertir las filas existentes, y no hay forma de saber en qué zona horaria están: la semilla las guarda sin zona. | |
| 14 | **#2** Cualquiera puede borrar cualquier comentario | `backend/start/routes.ts:352-353` | Desaparecen comentarios legítimos. Lo nota el autor del comentario y quien lee el post. | 1 bloque: `backend/start/routes.ts:349-355`, con la lectura del correo en la 350, la comparación en la 352-353 y la decisión en la 355. | Deshacer el arreglo es limpio. Lo que ya se haya borrado no se recupera, porque es un `delete` real (`routes.ts:359`), sin borrado lógico ni registro. | El 1 lo abarata. Comparte bloque con el 3 (línea 351) y con el 10, así que conviene arreglar los tres juntos. |
| 15 | **#21** Los errores de carga se ignoran | `frontend/src/componentes/Comentarios.jsx:25` | Si la API falla, quien lee ve "0 comentarios". | 1 sitio: `frontend/src/componentes/Comentarios.jsx:25`. | Limpia. | Desaparece si se hace el 20. |
| 16 | **#10** Borrar y editar tienen reglas de permiso distintas | `backend/start/routes.ts:379` | Un autor que escribe su correo con otras mayúsculas puede borrar pero no editar. Un moderador no puede editar. Un comentario aprobado no se puede editar. Si alguna de estas diferencias es intencionada no se puede saber leyendo el código. | 2 sitios: `backend/start/routes.ts:349-355` y `:378-381`. | Limpia. | Comparte bloque con el 2 y el 3. El 17 lo abarata, porque deja una sola regla de permisos. |
| 17 | **#18** Las respuestas a respuestas no se muestran | `frontend/src/componentes/Comentarios.jsx:50` | Esas respuestas desaparecen de la página. En la semilla no hay ningún caso. | 2 sitios: `frontend/src/componentes/Comentarios.jsx:50` y `:63-64`. | Limpia. | El 8 lo abarata. |
| 18 | **#5** El recuento y el listado no coinciden | `backend/start/routes.ts:75-76` frente a `:153` | El número anunciado no cuadra con los comentarios visibles. En la semilla, el post 1 se anuncia con 4 comentarios en el listado (`ListaPosts.jsx:57`) y muestra 2 en el detalle. | 3 sitios: `backend/start/routes.ts:75-76`, `:153` y `:223`. | Limpia, porque solo cambia consultas. | Arreglarlo antes que el 6 lo encarece: si el recuento pasa a contar solo `'aprobado'`, los comentarios guardados como `'Aprobado'` y `'ok'` dejan de contarse también. Comparte la línea 223 con el 19. El 14 depende de qué número se decida mostrar. |
| 19 | **#13** Crear y editar devuelven la fila tal cual | `backend/start/routes.ts:333`, `:392` | Las respuestas incluyen el correo, `estado` y `post_id`. No hay ningún consumidor en el frontend que lo note. En concreto, la fila cruda la devuelven el POST (`routes.ts:333`) y el PATCH (`routes.ts:392`); el DELETE responde solo `{borrado: true}` (`routes.ts:360`). | 2 sitios: `backend/start/routes.ts:333` y `:392`. | Limpia. | Abarata el 1 y el 4 si el transformer es compartido. El 17 lo incluye. |
| 20 | **#11** Los errores de validación no siguen un formato | `backend/start/routes.ts:310-321` | Cada cliente tiene que adivinar el formato de cada error. Un cuerpo corto devuelve 200, así que parece que el envío funcionó. | 4 respuestas en `backend/start/routes.ts:311`, `:314`, `:317` y `:320`, más el cliente que las lee en `Comentarios.jsx:44` y el centralizador de errores en `backend/app/exceptions/handler.ts`, que habría que tocar en un lugar todavía sin decidir. No sé si hay clientes de la API fuera de este repo. | Limpia. | Encarece el 12, porque obliga a cambiarlo a la vez. El 17 lo abarata: un validador de VineJS más el handler dan un único formato. |
| 21 | **#12** El frontend no muestra el error `errores[]` y da un aviso genérico | `frontend/src/componentes/Comentarios.jsx:44` | Con un correo sin `@`, quien comenta ve "No se ha podido enviar" sin saber por qué. | 1 sitio: `frontend/src/componentes/Comentarios.jsx:44`. | Limpia. | Depende del 11. Arreglarlo antes es trabajo que se tira. |
| 22 | **#4** El POST devuelve el último comentario de la tabla, no el que acaba de crear | `backend/start/routes.ts:329-331` | Con dos envíos a la vez, uno recibe el comentario del otro, con su correo y su `estado`. La persona no lo nota, porque el frontend solo mira si existe `d.comentario` (`Comentarios.jsx:37`). | 2 sitios: `backend/start/routes.ts:329-331` (la relectura) y `:333` (la respuesta). | Limpia. El insert de las líneas 324-327 guarda bien los datos; el error solo está en lo que se devuelve. | El 17 lo abarata (un repositorio que devuelva el id insertado) y el 13 también (con un transformer, la respuesta ya no lleva el correo). |
| 23 | **#7** Editar se salta la validación de crear | `backend/start/routes.ts:384` | Un comentario pendiente puede quedarse con 1 carácter o con un texto sin límite de longitud. Lo nota quien modera. | 2 sitios: `backend/start/routes.ts:383-386` (la edición) y `:319` (la regla de crear que habría que compartir). | Deshacer el arreglo es limpio. Los comentarios que ya se hayan editado por debajo del mínimo se quedan así; no sé si existe alguno. | El 17 lo abarata con un único validador. El 11 decide primero qué código de error debe dar. |
| 24 | **#14** Dos contadores que se desincronizan | `frontend/src/componentes/DetallePost.jsx:30`; `Comentarios.jsx:11` | Quien lee ve dos números distintos en la misma página en cuanto alguien comenta. | 7 sitios: `DetallePost.jsx:30`, `:38` y `:71`, y `Comentarios.jsx:11`, `:23`, `:39` y `:54`. | Limpia. | Se arregla en el mismo cambio que el 20, subiendo el estado a `DetallePost`. Depende del 5 para saber qué número enseñar. |
| 25 | **#1-F (arreglo)** La respuesta pública devuelve la fila cruda y con ella sale el correo del autor en cada post y el de quien comenta en cada comentario. Arreglo: el DTO que decide qué campos salen. | `backend/start/routes.ts:152-155`, `:171` | Cualquier visitante o robot que pida `GET /posts/:slug` recibe el correo de cada comentarista aprobado. En la web no se nota, porque `Comentarios.jsx` no pinta el correo; solo lo ve quien mire la respuesta de la API. | | | Espera al 6 (decisión: el DTO espera a que el modelo esté normalizado para no escribirse dos veces). El 13 y el 17 lo abaratan: con un único transformer, este arreglo sale casi gratis. |

**Nota sobre #1-C y #1-F.** La descripción de la decisión incluye el correo del autor de cada post.
Ese campo (`posts.autor_email`, servido por el `select *` de `routes.ts:111` y por `routes.ts:167`)
pertenece a la rebanada de posts y no estaba en esta auditoría. No se añade como hallazgo. El radio
de #1-C es el que se contó para el correo de quien comenta.

## Fuera de la tabla: propuestas sin medir

### #19 Una consulta extra por cada post relacionado para contar sus comentarios

- **Dónde:** `backend/start/routes.ts:220-232`, con la consulta en la 222-225.
- **Por qué sale de la tabla:** el defecto es de rendimiento y su daño no está medido («No sé si se
  nota en la práctica: no hay ninguna medición»). Arreglarlo es una propuesta, no la corrección de un
  defecto comprobable.
- **Qué hay que medir para que vuelva a entrar:**
  1. Cuánto tarda hoy `GET /posts/:slug` con un post de veinte comentarios.
  2. Qué parte de ese tiempo se va en la consulta.
- **Relación con la tabla:** comparte la línea 223 con el #5. Si vuelve a entrar, se arregla junto al
  #5.

## Casillas en blanco

| Hallazgo | Casillas en blanco |
|---|---|
| #9 | radio, bloquea/desbloquea |
| #22 | daño, bloquea/desbloquea |
| #23 | bloquea/desbloquea |
| #25 | daño, bloquea/desbloquea |
| #1-F | radio, revert |

Estas partes quedaron sin respuesta dentro de casillas que sí están rellenas:

- **#1:** quién ha recibido ya los correos.
- **#3:** si el repositorio es público.
- **#6, #8 y #15:** qué hay en los datos reales.
- **#11:** si hay clientes de la API fuera de este repo.
- **#10:** si las diferencias son intencionadas.
