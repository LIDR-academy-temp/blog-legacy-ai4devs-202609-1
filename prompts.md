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
Quiero hacer una auditoria del apartado de comentarios y que la dejes escrita en docs/auditoria/comentarios.md, no en el chat.
Una característica es una funcionalidad del blog de punta a punta : sus rutas en la API, su tabla en la base de datos y lo que la web enseña de ella. Este blog tiene cinco (posts, comentarios, autores, categorías y etiquetas), y  la tuya es comentarios : crear, editar, borrar y listar comentarios, en esas tres capas
No quiero que revises nada más que los comentarios.
El listado de lo que encuentres tiene que cumplir el siguiente formato: una fila por hallazgo y con estas seis columnas
- Qué es.  Una frase. Si necesitas tres, es que hay dos hallazgos.
- Dónde está , con  la línea que lo demuestra . Sin esta casilla, la fila no se escribe.
- Qué se rompe, y quién lo nota.  El efecto concreto ya quién le llega.  "Nadie todavía"  es una respuesta válida y buena.
- Cuántos sitios hay que tocar.  Contados, no estimados.
- ¿Se deshace con un revertir el cambio?  Sí o no, y si es que no, por qué no.
- ¿Bloquea o desbloquea a otro hallazgo?  Nombrando al otro.  "A ninguno"  es la respuesta más frecuente.

Una vez obtenido quiero que los ordenes siguiendo estos criterios y orden:
- Precedencia:Es un orden topológico, no un juicio. Si el arreglo de A abarata el de B, A va antes y no se discute: es una dependencia, como compilar antes de ejecutar.
- Y dentro de cada nivel, el  daño dividido por la radio . Si un hallazgo tiene el daño más alto y la precedencia más baja a la vez,  se parte en dos filas , una contención que corta el daño hoy y el arreglo de fondo que espera su turno. Y las propuestas que nadie ha medido todavía  van fuera de la tabla 
```

**Qué salió:** funcionó a la primera: auditoría con 23 filas en docs/auditoria/comentarios.md; la Parte B quedó con huecos para rellenar a mano.

## Prompt 2

**Modelo:** Opus 5.5
**Herramienta:** Claude Code

```
Guarda los prompts en el fichero prompts.md siguiendo el formato que tiene actualmente.
```

**Qué salió:** funcionó a la primera.
