# Prompts

Aquí van **todos los prompts que lanzaste** para hacer el ejercicio, en el orden en que los
lanzaste, con el modelo y la herramienta de cada uno.

Esto no es papeleo. Lo que se revisa es **cómo pediste las cosas**, no solo lo que salió: un
resultado flojo con un prompt bueno y un resultado flojo con un prompt vago necesitan feedback
distinto, y sin este archivo no se distinguen.

## Cómo rellenarlo

- Un apartado `## Prompt N` por cada prompt.
- **Pega el prompt tal cual lo lanzaste**, dentro del bloque de código, aunque ocupe diez líneas
  y aunque tenga faltas. No lo reescribas para que quede bien: el que arreglaste mentalmente
  después no es el que lanzaste.
- Incluye también los que **no funcionaron**. Suelen ser los más útiles de leer.
- `Modelo` y `Herramienta` en todos. Si cambiaste de una a otra a mitad, se nota aquí.

---

## Prompt 1 — Comprobación inicial del entorno

**Modelo:** Claude Opus 5.5 (`claude-opus-5-5`)
**Herramienta:** Claude Code

```
Estamos preparando una auditoría de código legacy del proyecto Blog Legacy.

Antes de empezar, realiza únicamente estas comprobaciones:

1. Consulta los últimos 5 commits de Git y resume brevemente los cambios.
2. Busca en el repositorio los archivos que contienen la palabra "comentarios".
3. Confirma si puedes leer archivos y ejecutar comandos Git.

No modifiques archivos, no ejecutes migraciones, no corrijas código y no inicies todavía la auditoría. Esta es solo una comprobación del entorno.
```

---

## Prompt 2 — Auditoría de la funcionalidad de comentarios

**Modelo:** Claude Opus 5.5 (`claude-opus-5-5`)
**Herramienta:** Claude Code

```
Actúa como auditor técnico especializado en sistemas legacy.

Audita exclusivamente la funcionalidad de comentarios de este repositorio: crear, editar, eliminar y listar comentarios, siguiendo su comportamiento desde el frontend hasta las rutas de la API y la base de datos.

OBJETIVO
Identificar hallazgos concretos, verificables y relevantes para priorizar una intervención futura. No implementes correcciones.

Para cada hallazgo proporciona:
1. Qué es, en una frase.
2. Archivo y líneas exactas que lo demuestran.
3. Qué se rompe y quién lo nota.
4. Número de sitios que habría que modificar, enumerándolos.
5. Si se puede deshacer mediante git revert y por qué.
6. Qué otro hallazgo bloquea o desbloquea, si existe.

REGLAS
- No audites funcionalidades ajenas a comentarios.
- Separa hechos comprobados, hipótesis e información no verificada.
- No inventes dependencias, consumidores ni impactos.
- Prioriza primero por precedencia; dentro de cada nivel, por daño dividido por radio de cambio.
- Si un hallazgo urgente requiere una solución estructural que depende de otros, separa contención inmediata y solución definitiva.
- Excluye de la tabla las propuestas cuyo beneficio todavía no se haya medido; indica aparte qué habría que medir.
- Mantén una lista corta y evita hallazgos redundantes.
- No modifiques código, tests, dependencias ni base de datos.

Primero presenta los hallazgos en el chat con sus evidencias. No escribas todavía docs/auditoria/comentarios.md: quiero revisar y verificar los hallazgos antes de versionarlos.
```

---

## Prompt 3 — Generación de docs/auditoria/comentarios.md

**Modelo:** Claude Opus 5.5 (`claude-opus-5-5`)
**Herramienta:** Claude Code

```
Genera el archivo docs/auditoria/comentarios.md a partir de la auditoría inicial, respetando el límite de 45 minutos y sin realizar más investigaciones.

Incluye una tabla breve, priorizada por precedencia real y después por daño dividido por radio de cambio. Utiliza las seis columnas exactas del enunciado: qué es; dónde está con línea; qué se rompe y quién lo nota; cuántos sitios tocar; si se deshace con revert; qué bloquea o desbloquea.

Claude devolvió 10 hallazgos. Durante la revisión humana se examinaron H1, H2, H3, H5 y H6:
- H1: confirmado en routes.ts y en GET /posts/:slug; los comentarios aprobados incluyen autor_email.
- H2: comprobado en el DELETE que se autoriza comparando el correo enviado por el cliente. No se reprodujo un borrado no autorizado.
- H3: confirmado: SECRETO_SESION está hardcodeado en routes.ts:25 y se utiliza para autorizar el DELETE.
- H5: observada la discrepancia en el post 1: el listado contabiliza 4 comentarios y el detalle devuelve 2. La causa completa no se verificó.
- H6: confirmados los estados aprobado, Aprobado, ok y pendiente en blog_seeder.ts. La migración define table.string('estado').notNullable().defaultTo('pendiente'), sin restricción de valores. No está confirmado que ok equivalga a aprobado.

Separa contención y arreglo definitivo cuando gravedad y precedencia entren en conflicto. No inventes verificaciones, dependencias, consumidores ni cantidades de archivos afectados. Deja vacías las casillas no comprobadas y mantén fuera de la tabla las propuestas sin medición.

Debajo de la tabla incluye exactamente las tres respuestas de la parte B:
1. 10 hallazgos devueltos y 5 examinados personalmente, algunos solo parcialmente.
2. H2 fue difícil de priorizar por el conflicto entre daño alto, contención urgente y dependencias de una corrección definitiva.
3. No se pudo verificar la hipótesis de H9 sobre respuestas incorrectas bajo concurrencia.

No modifiques el código, los tests ni la base de datos. Escribe únicamente el documento de auditoría y muestra un resumen de lo guardado.
```

---

## Prompt 4 — Revisión final del documento de auditoría

**Modelo:** Claude Opus 5.5 (`claude-opus-5-5`)
**Herramienta:** Claude Code

```
Revisa y ajusta el documento docs/auditoria/comentarios.md antes de su entrega al máster AI4DEVS.

CONTEXTO
La auditoría se ha realizado sobre la funcionalidad de comentarios del Blog Legacy, con un límite de 45 minutos. Claude identificó 10 hallazgos y se examinaron personalmente 5, algunos de manera parcial.

OBJETIVO
Mejorar la precisión, coherencia y priorización del documento existente, sin realizar una nueva auditoría.

CAMBIOS SOLICITADOS

1. H1: Aclara que dejar de exponer autor_email reduce una vía de explotación de H2, pero NO resuelve el problema de autorización.

2. H2a: Diferencia el problema de su contención inmediata. La contención debe describir una medida temporal para impedir borrados no autorizados, sin asumir mecanismos ni impactos que no se hayan comprobado. Deja vacías las casillas que no puedas justificar.

3. H3: Matiza la reversibilidad. El código puede revertirse, pero la exposición histórica del secreto no se elimina con git revert y requiere rotación.

4. PRIORIZACIÓN: Aplica estrictamente el criterio del ejercicio:
   - Primero, precedencia real entre hallazgos.
   - Dentro de cada nivel, daño dividido por radio de cambio.
   - Separa contención y solución definitiva cuando corresponda.
   - H6 debe preceder a H5 porque la política de estados condiciona el recuento.
   - No confundas categorías de gravedad con niveles de precedencia.

5. EXTENSIÓN: Reduce la tabla a una lista breve y útil. Prioriza los hallazgos examinados y conserva H4 solo si es necesario para representar la dependencia de la solución definitiva de H2. No añadas hallazgos nuevos.

6. EVIDENCIA: Conserva referencias exactas a archivos y líneas. No presentes afirmaciones del agente como verificaciones humanas. Mantén vacías las casillas que no se comprobaron y no inventes consumidores, efectos, números de archivos ni pruebas.

7. PARTE B: Conserva las tres respuestas obligatorias, reflejando los 10 hallazgos devueltos, los 5 examinados personalmente, el conflicto de prioridad de H2 y la hipótesis de concurrencia H9 no verificada.

RESTRICCIONES
- No modifiques código fuente, tests, dependencias ni base de datos.
- No ejecutes nuevas investigaciones o pruebas.
- No amplíes el alcance fuera de comentarios.
- Conserva las propuestas no medidas fuera de la tabla, indicando qué habría que medir.
- No completes artificialmente las casillas vacías.

MODIFICA únicamente docs/auditoria/comentarios.md.

Al terminar, muéstrame el diff de los cambios realizados y explica brevemente qué has corregido. No hagas commit ni push.
```

---

## Prompt 5 — Registro de prompts

**Modelo:** Claude Opus 5.5 (`claude-opus-5-5`)
**Herramienta:** Claude Code

```
Necesito completar el archivo prompts.md para entregar el ejercicio AI4DEVS.

Revisa el historial de nuestra conversación de esta sesión de Claude Code e identifica los prompts reales que te he enviado, en orden cronológico.

Incluye:
1. Comprobación inicial del entorno.
2. Auditoría de la funcionalidad de comentarios.
3. Generación de docs/auditoria/comentarios.md.
4. Revisión final del documento de auditoría.
5. Este propio prompt de registro, como último apartado.

INSTRUCCIONES:
- Conserva literalmente el texto de cada prompt, con sus saltos de línea y errores originales.
- No resumas, reformules ni mejores los prompts.
- Utiliza la estructura del archivo prompts.md existente.
- Indica el modelo realmente utilizado y la herramienta Claude Code.
- No utilices el modelo de ejemplo de la plantilla si no coincide con el utilizado.
- Si no tienes acceso al texto literal de algún prompt, NO lo reconstruyas: deja una indicación clara para que lo copie manualmente.
- Incluye también cualquier otro prompt que realmente se haya enviado durante el ejercicio.
- El propio prompt de registro debe aparecer al final.
- No modifiques ningún archivo distinto de prompts.md.
- No hagas commit ni push.

Al terminar, muestra el contenido generado para que pueda comprobarlo antes de entregar.
```
