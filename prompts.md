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
Vamos a llevar a cabo una auditoría priorizada de la feature de comentarios del proyecto. Una feature es una funcionalidad del blog de punta a punta: sus rutas en la API, su tabla en la base de datos y lo que la web enseña de ella. La feature de comentarios es crear, editar, borrar y listar comentarios, en las tres capas anteriores. Solo auditaremos esa feature, no el sistema entero, no te ofrezcas a hacer más. La auditoría quedará plasmada en una tabla ordenada primero por la precedencia (lo que abarata o desbloquea a otro hallazgo va antes), y dentro de cada nivel, el daño dividido por el radio. Si un hallazgo tiene el daño más alto y la precedencia más baja a la vez, se parte en dos filas, una contención que corta el daño hoy y el arreglo de fondo que espera su turno. Y las propuestas que nadie ha medido todavía van fuera de la tabla, con lo que habría que medir escrito al lado. El formata es el siguiente: 

una fila por hallazgo, con estas seis casillas.

Qué es. Una frase. Si necesitas tres, es que hay dos hallazgos.

Dónde está, con la línea que lo demuestra. Sin esta casilla, la fila no se escribe.

Qué se rompe, y quién lo nota. El efecto concreto y a quién le llega. "Nadie todavía" es una respuesta válida y buena.

Cuántos sitios hay que tocar. Contados, no estimados.

¿Se deshace con un revert? Sí o no, y si es que no, por qué no.

¿Bloquea o desbloquea a otro hallazgo? Nombrando al otro. "A ninguno" es la respuesta más frecuente.

 . Antes de rellenar cada celda con lo que hayas detectado y sugieres consultame para que yo revise el contenido y el código si es necesario. La tabla irá en un markdown en docs/auditoria/comentarios.md en una sección llamada "Auditoría"
```

**Qué salió:** Funcionó a la primera: leyó el código de las tres capas y propuso 12 hallazgos, con el orden y la fila partida, para revisarlos antes de escribir nada.

## Prompt 2

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
1 -> Sí, es eso 2 -> Esa vale 3 -> Hallazgo 4 -> Mecanismo todavía por decidir y los sitios a concretar. No propongas nada, esto es una auditoría
```

**Qué salió:** Funcionó a la primera: añadió el hallazgo 13 y dejó 3b con el mecanismo y los sitios por concretar. Escribió `docs/auditoria/comentarios.md` sin proponer soluciones.

## Prompt 3

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
No queda muy claro que son esos rangos de números en la columna de Dónde está. P.ej. :295-393 . Indica antes de la tabla qué significan
```

**Qué salió:** Funcionó a la primera: añadió antes de la tabla un apartado «Cómo leer la casilla "Dónde está"» que explica rangos, líneas sueltas y rutas de otros archivos.

## Prompt 4

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
Añade la ruta a la celda, auqnue sea repetitivo
```

**Qué salió:** Funcionó a la primera: puso la ruta completa en cada referencia de «Dónde está». Al comprobar las líneas encontró cinco citas mal puestas de la tabla anterior y las corrigió.

## Prompt 5

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
Debajo de la tabla vamos a añadir 3 lineas en la sección "Observaciones" 

Cuántos hallazgos devolvió el agente, y cuántos comprobaste tú abriendo el archivo. Los dos números, tal cual salieron. No los redondees ni los expliques.

El hallazgo del que no supiste decidir la prioridad, y en una frase, por qué. Lo que interesa es qué dos cosas se contradecían: lo grave contra lo que bloquea, lo urgente contra lo caro, lo que te pedían contra lo que veías.

Algo que el agente afirmó y no pudiste verificar. Ojo al matiz: no es lo que dijo mal. Es lo que no pudiste comprobar ni a favor ni en contra, y te tocó dejar en el aire.

Preguntame por lo que quiero poner en cada una antes de escribirlas.
```

**Qué salió:** Funcionó a la primera: no escribió nada y le preguntó al usuario qué poner en cada una de las tres líneas.

## Prompt 6

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
1 -> Devueltos por el agente: 13 Comprobados: 5 2 -> El 10, porque tiene el cociente más bajo, aunque cambia el contrato, como indicas. 3 -> El 5 por no poder verificar la concurrencia en el tiempo en el que se redacta el ejercicio
```

**Qué salió:** Funcionó a la primera: escribió las tres líneas de «Observaciones» con los números y las respuestas del usuario.

## Prompt 7

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
Pon Observaciones despues de la sección Fuera de la tabla: propuestas sin medir
```

**Qué salió:** Funcionó a la primera: movió la sección «Observaciones» al final del fichero, después de «Fuera de la tabla».
