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
Resume los últimos commits, y busca en qué archivos aparece una palabra "Comentario".
```

**Qué salió:** todo ok.

---

## Prompt 2

**Modelo:** Opus 5.5
**Herramienta:** Claude Code

```
Audita la rebanada de COMENTARIOS de este proyecto: todo lo que toque comentarios, en la capa de rutas, en la base de datos y en el frontend. Devuelve los hallazgos ORDENADOS POR CRITICIDAD, del más crítico al menos. Para cada uno: un título corto, el archivo y la línea, y una frase de por qué importa. No arregles nada. Termina con la lista numerada de los títulos en el orden final.
```

**Qué salió:** Todo ok.

---

## Prompt 3

**Modelo:** Opus 5.5
**Herramienta:** Claude Code

```
Coge los hallazgos que acabas de devolver de la rebanada de Comentarios y, para cada uno, rellena cuatro casillas: DAÑO, qué se rompe y quién lo nota; RADIO, cuántos sitios hay que tocar a la vez, contados y listados con su archivo y su línea, nunca "varios"; REVERSIBILIDAD, si lo deshace un revert limpio o deja rastro en datos ya guardados; y PRECEDENCIA, si su arreglo abarata o encarece el de otro hallazgo de esta misma lista, nombrándolo. Deja la casilla EN BLANCO cuando no puedas responderla abriendo el código de este repositorio, y no la rellenes por aproximación: quiero ver los huecos. No ordenes la lista, no cambies el orden que ya tiene, y no arregles nada. 
```

**Qué salió:** Corrigio su feedback sobre un hallazgo.

---

## Prompt 4

**Modelo:** Opus 5.5
**Herramienta:** Claude Code

```
Crea una rama `auditoria-CMR` desde la rama actual y escribe en `docs/auditoria/comentarios.md` la auditoría priorizada. Una fila por hallazgo, con seis columnas: qué es; dónde está, con la línea que lo demuestra; qué se rompe y quién lo nota; cuántos sitios hay que tocar; si lo deshace un revert; y a qué otro hallazgo bloquea o desbloquea. Rellénalas con los ejes que ya me diste, sin reescribirlos. 
El ORDEN de la tabla no es el que devolviste al principio: **descarta esa criticidad** y ordena con las dos claves que hemos usado en clase, en este orden. Primera, PRECEDENCIA, que es un orden topológico y no un juicio: si el arreglo de A abarata el de B, A va antes, y para eso usa la columna de precedencia que tú mismo rellenaste. Segunda, dentro de cada nivel, DAÑO dividido por RADIO, no daño a secas. Y encima de eso van estas dos decisiones que hemos tomado fuera del chat y que tú no has visto, así que se respetan al pie de la letra. NO te las doy por número ni por el título exacto que les pusiste: localiza en TU lista el hallazgo que corresponde a cada descripción, y dime cuál has elegido para cada una antes de escribir nada. 
SE PARTE EN DOS FILAS: el hallazgo de que la respuesta pública devuelve la fila cruda y con ella sale el correo del autor en cada post y el de quien comenta en cada comentario. Una fila de CONTENCIÓN (quitar esos campos de la respuesta; radio mínimo, lo deshace un revert limpio, entra hoy, y sobrevive a la normalización posterior) y otra de ARREGLO (el DTO que decide qué campos salen, que espera a que el modelo esté normalizado para no 
tener que escribirse dos veces). Cada fila va donde le toque según las dos claves, que 
no es el mismo sitio para las dos. 
FUERA DE LA TABLA: si en tu lista hay algún hallazgo que sea una propuesta sin medir en vez de un defecto comprobable (típicamente de rendimiento: cachear, paginar, un N+1), sácalo de la tabla a un apartado aparte, con lo que habría que medir para que vuelva a entrar: cuánto tarda hoy el endpoint de detalle con un post de veinte comentarios, y qué parte de ese tiempo se va en la consulta. Si no hay ninguno, no saques nada y dímelo. 
Las casillas que dejaste en blanco se quedan en blanco. No añadas hallazgos nuevos, no rellenes huecos por aproximación y no arregles nada. Cuando termines, dime en una línea qué orden ha salido y por qué el primero es el primero. Commitea solo ese archivo. 
```

**Qué salió:** OK, aparentemente.
