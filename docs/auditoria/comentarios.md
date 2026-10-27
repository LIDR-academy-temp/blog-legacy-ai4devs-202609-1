# Auditoría de la funcionalidad de comentarios — Blog Legacy

## Alcance y criterio

Auditoría limitada a comentarios: creación, listado, edición, eliminación, persistencia y representación en el frontend.

Fuente: código del repositorio en la rama `auditoria-rc`, revisión independiente de evidencias, historial Git y consulta de solo lectura a SQLite.

Se distingue entre **H** (hecho comprobado en código o datos) y **R** (riesgo derivado, no necesariamente reproducido). La prioridad considera primero las dependencias y, dentro de cada nivel, el daño frente al radio de cambio. Las medidas de contención no equivalen a soluciones definitivas.

Los niveles P1, P2 y P3 representan una priorización cualitativa basada en precedencia y daño/radio. El orden entre hallazgos de un mismo nivel no implica una puntuación numérica ni una comparación cuantitativa demostrada.

## Parte A — Auditoría priorizada

| Qué es | Dónde está (evidencia) | Qué se rompe / quién lo nota | Radio: sitios que habría que tocar | ¿Revert? | Bloquea / desbloquea |
|---|---|---|---|---|---|
| **P1 · C1 · H.** El detalle público devuelve todas las columnas de comentarios aprobados, incluido `autor_email`. | `backend/start/routes.ts:152-155,171`; regla 6 en `CLAUDE.md:148`. | Exposición de datos personales a consumidores de la API; respuesta HTTP no comprobada directamente. | **1** punto de selección SQL (`routes.ts:153`) para la contención propuesta. | **Sí**, el código; **no** se recuperan datos ya divulgados. | Contiene una vía de aprovechamiento de C2, pero **no resuelve** su autorización. |
| **P1 · C3 · H.** La clave de moderación está incorporada en el código y figura en el commit inicial. | `backend/start/routes.ts:25,349-351`; commit `e0e0943`; `backend/config/encryption.ts:16` utiliza `APP_KEY`. | Una persona con acceso a la clave podría superar la comprobación de moderador y borrar comentarios. No se reprodujo el abuso. | **—** El agente propuso cuatro puntos de intervención, pero no verificamos el alcance completo. Se comprobaron la declaración y el uso de la clave en `routes.ts`. | **No basta** un revert: la clave permanece en el historial; requeriría rotación. | Ninguno comprobado. |
| **P1 · C2 · H/R.** DELETE acepta como prueba de autoría la coincidencia de un correo suministrado por el solicitante y ejecuta un borrado físico. | `backend/start/routes.ts:339-359`. | Riesgo de eliminación no autorizada si se conoce el correo del autor; pérdida del comentario para autor y lectores. Explotación no reproducida. | **1** bloque de autorización (`routes.ts:348-356`) identificado como foco; solución completa sin dimensionar. | **Código: sí. Datos borrados: no**, salvo recuperación externa disponible. | C1 facilita una fuente de correos; resolver C1 **no elimina** C2. |
| **P1 · C4 · H/R.** Tras insertar, POST recupera el último comentario global, en lugar del registro insertado. | `backend/start/routes.ts:324-333`. | Una inserción concurrente podría causar respuesta con el comentario ajeno y sus datos; carrera no reproducida. | **1** bloque de recuperación (`routes.ts:329-331`). | **Sí** para código; una exposición previa no se revierte. | Ninguna dependencia comprobada. |
| **P2 · T1 · H.** La prueba examinada de comentarios verifica solo el camino exitoso de POST, con dos aserciones. | `backend/tests/functional/comentarios.spec.ts:15-43`; `CLAUDE.md:70-72,95-106,108-135`. | Defectos fuera de ese escenario pueden quedar sin detección; afecta a desarrolladores y futuros cambios. `make test`: 1 prueba aprobada. | **—** Casos y archivos adicionales no contados. | **Sí**, para nuevas pruebas versionadas. | Pruebas de caracterización preceden a refactorizaciones; los cambios de comportamiento requieren pruebas propias. No bloquea la auditoría ni la identificación de contenciones. |
| **P3 · F2-C · H.** Los listados cuentan `estado <> 'pendiente'`, pero el detalle muestra solo `estado = 'aprobado'`. | `backend/start/routes.ts:75-76,153,223`; regla 5 `CLAUDE.md:147`. | Recuentos diferentes entre listado y detalle; lo perciben los lectores. SQLite confirmó 7 comentarios globales no pendientes frente a 4 exactamente aprobados. | **2** sitios SQL para alinear contadores (`routes.ts:75-76,223`). | **Sí**, para un cambio de consulta. | Contención posible sin normalizar datos; arreglo definitivo condicionado por F3 y pruebas aplicables. |
| **P3 · F4 · H.** La sección aumenta el contador tras crear un comentario pendiente, mientras la cabecera mantiene otro estado independiente. | `frontend/src/componentes/Comentarios.jsx:11,23,37-39,54`; `frontend/src/componentes/DetallePost.jsx:30,38,71`; `routes.ts:324-327`. | Después de comentar pueden aparecer cifras distintas sin que el comentario sea visible; afecta al lector que comenta. No reproducido en navegador tras POST. | **1** actualización como contención (`Comentarios.jsx:39`); **2** componentes involucrados en el diseño. | **Sí**, cambio de frontend. | Ninguna precedencia funcional obligatoria demostrada; pruebas conforme a `CLAUDE.md` antes de corregir. |
| **P3 · F3 · H.** `estado` admite texto libre y SQLite contiene `aprobado`, `Aprobado`, `ok` y `pendiente`. | `backend/database/migrations/1769000000005_create_comentarios_table.ts:18`; `backend/database/seeders/blog_seeder.ts:510,522,575`; `routes.ts:153`; consulta SQLite de solo lectura. | Comentarios históricos pueden ser contados pero no mostrados; afecta a autores y lectores. El significado funcional de `ok` no está confirmado. | **—** No se contaron los puntos de una normalización completa, incluidas migración y datos. | **No necesariamente** para datos sobrescritos; restaurarlos exigiría mecanismo de recuperación. | Requiere decidir qué significa `ok` y caracterizar comportamiento; desbloquea la solución definitiva de F2-C. |

## Límites de evidencia

- La consulta SQLite devolvió: `aprobado` = 4, `Aprobado` = 2, `ok` = 1, `pendiente` = 2; son totales globales, no recuentos por publicación.
- C2 y C4 tienen mecanismos comprobados en código, pero no se reprodujeron mediante pruebas adversariales o de concurrencia.
- La cantidad de sitios de intervención es el radio de la contención cuando está indicada; no representa necesariamente el esfuerzo de una solución definitiva.
- Permanecen fuera de esta tabla otros candidatos del agente que no fueron contrastados independientemente con el mismo nivel de evidencia.

## Parte B — Revisión del agente

1. **Hallazgos propuestos y comprobados:** Claude Code propuso 15 filas de auditoría. Revisé directamente 8 candidatos mediante inspección del código, historial Git y, para F3, consulta de solo lectura a SQLite. Esta revisión no equivale a confirmar íntegramente los ocho impactos: quedaron sin reproducir los escenarios de abuso de C2 y de concurrencia de C4, y algunos radios de cambio no se midieron. El número ocho representa candidatos con evidencia examinada directamente, no ocho fallos reproducidos mediante pruebas de ejecución.

2. **Dificultad y contradicción de priorización:** C1 y C2 están relacionados. Evitar que la API publique el correo de los comentaristas puede contener una vía de obtención de ese dato, pero no elimina la debilidad del DELETE, que utiliza el conocimiento del correo como autorización. También fue necesario distinguir las pruebas exigidas por CLAUDE.md como precondición de cambios de código de la urgencia de identificar una contención. Por eso no corresponde presentar C1 como solución definitiva de C2.

3. **Afirmación que no pude verificar en ninguna dirección:** No pude determinar si el estado histórico `ok` significa realmente que un comentario fue aprobado. Confirmé que existe en la semilla y en SQLite, pero esa evidencia no permite establecer su significado funcional. No lo normalicé ni lo equiparé a `aprobado` sin una decisión de negocio.

## Propuestas sin medir — Fuera de la tabla priorizada

Claude Code planteó cinco propuestas adicionales que no se convierten en hallazgos confirmados sin medición:

| Propuesta | Evidencia necesaria |
|---|---|
| Evitar dos consultas del detalle del post desde componentes distintos | Contar peticiones y medir latencia por visualización. |
| Incorporar un índice para `comentarios.post_id` | Comparar planes de ejecución y tiempos de consulta con volumen representativo. |
| Revisar consultas adicionales de recuento en artículos relacionados | Medir latencia según la cantidad de artículos relacionados. |
| Incorporar controles antispam o límites de envío | Medir volumen, frecuencia y proporción de comentarios rechazados o pendientes. |
| Utilizar identificadores en lugar del índice como clave de React | Observar y reproducir problemas de reconciliación antes de atribuir impacto. |