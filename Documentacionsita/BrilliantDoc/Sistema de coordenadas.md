# Sistema de coordenadas

Cómo se representa "dónde está una casilla". Implementado en `lib/modelo/posicion.dart`.

Ver también: [[Modelo de dominio]] · [[Decisiones de extracción del manual]]

---

## Decisión 1: `Posicion` como clase propia, no campos sueltos

**Por qué no era obvio:** `Celda` originalmente tenía `fila` y `columna` como dos enteros
sueltos, lo cual funcionaba perfectamente bien.

| Alternativa | Ventaja | Desventaja |
|---|---|---|
| `Posicion{fila, columna}` como clase | Se puede pasar y comparar una posición sola (útil para validar movimientos); permite `Map<Posicion, Celda>` | Una clase más, un nivel de indirección |
| `fila`/`columna` sueltos en `Celda` | Más directo, menos clases | La posición no es un concepto reusable sin arrastrar la `Celda` entera |

**Decisión:** clase propia. Obligó a refactorizar la `Celda` ya construida (commit
`befd8da`), pero se paga solo: `Tablero` indexa sus casillas con `Map<Posicion, ...>`
gracias a que `Posicion` tiene igualdad por valor, y la futura validación de movimientos
podrá recibir una posición sin más contexto.

---

## Decisión 2: coordenadas de renglón y columna

`Posicion` guarda una **fila** y una **columna**, ambas base 0. Las razones:

| Criterio | Por qué encaja |
|---|---|
| Fuente de la verdad (el manual) | El tablero está documentado como tabla: fila 1..7 × columna A..G. La traducción es directa, sin conversiones |
| Renderizado en Flutter | `GridView`, `Table` y `Column`+`Row` iteran filas de arriba a abajo y columnas de izquierda a derecha. Calza 1:1 con cómo se dibuja |
| Indexado de matriz | Sigue la convención universal `matriz[fila][columna]`; aplanar la grilla es `fila * 7 + columna` |
| Claridad | "Fila" y "columna" nombran exactamente lo que son en un tablero, sin que haya que recordar cuál eje es cuál ni en qué dirección crece |

Para las transformaciones geométricas que pudieran hacer falta más adelante (moverse a
una casilla vecina, por ejemplo) basta con desplazamientos sobre esos mismos campos:
`fila ± 1`, `columna ± 1`.

---

## La notación del manual

Independiente de las dos decisiones anteriores, `Posicion` sabe convertir con la
notación del documento (letra = columna, número = fila):

```dart
Posicion.desdeNotacion('C1')   // Posicion(fila: 0, columna: 2)
posicion.notacion              // "C1"
```

**Por qué existe:** el manual, esta documentación y las conversaciones del proyecto usan
todas esa notación. Tenerla en el código significa que:

- el layout de `Tablero` se escribe y se lee casi igual que el PDF
- los errores de validación dicen *"la casilla C6 está declarada dos veces"* en vez de
  *"fila 5, columna 2"*
- `toString()` de una posición imprime `Posicion(C1)`

Está testeada de ida y vuelta para las 49 casillas del tablero y para las 6 casillas
iniciales.
