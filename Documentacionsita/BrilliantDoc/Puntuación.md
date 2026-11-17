# Puntuación

Cómo se ganan puntos. En el **multijugador** hay una tabla de puntos por zona, decidida
el 2026-11-10 y aplicada por el servidor. En el modo de **un jugador** todavía no hay
puntaje (ver abajo).

Ver también: [[Multijugador]] · [[Reglas del juego]] · [[Mapas]] · [[Estado del proyecto]]

## En el multijugador: puestos por zona

Cada zona completa da puntos según **el puesto en que se llena** (1.º, 2.º o 3.º) y según
el mapa y el color. Del 4.º en adelante, 0. Una zona está llena cuando todas sus casillas
tienen número (las reglas de color ya garantizan que cumple).

### La tabla (1.º / 2.º / 3.º)

| Color | Mapa 1 | Mapa 2 | Mapa 3 | Mapa 4 |
|---|---|---|---|---|
| Azul | 7 / 5 / 3 | 7 / 5 / 3 | 7 / 5 / 3 | 8 / 6 / 4 |
| Verde | 4 / 3 / 2 | 4 / 3 / 2 | 6 / 5 / 4 | 3 / 2 / 1 |
| Rojo | 6 / 4 / 2 | 6 / 4 / 2 | 6 / 4 / 2 | 6 / 4 / 2 |
| Morado | 6 / 4 / 2 | 6 / 4 / 2 | 7 / 5 / 3 | 7 / 5 / 3 |
| Amarillo | 8 / 6 / 4 | 6 / 4 / 2 | 7 / 5 / 3 | 8 / 6 / 4 |
| Gris | — | 3 / 2 / 1 | 8 / 6 / 4 | — |
| Naranja | — | — | — | 6 / 4 / 3 |

Los mapas 1 a 4 son los niveles 1 a 4 de [[Mapas]].

### Las reglas del puesto

- **Cada zona paga por separado**, con sus propios tres puestos. Hay colores con dos zonas
  (por ejemplo, las dos azules del mapa 1): si alguien se lleva el 1.º de una, la otra
  sigue pagando el 1.º al primero que la llene. El amarillo y el gris, de casillas
  sueltas, cuentan como una sola zona; las dos naranjas del mapa 4 pagan igual.
- Quien la llena en una ronda en que otro ya la había llenado antes toma el siguiente
  puesto libre.
- **Si varios la llenan en la misma ronda, todos toman el mismo puesto**, y se salta el
  siguiente: dos 1.º, y el siguiente es 3.º.
- Una zona con los tres puestos tomados queda **agotada**.
- **Gana el primero que llega a la meta** (ver abajo). Si nadie llega, gana quien más
  puntos sume al terminar. En los dos casos, si empatan, quien tenga más 1.º; si siguen
  empatados, ganan todos. Quien se rinde o se desconecta conserva sus puntos, pero no
  puede ganar.

La tabla vive en `Brilliant-servidor/juego/puntuacion.py` y los puestos se reparten al
cerrar cada ronda (`salas/dominio.py`). La app no calcula nada: muestra lo que manda el
servidor en el panel de zonas y en el resultado.

### La meta (2026-11-17)

Gana la partida **el primero que llega a la meta de puntos**, que depende de cuántos la
empiezan: con más jugadores las zonas se reparten entre más, así que la meta baja.

| Jugadores | Meta |
|---|---|
| 2 | 26 |
| 3 | 24 |
| 4 | 22 |
| 5 | 20 |
| 6 | 20 |

- **Se fija al empezar** (con los que empiezan) y no cambia si después alguien se va: así
  nadie gana ni pierde de golpe porque otro se rindió.
- Los puntos se reparten al cerrar cada ronda: **si alguien llegó, la partida termina
  ahí** ("Se alcanzó la meta: 26 puntos."). Si llegan varios en la misma ronda, gana el
  de más puntos, con el desempate de siempre.
- Quien se fue no termina la partida ni gana, aunque tenga más puntos.
- Si nadie llega, termina como antes: todos llenaron su tablero o nadie puede jugar.
- Es alcanzable: en el Nivel 1, los 1.º de todas las zonas suman 54. En las partidas
  simuladas (2 a 6 jugadores, los 4 mapas) todas terminaron por la meta.
- Se ve en el lobby ("Gana el primero que llegue a 26 puntos. Con más jugadores, la meta
  baja."), en el marcador (la nota y una **pista de puntos** en cada fila, que se llena
  hasta la meta), en la hoja de reglas y en el resultado.

Vive en `Brilliant-servidor/juego/puntuacion.py` (`META_POR_JUGADORES`, `meta_para`); el
servidor la manda en la sala (`meta`).

## En el modo de un jugador: sin puntaje todavía

> [!important] Con las reglas actuales, el tablero siempre se llena (2026-10-08)
> Las 10 partidas simuladas de [[Pruebas]] terminaron con **49 de 49 casillas**; solo
> varió cuántos turnos tardaron (entre 58 y 104). Ninguna zona se queda sin salida, y
> toda casilla vacía termina pegada a una llena. Por eso "1 punto por casilla" o "zona
> completada" no distinguiría a nadie jugando solo.

Opciones para cuando se decida: contar los turnos que se tardó en llenar el tablero (o
los pasados), o fijar un número de rondas, como en las partidas del PDF (que terminaron con
34 y 31 casillas llenas). En el multijugador esto no hace falta: se compite por **quién
llena cada zona primero**.

## Fin de la partida

Termina cuando ninguna tirada posible tiene jugada: no hay combinación de dado ancla y
número del 1 al 6 que quepa en ninguna casilla libre, pegada a una casilla con el número
del dado ancla, sin romper la regla de su región. En el multijugador termina antes, en
cuanto alguien llega a la meta; si nadie llega, cuando eso pasa para todos los que siguen
en la partida (o todos llenaron su tablero). Ver [[Turnos y jugadas]].
