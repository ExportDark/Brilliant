# Historial de cambios

Todo lo que se fue construyendo, por fecha, del más reciente al más viejo. Cada entrada
dice qué cambió, por qué y en qué commit. El detalle de cada pieza está en su nota.

Ver también: [[Estado del proyecto]] · [[Pruebas]]

---

## 2026-10-08 — Más pruebas de la regla del ancla

- **Pruebas nuevas de la lógica del juego** (`02e2904`): un número recién anotado sirve
  de ancla en el turno siguiente, los dos dados iguales, qué explicación gana cuando
  fallan dos cosas, el fin de la partida justo después de la última jugada y una
  posición fuera del tablero. Además, **10 partidas completas simuladas** con dados al
  azar (semillas fijas): todas terminan y ninguna zona rompe su regla. Ver [[Pruebas]].
- **Hallazgo:** las 10 partidas simuladas terminaron con el **tablero lleno (49 de 49)**.
  Con las reglas actuales ninguna zona se queda sin salida, así que cualquier partida
  acaba llenando el tablero; lo único que cambia es cuántos turnos tarda (entre 58 y 104
  en las simuladas). Esto importa para el puntaje. Ver [[Puntuación]].
- **Un archivo por prueba** (`81ad4f1`): los 7 casos puntuales de la regla del ancla
  pasan a vivir cada uno en su archivo, en `test/juego/partida/` y
  `test/juego/validacion/`, con sus ayudantes compartidos en `test/juego/ayudantes.dart`.
  Ver [[Pruebas]] y [[Cómo trabajar en el proyecto]].
- **El vault, al día con todo lo anterior**: notas nuevas [[Historial de cambios]],
  [[Pruebas]] e [[Interfaz del tablero]]; [[Puntuación]], [[Reglas del juego]] y
  [[Turnos y jugadas]] con el hallazgo del tablero lleno; [[Cómo trabajar en el proyecto]]
  con cómo probar la app en Edge, cómo leer el PDF y qué archivos no se suben. Desde
  ahora, todo cambio suma su entrada aquí.
- 177 tests.

## 2026-10-04 — La partida se puede jugar

- **Botón Aleatorio** en la preparación (`27336ab`): completa al azar las casillas
  iniciales vacías con los números que faltan, respetando lo ya puesto. Con las 6 llenas,
  revuelve todo. Ver [[Preparación de la partida]].
- **`PartidaBloc` y validación de jugadas** (`cce467c`): tirar 2 dados, elegir uno, pasar
  turno y fin de partida. `evaluarJugada` dice si una jugada vale y, si no, por qué. Cada
  regla de color suma su `descripcion` para explicársela al jugador. Ver
  [[Turnos y jugadas]] y [[Reglas de color en código]].
- **Pantalla de partida** (`44548a7`): deja de ser provisional. Muestra los dados, ilumina
  dónde se puede jugar y explica la regla al tocar una casilla donde no se puede.
- **Corrección visual: cuadrícula siempre negra** (`4c80c18`): se dejó de pintar el borde
  de las casillas. Lo que se ilumina ahora es el relleno: mucho donde se puede jugar,
  poco donde la regla lo impide. Ver [[Interfaz del tablero]].
- **Corrección de la mecánica: la regla del ancla** (`8878f92`): el dado elegido es el
  **ancla** y el **otro** se anota pegado (arriba, abajo, izquierda o derecha, sin
  diagonales) a una casilla que tenga el número del ancla. Las casillas ancla llevan un ⚓.
  **Difiere del PDF**, que permitía cualquier casilla libre: es una decisión del
  proyecto. Ver [[Turnos y jugadas]] y [[Reglas del juego]].
- 160 tests.

## 2026-09-30 — Layout verificado contra el PDF

- **El mapa del código coincide con el PDF** (`710a09d`). El PDF resultó ser dibujo
  vectorial, así que se leyó el color exacto de cada casilla de sus 5 tableros y se
  comparó con `Tablero.mapaOriginal()`: coinciden las 49 casillas y las 6 iniciales. La
  pantalla también se revisó por píxeles. Ver [[Decisiones de extracción del manual]].

## 2026-09-27 — Primeras pantallas

- **`TableroWidget`** (`598e568`): la grilla 7×7 con el color de cada región, los números
  anotados y la notación A–G / 1–7. `Tablero.conValores` aplica un reparto entero de una
  vez.
- **Pantalla de preparación** (`e3390a8`): la app arranca ahí. El jugador reparte los
  números del 1 al 6 tocando las casillas iniciales, y **Inicio** solo se habilita con
  las 6 llenas. Se agrega `flutter_bloc`. Ver [[Preparación de la partida]].

## 2026-09-21 — Tablero, vault y la preparación

- **`Tablero`** (`918664f`): las 9 regiones del mapa, declaradas con la notación del
  manual, con autovalidación del layout al construirse. Ver [[Tablero y regiones]].
- **Este vault** (`53d3bc9`): 12 notas enlazadas con las reglas, la arquitectura, el
  modelo y las decisiones de diseño. Se le quitaron después las referencias al proyecto
  previo y al plano cartesiano (`0af9913`). Ver [[Sistema de coordenadas]].
- **Primer `PartidaBloc`** (`7608191`): un bloc de toda la partida, con un gate que no
  dejaba jugar sin los 6 valores iniciales. El mismo día se reemplazó por
  **`PreparacionBloc`** (`9b37ce8`), un bloc local que solo se ocupa del reparto inicial y
  no conoce el tablero. El `PartidaBloc` actual es otro, del 2026-10-04.

## 2026-09-09 — Posiciones y regiones

- **`Posicion`** como value object propio (`befd8da`), que usa `Celda`.
- **`TipoRegion`, `Region` y `extraerValores`** (`9d2b697`). Ver [[Modelado de regiones]].

## 2026-09-03 — Arranque

- **Scaffold del proyecto**, la entidad **`Celda`** y su widget (`0fe18ee`).
- **Las 5 reglas de color**, una por commit: rojo (`e4cc27a`), amarillo (`a97670e`),
  verde (`55a14d3`), azul (`12b0b29`) y morado (`c36f24c`). Ver
  [[Reglas de color en código]].
