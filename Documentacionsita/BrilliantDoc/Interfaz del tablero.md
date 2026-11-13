# Interfaz del tablero

Cómo se ve la app: los colores, el tablero, las casillas, los dados y la elección de
mapa. Lo dibujan `CeldaWidget`, `TableroWidget` y `DadoWidget` (`lib/ui/widgets/`), con
el tema de `lib/ui/tema.dart`, y lo usan las tres pantallas.

Ver también: [[Turnos y jugadas]] · [[Preparación de la partida]] · [[Tablero y regiones]]

> [!note] Diseño actual: piezas de mesa (2026-11-12)
> Como un juego de mesa físico: la **mesa de fieltro verde** de fondo, encima **bandejas de
> cartón con borde de tinta**, y fichas de **colores planos** con una **sombra dura** (sin
> difuminar), como piezas que se pueden tocar. Lo memorable es esa sensación de pieza: los
> botones principales y el dado ancla **se hunden** al tocarlos. Lo demás es sobrio: sin
> degradados, sin sombras borrosas, sin rótulos en mayúsculas. Se eligió entre tres
> direcciones (hoja cuadriculada, gemas y piezas de mesa) con la skill `frontend-design`.
> **Al jugador nunca se le muestran coordenadas.** Las letras y números del manual (C1,
> F2…) siguen existiendo en el código (`Posicion.notacion`, las keys de los tests), pero no
> se ven en pantalla.

## El tema

Todo sale de `lib/ui/tema.dart` (`temaBrilliant()`), y las piezas de
`lib/ui/widgets/piezas.dart`.

| Token | Color | Para qué |
|---|---|---|
| `Paleta.mesa` | fieltro `#2F5D50` | el fondo de todas las pantallas y la barra de arriba |
| `Paleta.carton` | cartón `#F6EEDC` | las bandejas, la hoja de reglas, los diálogos |
| `Paleta.cartonClaro` | `#FFFCF4` | las piezas sobre una bandeja: tarjetas de mapa, marcador, fichas de número |
| `Paleta.tinta` | tinta `#1F1A17` | el texto, los bordes y las sombras duras; también el acento |
| `Paleta.ficha` | amarillo `#F2B705` | los botones principales, el dado ancla, lo elegido y el que va primero |
| `Paleta.baseTablero` | cartón oscuro `#E2D2B2` | divisores, lo apagado |

- **Letra:** Archivo para todo y Archivo Black para títulos, números del tablero y la
  barra de arriba, incluidas en la app (`assets/fuentes/`, licencia OFL), con una escala
  de 13, 15, 17, 19, 22, 26 y 34 puntos.
- **Bandeja** (`Bandeja`): el contenido de cada pantalla va en una bandeja de cartón con
  borde de tinta de 2,5 px y una sombra dura de 6 px, centrada y de 480 px como máximo.
  Es un `Material`, para que los toques de las listas se vean.
- **Botones:** el principal es una ficha amarilla con borde de tinta; envuelto en
  `PiezaPresionable`, lleva sombra dura y **se hunde** al tocarlo (sin animación si el
  sistema pide reducirlas; sin sombra si está deshabilitado). Los secundarios son de
  cartón con borde, y los de texto, subrayados.
- **Campos de texto:** fondo claro con borde de tinta; los avisos, tarjeta amarilla con
  borde.

### Los colores de las zonas

Planos y saturados, como fichas impresas:

| Zona | Color |
|---|---|
| rojo | `#E9573F` |
| morado | `#9B78DB` |
| azul | `#4A93E0` |
| verde | `#55B67C` |
| amarillo | `#F7C531` |
| gris | `#B3ACA2` |
| naranja | `#F28A2E` |

El gris y el naranja solo aparecen en algunos mapas (ver [[Mapas]]).

El color del número **se elige por contraste** con `tintaSobre()`: la tinta o el cartón,
el que más contraste tenga con el fondo. Sobre todos los colores de zona gana la tinta.

## La elección de mapa

`PantallaEleccionDeMapa` es la pantalla con la que arranca la app: "Elige un mapa" y las 4
tarjetas, siempre en dos columnas (`TarjetaDeMapa`, la misma del lobby). Cada tarjeta es
una pieza de cartón claro con borde de tinta y sombra dura (en el lobby, la elegida es
amarilla), y lleva:

- **la miniatura del mapa:** el mismo `TableroWidget` de la partida, vacío y sin toque,
  con las casillas iniciales marcadas con su aro;
- **el nombre** ("Nivel 3") y cuántas zonas tiene.

Como `TableroWidget` se adapta al ancho, las miniaturas se achican solas. Al tocar una
tarjeta se pasa a la preparación de ese mapa. Ver [[Mapas]].

## El tablero

- **Un tablero impreso y sin coordenadas.** Las 49 casillas son fichas de color plano,
  separadas 4 px entre sí sobre una **base de tinta**: lo que se ve entre ellas es la
  cuadrícula oscura de un tablero impreso. La base lleva una sombra dura debajo, como
  pieza.
- **Se adapta al ancho de la pantalla.** Cada ficha mide lo que cabe: el ancho disponible
  menos el borde de la base, entre 7, menos la separación, redondeado hacia abajo y con
  48 px como máximo.

  | Pantalla | Ancho para el tablero | Ficha |
  |---|---|---|
  | PC (las pantallas miden 480 como máximo) | 480 | 48 |
  | Celular de 360 px | 336 | 42 |
  | Celular de 320 px | 296 | 36 |

  Los 336 y 296 salen de descontar los 12 px de margen de cada lado de la pantalla.

## Las casillas

- Cada casilla es una **ficha con esquinas redondeadas** del color de su zona, sin borde.
- Las 6 casillas iniciales llevan un **aro tenue** de 2 px, en un tono más oscuro de su
  propio color. En la preparación, "las casillas con aro" son las que se llenan.
- El número va al centro, en Archivo Black, a un 44 % del tamaño de la ficha.

### Cómo se resalta una casilla

Para resaltar una casilla se **ilumina**: se aclara hacia el blanco sin perder el color de
su zona. Las que se pueden usar, además, quedan **encendidas**: llevan un aro de cartón de
3 px y, por fuera, un borde amarillo de ficha, sin difuminar, que se ve aunque la base
del tablero sea oscura. La casilla que se tocó y no se pudo usar lleva un **aro rojo**
mientras se explica por qué (`marcada`).

| Caso | Cuánto se aclara | Aro y borde amarillo | Dónde se usa |
|---|---|---|---|
| Normal | nada | no | — |
| `Iluminacion.posible` | mucho (`_aclaradoFuerte = 0.4`) | sí | Partida: ahí se puede anotar el dado |
| `Iluminacion.bloqueada` | poco (`_aclaradoSuave = 0.25`) | no | Partida: junto a una casilla con el número del dado ancla, pero la regla de color no lo acepta |
| `seleccionada` | mucho, igual que `posible` | sí | Preparación: la casilla donde va a caer el próximo número |

El cambio es una **transición suave** de 160 ms (`AnimatedContainer`). Solo se animan el
color y el aro. El tamaño queda fuera de la animación: si se animara, al achicar la
ventana el tablero se desbordaría mientras dura la transición.

Las constantes están al principio de `lib/ui/widgets/celda_widget.dart`.

### El número iluminado

En la partida, las casillas que tienen el número que sacó el dado ancla **iluminan su
número**: va en tinta sobre un círculo de cartón con borde de tinta, al centro de la
casilla. Así se ve
rápido junto a qué casillas se puede jugar. Es `numeroResaltado` en `CeldaWidget`.

**En el tablero no hay ninguna ⚓**: el ancla es solo un dado. Ver [[Turnos y jugadas]].

## Los dados

`DadoWidget` dibuja cada dado **como una pieza**: un cubo claro de 68 px con borde de tinta,
sombra dura y **los puntos** de su cara (de 1 a 6), repartidos en una grilla de 3×3.

- **El dado ancla se hunde** (casi sin sombra y un poco más abajo), se pinta del amarillo
  de ficha y, debajo, lleva ⚓ con la palabra **"ancla"**, que aparece con un fundido. Es
  el único lugar de la app donde aparece el ancla.
- Para lectores de pantalla (y para los tests), cada dado es un botón con la etiqueta
  "Dado: 4".

## La explicación

Al tocar una casilla vacía donde no se puede jugar, el motivo aparece **en la misma línea
de la indicación, arriba del tablero**, sin recuadro: un punto del color de la zona y el
texto, con un fundido (`LineaDeIndicacion`). La casilla tocada lleva un **aro suave** en un
tono oscuro de su zona (`CeldaWidget.marcada`). A los 4 segundos, o con lo siguiente que
haga el jugador, vuelve la indicación de siempre. Puede ser que no está junto a ninguna
casilla con el número buscado, o la regla de la zona con lo que la zona ya tiene. Es lo
mismo en la partida de un jugador y en la partida en línea (`explicacion_de_jugada.dart`).
Ver [[Turnos y jugadas]].

> Hasta el 2026-11-11 iba en un recuadro color arena debajo del tablero; se cambió para que
> fuera más sutil y no moviera nada.

## Las reglas, a mano

En la preparación, en la partida y en la partida en línea, el botón **Reglas** (un libro,
arriba a la derecha) abre una hoja desde abajo sin salir de la partida
(`hoja_de_reglas.dart`): cómo se anota con el dado ancla y la regla de **cada color de
zona de ese mapa**, una vez cada uno, con una ficha de su color (en el Nivel 4, las dos
naranjas con su rango). En línea agrega cómo se ganan los puntos. Se cierra tocando fuera
o deslizando hacia abajo, y la partida sigue igual.

## Cómo se decidió

- **2026-11-12, piezas de mesa:** con la skill `frontend-design` se propusieron tres
  direcciones (hoja cuadriculada, gemas, piezas de mesa) y se eligió la de piezas de mesa.
  El tema anterior (crema con acento lavanda y tarjetas blancas con sombra suave) era
  justo lo que la skill señala como genérico. Se revisó cada pantalla en el emulador:
  salieron y se arreglaron la hoja de reglas verde con letra oscura, el título cortado de
  la preparación en línea ("Quedan 57 s") y la fila de la ronda que no cabía en 320 px.
  Las pruebas de tamaños y la de la hoja de reglas lo vigilan.

- **2026-10-04, primera versión:** las jugadas válidas se marcaban con borde blanco y las
  bloqueadas se oscurecían, y la casilla seleccionada en la preparación llevaba borde
  ámbar.
- **2026-10-04, corrección:** el borde blanco hacía que la cuadrícula se viera blanca, y
  la idea era iluminar la casilla, no el borde. Se dejó la cuadrícula siempre negra y se
  pasó a aclarar el relleno. Las bloqueadas, en vez de oscurecerse, se iluminan un poco.
- **2026-10-04, regla del ancla:** las casillas con el número del dado ancla llevaban un ⚓
  chiquito en la esquina.
- **2026-10-09, el ancla es solo un dado:** se quitó la ⚓ del tablero, porque en el
  tablero no hay anclas, solo números. En su lugar, esas casillas iluminan su número.
- **2026-10-17, versión para celular:** el tablero medía siempre 360 px (7,5 casillas de
  48), y con los márgenes de la pantalla necesitaba 392 px: en un celular de 360 se
  desbordaba 32 px. Se hizo que las casillas se achiquen para caber, y las dos pantallas
  se envolvieron en `SafeArea` para no quedar debajo de la barra de navegación de Android.
  Ver [[Versión Android]].
- **2026-10-18, rediseño suave:** se pidió que la app fuera lo más amigable posible, con
  un estilo suave y pulido, y **sin mostrar coordenadas**. Se eligieron fichas
  redondeadas, dados con puntos y colores suaves.
  - **Se quitó la cuadrícula negra**, que se había pedido el 2026-10-04: las fichas
    separadas sobre una base ya marcan dónde termina cada casilla.
  - **Se quitaron las letras A–G y los números 1–7** alrededor del tablero, las chips
    "C1 = 4" de la preparación y el "C2 ·" de los mensajes.
  - Las casillas iniciales pasaron del borde negro grueso a un aro tenue de su color.
  - Al probar las capturas, las casillas aclaradas se veían desteñidas. Se les agregó el
    aro blanco con brillo, y el aclarado fuerte bajó de 0,55 a 0,4.
  - Los dados pasaron de un cuadro con el número a un dado con puntos.
- **2026-10-24, los 4 mapas:** se sumaron el gris y el naranja a la paleta, y la
  pantalla de elección de mapa con miniaturas. Ver [[Mapas]].
- **Cómo se pinta:** `CeldaWidget` no sabe nada de dados ni de reglas. Recibe
  `iluminacion`, `seleccionada` y `numeroResaltado`, y `TableroWidget` se los reparte con
  `iluminacionDe` y `numeroResaltadoEn`. Quien decide qué se ilumina es la pantalla, a
  partir de `state.evaluar(posicion)` y `state.tieneNumeroBuscado(posicion)` del bloc.
