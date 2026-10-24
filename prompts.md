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

> Los prompts 2 a 24 se han copiado literalmente del registro de la sesión de Claude Code. Dos retoques:
> (1) donde la persona pegó la clave de moderación escrita en `routes.ts` se ha sustituido por `<CLAVE-REDACTADA>` para no
> difundirla más (es el hallazgo 3: hay que rotarla); (2) las etiquetas `<pasted_content>` y el contexto del IDE
> que Claude Code añade solo se han quitado, y queda el texto pegado.

## Prompt 1 — PENDIENTE DE COMPLETAR POR LA PERSONA QUE ENTREGA

**Modelo:** (completar)
**Herramienta:** (completar)

> Réplica del Prompt 1, indicada por la persona que entrega y transcrita de las capturas del enunciado
> de la parte A. El prompt exacto que se lanzó al agente es anterior a esta sesión y no consta en su
> registro. Si difiere de este texto, sustitúyase por el original.

```
Parte A: la auditoría

Con un agente, produce la auditoría priorizada de la feature de comentarios y déjala escrita
en docs/auditoria/comentarios.md, no en el chat.

Una feature es una funcionalidad del blog de punta a punta: sus rutas en la API, su tabla en
la base de datos y lo que la web enseña de ella. Este blog tiene cinco (posts, comentarios,
autores, categorías y etiquetas), y la tuya es comentarios: crear, editar, borrar y listar
comentarios, en esas tres capas. Es la misma que audita el mentor en el directo.

Solo esa feature. No el sistema entero, aunque quepa y aunque el agente se ofrezca.

Y el orden, con el mismo criterio que usa el mentor: primero la precedencia (lo que abarata
o desbloquea a otro hallazgo va antes), y dentro de cada nivel, el daño dividido por el radio.
Si un hallazgo tiene el daño más alto y la precedencia más baja a la vez, se parte en dos filas,
una contención que corta el daño hoy y el arreglo de fondo que espera su turno. Y las
propuestas que nadie ha medido todavía van fuera de la tabla, con lo que habría que medir
escrito al lado.

El formato no es negociable: una fila por hallazgo, con estas seis casillas.

1. Qué es. Una frase. Si necesitas tres, es que hay dos hallazgos.
2. Dónde está, con la línea que lo demuestra. Sin esta casilla, la fila no se escribe.
3. Qué se rompe, y quién lo nota. El efecto concreto y a quién le llega. "Nadie todavía" es
   una respuesta válida y buena.
4. Cuántos sitios hay que tocar. Contados, no estimados.
5. ¿Se deshace con un revert? Sí o no, y si es que no, por qué no.
6. ¿Bloquea o desbloquea a otro hallazgo? Nombrando al otro. "A ninguno" es la respuesta
   más frecuente.

Cuando suene el reloj, para. Aunque esté a medias. Aunque falten filas, aunque haya casillas
en blanco, aunque justo estuvieras a punto de comprobar una cosa.

Una fila con tres casillas rellenas y tres en blanco es información: dice exactamente hasta
dónde llegaste. Una fila completada de memoria diez minutos después es ruido con formato, y
encima es indistinguible de la buena.
```

**Qué salió:** la tabla de 12 hallazgos y las 4 propuestas sin medir.

## Prompt 2

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code (extensión de VS Code)

```
@docs/auditoria/comentarios.md lee lo que es la parte a del ejercicio de la auditoria
```

**Qué salió:** Resumió la parte A correctamente.

## Prompt 3

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code (extensión de VS Code)

```
[captura adjunta]
```

**Qué salió:** Revisó mi borrador de la parte B contra el enunciado: señaló que la cifra de «comprobados» era del agente y no mía.

## Prompt 4

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code (extensión de VS Code)

```
mis iniciales son JDS81
[captura adjunta]
```

**Qué salió:** Comprobó que la rama ya era auditoria-JDS81 y no subió nada sin confirmar.

## Prompt 5

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code (extensión de VS Code)

```
compruebalas tu
```

**Qué salió:** Leyó el código de los 12 hallazgos y separó lo comprobado de lo no comprobable.

## Prompt 6

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code (extensión de VS Code)

```
confirmalo tambien
[captura adjunta]
```

**Qué salió:** Arrancó la API, hizo solo GET, confirmó los hallazgos 1 y 4 y la paró.

## Prompt 7

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code (extensión de VS Code)

```
rescribe las lineas
```

**Qué salió:** Reescribió las tres líneas de la parte B y dejó en blanco la cifra que solo yo podía dar.

## Prompt 8

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code (extensión de VS Code)

```
dond elos tengo que revisar o como dimelo
```

**Qué salió:** Me dio una tabla con archivo y línea de cada hallazgo para abrirlos yo.

## Prompt 9

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code (extensión de VS Code)

```
1.    

'select * from comentarios order by id desc limit 1'
  )

  return response.status(201).send({ comentario: nuevos[0] })
})

2.  

test('deja un comentario en un post publicado', async ({ client, assert }) => {
    await db.table('posts').insert({
      id: 9001,
      titulo: 'Post de prueba',
      slug: 'post-de-prueba',
      resumen: 'Resumen de prueba',
      cuerpo: '## Cuerpo de prueba',
      imagen_portada: null,
      estado: 'publicado',
      publicado_en: '2026-01-01 10:00:00',
      autor_id: 1,
      categoria_id: 1,
      autor_nombre: 'Marta Ruiz Calvo',
      autor_email: 'marta.ruiz@corriente.es',
      categoria_nombre: 'Noticias',
      etiquetas: 'Artículos',
      created_at: '2026-01-01 10:00:00',
      updated_at: '2026-01-01 10:00:00',
    })

4.   

'select *, (select count(*) from comentarios c where c.post_id = posts.id and c.estado <> ' +
      "'pendiente') as num_comentarios from posts" +
      donde +
      ' order by publicado_en desc limit ? offset ?',
    parametros.concat([POR_PAGINA, (pagina - 1) * POR_PAGINA])
  )

      

"select count(*) as total from comentarios where post_id = ? and estado <> 'pendiente'",
      [fila.id]
    )

// Solo los comentarios aprobados. La comparación es exacta, así que los que
  // se guardaron como 'Aprobado' o como 'ok' no salen por aquí.
  const comentarios: any = await db.rawQuery(
    "select * from comentarios where post_id = ? and estado = 'aprobado' order by creado_en asc",
    [post.id]
  )

  

// Solo los comentarios aprobados. La comparación es exacta, así que los que
  // se guardaron como 'Aprobado' o como 'ok' no salen por aquí.
  const comentarios: any = await db.rawQuery(
    "select * from comentarios where post_id = ? and estado = 'aprobado' order by creado_en asc",
    [post.id]
  )
```

**Qué salió:** Me avisó de que mi «1.» era en realidad el hallazgo 11. Contó 3 de 12.

## Prompt 10

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code (extensión de VS Code)

```
te voy apsando el codigo y tu lo escribes de los 12
```

**Qué salió:** Llevó la cuenta de lo que iba abriendo y dijo qué faltaba.

## Prompt 11

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code (extensión de VS Code)

```
1. no hay resultados
```

**Qué salió:** Prompt vago: adivinó que busqué el texto con el «…» de la tabla, y acertó.

## Prompt 12

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code (extensión de VS Code)

```
const comentarios: any = await db.rawQuery(
    "select * from comentarios where post_id = ? and estado = 'aprobado' order by creado_en asc",
    [post.id]
```

**Qué salió:** Contó el hallazgo 1 (4 de 12).

## Prompt 13

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code (extensión de VS Code)

```
// Puede borrar quien lo escribió, o cualquiera que traiga la clave de moderación.
  const clave = request.header('x-clave-moderacion')
  const email = request.input('autor_email', '')
  const esModerador = clave === SECRETO_SESION
  const esAutor =
```

**Qué salió:** Solo daba la mitad del 3 y del 5; no los contó todavía.

## Prompt 14

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code (extensión de VS Code)

```
String(comentario.autor_email).toLowerCase().trim() === String(email).toLowerCase().trim()

  if (!esModerador && !esAutor) {
    return response.status(403).send({ error: 'No puedes borrar este comentario' })
  }

const SECRETO_SESION = '<CLAVE-REDACTADA>'
```

**Qué salió:** Contó el 3 (5 de 12).

## Prompt 15

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code (extensión de VS Code)

```
// Aquí la regla se volvió a escribir a mano y salió distinta: no admite la
  // clave de moderación, compara el correo tal cual (con mayúsculas incluidas)
  // y encima exige que el comentario siga pendiente.
  const email = request.input('autor_email', '')
  if (comentario.autor_email !== email || comentario.estado !== 'pendiente') {
    return response.status(403).send({ error: 'No puedes editar este comentario' })
  }
```

**Qué salió:** Contó el 5 y el 6 (7 de 12).

## Prompt 16

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code (extensión de VS Code)

```
/*
|--------------------------------------------------------------------------
| Rutas de la API del blog «Corriente»
|--------------------------------------------------------------------------
|
| Todo el blog vive en este archivo: el SQL, la validación, las reglas de
| negocio y el formato de la respuesta. Empezó con dos rutas "provisionales"
| para salir del paso antes de una feria y nunca se movió de aquí.
|
| No hay controladores, ni servicios, ni repositorios, ni DTOs. Las filas de
| la base de datos se devuelven tal cual salen del `select *`.
|
*/

import { middleware } from '#start/kernel'
import router from '@adonisjs/core/services/router'
import db from '@adonisjs/lucid/services/db'
import { controllers } from '#generated/controllers'

/**
 * Clave con la que se firman las sesiones y con la que además se validan las
 * acciones de moderación. TODO(2024-11): sacarla a variables de entorno antes
 * de subir a producción.
 */
const SECRETO_SESION = '<CLAVE-REDACTADA>'

const POR_PAGINA = 5
const MAX_RELACIONADOS = 2
const MAX_RECIENTES = 4

router.get('/', () => {
  return { servicio: 'corriente-api', estado: 'ok' }
})

/* -------------------------------------------------------------------------
 * GET /posts — listado paginado de publicados, con filtros
 * ---------------------------------------------------------------------- */
router.get('/posts', async ({ request, response }) => {
  const pagina = Number(request.input('pagina', 1))
  const categoria = request.input('categoria')
  const etiqueta = request.input('etiqueta')
  const autor = request.input('autor')
  const q = request.input('q')

  if (!pagina || pagina < 1) {
    return response.status(400).send({ error: 'pagina inválida' })
  }

  let donde = " where estado = 'publicado'"
  const parametros: any[] = []

  if (categoria) {
    // Se filtra por el nombre copiado dentro del post, no por la tabla categorias.
    donde += ' and categoria_nombre = ?'
    parametros.push(categoria)
  }
  if (etiqueta) {
    // Las etiquetas son una cadena con comas, así que esto es un LIKE y punto.
    donde += ' and etiquetas like ?'
    parametros.push('%' + etiqueta + '%')
  }
  if (autor) {
    donde += ' and autor_id = ?'
    parametros.push(autor)
  }
  if (q) {
    donde += ' and (titulo like ? or resumen like ? or cuerpo like ?)'
    parametros.push('%' + q + '%', '%' + q + '%', '%' + q + '%')
  }

  const totales: any = await db.rawQuery('select count(*) as total from posts' + donde, parametros)
  const total = totales[0].total

  const filas: any = await db.rawQuery(
    'select *, (select count(*) from comentarios c where c.post_id = posts.id and c.estado <> ' +
      "'pendiente') as num_comentarios from posts" +
      donde +
      ' order by publicado_en desc limit ? offset ?',
    parametros.concat([POR_PAGINA, (pagina - 1) * POR_PAGINA])
  )

  return response.send({
    pagina: pagina,
    porPagina: POR_PAGINA,
    total: total,
    datos: filas,
  })
})

/* -------------------------------------------------------------------------
 * GET /posts/recientes — los N últimos publicados (para la barra lateral)
 * ---------------------------------------------------------------------- */
router.get('/posts/recientes', async ({ request, response }) => {
  let cuantos = Number(request.input('limite', MAX_RECIENTES))
  if (isNaN(cuantos)) cuantos = MAX_RECIENTES
  if (cuantos > 20) cuantos = 20

  const filas: any = await db.rawQuery(
    "select * from posts where estado = 'publicado' order by publicado_en desc limit ?",
    [cuantos]
  )

  return response.send({ datos: filas })
})

/* -------------------------------------------------------------------------
 * GET /posts/:slug — detalle completo
 * ---------------------------------------------------------------------- */
router.get('/posts/:slug', async ({ params, response }) => {
  const posts: any = await db.rawQuery(
    "select * from posts where slug = ? and estado = 'publicado' limit 1",
    [params.slug]
  )
  if (posts.length === 0) {
    return response.status(404).send({ error: 'Post no encontrado' })
  }
  const post = posts[0]

  const autores: any = await db.rawQuery('select * from autores where id = ? limit 1', [
    post.autor_id,
  ])
  const autor = autores[0] || null
  if (autor && autor.redes) {
    try {
      autor.redes = JSON.parse(autor.redes)
    } catch (e) {
      autor.redes = {}
    }
  }

  const categorias: any = await db.rawQuery('select * from categorias where id = ? limit 1', [
    post.categoria_id,
  ])

  // Las etiquetas hay que reconstruirlas partiendo la cadena por comas y
  // buscando cada nombre en la tabla, porque no existe la tabla pivote.
  const nombresEtiquetas = String(post.etiquetas || '')
    .split(',')
    .map((e: string) => e.trim())
    .filter((e: string) => e !== '')
  let etiquetas: any = []
  if (nombresEtiquetas.length > 0) {
    const huecos = nombresEtiquetas.map(() => '?').join(',')
    etiquetas = await db.rawQuery(
      'select * from etiquetas where nombre in (' + huecos + ')',
      nombresEtiquetas
    )
  }

  // Solo los comentarios aprobados. La comparación es exacta, así que los que
  // se guardaron como 'Aprobado' o como 'ok' no salen por aquí.
  const comentarios: any = await db.rawQuery(
    "select * from comentarios where post_id = ? and estado = 'aprobado' order by creado_en asc",
    [post.id]
  )

  const anteriores: any = await db.rawQuery(
    "select id, titulo, slug, imagen_portada from posts where estado = 'publicado' and publicado_en < ? order by publicado_en desc limit 1",
    [post.publicado_en]
  )
  const siguientes: any = await db.rawQuery(
    "select id, titulo, slug, imagen_portada from posts where estado = 'publicado' and publicado_en > ? order by publicado_en asc limit 1",
    [post.publicado_en]
  )

  return response.send({
    post: post,
    autor: autor,
    categoria: categorias[0] || null,
    etiquetas: etiquetas,
    comentarios: comentarios,
    anterior: anteriores[0] || null,
    siguiente: siguientes[0] || null,
  })
})

/* -------------------------------------------------------------------------
 * GET /posts/:slug/relacionados — por categoría y etiquetas compartidas
 * ---------------------------------------------------------------------- */
router.get('/posts/:slug/relacionados', async ({ params, response }) => {
  const base: any = await db.rawQuery(
    "select * from posts where slug = ? and estado = 'publicado' limit 1",
    [params.slug]
  )
  if (base.length === 0) {
    return response.status(404).send({ error: 'Post no encontrado' })
  }
  const post = base[0]

  const candidatos: any = await db.rawQuery(
    "select * from posts where estado = 'publicado' and id <> ? order by publicado_en desc",
    [post.id]
  )

  const misEtiquetas = String(post.etiquetas || '')
    .split(',')
    .map((e: string) => e.trim().toLowerCase())
    .filter((e: string) => e !== '')

  const puntuados: any[] = []
  for (let i = 0; i < candidatos.length; i++) {
    const c = candidatos[i]
    let puntos = 0
    if (c.categoria_id === post.categoria_id) puntos = puntos + 2
    const suyas = String(c.etiquetas || '')
      .split(',')
      .map((e: string) => e.trim().toLowerCase())
    for (let j = 0; j < suyas.length; j++) {
      if (misEtiquetas.indexOf(suyas[j]) !== -1) puntos = puntos + 1
    }
    if (puntos > 0) puntuados.push({ fila: c, puntos: puntos })
  }

  puntuados.sort((a, b) => b.puntos - a.puntos)
  const elegidos = puntuados.slice(0, MAX_RELACIONADOS)

  // Una consulta por cada relacionado para el número de comentarios, y otra
  // para el autor. Con dos relacionados son cuatro viajes extra a la base.
  const salida: any[] = []
  for (let i = 0; i < elegidos.length; i++) {
    const fila = elegidos[i].fila
    const cuenta: any = await db.rawQuery(
      "select count(*) as total from comentarios where post_id = ? and estado <> 'pendiente'",
      [fila.id]
    )
    const autor: any = await db.rawQuery('select * from autores where id = ? limit 1', [
      fila.autor_id,
    ])
    fila.num_comentarios = cuenta[0].total
    fila.autor = autor[0] || null
    salida.push(fila)
  }

  return response.send({ datos: salida })
})

/* -------------------------------------------------------------------------
 * GET /categorias — con recuento de posts publicados
 * ---------------------------------------------------------------------- */
router.get('/categorias', async ({ response }) => {
  const filas: any = await db.rawQuery(
    'select c.*, (select count(*) from posts p where p.categoria_id = c.id and ' +
      "p.estado = 'publicado') as num_posts from categorias c order by c.nombre asc"
  )
  return response.send({ datos: filas })
})

/* -------------------------------------------------------------------------
 * GET /etiquetas — con recuento de posts publicados
 * ---------------------------------------------------------------------- */
router.get('/etiquetas', async ({ response }) => {
  const etiquetas: any = await db.rawQuery('select * from etiquetas order by nombre asc')

  // Como las etiquetas de un post son una cadena, el recuento se hace con un
  // LIKE por etiqueta: once etiquetas, once consultas.
  for (let i = 0; i < etiquetas.length; i++) {
    const cuenta: any = await db.rawQuery(
      "select count(*) as total from posts where estado = 'publicado' and etiquetas like ?",
      ['%' + etiquetas[i].nombre + '%']
    )
    etiquetas[i].num_posts = cuenta[0].total
  }

  return response.send({ datos: etiquetas })
})

/* -------------------------------------------------------------------------
 * GET /autores/:id — ficha del autor y sus posts
 * ---------------------------------------------------------------------- */
router.get('/autores/:id', async ({ params, response }) => {
  const autores: any = await db.rawQuery('select * from autores where id = ? limit 1', [params.id])
  if (autores.length === 0) {
    return response.status(404).send({ error: 'Autor no encontrado' })
  }
  const autor = autores[0]
  if (autor.redes) {
    try {
      autor.redes = JSON.parse(autor.redes)
    } catch (e) {
      autor.redes = {}
    }
  }

  const posts: any = await db.rawQuery(
    'select * from posts where autor_id = ? order by publicado_en desc',
    [params.id]
  )

  return response.send({ autor: autor, posts: posts })
})

/* -------------------------------------------------------------------------
 * POST /posts/:slug/comentarios — deja un comentario pendiente de moderar
 * ---------------------------------------------------------------------- */
router.post('/posts/:slug/comentarios', async ({ params, request, response }) => {
  const posts: any = await db.rawQuery(
    "select * from posts where slug = ? and estado = 'publicado' limit 1",
    [params.slug]
  )
  if (posts.length === 0) {
    return response.status(404).send({ error: 'Post no encontrado' })
  }
  const post = posts[0]

  const nombre = request.input('autor_nombre')
  const email = request.input('autor_email')
  const cuerpo = request.input('cuerpo')
  const padre = request.input('padre_id', null)

  if (!nombre) {
    return response.status(400).send({ error: 'El nombre es obligatorio' })
  }
  if (!email) {
    return response.status(422).send({ message: 'Falta el email' })
  }
  if (String(email).indexOf('@') === -1) {
    return response.status(400).send({ errores: ['email no válido'] })
  }
  if (!cuerpo || String(cuerpo).length < 5) {
    return response.send({ ok: false, motivo: 'comentario demasiado corto' })
  }

  const creado = new Date().toISOString().slice(0, 19).replace('T', ' ')
  await db.rawQuery(
    'insert into comentarios (post_id, autor_nombre, autor_email, cuerpo, estado, creado_en, padre_id) values (?, ?, ?, ?, ?, ?, ?)',
    [post.id, nombre, email, cuerpo, 'pendiente', creado, padre]
  )

  const nuevos: any = await db.rawQuery(
    'select * from comentarios order by id desc limit 1'
  )

  return response.status(201).send({ comentario: nuevos[0] })
})

/* -------------------------------------------------------------------------
 * DELETE /comentarios/:id — borra un comentario
 * ---------------------------------------------------------------------- */
router.delete('/comentarios/:id', async ({ params, request, response }) => {
  const filas: any = await db.rawQuery('select * from comentarios where id = ? limit 1', [
    params.id,
  ])
  if (filas.length === 0) {
    return response.status(404).send({ error: 'Comentario no encontrado' })
  }
  const comentario = filas[0]

  // Puede borrar quien lo escribió, o cualquiera que traiga la clave de moderación.
  const clave = request.header('x-clave-moderacion')
  const email = request.input('autor_email', '')
  const esModerador = clave === SECRETO_SESION
  const esAutor =
    String(comentario.autor_email).toLowerCase().trim() === String(email).toLowerCase().trim()

  if (!esModerador && !esAutor) {
    return response.status(403).send({ error: 'No puedes borrar este comentario' })
  }

  await db.rawQuery('delete from comentarios where id = ?', [params.id])
  return response.status(200).send({ borrado: true })
})

/* -------------------------------------------------------------------------
 * PATCH /comentarios/:id — edita el cuerpo de un comentario
 * ---------------------------------------------------------------------- */
router.patch('/comentarios/:id', async ({ params, request, response }) => {
  const filas: any = await db.rawQuery('select * from comentarios where id = ? limit 1', [
    params.id,
  ])
  if (filas.length === 0) {
    return response.status(404).send({ error: 'Comentario no encontrado' })
  }
  const comentario = filas[0]

  // Aquí la regla se volvió a escribir a mano y salió distinta: no admite la
  // clave de moderación, compara el correo tal cual (con mayúsculas incluidas)
  // y encima exige que el comentario siga pendiente.
  const email = request.input('autor_email', '')
  if (comentario.autor_email !== email || comentario.estado !== 'pendiente') {
    return response.status(403).send({ error: 'No puedes editar este comentario' })
  }

  const cuerpo = request.input('cuerpo')
  if (!cuerpo) {
    return response.status(400).send({ error: 'Falta el cuerpo' })
  }

  await db.rawQuery('update comentarios set cuerpo = ? where id = ?', [cuerpo, params.id])
  const actualizados: any = await db.rawQuery('select * from comentarios where id = ? limit 1', [
    params.id,
  ])
  return response.send({ comentario: actualizados[0] })
})

/* -------------------------------------------------------------------------
 * Autenticación del starter kit. Esto sí tiene controladores, validadores y
 * transformers: es el ejemplo de cómo debería estar escrito el resto.
 * ---------------------------------------------------------------------- */
router
  .group(() => {
    router
      .group(() => {
        router.post('signup', [controllers.NewAccount, 'store'])
        router.post('login', [controllers.AccessTokens, 'store'])
      })
      .prefix('auth')
      .as('auth')

    router
      .group(() => {
        router.get('profile', [controllers.Profile, 'show'])
        router.post('logout', [controllers.AccessTokens, 'destroy'])
      })
      .prefix('account')
      .as('profile')
      .use(middleware.auth())
  })
  .prefix('/api/v1')
```

**Qué salió:** Contó el 9 (8 de 12). Advirtió de que pegar un archivo entero no demuestra haberlo leído.

## Prompt 17

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code (extensión de VS Code)

```
function enviar(evento) {
    evento.preventDefault()
    fetch(API + '/posts/' + encodeURIComponent(slug) + '/comentarios', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ autor_nombre: nombre, autor_email: email, cuerpo: cuerpo }),
    })
      .then((r) => r.json())
      .then((d) => {
        if (d.comentario) {
          setAviso('Gracias, tu comentario está pendiente de moderación.')
          setTotal(total + 1)
          setNombre('')
          setEmail('')
          setCuerpo('')
        } else {
          setAviso(d.error || d.message || d.motivo || 'No se ha podido enviar.')
        }
      })
      .catch(() => setAviso('No se ha podido enviar.'))
  }
```

**Qué salió:** Contó el 7 (9 de 12).

## Prompt 18

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code (extensión de VS Code)

```
useEffect(() => {
    // Se vuelve a pedir el post entero solo para sacar los comentarios.
    fetch(API + '/posts/' + encodeURIComponent(slug))
      .then((r) => r.json())
      .then((d) => {
        setComentarios(d.comentarios || [])
        setTotal((d.comentarios || []).length)
      })
      .catch(() => {})
  }, [slug])
```

**Qué salió:** Daba la primera mitad del 12; no lo contó todavía.

## Prompt 19

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code (extensión de VS Code)

```
fetch(API + '/posts/' + encodeURIComponent(slug))

 

useEffect(() => {
    setCargando(true)
    fetch(API + '/posts/' + encodeURIComponent(slug))
      .then((r) => r.json())
      .then((d) => {
        setDatos(d)
        setNumComentarios((d.comentarios || []).length)
        setCargando(false)
        window.scrollTo(0, 0)
      })
      .catch(() => setCargando(false))
  }, [slug])

export default function Comentarios({ slug }) {
  const [comentarios, setComentarios] = useState([])
  // …y este hermano guarda OTRO recuento, que además incrementa al enviar.
  // El de la cabecera del artículo nunca se entera, así que los dos números
  // dejan de coincidir en cuanto alguien comenta.
  const [total, setTotal] = useState(0)
  const [nombre, setNombre] = useState('')
  const [email, setEmail] = useState('')
  const [cuerpo, setCuerpo] = useState('')
  const [aviso, setAviso] = useState('')

function enviar(evento) {
    evento.preventDefault()
    fetch(API + '/posts/' + encodeURIComponent(slug) + '/comentarios', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ autor_nombre: nombre, autor_email: email, cuerpo: cuerpo }),
    })
      .then((r) => r.json())
      .then((d) => {
        if (d.comentario) {
          setAviso('Gracias, tu comentario está pendiente de moderación.')
          setTotal(total + 1)
          setNombre('')
          setEmail('')
          setCuerpo('')
        } else {
          setAviso(d.error || d.message || d.motivo || 'No se ha podido enviar.')
        }
      })
      .catch(() => setAviso('No se ha podido enviar.'))
  }

  

return (
    <section className="comentarios">
      <h2>{total} comentarios</h2>

      {raices.map((c, index) => (
        <div className="comentario" key={index}>
          <p className="comentario-autor">
            {c.autor_nombre} <small>{String(c.creado_en).substring(0, 10)}</small>
          </p>
          <p>{c.cuerpo}</p>

          {comentarios
            .filter((r) => r.padre_id === c.id)
            .map((r, i) => (
              <div className="comentario respuesta" key={i}>
                <p className="comentario-autor">
                  {r.autor_nombre} <small>{String(r.creado_en).substring(0, 10)}</small>
                </p>
                <p>{r.cuerpo}</p>
              </div>
            ))}
        </div>
      ))}
```

**Qué salió:** Contó el 12 (10 de 12).

## Prompt 20

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code (extensión de VS Code)

```
export default function DetallePost({ slug }) {
  const [datos, setDatos] = useState(null)
  const [cargando, setCargando] = useState(true)
  // Este componente guarda su propio recuento de comentarios…
  const [numComentarios, setNumComentarios] = useState(0)
```

**Qué salió:** Faltaba aún el 71 del 8; no lo contó.

## Prompt 21

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code (extensión de VS Code)

```
<span className="recuento-cabecera">{numComentarios} comentarios</span>
      </div>
```

**Qué salió:** Contó el 8 (11 de 12).

## Prompt 22

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code (extensión de VS Code)

```
table.integer('padre_id').nullable()
```

**Qué salió:** Contó el 10 (12 de 12) y escribió «12 de 12» en la línea 1, con lo que no se comprobó.

## Prompt 23

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code (extensión de VS Code)

```
rellenalo
```

**Qué salió:** Primera versión de este archivo, con los pegados abreviados y el Prompt 1 sin completar.

## Prompt 24

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code (extensión de VS Code)

```
reajustalo y rellena todo
```

**Qué salió:** Esta versión: pegados literales sacados del registro de la sesión.
