# Brilliant

Recreación digital (roll & write) del juego de mesa *Brilliant* (Ravensburger) — imitación
casera con fines personales/educativos, sin afiliación oficial.

Cada jugador tiene un tablero de 7×7 dividido en zonas de color. En cada turno se tiran
2 dados: uno es el **dado ancla**, que dice qué número buscar en el tablero, y el otro se
anota en una celda libre pegada (sin diagonales) a una casilla que tenga ese número,
respetando la regla de color de la zona. El ancla es solo un dado: en el tablero no hay
anclas, solo números.

## Estado del proyecto

Construcción incremental, módulo por módulo:

- [x] Entidad `Celda` y su widget de visualización (`lib/modelo/celda.dart`,
      `lib/ui/widgets/celda_widget.dart`)
- [x] Reglas de color: rojo, amarillo, verde, azul, morado, gris y naranja
- [x] `TipoRegion`, `Region`, `extraerValores`
- [x] `Tablero` completo (7×7), armado desde cualquiera de los 4 mapas oficiales
- [x] `TableroWidget`: las 7×7 fichas con los números anotados
- [x] Preparación de la partida (`PreparacionBloc`): repartir los valores iniciales
- [x] Pantalla de preparación: repartir los 6 números en el tablero y botón **Inicio**
- [x] Motor de partida (`PartidaBloc`): dados, regla del dado ancla, turnos, validación de
      jugadas
- [x] Pantalla de partida: dados, números buscados iluminados, jugadas iluminadas y la regla
      explicada
- [x] Interfaz suave: tema propio, fichas redondeadas, dados con puntos, sin coordenadas a
      la vista
- [x] Los 4 mapas oficiales, y una pantalla para elegir uno al abrir la app
- [ ] Puntuación

## Estructura

```
lib/
  modelo/   entidades de dominio (Posicion, Celda, Region, Mapa, Tablero, ...)
  reglas/   reglas de colocación por color
  juego/    estado de la partida con BLoC (preparación y turnos) y validación de jugadas
  ui/
    widgets/    CeldaWidget, TableroWidget, DadoWidget
    pantallas/  PantallaEleccionDeMapa, PantallaPreparacion, PantallaPartida
    tema.dart   colores y estilo de la app
  main.dart
test/       tests, misma estructura que lib/
```

## Correr el proyecto

```
flutter run -d edge                             # web, en Edge (Chrome sirve igual si está instalado)
flutter build apk --release --split-per-abi     # Android: genera el APK para instalar en el teléfono
flutter run -d windows                          # escritorio (necesita Visual Studio con C++)
```

El APK para teléfonos Android modernos queda en
`build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`.

## Tests

```
flutter test
```

## Módulo: Posicion (`lib/modelo/posicion.dart`)

Value object `{fila, columna}`: una posición fija en la grilla, reusable de forma
independiente (por ejemplo para validar movimientos por posición sin necesitar la
`Celda` completa).

Convierte con la notación del manual, donde la letra es la columna y el número es la
fila: `Posicion.desdeNotacion("C1")` y `posicion.notacion` → `"C1"`. Así el layout del
tablero se escribe igual que en el documento y los mensajes de error dicen `"C6"` en
vez de `"fila 5, columna 2"`.

## Módulo: Celda (`lib/modelo/celda.dart`)

Entidad inmutable que representa una casilla del tablero:

- `posicion`: su `Posicion` fija en la grilla.
- `color`: el `ColorZona` de su zona (determina qué regla aplica).
- `valor`: el número 1-6 anotado, o `null` si sigue vacía.
- `esInicial`: si es una de las 6 casillas fijas que se llenan en la preparación
  de la partida (antes de tirar dados).

`conValor(nuevoValor)` devuelve una copia con el valor anotado, sin mutar la original.

`CeldaWidget` (`lib/ui/widgets/celda_widget.dart`) la renderiza como una ficha redondeada
del color de su zona, sin borde, con el valor centrado; si es inicial, lleva un aro tenue
en un tono más oscuro de su color. Para resaltar una casilla se **ilumina**: se aclara
hacia el blanco. Con `seleccionada` o `Iluminacion.posible` se aclara mucho y queda
encendida, con aro blanco y brillo; con `Iluminacion.bloqueada`, solo se aclara un poco.
El cambio es una transición suave. Con `numeroResaltado` el número se ilumina: va en
tinta oscura sobre un círculo blanco.

## Módulo: regla de color rojo (`lib/reglas/`)

- `regla_color.dart`: contrato `ReglaColor` — toda regla de color implementa
  `puedeAgregar(numeros, numero)`, decidiendo si el nuevo valor es válido dado lo que
  ya hay en la zona, y `descripcion`, la regla dicha en una frase para mostrársela al
  jugador.
- `regla_numeros_distintos.dart`: función pura `puedeAgregarManteniendoDistintos` —
  el valor solo es válido si no se repite ningún número en la zona. La usan tanto el
  rojo como el amarillo (misma regla "todos diferentes", ver manual del juego).
- `regla_rojo.dart`: `ReglaRojo` — ningún número se repite en la zona roja (con 6
  celdas, una corrida del 1 al 6).
- `regla_amarillo.dart`: `ReglaAmarillo` — sus celdas pueden estar dispersas por el
  tablero pero se tratan como una única región lógica: no se puede repetir ningún valor entre
  ninguna de ellas (misma regla que rojo, reutilizando `puedeAgregarManteniendoDistintos`).
- `regla_cualquiera.dart` / `regla_verde.dart`: `ReglaVerde` — sin restricción, cualquier
  valor es válido en cualquier celda libre de la zona.
- `regla_valor_unico.dart` / `regla_azul.dart`: `ReglaAzul` — todas las celdas de la zona
  deben terminar con el mismo valor.
- `regla_maximo_valores_distintos.dart` / `regla_morado.dart`: `ReglaMorado` — como
  máximo 2 valores distintos en toda la zona.
- `regla_gris.dart`: `ReglaGris` — como el azul, todas las celdas con el mismo valor.
- `regla_rango.dart` / `regla_naranja.dart`: `ReglaNaranja(minimo, maximo)` — solo
  números de un rango ("1-3" o "4-6"), aunque la zona esté vacía.

## Módulo: TipoRegion, Region, extraerValores (`lib/modelo/`)

- `tipo_region.dart`: `TipoRegion{color, regla}` — une cada color con su regla ya
  instanciada. Constantes ya armadas (`tipoAmarillo`, `tipoVerde`, `tipoMorado`,
  `tipoAzul`, `tipoRojo`) que `Tablero` usa directo, sin ningún dispatcher/switch. Cuántas
  casillas tiene cada zona no es parte del tipo: lo decide el mapa.
- `region.dart`: `Region{identificador, tipo, casillas}` — una zona física concreta del
  tablero, de cualquier tamaño. `completada` es un getter calculado a partir de
  `casillas`, nunca un campo guardado.
- `extraer_valores.dart`: `extraerValores(Region) -> List<int>` — los valores ya
  anotados en la región, para alimentar `region.tipo.regla.puedeAgregar(...)`.

## Módulo: Mapa (`lib/modelo/mapa.dart`)

Los 4 mapas oficiales, `nivel1` a `nivel4` (en la lista `mapas`). Cada `Mapa` declara
sus zonas, cada una con su tipo y la **lista de sus casillas en notación** (`['C1',
'C2', 'D2', 'D3']`), y sus 6 casillas iniciales. Las zonas no se declaran como una
grilla de colores: así el layout se lee igual que la tarjeta y no hay que deducir por
adyacencia a cuál de las zonas de un color pertenece cada casilla.

El `nivel1` es el mapa del manual (9 regiones). Los otros salieron de una foto de las
tarjetas y suman dos colores: el gris y el naranja.

## Módulo: Tablero (`lib/modelo/tablero.dart`)

`Tablero.desdeMapa(mapa)` arma el tablero 7×7 de un mapa, con sus casillas iniciales
marcadas. `Tablero.mapaOriginal()` es un atajo de `Tablero.desdeMapa(nivel1)`.

Como el layout se transcribe a mano, el tablero se valida solo al construirse: ninguna
casilla declarada dos veces, ninguna casilla de la grilla sin cubrir y ninguna casilla
fuera de la grilla. Cualquier error de transcripción revienta al instante diciendo qué
casilla.

Consultas: `regiones`, `celdas`, `celdaEn(posicion)` y `regionEn(posicion)`.

Para anotar: `conValor(posicion, valor)`, `conValores({posicion: valor, ...})` y
`sinValor(posicion)`, todos devolviendo un tablero nuevo sin mutar el original.

## Módulo: TableroWidget (`lib/ui/widgets/tablero_widget.dart`)

Dibuja un `Tablero` completo: las 49 fichas con el color de su región y el número que
tengan anotado, separadas entre sí sobre una base redondeada. **No muestra coordenadas**:
la notación del manual (C1, F2…) solo existe en el código.

Como se dibuja siempre a partir de un `Tablero`, para mostrar lo que el jugador va
poniendo basta con pasarle `tablero.conValores(...)`: cada número aparece en su celda.

Opcionalmente recibe `seleccionada` (la casilla resaltada), `alTocar` y `esTocable`
(qué casillas responden al toque), `iluminacionDe` (cómo se resalta cada casilla) y
`numeroResaltadoEn` (qué casillas iluminan su número).

El tablero se adapta al ancho que tenga: las fichas miden hasta 48 px y se achican para
caber, por ejemplo a 42 px en un celular de 360 px.

## Módulo: tema y dados (`lib/ui/`)

- `tema.dart`: `temaBrilliant()`, el tema de la app (fondo crema, acento lavanda,
  botones redondeados); `Paleta`, sus colores; `coloresDeZona`, los colores suaves de
  las 5 zonas; y `tintaSobre(fondo)`, que elige tinta oscura o blanco para que el número
  siempre se lea.
- `widgets/dado_widget.dart`: `DadoWidget`, un dado blanco redondeado con los puntos de su
  cara. Con `anclado` lleva un aro de acento y debajo ⚓ "ancla": es el único lugar
  donde aparece el ancla. Para lectores de pantalla es un botón "Dado: 4".

## Módulo: preparación de la partida (`lib/juego/`)

Antes de tirar el primer dado, el jugador reparte los números del **1 al 6** entre las
**6 casillas iniciales** del mapa, las de la estrellita (en el Nivel 1: C1, F2, B4, E4,
C6, E7), sin repetir ninguno. Es
una decisión estratégica: cuatro de esas casillas caen dentro de regiones con regla y
condicionan lo que se podrá anotar ahí durante la partida.

**La partida no puede empezar hasta que las 6 casillas tengan número.**

Ese reparto lo administra `PreparacionBloc`, un bloc local: se crea en la pantalla de
preparación, recibe en el constructor las casillas que hay que llenar y no conoce el
tablero. Al terminar entrega las asignaciones en `PreparacionState.valores`.

- `preparacion_event.dart`: `ValorAsignado`, `ValorQuitado`, `RepartoAleatorio`,
  `PreparacionConfirmada`, `PreparacionReiniciada`.
- `preparacion_state.dart`: `PreparacionState{casillas, valores, confirmada}`, con
  `disponibles`, `completa` y `valorDe(casilla)` derivados de lo repartido.
- `preparacion_bloc.dart`: `PreparacionBloc`.

Reglas que hace cumplir:

1. Solo se aceptan las casillas que el bloc recibió, y solo números del 1 al 6.
2. Un número ya usado en otra casilla se rechaza — así los 6 quedan distintos entre sí.
   Cambiar el número de una casilla ya asignada sí se permite.
3. `PreparacionConfirmada` no hace nada mientras falte alguna casilla. Solo con las 6
   puestas marca `confirmada`.
4. Una vez confirmada, el reparto queda fijo.
5. Un número que no cabe en su casilla se rechaza. Solo pasa en el Nivel 4, donde dos
   iniciales caen en zonas naranjas (E1 en la "4-6", B7 en la "1-3"). El bloc recibe
   una función `admite(casilla, valor)`, que la pantalla arma con
   `Tablero.aceptaComoInicial`.

`RepartoAleatorio` reparte al azar los números que faltan entre las casillas vacías,
respetando lo que el jugador ya puso y que cada número quepa en su casilla. Si las 6 ya
están llenas, o si lo ya puesto no deja completar, revuelve todo de nuevo. El bloc recibe
un `Random` opcional en el constructor para que los tests usen una semilla fija.

Los eventos inválidos se ignoran sin emitir estado, de modo que en los tests el rechazo
se observa como una ausencia de emisión.

## Módulo: turnos y jugadas (`lib/juego/`)

En cada turno se tiran **dos dados** y el jugador elige uno como **dado ancla** (puede
cambiarlo por el otro mientras no coloque). El dado ancla dice qué número buscar en el
tablero: el **otro dado** se anota en una casilla libre pegada a una casilla que tenga ese
número, arriba, abajo, a la izquierda o a la derecha (sin diagonales), y solo si la regla
de color de esa zona lo acepta. Por ejemplo: salen 2 y 4, el dado ancla es el 4, se
buscan las casillas con un 4, y el 2 va junto a cualquiera de ellas.

El ancla es solo un dado: en el tablero no hay anclas, solo casillas con números. Esta
regla no viene del manual en PDF (que permitía cualquier casilla libre): es una decisión
del proyecto.

- `validacion_jugada.dart`: `evaluarJugada(tablero, posicion, ancla: a, valor: v)` devuelve
  `CasillaOcupada`, `SinVecinoConNumero(numero)`, `ReglaRota(region, valoresEnZona)` o
  `JugadaValida`. Las vecinas salen de `Posicion.vecinas` y la regla de color, de
  `region.tipo.regla.puedeAgregar`. `hayJugada(tablero, ancla: a, valor: v)` dice si
  alguna casilla acepta `v` cuando el dado ancla sacó `a`.
- `partida_event.dart`: `DadosTirados`, `DadoElegido(indice)` (el dado ancla),
  `ValorColocado(posicion)` y `TurnoPasado`.
- `partida_state.dart`: `PartidaState{tablero, dados, dadoElegido, turno}`, con
  `valorAncla`, `valorAColocar`, `evaluar(posicion)`, `tieneNumeroBuscado(posicion)`,
  `sinJugada`, `terminada` y `casillasLlenas` derivados.
- `partida_bloc.dart`: `PartidaBloc`. Recibe el tablero con los valores iniciales y una
  función `tirarDado` opcional, para que los tests decidan qué sale.

Reglas que hace cumplir:

1. Una sola tirada por turno: hasta colocar o pasar no se vuelve a tirar.
2. Solo se coloca con un dado ancla elegido, en una casilla libre pegada a una casilla con
   su número, y si la regla de su zona lo acepta. Colocar cierra el turno.
3. `TurnoPasado` solo procede si no hay jugada con ninguno de los dos dados como ancla.
4. La partida termina cuando ninguna combinación de dado ancla y número del 1 al 6 tiene
   jugada.

## Módulo: elección de mapa (`lib/ui/pantallas/pantalla_eleccion_de_mapa.dart`)

Es la pantalla con la que arranca la app: "Elige un mapa" y los 4 mapas oficiales en
tarjetas de dos columnas, cada una con su tablero vacío en miniatura (el mismo
`TableroWidget`), su nombre ("Nivel 3") y cuántas zonas tiene. Al tocar una tarjeta se
pasa a la preparación de ese mapa.

## Módulo: pantalla de preparación (`lib/ui/pantallas/`)

El jugador reparte los números del 1 al 6 entre las 6 casillas iniciales del mapa que
eligió, viendo en el tablero qué número va quedando en cada posición. La barra superior
dice el nivel, y la flecha de atrás vuelve a elegir mapa.

- `pantalla_preparacion.dart`: `PantallaPreparacion` crea el `PreparacionBloc` (vía
  `flutter_bloc`) con las casillas iniciales del mapa y dibuja su estado:
  - "Prepara tu tablero", qué hacer y cuántos números faltan;
  - el `TableroWidget` con lo repartido hasta ahora (`tablero.conValores(state.valores)`),
    con la casilla seleccionada encendida. No hay resumen aparte: lo repartido se ve en
    el tablero;
  - los números del 1 al 6 como fichas redondas en una fila, donde salen apagados los ya
    usados y los que no caben en la casilla seleccionada;
  - **Aleatorio** (completa al azar lo que falta), **Quitar** y **Reiniciar**, como
    acciones discretas;
  - el botón **Inicio**, habilitado solo cuando `state.completa`.
- Al oprimir Inicio el bloc confirma el reparto y la app pasa a `PantallaPartida` con el
  tablero y los 6 valores ya fijos.

Para asignar un número se toca una casilla inicial (las que tienen aro) y después el
número. La selección salta sola a la siguiente casilla vacía. Qué casilla está
seleccionada es estado de la pantalla, no del bloc: al reparto no le importa qué se está
mirando.

El botón Inicio deshabilitado es solo la cara visible de la regla. Aunque se oprimiera, el
bloc no confirma un reparto incompleto.

## Módulo: pantalla de partida (`lib/ui/pantallas/pantalla_partida.dart`)

`PantallaPartida` crea el `PartidaBloc` con el tablero que dejó la preparación y dibuja
cada turno. La barra superior dice el nivel. Salir a mitad de partida con la flecha de
atrás pide confirmación ("¿Salir de la partida?"), para no perder lo jugado sin querer.

Arriba van el turno y una barra de progreso con las casillas llenas ("12 de 49
casillas").

1. **Tirar dados** saca los dos dados, dibujados con sus puntos. El botón se esconde
   mientras haya dados en la mesa.
2. Se toca un dado para hacerlo **dado ancla** (aro lavanda y ⚓ "ancla" debajo).
   Mientras no se coloque, se puede cambiar al otro. Es el único lugar donde aparece el
   ancla.
3. Las casillas del tablero que tienen el número del dado ancla **iluminan su número**
   (en tinta oscura sobre un círculo blanco). Sus vecinas donde el otro dado cabe se
   **encienden** (más claras, con aro blanco y brillo), y las vecinas cuya zona no lo
   acepta se aclaran apenas.
4. Tocar una casilla encendida anota el número y pasa al siguiente turno. Tocar cualquier
   otra casilla vacía explica debajo del tablero por qué no se puede, sin coordenadas,
   por ejemplo:
   - *"Esa casilla no está junto a ningún 4: el 2 va arriba, abajo o a un lado de un 4."*
   - *"Zona azul — Todos iguales: todas las casillas llevan el mismo número. Ya tiene: 4"*
5. Si no hay jugada con ningún dado como ancla, aparece **Pasar turno** en lugar de
   Tirar dados. Cuando ninguna tirada posible tiene jugada, aparece una tarjeta con
   "¡Tablero completo!", en cuántos turnos se jugó y el botón **Jugar otra vez**, que
   vuelve a la preparación.

Qué casillas se iluminan sale de `state.evaluar(posicion)`, es decir, de la misma
validación que usa el bloc para aceptar o rechazar la jugada. La pantalla no decide nada
por su cuenta. `PantallaPartida` recibe un `tirarDado` opcional, para que los tests fijen
qué sale en los dados. `BrilliantApp`, `PantallaEleccionDeMapa` y `PantallaPreparacion`
también lo reciben y lo pasan a la partida, así un test puede jugar la app entera con
dados fijos.

## Tests del camino feliz

Hay dos, y los dos juegan una partida entera de la preparación al tablero lleno, en cada
uno de los 4 mapas:

- `test/juego/camino_feliz/partida_entera_test.dart`: un **unit test** que maneja los blocs
  directo, sin pantalla.
- `test/ui/camino_feliz/partida_entera_por_la_pantalla_test.dart`: un **widget test** que
  abre la app, elige el mapa y juega tocando, hasta "¡Tablero completo!" y "Jugar otra
  vez".
