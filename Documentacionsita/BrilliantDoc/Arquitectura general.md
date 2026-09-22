# Arquitectura general

El diseño tiene **cuatro capas**, cada una respondiendo a una pregunta distinta y sin
saber casi nada de las demás.

Ver también: [[Modelo de dominio]] · [[Reglas de color en código]]

## Las 4 capas

### 1. ¿Dónde estoy? — `Posicion`

Un concepto puro de coordenadas (fila, columna). No sabe nada de colores, reglas ni
valores. Es solo "un lugar en la grilla". Ver [[Sistema de coordenadas]].

### 2. ¿Qué hay ahí? — `Celda`

Una posición + un valor (o vacío) + si es una casilla inicial. No sabe qué regla la
gobierna ni si su región está completa — solo es un dato.

### 3. ¿Qué regla aplica y a quién? — `TipoRegion` / `Region`

- `TipoRegion` es la idea abstracta de "un color de zona": qué regla de colocación le
  corresponde y cuántas casillas debe tener cada región de ese tipo. Es una definición,
  no una instancia física del tablero.
- `Region` es una instancia física concreta: un grupo real de casillas del tablero que
  comparte un `TipoRegion`. El tablero tiene 9 de estas.

La idea clave: **la regla no vive "suelta"** — vive pegada al tipo de región, y cada
región concreta sabe a cuál tipo pertenece. Así, validar un movimiento es siempre la
misma pregunta hecha de la misma forma: "¿esta región, con su regla, acepta este valor
nuevo?", sin importar si es rojo, verde o el color que sea.

### 4. ¿Cómo se arma todo y quién manda? — `Tablero` y los blocs

`Tablero` es el que conoce el layout fijo (qué región cae en qué posición) — es la única
pieza que "sabe todo" al construirse, y por eso puede armar las 9 regiones sin que nadie
tenga que buscar nada en tiempo de ejecución.

Encima van los **blocs**, uno por cada momento del juego: reciben lo que el jugador
intenta hacer, deciden si es válido y publican el estado resultante para que la pantalla
lo dibuje. El primero es `PreparacionBloc`, que administra el reparto de los valores
iniciales — ver [[Preparación de la partida]]. Faltan los dados, los turnos y la
validación de las jugadas contra las reglas de color.

## El principio que atraviesa todo

Cada capa solo sabe resolver una pregunta (posición, valor, regla, layout, turno) y
nunca se mete en el trabajo de la capa vecina.

## Qué permite este diseño

| Pregunta | Quién la responde | Por qué funciona |
|---|---|---|
| ¿Qué pasa cuando haya **nuevos mapas**? | Un `Tablero` nuevo | El tablero es solo un layout separado de las reglas: un mapa nuevo es un archivo nuevo, sin tocar ninguna regla |
| ¿Y si hay **colores nuevos** con reglas? | Un `TipoRegion` nuevo | Se suma el color al enum, se reusa o escribe una función de regla, y una clase que la envuelva — sin tocar los demás colores |
| ¿A quién le pregunto si algo **está lleno**? | `Celda` (una casilla) y `Region` (una zona) | Las reglas no lo saben: solo validan movimientos, no llevan la cuenta del progreso |
| ¿Quién sabe la **puntuación final**? | El módulo `puntuacion/` | Lee el tablero ya terminado; ni las reglas ni el tablero calculan puntos |
| ¿Quién sabe qué regiones **están terminadas**? | `Region` (y `Tablero` agregando) | Compara casillas llenas contra su tamaño; ver [[Modelado de regiones]] |

En resumen: separar "¿puedo poner esto aquí?" (reglas) de "¿qué hay en el tablero?"
(modelo) y de "¿cómo va la partida?" (juego/puntuación) permite que cada pregunta nueva
se resuelva agregando código en su capa, sin tocar lo que ya funciona y ya está probado.

## Estructura de carpetas

```
lib/
  modelo/     Posicion, Celda, Color5, TipoRegion, Region, extraerValores, Tablero
  reglas/     ReglaColor + funciones puras + una clase por color
  juego/      PreparacionBloc con su estado y sus eventos
              (faltan: dados, turnos, validación de movimientos)
  puntuacion/ cálculo de puntaje                                        (pendiente)
  ui/         widgets y pantallas
test/         misma estructura que lib/, un test por archivo de lógica
```
