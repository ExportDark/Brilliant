# Fase de preparación y su bloc

La primera fase de toda partida: repartir los números del 1 al 6 entre las 6 casillas
iniciales, antes de tirar un solo dado. Implementada en `lib/juego/`.

Ver también: [[Tablero y regiones]] · [[Arquitectura general]] · [[Reglas del juego]]

## Qué exige el manual

Antes de la primera tirada, el jugador anota los números **1 al 6, sin repetir**, uno en
cada una de las 6 casillas iniciales fijas (C1, F2, B4, E4, C6, E7) — una permutación
completa. Es una decisión estratégica: cuatro de esas casillas caen dentro de regiones
con regla y condicionan todo lo que se pueda anotar ahí después.

**El requisito de diseño:** la partida no puede avanzar a la fase de juego hasta que esos
6 valores estén puestos.

## El patrón elegido

**Bloc completo con eventos** (no Cubit), del paquete `bloc`. `flutter_bloc` no está
instalado todavía: solo hace falta para `BlocProvider`/`BlocBuilder`, que son cosa de la
UI, y la UI viene después. No se instala un paquete antes de usarlo.

**Un solo `PartidaBloc`** con las fases adentro, en vez de un bloc dedicado solo a la
preparación. Así hay una sola fuente de verdad para la partida y la regla de transición
entre fases vive en un solo lugar.

## Las piezas

### `FasePartida`

```dart
enum FasePartida { preparando, jugando, terminada }
```

### `PartidaEvent` — sealed class

| Evento | Qué hace |
|---|---|
| `PartidaIniciada` | Arranca de cero: tablero vacío en fase `preparando` |
| `ValorInicialAsignado(posicion, valor)` | Anota un número en una casilla inicial |
| `ValorInicialQuitado(posicion)` | Libera una casilla inicial ya asignada |
| `PreparacionConfirmada` | Intenta pasar a jugar — **aquí vive el gate** |

Es `sealed` para que el manejo de eventos sea exhaustivo en tiempo de compilación.

`ValorInicialQuitado` existe porque sin él un toque equivocado dejaría la preparación
trabada sin salida.

### `PartidaState`

```dart
class PartidaState {
  final Tablero tablero;
  final FasePartida fase;
}
```

**Solo guarda esos dos campos.** Todo lo demás se deriva del tablero, siguiendo el mismo
criterio que `Region.completada` (ver [[Modelado de regiones]]): sin estado duplicado que
pueda desincronizarse.

- `casillasIniciales` → las celdas con `esInicial == true`
- `valoresInicialesUsados` → los números ya repartidos
- `valoresDisponibles` → `{1..6}` menos los usados
- `preparacionCompleta` → las 6 iniciales tienen valor

## El gate

Las reglas que hacen cumplir el requisito:

1. En fase `preparando` solo se aceptan asignaciones sobre casillas con `esInicial == true`.
2. Un valor ya usado en **otra** casilla inicial se rechaza — debe quedar una permutación
   sin repetir. (Reasignar otro valor a la *misma* casilla sí se permite.)
3. Los valores fuera de 1-6 se rechazan.
4. **`PreparacionConfirmada` no hace nada mientras `preparacionCompleta` sea `false`.**
5. Con las 6 puestas, y solo entonces, la fase pasa a `jugando`.
6. Ya en fase `jugando`, los eventos de preparación se ignoran: lo repartido queda fijo.

## Decisión: los eventos inválidos no emiten estado

Cuando un evento se rechaza, el bloc simplemente **no llama a `emit`**. Ventajas:

- El rechazo es observable en los tests como "no hubo emisión" (`expect: () => []`)
- No hace falta darle igualdad por valor al estado ni meter el paquete `equatable`

El costo: la UI no puede explicar *por qué* se rechazó algo. Se consideró aceptable
porque la expresión natural del gate en pantalla es un botón "continuar" deshabilitado
mientras `preparacionCompleta` sea falso, no un mensaje de error. Si más adelante hace
falta el mensaje, se agrega un campo al estado.

## Prerequisito que hubo que agregar al modelo

`Celda.conValor()` ya existía, pero **nada reconstruía la `Region` ni el `Tablero`** a
partir de esa celda, así que el bloc no tenía dónde registrar una asignación. Se
agregaron, manteniendo el estilo inmutable:

- `Celda.sinValor()` — copia con el valor borrado
- `Region.conCasilla(posicion, valor)` / `Region.sinCasilla(posicion)`
- `Tablero.conValor(posicion, valor)` / `Tablero.sinValor(posicion)`

`Tablero` ubica la región con el índice `_regionPorPosicion` que ya tenía, la reemplaza
por su versión actualizada y devuelve un tablero nuevo. Reindexar cuesta 49 operaciones
por jugada — irrelevante aquí, y tiene la ventaja de que **las validaciones de layout se
re-verifican en cada reconstrucción**.
