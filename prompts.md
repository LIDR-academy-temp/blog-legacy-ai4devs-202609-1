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

**Modelo:** Claude 3.5 Sonnet
**Herramienta:** GitHub Copilot (Eclipse - Chat)

```
Audita exclusivamente la feature de comentarios (crear, editar, borrar y listar comentarios en API, Base de Datos y Frontend/Web). NO audites el resto de features (posts, autores, categorías, etiquetas) ni modifiques código del proyecto.

Analiza el código y lista los hallazgos con las siguientes 6 columnas por fila:
1. Qué es (una sola frase).
2. Dónde está (archivo y línea exacta que lo demuestra).
3. Qué se rompe, y quién lo nota.
4. Cuántos sitios hay que tocar (conteo exacto, no estimado).
5. ¿Se deshace con un revert? (Sí/No y por qué).
6. ¿Bloquea o desbloquea a otro hallazgo? (nombrando el otro o "A ninguno").

No modifiques ningún archivo. Muestra únicamente la lista de hallazgos en el chat.
```

**Qué salió:** El agente entregó la matriz con 15 hallazgos detallados y acotados únicamente a la feature de comentarios, identificando discrepancias de datos en la semilla, filtros duplicados, problemas de seguridad y falta de tests.
