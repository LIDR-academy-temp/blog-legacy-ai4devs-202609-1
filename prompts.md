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

Borra el ejemplo de abajo cuando escribas el primero.

---

## Prompt 1

**Modelo:** Opus 5.5 (esfuerzo Medium)
**Herramienta:** Claude Code

```text
Estamos preparando el Laboratorio 6 de AI4Devs. Esta es únicamente una comprobación de capacidades, no una auditoría.

1. Muéstrame un resumen de los últimos 3 commits de este repositorio.
2. Busca en qué archivos del proyecto aparece el término "comentarios" e identifica algunos resultados con sus rutas.

No modifiques archivos, no ejecutes instalaciones ni propongas correcciones. Informa si alguna operación no pudo completarse.
```

**Qué salió:** Comprobación preliminar satisfactoria: consulta del historial Git y búsqueda de referencias a comentarios. No se modificaron archivos.

## Prompt 2

**Modelo:** Opus 5.5 (esfuerzo Medium)
**Herramienta:** Claude Code

```text
Audita exclusivamente la feature de comentarios de Blog Legacy, de punta a punta: API, base de datos y frontend. Incluye crear, editar, borrar y listar comentarios. No audites las demás features.

Identifica candidatos a hallazgo y clasifícalos como hechos comprobables, riesgos derivados u opiniones/propuestas sin medir. Para cada hallazgo, señala el archivo y la línea exacta que lo demuestra. Si no puedes aportar esa evidencia, no lo presentes como confirmado.

Prepara una auditoría priorizada con una fila por hallazgo y estas seis casillas:
1. Qué es, en una frase.
2. Dónde está, con archivo y línea.
3. Qué se rompe y quién lo nota.
4. Cuántos sitios hay que tocar, contados e identificados.
5. Si se deshace con un revert: sí o no, y por qué si no.
6. Si bloquea o desbloquea otro hallazgo, nombrándolo; si no, indica ninguno.

Prioriza primero por precedencia y, dentro de cada nivel, por daño dividido por radio. Si daño y precedencia entran en conflicto, separa contención y arreglo de fondo. Mantén fuera de la tabla las propuestas no medidas e indica qué habría que medir.

No inventes información ni completes con suposiciones los campos que no puedas comprobar: déjalos vacíos. No corrijas código, no refactorices, no instales dependencias, no cambies configuraciones ni ejecutes migraciones.

Por ahora presenta los candidatos y sus evidencias para revisión. No escribas todavía archivos ni realices commits.
```

**Qué salió:** El agente propuso 15 filas de auditoría y 5 propuestas sin medir. La verificación independiente comenzó posteriormente sobre el código, el historial Git y SQLite.
