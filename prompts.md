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

**Modelo:** Opus 5.5
**Herramienta:** Claude Code

```
Produce una auditoría priorizada de la feature de comentarios y déjala escrita en docs/auditoria/comentarios.md. Una feature es una funcionalid del blog de punta a punta: sus rutas en la API, su tabla en la base de datos y lo que la web enseña de ella. Este blog tiene 5 features (posts, comentarios, autores, categorías y etiquetas). Pon el foco en la feature de comentarios e ignora el resto. El formato de la auditoria no es negociable, revisa el fichero README.md donde se describe dicho formato
```

**Qué salió:** a la primera; 18 hallazgos con las seis casillas, dos comprobados contra la API en marcha, y la Parte B queda con huecos para rellenar a mano.

## Prompt 2

**Modelo:** Opus 5.5
**Herramienta:** Claude Code

```
¿qué significa el tickbox de columna # de lar parte A Hallazgos del fichero comentarios.md?
```

**Qué salió:** explicó que la ✔ marca los hallazgos comprobados contra la API en marcha (C1 y C4).
