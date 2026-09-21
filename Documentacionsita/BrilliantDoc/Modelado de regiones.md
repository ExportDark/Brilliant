# Modelado de regiones

Las decisiones detrás de `TipoRegion` y `Region`. Varias salieron de una propuesta de
diseño del usuario que mejoró el plan original.

Ver también: [[Modelo de dominio]] · [[Arquitectura general]] · [[Tablero y regiones]]

---

## `TipoRegion`: color + regla juntos, sin dispatcher

**Por qué no era obvio:** el plan original tenía `Color5` como enum suelto, y para saber
qué regla aplicaba a una zona hacía falta un dispatcher (`reglas_por_color.dart`, un
`switch` color → regla).

| Alternativa | Ventaja | Desventaja |
|---|---|---|
| `TipoRegion{color, regla}`, cada `Region` lo referencia | Elimina el dispatcher; agrupa dos cosas que siempre viajan juntas | Una clase más |
| Dispatcher separado con un `switch` | — | Indirección innecesaria si `Tablero` ya sabe el tipo de cada región al construirla |

**Decisión:** `TipoRegion`. Como `Tablero` arma las 9 regiones a mano (layout
hardcodeado), cada una recibe su tipo directo y **no hace falta ningún lookup en tiempo
de ejecución**. Esta fue una propuesta del usuario, mejor que el diseño original.

---

## `cantidadCeldas`: cuántas casillas debe tener cada región de ese tipo

Para este mapa: **amarillo 5, azul 4, verde 6, rojo 6, morado 6**.

**Punto clave:** esto es propio del mapa, **no una ley universal del color**. Otro mapa
podría declarar otros tamaños para el mismo color. Por eso las 5 constantes
(`tipoAmarillo`, `tipoVerde`, …) con sus `cantidadCeldas` son las *del mapa actual*, no
valores reutilizables sin más por cualquier mapa futuro.

**Para qué sirve:** validación defensiva. Al construir cada `Region`, un `assert`
verifica `casillas.length == tipo.cantidadCeldas` — así un error de tipeo al transcribir
el layout 7×7 a mano (ej. olvidar una casilla morada) falla de inmediato en vez de pasar
desapercibido.

---

## `completada`: getter calculado, no campo guardado

| Alternativa | Ventaja | Desventaja |
|---|---|---|
| Campo booleano guardado | Se ve como un dato directo del estado | Riesgo de quedar desincronizado si se olvida actualizarlo al llenar una casilla; rompe el patrón inmutable de `Celda` |
| Getter calculado: `casillas.every((c) => !c.estaVacia)` | Imposible que quede desactualizado; consistente con la inmutabilidad | Se recalcula al consultarlo (irrelevante: máximo 6 casillas) |

**Decisión:** getter calculado. Una sola fuente de la verdad, sin flags que mantener.

---

## `identificador`: un número simple

| Alternativa | Ventaja | Desventaja |
|---|---|---|
| Número (`1`..`9`) | Simple | Solo, no dice nada ("región 4") |
| Texto (`"azul_1"`) | Auto-descriptivo al debuggear | Más verboso |

**Decisión:** número. Como el color ya vive en `tipo`, un número solo no pierde contexto
real: se puede loguear como `"${region.tipo.color} #${region.identificador}"`.

---

## Regiones declaradas por lista de casillas, no por grilla de colores

**Por qué no era obvio:** el mapa podría declararse como una grilla 7×7 de colores, que
es como se ve en el manual.

| Alternativa | Ventaja | Desventaja |
|---|---|---|
| Grilla de colores | Se ve idéntica a la imagen del PDF | No dice a cuál de las dos regiones de un color pertenece cada casilla: habría que deducirlo por adyacencia en tiempo de ejecución |
| Lista de casillas por región (`['C1','C2','D2','D3']`) | Explícita: cada región sabe exactamente cuáles son sus casillas | Hay que transcribirla a mano |

**Decisión:** lista de casillas en notación. Es explícita y se lee casi igual que el
manual. El costo (transcribir a mano) se cubre con las validaciones automáticas de
`Tablero` — ver [[Modelo de dominio]].

---

## `extraerValores` como función pura, no como getter

**Por qué no era obvio:** podría ser simplemente `region.valores` como propiedad
derivada, que es idiomático en Dart.

**Decisión:** función pura en su propio archivo, manteniendo el mismo patrón que las
reglas de color (funciones puras independientes y testeables en aislado). Fue elección
explícita del usuario sobre la alternativa del getter.

**El problema que evita:** si la extracción fuera lo único que representa el contenido de
una región, la lista plana de valores descartaría de qué casilla vino cada uno. Eso
alcanza para las reglas, pero no para saber qué casilla concreta rompe una regla ni para
distinguir entre las dos regiones físicas de un mismo color. Por eso la `Region` guarda
sus `Celda` completas (cada una con su posición y valor) y tiene identificador propio:
`extraerValores` es solo la vista aplanada que las reglas necesitan, no la fuente de la
verdad.
