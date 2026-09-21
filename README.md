# Brilliant

Recreación digital (roll & write) del juego de mesa *Brilliant* (Ravensburger) — imitación
casera con fines personales/educativos, sin afiliación oficial.

Cada jugador tiene un tablero de 7×7 dividido en zonas de color; en cada turno se tiran
2 dados y se anota uno de los dos valores en una celda libre, respetando la regla de la
zona de color donde se coloque.

## Estado del proyecto

Construcción incremental, módulo por módulo:

- [x] Entidad `Celda` y su widget de visualización (`lib/modelo/celda.dart`,
      `lib/ui/widgets/celda_widget.dart`)
- [x] Reglas de color: rojo, amarillo, verde, azul, morado
- [x] `TipoRegion`, `Region`, `extraerValores`
- [x] `Tablero` completo (7×7, 9 regiones)
- [x] `PartidaBloc` — fase de preparación con su gate
- [ ] Motor de partida (dados, turnos, validación de movimientos)
- [ ] Puntuación
- [ ] UI jugable completa

## Estructura

```
lib/
  modelo/   entidades de dominio (Posicion, Celda, Region, Tablero, ...)
  reglas/   reglas de colocación por color
  juego/    estado de la partida: fases, eventos y BLoC
  ui/       widgets y pantallas
  main.dart
test/       tests, misma estructura que lib/
```

## Correr el proyecto

```
flutter run -d chrome     # web
flutter run -d windows    # escritorio
```

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
- `color`: el `Color5` de su zona (determina qué regla aplica).
- `valor`: el número 1-6 anotado, o `null` si sigue vacía.
- `esInicial`: si es una de las 6 casillas fijas que se llenan en la preparación
  de la partida (antes de tirar dados).

`conValor(nuevoValor)` devuelve una copia con el valor anotado, sin mutar la original.

`CeldaWidget` (`lib/ui/widgets/celda_widget.dart`) la renderiza como un cuadro del color
de su zona, con borde grueso si es inicial y el valor centrado.

## Módulo: regla de color rojo (`lib/reglas/`)

- `regla_color.dart`: contrato `ReglaColor` — toda regla de color implementa
  `puedeAgregar(numeros, numero)`, decidiendo si el nuevo valor es válido dado lo que
  ya hay en la zona.
- `regla_numeros_distintos.dart`: función pura `puedeAgregarManteniendoDistintos` —
  el valor solo es válido si no se repite ningún número en la zona. La usan tanto el
  rojo como el amarillo (misma regla "todos diferentes", ver manual del juego).
- `regla_rojo.dart`: `ReglaRojo` — la zona roja (6 celdas) debe terminar con 6 valores
  todos distintos entre sí (una corrida del 1 al 6).
- `regla_amarillo.dart`: `ReglaAmarillo` — sus 5 celdas están dispersas por el tablero
  pero se tratan como una única región lógica: no se puede repetir ningún valor entre
  ninguna de ellas (misma regla que rojo, reutilizando `puedeAgregarManteniendoDistintos`).
- `regla_cualquiera.dart` / `regla_verde.dart`: `ReglaVerde` — sin restricción, cualquier
  valor es válido en cualquier celda libre de la zona.
- `regla_valor_unico.dart` / `regla_azul.dart`: `ReglaAzul` — todas las celdas de la zona
  deben terminar con el mismo valor.
- `regla_maximo_valores_distintos.dart` / `regla_morado.dart`: `ReglaMorado` — como
  máximo 2 valores distintos en toda la zona (6 celdas).

## Módulo: TipoRegion, Region, extraerValores (`lib/modelo/`)

- `tipo_region.dart`: `TipoRegion{color, regla, cantidadCeldas}` — une cada color con
  su regla ya instanciada. `cantidadCeldas` es propia de este mapa (amarillo 5, azul 4,
  verde/morado/rojo 6), no una ley universal del color. 5 constantes ya armadas
  (`tipoAmarillo`, `tipoVerde`, `tipoMorado`, `tipoAzul`, `tipoRojo`) que `Tablero`
  reutilizará directo, sin ningún dispatcher/switch.
- `region.dart`: `Region{identificador, tipo, casillas}` — una zona física concreta del
  tablero. Valida al construirse que `casillas.length == tipo.cantidadCeldas` (falla
  rápido si el layout se transcribe mal). `completada` es un getter calculado a partir
  de `casillas`, nunca un campo guardado.
- `extraer_valores.dart`: `extraerValores(Region) -> List<int>` — los valores ya
  anotados en la región, para alimentar `region.tipo.regla.puedeAgregar(...)`.

## Módulo: Tablero (`lib/modelo/tablero.dart`)

`Tablero.mapaOriginal()` arma el mapa 7×7 del manual: 9 regiones (1 amarilla de 5
casillas dispersas + 2 de cada otro color) y las 6 casillas iniciales marcadas.

Cada región se declara con la **lista de sus casillas en notación** (`['C1', 'C2',
'D2', 'D3']`), no como una grilla de colores: así el layout se lee igual que el manual
y no hay que deducir por adyacencia a cuál de las dos regiones de un color pertenece
cada casilla.

Como el layout se transcribe a mano, el tablero se valida solo al construirse: ninguna
casilla declarada dos veces, ninguna casilla de la grilla sin cubrir, ninguna casilla
fuera de la grilla, y (vía `Region`) cada región con la cantidad de casillas de su
tipo. Cualquier error de transcripción revienta al instante diciendo qué casilla.

Consultas: `regiones`, `celdas`, `celdaEn(posicion)` y `regionEn(posicion)`.

## Módulo: PartidaBloc (`lib/juego/`)

Estado de la partida con el patrón BLoC (paquete `bloc`; `flutter_bloc` se agregará
cuando llegue la UI).

- `fase_partida.dart`: `FasePartida { preparando, jugando, terminada }`.
- `partida_event.dart`: `sealed class PartidaEvent` — `PartidaIniciada`,
  `ValorInicialAsignado`, `ValorInicialQuitado`, `PreparacionConfirmada`.
- `partida_state.dart`: `PartidaState{tablero, fase}`. Todo lo demás se deriva del
  tablero (`casillasIniciales`, `valoresDisponibles`, `preparacionCompleta`), sin estado
  duplicado que pueda desincronizarse.
- `partida_bloc.dart`: `PartidaBloc`.

**El gate de la preparación:** la partida arranca en fase `preparando`, donde el jugador
reparte los números 1-6 entre las 6 casillas iniciales (C1, F2, B4, E4, C6, E7) sin
repetir. `PreparacionConfirmada` **no hace nada** mientras falte alguna casilla — solo
con las 6 puestas la fase pasa a `jugando`.

Los eventos inválidos (casilla que no es inicial, valor ya usado, valor fuera de 1-6) se
ignoran sin emitir estado.
