# Interfaz del tablero

Cómo se ve la app: los colores, el tablero, las casillas, los dados y la elección de
mapa. Lo dibujan `CeldaWidget`, `TableroWidget` y `DadoWidget` (`lib/ui/widgets/`), con
el tema de `lib/ui/tema.dart`, y lo usan las tres pantallas.

Ver también: [[Turnos y jugadas]] · [[Preparación de la partida]] · [[Tablero y regiones]]

> [!note] Diseño actual
> Lo de esta nota es el rediseño del 2026-10-18: un estilo suave, sin tanto detalle,
> pensado para que sea lo más amigable posible. **Al jugador nunca se le muestran
> coordenadas.** Las letras y números del manual (C1, F2…) siguen existiendo en el código
> (`Posicion.notacion`, las keys de los tests), pero no se ven en pantalla.

## El tema

Todo sale de `lib/ui/tema.dart`, que se aplica en `main.dart` con `theme: temaBrilliant()`.

- **Fondo crema** (`Paleta.fondo`, `#FAF7F2`) y barra superior lisa del mismo tono, con
  el título al centro: "Brilliant" en la elección de mapa, y el nivel ("Nivel 2") en la
  preparación y en la partida.
- Textos en tinta oscura (`Paleta.tinta`) y suave (`Paleta.tintaSuave`) para las
  indicaciones.
- Un color de **acento lavanda** (`Paleta.acento`, `#6A5FB0`) para lo que importa: el
  dado ancla, el brillo de las casillas iluminadas, la cuenta de lo que falta.
- **Botones redondeados**: el principal (Inicio, Tirar dados, Jugar otra vez) es una
  píldora de 52 px de alto como mínimo; las acciones secundarias son botones de texto con
  ícono.

### Los colores de las zonas

Colores suaves en vez de los colores puros:

| Zona | Color |
|---|---|
| rojo | coral `#F28B82` |
| morado | lavanda `#B79CED` |
| azul | celeste `#7FB7F0` |
| verde | salvia `#8FCB9B` |
| amarillo | mantequilla `#F6D365` |
| gris | gris cálido `#C9C2B8` |
| naranja | naranja suave `#F5A65B` |

El gris y el naranja solo aparecen en algunos mapas (ver [[Mapas]]). El naranja está
entre el coral y la mantequilla, para no confundirse con ninguno de los dos. El gris es
más oscuro que la base del tablero, para que sus casillas no se pierdan sobre ella.

Están en `coloresDeZona`. El color del número (tinta oscura o blanco) **se elige según el
fondo** con `tintaSobre()`, que usa `ThemeData.estimateBrightnessForColor`, para que
siempre se lea. Con esta paleta, sobre todas las zonas va la tinta oscura.

## La elección de mapa

`PantallaEleccionDeMapa` es la pantalla con la que arranca la app: "Elige un mapa" y
las 4 tarjetas, siempre en dos columnas. Cada tarjeta es blanca, redondeada y con una
sombra suave, y lleva:

- **la miniatura del mapa:** el mismo `TableroWidget` de la partida, vacío y sin toque,
  con las casillas iniciales marcadas con su aro;
- **el nombre** ("Nivel 3") y cuántas zonas tiene.

Como `TableroWidget` se adapta al ancho, las miniaturas se achican solas: en la PC las
fichas miden unos 24 px, y en un celular de 360 px, unos 14. Al tocar una tarjeta se
pasa a la preparación de ese mapa. Ver [[Mapas]].

## El tablero

- **Sin cuadrícula y sin coordenadas.** Las 49 casillas son fichas redondeadas, separadas
  4 px entre sí, apoyadas sobre una base redondeada de tono arena (`Paleta.baseTablero`)
  con 6 px de borde.
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
- El número va al centro, en negrita, a un 42 % del tamaño de la ficha.

### Cómo se resalta una casilla

Para resaltar una casilla se **ilumina**: se aclara hacia el blanco sin perder el color de
su zona. Las que se pueden usar, además, quedan **encendidas**: llevan un aro blanco de
3 px y un brillo lavanda alrededor. Sin ese aro y ese brillo, una casilla aclarada con
colores suaves parecía apagada en vez de iluminada.

| Caso | Cuánto se aclara | Aro y brillo | Dónde se usa |
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
número**: va en tinta oscura sobre un círculo blanco, al centro de la casilla. Así se ve
rápido junto a qué casillas se puede jugar. Es `numeroResaltado` en `CeldaWidget`.

**En el tablero no hay ninguna ⚓**: el ancla es solo un dado. Ver [[Turnos y jugadas]].

## Los dados

`DadoWidget` dibuja cada dado **como un dado de verdad**: un cuadro blanco redondeado de
68 px, con sombra suave y **los puntos** de su cara (de 1 a 6), repartidos en una grilla
de 3×3.

- **El dado ancla** lleva un aro lavanda de 3 px, fondo lavanda muy claro, un poco más de
  sombra y, debajo, ⚓ con la palabra **"ancla"**, que aparece con un fundido. Es el único
  lugar de la app donde aparece el ancla.
- Para lectores de pantalla (y para los tests), cada dado es un botón con la etiqueta
  "Dado: 4".

## La explicación

Al tocar una casilla vacía donde no se puede jugar, aparece debajo del tablero un
**recuadro suave color arena** (`Paleta.aviso`, no rojo de error) con un ícono de
información y el motivo, sin coordenadas. Puede ser que no está junto a ninguna casilla
con el número buscado, o la regla de la zona con lo que la zona ya tiene. Ver
[[Turnos y jugadas]].

## Cómo se decidió

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
