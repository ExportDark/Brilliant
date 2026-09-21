# Reglas del juego

Brilliant es un **roll & write** (tira los dados y anota): cada jugador tiene su propio
tablero de 7×7 dividido en zonas de color, todos comparten los mismos resultados de
dados en cada turno, pero cada quien decide dónde anotarlos en su propia hoja.

Ver también: [[Tablero y regiones]] · [[Puntuación]]

## Objetivo

Llenar la mayor cantidad de casillas posible respetando la regla de cada zona de color.
Entre más zonas completes cumpliendo su regla, mejor tablero terminas.

## Materiales

- Una hoja/tablero de 7×7 por jugador
- Dos dados de 6 caras
- Lápiz para anotar

## Reglas por color

Cada color impone una condición que deben cumplir, **en conjunto**, todas las casillas
de esa zona específica:

| Color | Regla | Qué significa |
|---|---|---|
| Amarillo | Todos diferentes | Las 5 casillas amarillas (dispersas por el tablero) cuentan como **una sola región**: no puede repetirse ningún valor entre ellas |
| Verde | Cualquiera | Sin restricción de valor: cualquier número de los dados en cualquier celda libre |
| Morado | Solo dos números diferentes | En toda la zona (6 celdas) puede haber como máximo **dos** valores distintos |
| Azul | Todos iguales | Las 4 celdas de la zona deben terminar con el **mismo** número |
| Rojo | Todos diferentes | Las 6 celdas deben terminar con 6 números todos distintos (una "corrida" del 1 al 6) |

> [!note] Sobre el amarillo
> El manual original describe el amarillo como "5 zonas de una sola casilla", lo que
> volvería la regla trivial. Se decidió tratarlas como una sola región lógica para que
> la regla tenga efecto real. Ver [[Modelado de regiones]].

## Desarrollo de un turno

1. **Preparación** (una sola vez, antes de la primera tirada): cada jugador anota los
   números del 1 al 6, sin repetir, uno en cada una de sus 6 casillas iniciales.
   Ver [[Tablero y regiones]].
2. Se tiran los dos dados. El resultado se anuncia para todos por igual.
3. Cada jugador elige, en privado y de forma simultánea, **UNO** de los dos números
   mostrados (no la suma, el valor de un dado).
4. Anota ese número en una casilla libre de su propio tablero (distinta de las 6
   iniciales, que ya están ocupadas), dentro de la zona de color donde quiera jugarlo,
   siempre que esa jugada no rompa la regla de esa zona.
5. El turno termina y se repite: se vuelven a tirar los dados hasta que los tableros se
   llenen o ya no haya jugadas legales.

## Fuente

Estas reglas salieron del PDF `Brilliant_Imitacion_Manual_y_Partidas.pdf`, que a su vez
se generó del archivo `jUEGUITO_OMG_1.xlsx`. El documento incluye dos partidas jugadas
que sirvieron para verificar la interpretación — ver
[[Decisiones de extracción del manual]].
