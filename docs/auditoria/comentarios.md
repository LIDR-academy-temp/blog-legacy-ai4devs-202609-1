# Auditoría priorizada — comentarios

## Parte A: auditoría

| Qué es | Dónde está (archivo y líneas) | Qué se rompe y quién lo nota | Sitios que hay que tocar | ¿Se deshace con un revert? | ¿Qué hallazgo bloquea o desbloquea? |
|---|---|---|---:|---|---|
| C2 — DELETE permite borrar un comentario usando el email de autoría como comprobación. | `backend/start/routes.ts:348-359` | Quien conozca el email puede borrar el comentario; lo notan quien lo escribió y quienes leen el post. | 1 ruta: DELETE /comentarios/:id | Sí para el cambio de código; un comentario borrado no se recupera con el revert. | C8, si una política común de autoría resuelve ambos. |
| C4 — El detalle del post devuelve la fila completa de cada comentario. | `backend/start/routes.ts:152-155, 166-171` | La respuesta incluye campos del comentario, entre ellos el email del autor; afecta a quienes comentan. | 1 ruta: GET /posts/:slug | Sí para el cambio de código; un correo ya copiado no se puede retirar. | Ninguno demostrado. |
| C8 — DELETE y PATCH aplican comprobaciones de autoría distintas. | `backend/start/routes.ts:348-355, 375-380` | Diferencias de mayúsculas o espacios pueden permitir borrar y bloquear la edición; la clave de moderación tampoco permite editar. | 2 rutas: DELETE y PATCH | Sí; son comprobaciones de código. |  |

## Hipótesis por medir, fuera de la tabla

- C3: comprobar si dos POST concurrentes pueden hacer que una respuesta devuelva el comentario de otra persona. Medir enviando POST en paralelo contra una base de prueba y comparar el ID insertado con el ID devuelto. No se ha medido.

## Parte B: las tres líneas

1. Hallazgos devueltos por el agente: 14; comprobados por mí abriendo el archivo: 3.
2. Hallazgo cuya prioridad no supe decidir y por qué: Me costó ordenar C2 y C4: quitar autor_email del GET contiene la exposición, pero no corrige el borrado autorizado solo por email; corregir C2 ataca esa causa, pero deja el correo expuesto mientras tanto.
3. Afirmación del agente que no pude verificar: No pude verificar en ejecución si dos POST concurrentes pueden hacer que una respuesta devuelva el comentario de otra persona (C3); no hice esa prueba y el agente lo dedujo del código.