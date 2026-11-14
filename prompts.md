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
Audita la rebanada de COMENTARIOS (crear, editar, borrar y listar comentarios) de este proyecto: todo lo que toque la feature de comentarios en la capa de rutas en la API, su(s) tabla(s) en la base de datos y lo que se ve en la WEB (frontend) de ella. Devuelve los hallazgos de la rebanada de COMENTARIOS y, para cada uno proporciona una fila con las siguientes casillas: 
- ¿QUE ES?: En una frase, si requieres más de 2 son dos hallazgos.
- UBICACION: Donde esta y con la línea que lo demuestra. Sin esta casilla la fila no se escribe.
- DAÑO: qué se rompe y quién lo nota.  El efecto concreto y a quién le llega. "Nadie todavía" es una respuesta válida y buena. 
- RADIO: cuántos sitios hay que tocar para corregir el hallazgo. Contados y nombrados, no estimados.
- ¿ES REVERSIBLE?: SI/NO. Sino por que no
- PRECEDENCIA: ¿su arreglo afecta a otro hallazgo?. Nombra al hallazgo que afecta. "A ninguno" es una respuesta valida.
Esto es una AUDITORIA, no arregles nada.
```

**Qué salió:** 28 hallazgos con las seis casillas; el agente los escribió en `docs/auditoria/comentarios.md` (lo pide el README) además de resumirlos en el chat.

## Prompt 2

**Modelo:** Opus 5.5
**Herramienta:** Claude Code

```
Ordena la lista de hallazgo que acabas de encontrar de la feature de comentarios priorizada primero por PRECEDENCIA (esto es que van primero los hallazgos que su corrección tienen afectación en otros hallazgos de la lista) y luego por DAÑO dividido por RADIO. Guarda la lista ordenada y priorizada en `docs/auditoria/comentarios.md`
```

**Qué salió:** reordenó por nivel de precedencia y después por daño ÷ radio, puntuando el daño de 1 a 4; reescribió la casilla Precedencia como «Afecta a / Depende de / Junto a» y añadió la tabla del cálculo.

## Prompt 3

**Modelo:** Opus 5.5
**Herramienta:** Claude Code

```
 Guarda en `prompts.md` los prompts de esta sesión de acuerdo a los lineamientos descritos ahí.
```

**Qué salió:** este archivo.
