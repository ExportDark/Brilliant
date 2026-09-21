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

## Decisión 2: renglón/columna, no plano cartesiano

**Por qué no era obvio:** ambas son "dos enteros"; la diferencia real es el nombre, el
origen y la dirección de los ejes.

| Criterio | Renglón/columna (`fila`, `columna`) | Plano cartesiano (`x`, `y`) |
|---|---|---|
| Fuente de la verdad (el manual) | El tablero está documentado como tabla: fila 1..7 × columna A..G. Traducción directa | Habría que convertir en cada lectura |
| Renderizado en Flutter | `GridView`/`Table`/`Column`+`Row` iteran filas arriba→abajo, columnas izq→der. Calza 1:1 | Hay que invertir el eje Y para dibujar |
| Indexado de matriz | Convención universal `matriz[fila][columna]`; aplanar es `fila * 7 + columna` | Requiere recordar si es `[x][y]` o `[y][x]` |
| Ambigüedad de ejes | Ninguna | El eje Y crece hacia arriba en matemáticas y hacia abajo en pantalla — fuente clásica de bugs |
| Geometría (rotar, reflejar, vectores) | Se puede igual, con offsets `fila±1`, `columna±1` | Su única ventaja real |

**Decisión:** renglón/columna. La ventaja del cartesiano solo se paga con
transformaciones geométricas (rotar mapas, generar variantes reflejadas, distancias
vectoriales), y en Brilliant las regiones son fijas y transcritas del manual. Lo único
"dinámico" es que otro mapa tendrá otro layout, no que el mismo layout se transforme. No
había nada que ganar y sí un riesgo concreto que asumir.

Tampoco encierra: cambiarlo después sería un rename, no una reescritura.

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
