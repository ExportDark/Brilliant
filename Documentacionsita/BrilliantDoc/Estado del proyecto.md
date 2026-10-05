# Estado del proyecto

Última actualización: 2026-10-04 · Repo: https://github.com/ExportDark/Brilliant

Ver también: [[Cómo trabajar en el proyecto]] · [[Arquitectura general]]

## Qué está construido

- [x] **Scaffold** del proyecto Flutter (solo plataformas `windows` y `web`)
- [x] **`Posicion`** — value object con notación del manual ([[Sistema de coordenadas]])
- [x] **`Celda`** + `CeldaWidget` para renderizarla
- [x] **Las 5 reglas de color** — rojo, amarillo, verde, azul, morado
      ([[Reglas de color en código]])
- [x] **`TipoRegion`, `Region`, `extraerValores`** ([[Modelado de regiones]])
- [x] **`Tablero`** — las 9 regiones del mapa, con autovalidación del layout
      ([[Tablero y regiones]])
- [x] **Anotar valores en el tablero** — `Tablero.conValor` / `conValores` / `sinValor`,
      `Region.conCasilla` / `sinCasilla`, `Celda.sinValor`, todos devolviendo copias
      nuevas sin mutar nada
- [x] **`TableroWidget`** — la grilla 7×7 con el color de cada región, el número anotado
      en cada casilla y la notación A–G / 1–7 en los bordes
- [x] **`PreparacionBloc`** — el reparto de los valores iniciales, que no deja empezar
      la partida hasta tener las 6 casillas llenas ([[Preparación de la partida]])
- [x] **Pantalla de preparación** — el jugador reparte los 1-6 tocando las casillas del
      tablero y ve cada número en su posición. El botón **Inicio** solo se habilita con
      las 6 llenas y lleva a la pantalla de partida
- [x] **Botón Aleatorio** en la preparación — completa al azar las casillas que falten
- [x] **Layout verificado contra el PDF** (2026-09-30) — se compararon los colores de las
      49 casillas de los 5 tableros del PDF con el modelo y con la pantalla, y coinciden
      todas, igual que las 6 casillas iniciales ([[Decisiones de extracción del manual]])
- [x] **`PartidaBloc` y validación de jugadas** — dados (2d6), dado anclado, turnos,
      validación contra las reglas de color, pasar turno y fin de partida
      ([[Turnos y jugadas]])
- [x] **Pantalla de partida** — tirar los dados, anclar uno, iluminar dónde cabe (y
      apenas dónde la regla lo impide, explicándola al tocar); pasar turno y fin de
      partida. La cuadrícula siempre es negra: lo que se ilumina es la casilla

**Ya se puede jugar una partida de principio a fin**, de la preparación hasta que ninguna
casilla acepta nada. Lo único que falta para cerrarla es el puntaje. 147 tests, todos
pasando.

## Qué falta

- [ ] **`puntuacion/`** — el cálculo de puntaje, y mostrarlo al terminar la partida
      ([[Puntuación]])
- [ ] Tests de integración reproduciendo las Partidas 1 y 2 del manual

## Cómo se viene trabajando

Construcción **incremental, módulo por módulo**: cada pieza se agrega con sus tests y su
commit propio, con la documentación actualizada en el mismo commit. Nada de commits
gigantes que mezclen varias cosas.

Para ver qué se hizo y cuándo, el historial está en el repositorio: `git log --oneline`,
o en https://github.com/ExportDark/Brilliant/commits.
