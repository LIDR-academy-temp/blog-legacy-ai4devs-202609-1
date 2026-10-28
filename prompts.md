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

**Proyecto:** blog-legacy-ai4devs-202609-1 (rama `s6/start`)
**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code 2.1.296

```
Haz un resumen de los últimos commits
```

**Qué salió:** funcionó a la primera. Resumió los 3 commits de `s6/start`. El primer intento falló con «Login expired» y lo relancé después de `/login`.

---

## Prompt 2

**Proyecto:** blog-legacy-ai4devs-202609-1 (rama `s6/start`)
**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code 2.1.296

```
lista los archivos donde aparezca la palabra 'BarraLateral'
```

**Qué salió:** funcionó a la primera. Encontró 2 archivos, `frontend/src/App.jsx` y `frontend/src/componentes/BarraLateral.jsx`, con las líneas exactas.

---

## Prompt 3

**Proyecto:** blog-legacy-ai4devs-202609-1 (rama `auditoria-maj`)
**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code 2.1.296

```
Produce la auditoría de la feature de comentarios y déjala escrita en docs/auditoria/comentarios.md.
la feature comentarios es una funcionalidad del blog de punta a punta, sus capas son: rutas en la API, tabla en la base de datos y lo que la web enseña de ella. 
Sus funcionalidades a auditar son: crear, editar, borrar y listar comentarios, en esas tres capas.
No auditar ninguna feature mas.
El formato no es negociable: una fila por hallazgo, con estas seis casillas.
Qué es. En Una frase.
Dónde está, con la línea que lo demuestra. Sin esta casilla, la fila no se escribe.
Qué se rompe, y quién lo nota. El efecto concreto y a quién le llega. "Nadie todavía" es una respuesta válida y buena.
Cuántos sitios hay que tocar. Contados, no estimados.
¿Se deshace con un revert? Sí o no, y si es que no, por qué no.
¿Bloquea o desbloquea a otro hallazgo? Nombrando al otro. "A ninguno" es la respuesta más frecuente.
```

**Qué salió:** funcionó a la primera. Escribió 17 hallazgos (C1–C17) con las seis casillas, cada uno con su línea citada y ordenados por prioridad. La Parte B se quedó vacía para rellenarla a mano.
