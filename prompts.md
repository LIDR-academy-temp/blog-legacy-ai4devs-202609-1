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

**Modelo:** Opus 5.5
**Herramienta:** Claude Code

```
Resume los últimos commits de este repositorio con su hash corto y mensaje. No modifiques archivos.
```

**Qué salió:** Resumió los tres commits de la rama `s6/start`; confirmó que no modificó archivos.

## Prompt 2

**Modelo:** Opus 5.5
**Herramienta:** Claude Code

```
Busca en qué archivos del proyecto aparece la palabra comentarios y enumera las rutas. No modifiques archivos.
```

**Qué salió:** Enumeró 12 archivos; confirmó que no modificó archivos.

## Prompt 3

**Modelo:** Opus 5.5
**Herramienta:** Claude Code

```
Audita exclusivamente la feature de comentarios (crear, editar, borrar y listar) en la API, la base de datos y el frontend. Devuelve hallazgos candidatos distintos, agrupando las repeticiones del mismo problema. Para cada uno cita archivo y líneas exactas, describe el efecto observable y cuenta los sitios a tocar. Indica si el cambio se deshace con un revert y qué hallazgo desbloquea solo cuando el código lo demuestre. Propón un orden por precedencia y luego por daño dividido entre radio. Separa las hipótesis sin verificar e indica qué habría que medir. No modifiques archivos.
```

**Qué salió:** 14 hallazgos.