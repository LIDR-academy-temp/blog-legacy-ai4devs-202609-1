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

**Modelo:** Opus 1M xHigh
**Herramienta:** Claude Code

```
necesito produzcas una auditoria priorizada del feature de comentarios, dentro de la aplicacion.
Solo esa feature de comentarios. No el sistema entero.
Creame la auditoria en docs/auditoria/comentarios.md con una fila por hallazgo, con estas seis columnas:

- Qué es. Una frase. Si necesitas tres, es que hay dos hallazgos.
- Evidencia de Dónde está, con la línea que lo demuestra. Sin esta casilla, la fila no se escribe.
- Qué se rompe, y quién lo nota. El efecto concreto y a quién le llegaria.
- Cuántos sitios hay que tocar. Contados, no estimados.
- ¿Se deshace con un revert? Sí o no, y si es que no, por qué no.
- ¿Bloquea o desbloquea a otro hallazgo? Nombrando al otro. "A ninguno" es la respuesta valida.

No supongas nada, si no tenes algun dato para completar, deja la columna en blanco.
```

**Qué salió:** (opcional, una línea)  tuve que insistir agregando el orden

--

## Prompt 2

**Modelo:** Opus 1M xHigh
**Herramienta:** Claude Code

```
NEcesito que modifiques el orden de la matriz generada.
primero la precedencia (lo que abarata o desbloquea a otro hallazgo va antes), y dentro de cada nivel, el daño dividido por el radio(cuantos sitios hay que tocar). 
Si un hallazgo tiene el daño más alto y la precedencia más baja a la vez, se parte en dos filas, una contención que corta el daño hoy y el arreglo de fondo que espera su turno. 
las propuestas que nadie ha medido todavía van fuera de la tabla, con lo que habría que medir escrito al lado.
```

**Qué salió:** (opcional, una línea)  tuve que insistir agregando el orden

