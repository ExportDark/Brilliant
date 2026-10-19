# Historial de cambios

Todo lo que se fue construyendo, por fecha, del más reciente al más viejo. Cada entrada
dice qué cambió, por qué y en qué commit. El detalle de cada pieza está en su nota.

Ver también: [[Estado del proyecto]] · [[Pruebas]]

---

## 2026-10-18 — Interfaz suave

- **Rediseño de la interfaz**, para que sea lo más amigable posible: un estilo suave, sin
  tanto detalle pero pulido. Se eligieron fichas redondeadas, dados con puntos y colores
  suaves. La lógica del juego no cambió. Ver [[Interfaz del tablero]].
  - **Tema propio** (`lib/ui/tema.dart`): fondo crema, acento lavanda, botones
    redondeados y una paleta suave para las 5 zonas. El número elige su color según el
    fondo para que siempre se lea.
  - **Sin coordenadas a la vista**: se quitaron las letras A–G y los números 1–7 del
    tablero, las chips "C1 = 4" de la preparación y el "C2 ·" de los mensajes. En el
    código siguen existiendo.
  - **Sin cuadrícula negra**, que se había pedido el 2026-10-04: las casillas son fichas
    redondeadas, separadas, sobre una base. Las iniciales llevan un aro tenue de su color.
  - **Casillas encendidas**: las que se pueden usar llevan aro blanco y brillo lavanda,
    porque con los colores suaves una casilla solo aclarada parecía apagada. Los cambios
    de iluminación son una transición suave.
  - **Dados con puntos** (`DadoWidget`), y el dado ancla con aro y la palabra "ancla".
  - **Preparación:** "Prepara tu tablero", cuántos faltan, los números como fichas
    redondas en una sola fila, y Aleatorio / Quitar / Reiniciar como acciones discretas.
    Ver [[Preparación de la partida]].
  - **Partida:** barra de progreso con "12 de 49 casillas", mensajes sin coordenadas en un
    recuadro suave, "Tirar dados" escondido mientras hay dados en la mesa, y una tarjeta
    de fin de partida con **Jugar otra vez**, que vuelve a la preparación. Ver
    [[Turnos y jugadas]].
  - El contenido de las pantallas va arriba en vez de centrado, para que el tablero no
    salte cuando aparecen los dados o la explicación.
- Se revisó en Edge (PC y celular) y en el emulador Android de 360 px, y se recompiló el
  APK.
- 4 tests renombrados porque probaban cosas que ya no se ven, varios actualizados a los
  textos nuevos, y 8 nuevos: los puntos del dado, la barra de progreso y el fin de partida
  con "Jugar otra vez". Ver [[Pruebas]].
- 252 tests.

## 2026-10-18 — Camino feliz

- **Unit test del happy path** (`4ed780c`): una partida entera, de la preparación al final, sin
  pantalla. Encadena `PreparacionBloc` → tablero → `PartidaBloc`, con dados sin azar que
  recorren las 36 combinaciones, y termina con las 49 casillas llenas y cada zona
  cumpliendo las reglas del manual, revisadas a mano en el test. Dura siempre 73 turnos.
  Se comprobó que falla si la preparación entrega mal los números o si una regla deja
  pasar repetidos. Ver [[Pruebas]].
- El jugador automático y la verificación de zonas pasaron de `partida_completa_test` a
  los ayudantes compartidos.
- 243 tests.

## 2026-10-17 — Versión Android

- **El tablero se adapta al ancho de la pantalla** (`96b8a4c`). Medía siempre 360 px y,
  con los márgenes, necesitaba 392: en un celular de 360 se desbordaba 32 px. Ahora las
  casillas miden el ancho disponible entre 7,5, con 48 px como máximo (43 en un celular de
  360). Las pantallas van dentro de `SafeArea`. Se sumaron 21 widget tests de tamaños, y
  se comprobó que fallan con el tablero fijo. Ver [[Interfaz del tablero]] y [[Pruebas]].
- **Plataforma Android**: nombre "Brilliant", paquete `com.exportdark.brilliant`, solo
  vertical. El APK (`app-arm64-v8a-release.apk`, 15,1 MB) se instala en el teléfono como
  cualquier app. Se probó en un emulador de 360 px: preparación, partida, un turno
  completo, y que no gire. Ver [[Versión Android]].
- **Comandos corregidos:** para web se usa `-d edge`, porque en esta PC no hay Chrome, y
  `-d windows` necesita Visual Studio, que no está instalado. Ver
  [[Cómo trabajar en el proyecto]].
- 242 tests.

## 2026-10-13 — Tests de todo lo que faltaba

- **41 tests nuevos** para cubrir lo que había quedado sin probar desde el inicio del
  proyecto hasta la regla del dado ancla, cada uno en su propio archivo. Ver [[Pruebas]]:
  - **Modelo:** `Region.conCasilla` / `sinCasilla`, `Celda.sinValor`, y cuántas vecinas
    tiene cada casilla dentro del tablero.
  - **Reglas:** la `descripcion` de cada color.
  - **Preparación:** Aleatorio con una sola casilla vacía, Aleatorio reproducible con la
    misma semilla, y que no se pueda reasignar tras confirmar.
  - **Partida:** el dado de verdad saca del 1 al 6, el estado sin dado ancla, índice
    negativo, tirar tras pasar, dado ancla sin jugada, ningún número en el tablero, y cómo
    crece la iluminación al anotar.
  - **Casillas iluminadas:** los conjuntos exactos para los 6 números iniciales, con
    varias casillas con el número, en la esquina, con una vecina ocupada, y el amarillo
    que bloquea desde lejos.
  - **Interfaz:** borde grueso solo en iniciales, número negro en la seleccionada,
    etiquetas A–G / 1–7, la selección que salta, las chips, solo iniciales tocables,
    Aleatorio + Inicio, las indicaciones, Pasar turno en lugar de Tirar, la explicación
    que se borra, casilla ocupada, la iluminación que se apaga al anotar, solo el número
    exacto resaltado, y que la pantalla coincida con la validación.
  - **App:** arranca en la pantalla de preparación.
- Ayudantes nuevos: `posiblesEn` / `bloqueadasEn` / `casillasDonde` en
  `test/juego/ayudantes.dart`, y `test/ui/pantallas/ayudantes_pantallas.dart` para los
  tests de pantallas.
- Ningún test destapó un bug: no se tocó código de `lib/`.
- 221 tests.

## 2026-10-09 — El ancla es solo un dado

- **Cambio de concepto, no de mecánica.** "Ancla" pasa a referirse **solo a uno de los dos
  dados**. En el tablero no hay anclas: hay casillas con números. Con 2 y 4 y el 4 como
  dado ancla, se buscan en el tablero las casillas que tienen un 4, y el 2 va pegado a
  alguna de ellas, igual que antes. Ver [[Turnos y jugadas]].
- **Pantalla:** se quitó la ⚓ de las casillas del tablero. En su lugar, las casillas que
  tienen el número del dado ancla **iluminan su número**: va en negro sobre un círculo
  blanco. La ⚓ queda solo debajo del dado ancla. Ver [[Interfaz del tablero]].
- **Código:** `SinAncla` pasó a ser `SinVecinoConNumero`; `PartidaState.esAncla`, a
  `tieneNumeroBuscado`; y el `esAncla` de `CeldaWidget` / `TableroWidget`, a
  `numeroResaltado` / `numeroResaltadoEn`. El mensaje dice ahora "...de una casilla con 4".
- **Tests:** los que hablaban de un ancla en el tablero se renombraron:
  `numero_recien_anotado_test`, `jugar_junto_al_numero_nuevo_test` y
  `lejos_del_numero_gana_test`. Se agregaron 3: el ancla se ve solo en los dados, y el
  número resaltado va en negro sobre un círculo (y sin resaltar, en blanco y sin
  círculo). Ver [[Pruebas]].
- 180 tests.

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
