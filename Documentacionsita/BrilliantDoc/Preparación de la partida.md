# Preparación de la partida

El paso previo a jugar: repartir los valores iniciales. Implementado en `lib/juego/`.

Ver también: [[Tablero y regiones]] · [[Reglas del juego]] · [[Arquitectura general]]

## En qué consiste

Antes de tirar el primer dado, el jugador anota los números del **1 al 6** en las **6
casillas iniciales** del tablero (C1, F2, B4, E4, C6, E7), **sin repetir ninguno**. Cada
casilla se queda con un número distinto.

No es un trámite: cuatro de esas casillas caen dentro de regiones que tienen regla, y el
número que se ponga ahí condiciona todo lo que se pueda anotar después en esa región. Por
ejemplo, el número que va en C1 define de una vez cuál será el número único de toda la
región azul. Ver [[Tablero y regiones]].

**La partida no puede empezar hasta que las 6 casillas tengan número.** Esa es la regla
que el módulo hace cumplir.

## Cómo está resuelto

El reparto lo administra `PreparacionBloc`, siguiendo el patrón **BLoC**: la pantalla le
manda *eventos* ("pon el 4 en C1") y el bloc responde con un *estado* nuevo que describe
cómo quedó el reparto. La pantalla solo dibuja lo que el estado dice; toda la decisión de
qué es válido vive en el bloc.

Es un **bloc local**: se crea en la pantalla de preparación y vive solo mientras esa
pantalla existe. Recibe en el constructor las casillas que hay que llenar, así que no
necesita conocer el tablero ni nada del resto del juego — su única responsabilidad son
esos valores iniciales. Cuando el reparto termina, lo entrega y quien lo reciba decide
qué hacer con él.

### Los eventos

| Evento | Qué hace |
|---|---|
| `ValorAsignado(casilla, valor)` | Anota un número en una casilla |
| `ValorQuitado(casilla)` | Libera una casilla para volver a repartirla |
| `RepartoAleatorio` | Reparte al azar los números que faltan entre las casillas vacías; con las 6 llenas, revuelve todo |
| `PreparacionConfirmada` | Cierra el reparto y da luz verde para jugar |
| `PreparacionReiniciada` | Borra todo y vuelve a empezar |

Están declarados como `sealed`, lo que hace que el compilador avise si algún día se
agrega un evento y se olvida atenderlo.

### El estado

```dart
class PreparacionState {
  final List<Posicion> casillas;      // las casillas por llenar
  final Map<Posicion, int> valores;   // lo repartido hasta ahora
  final bool confirmada;              // si el jugador ya cerró el reparto
}
```

Lo demás se calcula a partir de esos campos, para que no haya dos versiones de la misma
información que puedan contradecirse:

- `valorDe(casilla)` → el número de esa casilla, o nada si sigue vacía
- `disponibles` → los números que todavía no se han usado
- `completa` → si ya están todas las casillas llenas

### Las reglas que hace cumplir

1. Solo se aceptan las casillas que el bloc recibió, y solo números del 1 al 6.
2. **Un número ya usado en otra casilla se rechaza.** Esto es lo que garantiza que los 6
   queden distintos entre sí. Cambiar el número de una casilla que ya tenía uno sí se
   permite: el jugador puede recomponer su reparto.
3. **`PreparacionConfirmada` no hace nada mientras falte alguna casilla.** Solo con las 6
   puestas marca `confirmada`, y recién ahí la partida puede arrancar.
4. Una vez confirmada, el reparto queda fijo y se ignoran nuevos cambios.

Como nunca se admite un número repetido, tener las 6 casillas llenas implica
necesariamente que los valores son una permutación completa del 1 al 6 — la regla de
"todos distintos" se cumple por construcción, sin necesidad de una comprobación aparte al
final.

## La pantalla

`PantallaPreparacion` (`lib/ui/pantallas/pantalla_preparacion.dart`) es con la que arranca
la app. Crea el bloc con `BlocProvider` (de `flutter_bloc`) y dibuja su estado:

- **El tablero completo**, con lo repartido hasta ahora anotado en cada casilla
  (`tablero.conValores(state.valores)`). Así el jugador ve en qué posición queda cada
  número. Solo las 6 casillas iniciales responden al toque, y la seleccionada se resalta
  en ámbar.
- **Un resumen** con una chip por casilla: `C1 = 4`, `F2 = —`… Tocar una chip también
  selecciona su casilla.
- **Los números del 1 al 6.** Los ya usados en otra casilla salen deshabilitados, así que
  el jugador nunca llega a intentar un repetido.
- **Quitar**, que vacía la casilla seleccionada, y **Reiniciar**.
- **Aleatorio**, que manda `RepartoAleatorio`: el azar completa lo que falta.
- **Inicio**, habilitado solo cuando `state.completa`. Al oprimirlo manda
  `PreparacionConfirmada`, y cuando el estado pasa a `confirmada` la app navega a
  `PantallaPartida` con el tablero y los 6 valores ya fijos.

Para asignar, se toca una casilla y luego un número. Después la selección salta sola a la
siguiente casilla vacía, con lo que repartir los 6 son 6 toques de número si se sigue el
orden.

Qué casilla está seleccionada lo guarda la pantalla, no el bloc. Es estado de la interfaz:
al reparto no le importa qué casilla se está mirando.

Lo que pasa en `PantallaPartida` está en [[Turnos y jugadas]].

## Decisión: el reparto aleatorio respeta lo ya puesto

`RepartoAleatorio` solo llena las casillas vacías, con los números que todavía no se
usaron. Así el jugador puede fijar a mano las casillas que le importan (por ejemplo, el
número de C1, que define toda la región azul) y dejar el resto al azar. Con las 6 ya
llenas no queda nada que completar, así que revuelve todo de nuevo: oprimir el botón
varias veces sigue dando repartos distintos.

El bloc recibe un `Random` opcional en el constructor. En los tests se pasa con semilla
fija, y lo que se comprueba es que el resultado sea una permutación completa del 1 al 6
que conserve lo que ya estaba puesto.

## Decisión: el gate vive en el bloc, no en la pantalla

La forma natural de mostrar esta regla en pantalla es un botón de "empezar" deshabilitado
mientras falten casillas. Pero además el propio bloc se niega a confirmar: aunque la
interfaz olvidara deshabilitar el botón, la partida no arrancaría igual.

La ventaja práctica es que la regla se puede probar sin levantar ninguna pantalla — los
tests le mandan `PreparacionConfirmada` con el reparto incompleto y verifican que no pasa
nada.

## Decisión: los eventos inválidos no emiten estado

Cuando un evento se rechaza (una casilla que no corresponde, un número repetido, un valor
fuera del 1 al 6), el bloc simplemente no emite un estado nuevo.

- **Ventaja:** el rechazo se observa en los tests como "no hubo emisión", y el estado no
  necesita comparación por valor para evitar redibujados innecesarios.
- **Costo:** la pantalla no recibe una explicación de *por qué* se rechazó algo. Se
  consideró aceptable porque la interfaz puede mostrar de entrada solo los números
  disponibles, con lo cual el jugador nunca llega a intentar una jugada inválida. Si hace
  falta el mensaje, se agrega un campo al estado.
