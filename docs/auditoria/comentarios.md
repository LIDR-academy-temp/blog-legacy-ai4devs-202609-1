# Auditoría: feature de comentarios

Alcance: crear, editar, borrar y listar comentarios (API en `backend/start/routes.ts`, tabla
`comentarios`, componentes `Comentarios.jsx` y `DetallePost.jsx`).

**Cómo está ordenada la tabla.**

- **Precedencia real.** El nivel indica qué tiene que hacerse antes. Nivel 1: no depende de
  ningún otro hallazgo. Nivel 2: depende de uno del nivel 1. El nivel no es una categoría de
  gravedad.
- **Dentro de cada nivel**, daño dividido por radio de cambio. Las filas cuyo radio no está
  comprobado van detrás de las que sí lo tienen.
- **Contención y solución definitiva** van en filas separadas cuando la segunda depende de otro
  hallazgo (H2a / H2b).
- **Casillas vacías:** no se comprobaron en la revisión humana o no se pueden justificar con lo
  revisado.

| # | Qué es | Dónde está (línea) | Qué se rompe y quién lo nota | Cuántos sitios tocar | ¿Se deshace con revert? | Bloquea / desbloquea |
|---|---|---|---|---|---|---|
| 1.1 · H2a | **Problema:** el `DELETE` se autoriza comparando el correo que envía el cliente. **Contención:** restringir temporalmente `DELETE /comentarios/:id` para que no acepte esa comparación como autorización. | `backend/start/routes.ts:350-356` | Borrado no autorizado no reproducido. | | Sí | Complementa a H1 y H3; no los sustituye. La solución definitiva es H2b. |
| 1.2 · H1 | `GET /posts/:slug` devuelve los comentarios aprobados con `autor_email` (regla 6). | `routes.ts:152-155` (`select * from comentarios …`), `:171` | Cualquier cliente de la API obtiene el correo de quien comenta. | Contención: 1 (`routes.ts:153`, columnas explícitas) | Sí el código; lo ya expuesto no | Reduce una vía de explotación de H2 (obtener el correo), pero **no resuelve** la autorización de H2. |
| 1.3 · H3 | La clave de moderación está hardcodeada y autoriza el `DELETE`. | `routes.ts:25` (`SECRETO_SESION = 'dev-secret-cambiar'`), `:351` | Quien conozca la clave puede borrar cualquier comentario. | 2 en `routes.ts` (`:25`, `:351`) | El código, sí. La exposición histórica del secreto no se elimina con `git revert`: requiere rotarlo. | Cierra la otra vía de borrado que H2a no cubre. |
| 1.4 · H6 | `estado` es texto libre: conviven `aprobado`, `Aprobado`, `ok` y `pendiente`. | `backend/database/migrations/1769000000005_create_comentarios_table.ts:18`; `backend/database/seeders/blog_seeder.ts` | Sin confirmar que `ok` equivalga a `aprobado`. | | | Precede a H5: la política de estados condiciona el recuento. |
| 1.5 · H4 | La suite tiene un solo test (camino feliz del `POST`). *Afirmación del agente, no examinada.* | `backend/tests/functional/comentarios.spec.ts:41-42` | | | | Desbloquea H2b (`CLAUDE.md`: caracterizar antes de refactorizar). |
| 2.1 · H2b | Solución definitiva de H2: una autorización que no dependa del correo que envía el cliente. | `routes.ts:350-356` | | | | Depende de H4. |
| 2.2 · H5 | El recuento de comentarios no coincide con los que se muestran (regla 5). | `routes.ts:75-76`, `:223` (causa propuesta por el agente, no verificada); `:153` | Post 1: el listado dice 4 y el detalle devuelve 2. | | | Depende de H6. |

**Fuera de la tabla.**

- **No examinados:** H7, H8, H9 y H10, propuestos por el agente. H9 se cita en la Parte B.
- **Sin medir:**
  - La doble petición a `GET /posts/:slug` (`frontend/src/componentes/DetallePost.jsx:34` y
    `Comentarios.jsx:19`). Habría que medir peticiones y latencia por visita.
  - La falta de índice en `comentarios.post_id`. Habría que medir con `EXPLAIN QUERY PLAN` y un
    volumen realista.

## Parte B

1. 10 hallazgos devueltos y 5 examinados personalmente, algunos solo parcialmente.
2. H2 fue difícil de priorizar por el conflicto entre daño alto, contención urgente y dependencias de una corrección definitiva.
3. No se pudo verificar la hipótesis de H9 sobre respuestas incorrectas bajo concurrencia.
