# Tablero y regiones

El tablero es una grilla **fija** de 7×7 (49 casillas), dividida en **9 regiones** de
color. El layout es siempre el mismo en este mapa.

Ver también: [[Reglas del juego]] · [[Sistema de coordenadas]] · [[Modelo de dominio]]

## El mapa

Columnas A–G (izquierda a derecha), filas 1–7 (arriba a abajo). `(F)` marca las
casillas iniciales fijas.

| Fila | A | B | C | D | E | F | G |
|---|---|---|---|---|---|---|---|
| 1 | Amarillo | Verde | **Azul (F)** | Morado | Morado | Morado | Amarillo |
| 2 | Verde | Verde | Azul | Azul | Morado | **Morado (F)** | Verde |
| 3 | Verde | Rojo | Rojo | Azul | Morado | Verde | Verde |
| 4 | Verde | **Rojo (F)** | Morado | Amarillo | **Verde (F)** | Verde | Verde |
| 5 | Verde | Rojo | Morado | Morado | Rojo | Rojo | Azul |
| 6 | Rojo | Rojo | **Morado (F)** | Rojo | Rojo | Azul | Azul |
| 7 | Amarillo | Morado | Morado | Rojo | **Rojo (F)** | Azul | Amarillo |

## Las 9 regiones

Cada región se valida de forma **independiente** de las demás, incluso de las del mismo
color: las dos regiones rojas, por ejemplo, cada una necesita su propia corrida del 1
al 6 — no comparten valores entre sí.

| # | Color | Casillas | Cantidad |
|---|---|---|---|
| 1 | Amarillo | A1, G1, D4, A7, G7 | 5 |
| 2 | Verde | B1, A2, B2, A3, A4, A5 | 6 |
| 3 | Verde | G2, G3, F3, E4, F4, G4 | 6 |
| 4 | Azul | C1, C2, D2, D3 | 4 |
| 5 | Azul | G5, G6, F6, F7 | 4 |
| 6 | Morado | D1, E1, F1, E2, F2, E3 | 6 |
| 7 | Morado | C4, C5, D5, C6, C7, B7 | 6 |
| 8 | Rojo | B3, C3, B4, B5, B6, A6 | 6 |
| 9 | Rojo | E5, F5, E6, D6, D7, E7 | 6 |

Totales por color: amarillo 5, verde 12, azul 8, morado 12, rojo 12 → **49 casillas**.

El amarillo es la única región con casillas **no contiguas**: sus 5 celdas están sueltas
por el tablero pero forman una sola región lógica. Ver [[Modelado de regiones]].

## Casillas iniciales

Seis casillas — **C1, F2, B4, E4, C6, E7** — son siempre las mismas, sin importar el
color de fondo que les toque. No se llenan con los dados: en la preparación, antes de
tirar, el jugador coloca en ellas los números del 1 al 6, uno en cada casilla, sin
repetir (una permutación completa del 1 al 6).

Cuatro de las seis caen dentro de una zona con regla, y el número que elijas ahí queda
fijo desde el arranque, condicionando el resto de esa zona:

| Casilla | Región | Efecto |
|---|---|---|
| C1 | Azul #4 | Define de una vez cuál será el número único de toda la zona |
| F2 | Morado #6 | Consume uno de los dos números permitidos |
| C6 | Morado #7 | Consume uno de los dos números permitidos |
| B4 | Rojo #8 | Reserva uno de los seis números de la corrida |
| E7 | Rojo #9 | Reserva uno de los seis números de la corrida |
| E4 | Verde #3 | Sin efecto: el verde no tiene restricción de valor |

Por eso la preparación es una decisión estratégica del jugador, no un reparto aleatorio.

## Cómo está en el código

`Tablero.mapaOriginal()` (`lib/modelo/tablero.dart`) declara estas 9 regiones con la
lista de casillas en notación, tal cual aparecen en la tabla de arriba, y valida al
construirse que el layout cubra la grilla exactamente una vez.
Ver [[Modelo de dominio]].
