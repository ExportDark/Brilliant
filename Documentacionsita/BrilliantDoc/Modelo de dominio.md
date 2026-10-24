# Modelo de dominio

Las entidades de `lib/modelo/`, de la más simple a la que las agrupa a todas.

Ver también: [[Arquitectura general]] · [[Modelado de regiones]] · [[Tablero y regiones]]

## `ColorZona` (`color_zona.dart`)

Enum con los colores de zona: `amarillo`, `verde`, `morado`, `azul`, `rojo`, `gris` y
`naranja`. El gris y el naranja solo aparecen en algunos mapas. Hasta el 2026-10-24 se
llamaba `Color5`, y se renombró al sumar esos dos. Ver [[Mapas]].

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

`posicion.vecinas` da las 4 posiciones pegadas: arriba, abajo, izquierda y derecha, sin
diagonales. Es lo que usa la regla del ancla ([[Turnos y jugadas]]). `Posicion` no sabe
el tamaño del tablero, así que en los bordes algunas vecinas caen fuera de la grilla:
quien las use las descarta (`tablero.celdaEn` devuelve `null` para esas).

## `Celda` (`celda.dart`)

Entidad **inmutable** que representa una casilla:

- `posicion`: su `Posicion` fija en la grilla
- `color`: el `ColorZona` de su región (determina qué regla aplica)
- `valor`: el número 1-6 anotado, o `null` si sigue vacía
- `esInicial`: si es una de las 6 casillas que se llenan en la preparación (las decide
  el mapa)

`conValor(nuevoValor)` devuelve una **copia** con el valor anotado, sin mutar la
original. `estaVacia` dice si todavía no tiene valor. Un `assert` rechaza valores fuera
del rango 1-6.

## `TipoRegion` (`tipo_region.dart`)

`{color, regla}` — une cada color con su `ReglaColor` ya instanciada. Cuántas casillas
tiene cada zona no es parte del tipo: lo decide el mapa al declarar sus zonas.

| Constante | Color | Regla |
|---|---|---|
| `tipoAmarillo` | amarillo | `ReglaAmarillo` |
| `tipoVerde` | verde | `ReglaVerde` |
| `tipoMorado` | morado | `ReglaMorado` |
| `tipoAzul` | azul | `ReglaAzul` |
| `tipoRojo` | rojo | `ReglaRojo` |
| `tipoGris` | gris | `ReglaGris` |
| `tipoNaranjaBajo` | naranja | `ReglaNaranja(1, 3)` |
| `tipoNaranjaAlto` | naranja | `ReglaNaranja(4, 6)` |

## `Region` (`region.dart`)

`{identificador, tipo, casillas}` — una zona física concreta del tablero.

- `completada` es un **getter calculado** (`casillas.every((c) => !c.estaVacia)`), nunca
  un campo guardado
- Puede tener cualquier cantidad de casillas: el tamaño lo pone el mapa

Ver [[Modelado de regiones]] para el razonamiento detrás de cada decisión.

## `extraerValores` (`extraer_valores.dart`)

Función pura `List<int> extraerValores(Region region)`: los valores ya anotados en la
región, saltándose las casillas vacías. Es lo único que consumen las reglas de color.

Si algo necesita saber la posición o la casilla exacta, accede directo a
`region.casillas` sin pasar por esta función — cada `Celda` ya trae su posición y su
valor.

## `Mapa` (`mapa.dart`)

`{nivel, casillasIniciales, zonas}` — uno de los 4 mapas oficiales: sus zonas, cada una
con su tipo y sus casillas, y sus 6 casillas iniciales en el orden en que se van
seleccionando en la preparación. `nombre` da "Nivel 2".

Están las constantes `nivel1` a `nivel4` y la lista `mapas`. Ver [[Mapas]].

## `Tablero` (`tablero.dart`)

`Tablero.desdeMapa(mapa)` arma el tablero 7×7 de un mapa. Las regiones se numeran desde
1 en el orden en que el mapa declara sus zonas. `Tablero.mapaOriginal()` es un atajo de
`Tablero.desdeMapa(nivel1)`, que usan muchos tests.

Cada zona se declara con la **lista de sus casillas en notación**:

```dart
(tipo: tipoAzul, casillas: ['C1', 'C2', 'D2', 'D3']),
```

y no como una grilla de colores, porque una grilla sola no dice a cuál de las dos
regiones de un mismo color pertenece cada casilla — habría que deducirlo por adyacencia
en tiempo de ejecución. Declaradas así, el layout se lee igual que el manual.

**Se valida solo al construirse** (el layout está transcrito a mano, así que un error
de dedo es plausible):

- ninguna casilla declarada en dos regiones
- ninguna casilla de la grilla sin cubrir
- ninguna casilla declarada fuera de la grilla

Cualquiera de estos falla al instante diciendo **qué casilla** en notación del manual.

Consultas: `regiones`, `celdas`, `celdaEn(posicion)`, `regionEn(posicion)`.

Para anotar: `conValor(posicion, valor)`, `conValores({posicion: valor, ...})` y
`sinValor(posicion)`. Devuelven un tablero **nuevo** sin mutar el original. `conValores`
es el puente entre lo que el jugador reparte en la preparación y el tablero que se dibuja
en pantalla.
