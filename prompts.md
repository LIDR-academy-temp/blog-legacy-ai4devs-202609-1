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

## Prompt 1

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
no me está funcionando levantar el front end (cuando hago make web). Por qué?
```

**Qué salió:** encontró la causa a la primera: faltaba `frontend/node_modules` y `vite` no estaba instalado.

---

## Prompt 2

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
ya he hecho make setup, make db y make api. Comprueba otra vez
```

**Qué salió:** comprobó que Vite arrancaba y respondía 200, pero a mí me seguía fallando.

---

## Prompt 3

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
sigue sin funcionar
```

**Qué salió:** no lo reprodujo. Pidió el error exacto, porque el prompt no decía qué veía.

---

## Prompt 4

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
ya funciona
```

---

## Prompt 5

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
resúmeme los últimos comits de este repo
```

**Qué salió:** funcionó a la primera. Solo hay un commit.

---

## Prompt 6

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
busca en qué archivos aparece la palabra post
```

**Qué salió:** funcionó, pero tuvo que elegir qué excluir (`node_modules`, lockfiles, copia anidada) porque el prompt no lo decía.

---

## Prompt 7

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
Cuál es la feature de comentarios?
```

**Qué salió:** leyó rutas, migración, test y componente, y explicó la feature con sus incoherencias.

---

## Prompt 8

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
Con un agente, produce la auditoría priorizada de la feature de comentarios (ninguna otra feature, no me interesan). El plan es dejarla escrita en docs/auditoria/comentarios.md.

el orden, con el mismo criterio que usa el mentor: primero la precedencia (lo que abarata o desbloquea a otro hallazgo va antes), y dentro de cada nivel, el daño dividido por el radio. Si un hallazgo tiene el daño más alto y la precedencia más baja a la vez, se parte en dos filas, una contención que corta el daño hoy y el arreglo de fondo que espera su turno. Y las propuestas que nadie ha medido todavía van fuera de la tabla, con lo que habría que medir escrito al lado.

El formato no es negociable: una fila por hallazgo, con estas seis casillas.

Qué es. Una frase. Si necesitas tres, es que hay dos hallazgos.

Dónde está, con la línea que lo demuestra. Sin esta casilla, la fila no se escribe.

Qué se rompe, y quién lo nota. El efecto concreto y a quién le llega. "Nadie todavía" es una respuesta válida y buena.

Cuántos sitios hay que tocar. Contados, no estimados.

¿Se deshace con un revert? Sí o no, y si es que no, por qué no.

¿Bloquea o desbloquea a otro hallazgo? Nombrando al otro. "A ninguno" es la respuesta más frecuente.
```

**Qué salió:** lanzó un agente de exploración, verificó las líneas y escribió `docs/auditoria/comentarios.md` con 19 hallazgos y las propuestas sin medir aparte.

---

## Prompt 9

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
Busca El hallazgo del que me necesites para  decidir la prioridad, y en una frase, por qué. Lo que interesa es qué dos cosas se contradecían: lo grave contra lo que bloquea, lo urgente contra lo caro, lo que te pedían contra lo que veías. Empieza por el principio de la tabla.
```

**Qué salió:** tuvo que interpretar el prompt (qué es «el hallazgo del que me necesites»). Respondió con cuatro filas en conflicto.

---

## Prompt 10

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
Lee la plantilla de prompts.md y complétala con todos los prompts de hoy según esas instrucciones. Borra lo que indica que borres en la plantilla
```
