# Modelo de dominio

Las entidades de `lib/modelo/`, de la más simple a la que las agrupa a todas.

Ver también: [[Arquitectura general]] · [[Modelado de regiones]] · [[Tablero y regiones]]

## `Color5` (`color5.dart`)

Enum con los 5 colores de zona: `amarillo`, `verde`, `morado`, `azul`, `rojo`.

## `Posicion` (`posicion.dart`)

Value object `{fila, columna}`, ambas base 0. Tiene igualdad por valor (`==` y
`hashCode`), lo que permite usarla como llave de un `Map` — que es justamente cómo
`Tablero` indexa sus casillas.

Convierte con la notación del manual (letra = columna, número = fila):

```dart
Posicion.desdeNotacion('C1')   // Posicion(fila: 0, columna: 2)
posicion.notacion              // "C1"
```

Ver [[Sistema de coordenadas]] para el porqué de esta elección.

## `Celda` (`celda.dart`)

Entidad **inmutable** que representa una casilla:

- `posicion`: su `Posicion` fija en la grilla
- `color`: el `Color5` de su región (determina qué regla aplica)
- `valor`: el número 1-6 anotado, o `null` si sigue vacía
- `esInicial`: si es una de las 6 casillas que se llenan en la preparación

`conValor(nuevoValor)` devuelve una **copia** con el valor anotado, sin mutar la
original. `estaVacia` dice si todavía no tiene valor. Un `assert` rechaza valores fuera
del rango 1-6.

## `TipoRegion` (`tipo_region.dart`)

`{color, regla, cantidadCeldas}` — une cada color con su `ReglaColor` ya instanciada y
con cuántas casillas debe tener cada región de ese tipo **en este mapa**.

Hay 5 constantes ya armadas para el mapa actual:

| Constante | Color | Regla | cantidadCeldas |
|---|---|---|---|
| `tipoAmarillo` | amarillo | `ReglaAmarillo` | 5 |
| `tipoVerde` | verde | `ReglaVerde` | 6 |
| `tipoMorado` | morado | `ReglaMorado` | 6 |
| `tipoAzul` | azul | `ReglaAzul` | 4 |
| `tipoRojo` | rojo | `ReglaRojo` | 6 |

## `Region` (`region.dart`)

`{identificador, tipo, casillas}` — una zona física concreta del tablero.

- `completada` es un **getter calculado** (`casillas.every((c) => !c.estaVacia)`), nunca
  un campo guardado
- Al construirse valida que `casillas.length == tipo.cantidadCeldas`

Ver [[Modelado de regiones]] para el razonamiento detrás de cada decisión.

## `extraerValores` (`extraer_valores.dart`)

Función pura `List<int> extraerValores(Region region)`: los valores ya anotados en la
región, saltándose las casillas vacías. Es lo único que consumen las reglas de color.

Si algo necesita saber la posición o la casilla exacta, accede directo a
`region.casillas` sin pasar por esta función — cada `Celda` ya trae su posición y su
valor.

## `Tablero` (`tablero.dart`)

`Tablero.mapaOriginal()` arma el mapa 7×7 del manual con sus 9 regiones.

Cada región se declara con la **lista de sus casillas en notación**:

```dart
_construirRegion(4, tipoAzul, ['C1', 'C2', 'D2', 'D3']),
```

y no como una grilla de colores, porque una grilla sola no dice a cuál de las dos
regiones de un mismo color pertenece cada casilla — habría que deducirlo por adyacencia
en tiempo de ejecución. Declaradas así, el layout se lee igual que el manual.

**Se valida solo al construirse** (el layout está transcrito a mano, así que un error
de dedo es plausible):

- ninguna casilla declarada en dos regiones
- ninguna casilla de la grilla sin cubrir
- ninguna casilla declarada fuera de la grilla
- cada región con la cantidad de casillas de su tipo (vía `Region`)

Cualquiera de estos falla al instante diciendo **qué casilla** en notación del manual.

Consultas: `regiones`, `celdas`, `celdaEn(posicion)`, `regionEn(posicion)`.
