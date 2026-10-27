# Mapas

Los 4 mapas oficiales que se pueden jugar, el "Level 1" a "Level 4" de las tarjetas del
juego. Están en `lib/modelo/mapa.dart` y se arman con `Tablero.desdeMapa(mapa)`.

Ver también: [[Tablero y regiones]] · [[Reglas de color en código]] · [[Modelo de dominio]]

## Los 4 mapas

Fila por fila, de arriba abajo. Am amarillo, Ve verde, Az azul, Mo morado, Ro rojo,
Gr gris, Na naranja.

```
Nivel 1               Nivel 2               Nivel 3               Nivel 4
Am Ve Az Mo Mo Mo Am  Mo Mo Mo Gr Ve Ve Ve  Am Am Mo Gr Mo Am Am  Na Na Na Na Na Na Na
Ve Ve Az Az Mo Mo Ve  Mo Am Az Az Az Am Ve  Gr Am Mo Mo Mo Am Gr  Am Ro Az Ve Az Ro Am
Ve Ro Ro Az Mo Ve Ve  Mo Ro Ro Az Az Ro Ve  Ro Ro Ro Mo Ro Ro Ro  Ro Ro Mo Mo Mo Ro Ro
Ve Ro Mo Am Ve Ve Ve  Ro Ro Ro Am Ro Ro Ro  Ro Ro Ro Gr Ro Ro Ro  Am Ve Az Mo Az Ve Am
Ve Ro Mo Mo Ro Ro Az  Ve Ro Az Az Ro Ro Mo  Ve Az Az Az Az Az Ve  Ro Ro Mo Mo Mo Ro Ro
Ro Ro Mo Ro Ro Az Az  Ve Am Az Az Az Am Mo  Ve Ve Ve Ve Ve Ve Ve  Am Ro Az Ve Az Ro Am
Am Mo Mo Ro Ro Az Am  Ve Ve Ve Gr Mo Mo Mo  Mo Mo Mo Gr Mo Mo Mo  Na Na Na Na Na Na Na
```

El **Nivel 1** es el mapa del manual de la imitación, el que el juego tuvo siempre. Sus
zonas están en [[Tablero y regiones]].

### Nivel 2: 10 zonas

| Zona | Casillas |
|---|---|
| amarilla | B2 F2 D4 B6 F6 |
| verde de arriba | E1 F1 G1 G2 G3 |
| verde de abajo | A5 A6 A7 B7 C7 |
| azul de arriba | C2 D2 E2 D3 E3 |
| azul de abajo | C5 D5 C6 D6 E6 |
| morada de arriba | A1 B1 C1 A2 A3 |
| morada de abajo | G5 G6 E7 F7 G7 |
| roja izquierda | B3 C3 A4 B4 C4 B5 |
| roja derecha | F3 E4 F4 G4 E5 F5 |
| gris | D1 D7 |

### Nivel 3: 8 zonas

| Zona | Casillas |
|---|---|
| amarilla | A1 B1 B2 F1 G1 F2 |
| verde | A5 G5 y la fila 6 entera (9 casillas) |
| azul | B5 C5 D5 E5 F5 |
| morada de arriba | C1 E1 C2 D2 E2 D3 |
| morada de abajo | A7 B7 C7 E7 F7 G7 |
| roja izquierda | A3 B3 C3 A4 B4 C4 |
| roja derecha | E3 F3 G3 E4 F4 G4 |
| gris | D1 A2 G2 D4 D7 |

### Nivel 4: 8 zonas

| Zona | Casillas |
|---|---|
| amarilla | A2 G2 A4 G4 A6 G6 |
| verde | D2 B4 F4 D6 |
| azul | C2 E2 C4 E4 C6 E6 |
| morada | C3 D3 E3 D4 C5 D5 E5 |
| roja izquierda | B2 A3 B3 A5 B5 B6 |
| roja derecha | F2 F3 G3 F5 G5 F6 |
| naranja "4-6" | la fila 1 entera |
| naranja "1-3" | la fila 7 entera |

Como el amarillo del Nivel 1, varias zonas tienen casillas sueltas que cuentan como una
sola zona: la gris de los niveles 2 y 3, y la amarilla, la verde y la azul del Nivel 4.

## En la app

La app abre en **"Elige un mapa"**, con las 4 tarjetas y su tablero en miniatura. Al
tocar una se pasa a la preparación de ese mapa, y de ahí a la partida. La barra superior
de las dos dice el nivel. "Jugar otra vez" repite el mismo mapa, y la flecha de atrás
vuelve a elegir (a mitad de partida, pregunta antes). Ver [[Interfaz del tablero]] y
[[Turnos y jugadas]].

## Las reglas, por símbolo

En las tarjetas, cada zona tiene un símbolo al costado. La regla depende del símbolo, y
cada color tiene siempre el mismo, menos el naranja:

| Símbolo | Regla | Colores |
|---|---|---|
| ≠ | Todos diferentes | rojo, amarillo |
| = | Todos iguales | azul, **gris** |
| ? | Cualquiera | verde |
| XO | Solo dos números distintos | morado |
| 1-3 / 4-6 | Solo números de ese rango | **naranja** |

El gris y el naranja solo aparecen en estos mapas. Están en `ReglaGris` y
`ReglaNaranja(minimo, maximo)`; cada zona naranja trae su rango (`tipoNaranjaBajo` y
`tipoNaranjaAlto`). Ver [[Reglas de color en código]].

Una zona naranja puede rechazar un número aunque esté vacía: un 2 no cabe en la fila
"4-6". Ninguna otra regla rechaza nada en una zona vacía.

## Las casillas iniciales

En las tarjetas del juego, las casillas iniciales llevan una **estrellita**: ahí se anotan
los números del 1 al 6 antes de la primera tirada, uno en cada zona.

| Mapa | Casillas iniciales |
|---|---|
| Nivel 1 | C1, F2, B4, E4, C6, E7 |
| Nivel 2 | E1, A3, C4, F5, B6, E7 |
| Nivel 3 | C2, F2, D4, B5, G5, C7 |
| Nivel 4 | E1, C3, F3, A4, E6, B7 |

En la foto original las estrellas no se distinguían, y el 2026-10-24 se eligieron otras a
criterio propio. El 2026-10-26 el usuario marcó las estrellas de cada tarjeta en la foto
con una estrella negra, y se detectaron por píxel: 6 por nivel, cada una en el centro de
su casilla. Las del Nivel 1 coincidieron con las que ya tenía el juego, lo que confirmó la
lectura.

En cada mapa caen en 6 zonas distintas. En el Nivel 4, **dos caen en las zonas
naranjas**: E1 en la fila "4-6" y B7 en la "1-3". Ahí no cabe cualquier número:

- en E1 solo se puede poner un 4, un 5 o un 6, y en B7 un 1, un 2 o un 3;
- la preparación apaga las fichas que no caben en la casilla seleccionada, y el bloc
  ignora un número que no cabe;
- **Aleatorio** solo reparte números que caben. Si lo ya puesto no deja completar (por
  ejemplo, ya se usaron el 4, el 5 y el 6 y E1 sigue vacía), revuelve todo desde cero.

Lo decide `Tablero.aceptaComoInicial(posicion, valor)`: si la regla de la zona, vacía,
acepta ese número. Como cada inicial está en una zona distinta, solo una zona naranja
puede rechazar algo. Ver [[Preparación de la partida]].

Las reglas del juego también permiten, en partidas avanzadas, elegir libremente dónde van
los números iniciales, siempre en zonas distintas. Eso no está implementado: la app usa
siempre las de la estrellita.

## Cómo se transcribió la foto

Los mapas salieron de una foto de las 4 tarjetas (`imagen (1).png`, que no se sube al
repo, igual que el PDF del manual). En vez de leerla a ojo:

1. Se decodificó el PNG con la biblioteca estándar de Python (zlib), sin instalar nada.
2. Se ubicó la cuadrícula de cada tarjeta y se midió el color promedio del centro de
   cada una de las 49 casillas.
3. Cada casilla se clasificó por su tono:

   | Color | Tono | Saturación |
   |---|---|---|
   | rojo | 20–26° | |
   | naranja | 40–42° | |
   | amarillo | 52–58° | |
   | verde | 92–110° | |
   | azul | 185–192° | |
   | morado | 238–284° | baja |
   | gris | | menor a 11 %, con un tono distinto al del morado |

4. **El Level 1 coincidió casilla por casilla con el mapa que ya tenía el juego**, lo que
   confirmó la lectura de los otros tres.

Las zonas se separaron contando los símbolos a los costados de cada tarjeta: hay uno por
zona (9 en el Nivel 1, 10 en el 2, 8 en el 3 y en el 4). Cuando un color tiene dos zonas,
se separan por lado del tablero.

Las estrellitas de las casillas iniciales no se distinguen en la foto original: son
chicas y se confunden con los reflejos. Ver "Las casillas iniciales", arriba.

## Cómo juegan

Con dados al azar, las 10 partidas simuladas de cada mapa terminan con **las 49 casillas
llenas**, igual que el Nivel 1. Con los dados sin azar del camino feliz, cada mapa dura
siempre lo mismo:

| Mapa | Camino feliz | Partidas al azar |
|---|---|---|
| Nivel 1 | 73 turnos | 58 a 104 turnos |
| Nivel 2 | 73 turnos | 58 a 99 turnos |
| Nivel 3 | 51 turnos | 54 a 101 turnos |
| Nivel 4 | 52 turnos | 50 a 79 turnos |

Ver [[Pruebas]].

## Lo que quedó fuera

Las tarjetas traen más cosas, que son de la puntuación, todavía pendiente (ver
[[Puntuación]]):

- tres puntajes por zona, junto a cada símbolo (7 5 3, 6 4 2, 8 6 4…);
- una pista del 1 al 30 arriba, con marcas en algunos números.

En la foto los dígitos se leen mal; habrá que confirmarlos cuando se decida cómo se
puntúa.
