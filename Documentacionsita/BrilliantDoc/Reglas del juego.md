# Reglas del juego

Brilliant es un **roll & write** (tira los dados y anota): cada jugador tiene su propio
tablero de 7×7 dividido en zonas de color (hay 4 mapas para elegir, ver [[Mapas]]), todos comparten los mismos resultados de
dados en cada turno, pero cada quien decide dónde anotarlos en su propia hoja.

Ver también: [[Tablero y regiones]] · [[Puntuación]]

## Objetivo

Llenar la mayor cantidad de casillas posible respetando la regla de cada zona de color.
Entre más zonas completes cumpliendo su regla, mejor tablero terminas.

> [!important] Con las reglas de este proyecto, el tablero siempre se llena
> Jugando sin límite de turnos, toda partida termina con las 49 casillas llenas: lo que
> cambia es cuántos turnos tarda. Este objetivo, tal como lo plantea el manual, supone un
> número fijo de rondas. Ver [[Puntuación]].

## Materiales

- Una hoja/tablero de 7×7 por jugador
- Dos dados de 6 caras
- Lápiz para anotar

## Reglas por color

Cada color impone una condición que deben cumplir, **en conjunto**, todas las casillas
de esa zona específica:

| Color | Regla | Qué significa |
|---|---|---|
| Amarillo | Todos diferentes | Las casillas amarillas (dispersas por el tablero) cuentan como **una sola región**: no puede repetirse ningún valor entre ellas |
| Verde | Cualquiera | Sin restricción de valor: cualquier número de los dados en cualquier celda libre |
| Morado | Solo dos números diferentes | En toda la zona puede haber como máximo **dos** valores distintos |
| Azul | Todos iguales | Las celdas de la zona deben terminar con el **mismo** número |
| Rojo | Todos diferentes | Ningún número se repite en la zona; con 6 celdas, es una "corrida" del 1 al 6 |
| Gris | Todos iguales | Como el azul. Solo en los niveles 2 y 3 |
| Naranja | 1-3 o 4-6 | Solo números de ese rango, aunque la zona esté vacía. Solo en el Nivel 4 |

Cuántas casillas tiene cada zona depende del mapa. Las del Nivel 1 están en
[[Tablero y regiones]], y las de los otros en [[Mapas]].

> [!note] Sobre el amarillo
> El manual original describe el amarillo como "5 zonas de una sola casilla", lo que
> volvería la regla trivial. Se decidió tratarlas como una sola región lógica para que
> la regla tenga efecto real. Ver [[Modelado de regiones]].

## Desarrollo de un turno

1. **Preparación** (una sola vez, antes de la primera tirada): cada jugador anota los
   números del 1 al 6, sin repetir, uno en cada una de sus 6 casillas iniciales, las que
   en la tarjeta llevan una estrellita, cada una en una zona distinta. Si una cae en una
   zona naranja, el número tiene que ser de su rango. Ver [[Mapas]].
2. Se tiran los dos dados. El resultado se anuncia para todos por igual.
3. Cada jugador elige, en privado y de forma simultánea, **UNO** de los dos dados como
   **dado ancla** (no la suma, el valor de un dado). El ancla es solo ese dado: dice qué
   número buscar en el tablero.
4. Anota **el otro dado** en una casilla libre de su tablero **pegada a una casilla que
   tenga el número del dado ancla**: arriba, abajo, a la izquierda o a la derecha, nunca en
   diagonal. La jugada tampoco puede romper la regla de color de esa zona.
   *Ejemplo:* salen 2 y 4. Si el dado ancla es el 4, se buscan en el tablero las casillas
   que tienen un 4, y el 2 va en una casilla libre junto a cualquiera de ellas.
5. El turno termina y se repite: se vuelven a tirar los dados hasta que los tableros se
   llenen o ya no haya jugadas legales. Si en una tirada no hay jugada con ninguno de los
   dos dados como ancla, se pasa el turno.

> [!warning] La regla del ancla no viene del manual
> El PDF dice que el número se anota en *cualquier* casilla libre de la zona que se
> quiera. La regla del ancla (el otro dado va pegado a una casilla con el número del dado
> ancla) es una
> decisión del proyecto del 2026-10-04, para que cada jugada dependa de cómo va el tablero.
> Ver [[Turnos y jugadas]].

## Fuente

Estas reglas salieron del PDF `Brilliant_Imitacion_Manual_y_Partidas.pdf`, que a su vez
se generó del archivo `jUEGUITO_OMG_1.xlsx`. El documento incluye dos partidas jugadas
que sirvieron para verificar la interpretación — ver
[[Decisiones de extracción del manual]].
