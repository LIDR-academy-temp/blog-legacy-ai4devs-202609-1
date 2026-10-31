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

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
Realiza un resumen de los últimos commits y busca en que archivos se utiliza la palabra "User" referente al modelo del backend.
```

**Qué salió:** Funcionó, 3 commits. Y sobre la palabra encontró 5 archivos donde se usa la palabra referente al modelo e incluso otorgo la linea del archivo.

## Prompt 2

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
Genera una auditoria sobre el feature "comentarios" de este proyecto, considera backend (incluida la base de datos) y frontend para el analisis. Realiza un orden de mayor a menor segun criticidad. No consideres hallazgos que no se puedan comprobar, indica el archivo y la linea donde se encuentre el problema. Plasma esto como una tabla que incluya "Identificador" (Texto breve del fallo), "Evidencia" (archivo y linea que respaldan el hallazgo) y "Justificación" (Explicación del impacto/criticidad), por cada hallazgo. 
```

**Qué salió:** Genero el listado según su consideración devolviendo 22 hallazgos.

## Prompt 3

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
Ahora con el listado anterior, realiza un reordenamiento considerando:
1. Precedencia: Lo que avarata o facilita otro hallazgo va antes.
2. Daño dividido por radio: Se considera el daño que casua este hallazgo y la cantidad archivos que se requieren modificar para solucionarlo.
3. Si un hallazgo tiene el daño más alto y la precendencia más baja a la vez, se parte en 2 filas, una para contener el daño y otra para solucionar el problema de fondo (este espera su turno segun la precedencia).

El formato de entrega es una tabla con las siguientes columnas:
- Qué es: Una frase que describa el hallazgo.
- Donde está: El archivo y la linea que lo demuestra.
- Qué se rompe y quién lo nota: El efecto concreto y a quién le llega. "Nadie todavía" es valido.
- Cuántos sitios hay que tocar: Contar los archivos que se requieren modificar y presentar el número exacto.
- ¿Se deshace con un revert?: SI / NO. Si la respuesta es NO se debe agregar el por qué.
- ¿Bloquea o desbloquea algún otro hallazgo?: Nombrar el otro hallazgo. "A ninguno" igual es valido.

La tabla con el nuevo orden se debe visualizar en el archivo docs/auditoria/comentarios.md, genera esta archivo.
```

**Qué salió:** Genero el archivo solicitado y cambio el orden según las indicaciones.


## Prompt 4

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
el archivo comentarios_repository.ts en donde se encuentra?
```

**Qué salió:** Indicó que como tal el archivo no existe, es un archivo que se tendría que crear y el nombre lo tomó en base a las convenciones del archivo CLAUDE.md, esto salio como duda por los archivos que indicaba que se debían tocar.


