# Turnos y jugadas

Lo que pasa después de la preparación: tirar los dados, elegir uno como **ancla** y anotar
el otro junto a una casilla que tenga el número del ancla. Implementado en `lib/juego/`.

Ver también: [[Reglas del juego]] · [[Preparación de la partida]] · [[Reglas de color en código]]

## Un turno

1. Se tiran los **dos dados**. Por ejemplo, salen 4 y 2.
2. El jugador elige uno como **ancla**, por ejemplo el 4. El otro dado (el 2) es el número
   que va a anotar. Mientras no lo coloque, puede cambiar el ancla al otro dado.
3. Anota el 2 en una **casilla libre pegada a cualquier casilla que tenga un 4**: arriba,
   abajo, a la izquierda o a la derecha. **Las diagonales no cuentan.** Además, la regla de
   color de la zona donde cae tiene que aceptar el 2. Anotar cierra el turno.
4. Si **no hay jugada con ninguno de los dos dados como ancla**, el turno se pasa sin anotar.

La partida **termina** cuando ninguna tirada posible tiene jugada: ninguna combinación de
ancla y número del 1 al 6 cabe en ningún lado. Eso incluye el tablero lleno, pero también
un tablero con casillas libres que ninguna tirada puede llenar, por ejemplo una zona roja
que ya repitió un número.

Al empezar siempre hay jugada: la preparación pone los 6 números, uno en cada casilla
inicial, así que cualquier dado tiene al menos una casilla ancla.

> [!warning] Difiere del manual (decisión del 2026-10-04)
> El PDF dice que el número se anota en *cualquier* casilla libre. En este proyecto se
> decidió que el otro dado vaya pegado a una casilla con el número del ancla, para que
> cada jugada dependa de lo que ya hay en el tablero. Ver [[Reglas del juego]].

## La validación de una jugada

`evaluarJugada(tablero, posicion, ancla: a, valor: v)` (`validacion_jugada.dart`) responde
qué pasaría al anotar `v` en `posicion` con `a` de ancla. Revisa en este orden y devuelve
uno de cuatro resultados (`sealed`):

| Resultado | Cuándo |
|---|---|
| `CasillaOcupada` | La casilla ya tiene número (por ejemplo, una de las 6 iniciales) |
| `SinAncla(ancla)` | Ninguna de sus vecinas (arriba, abajo, izquierda, derecha) tiene el número ancla |
| `ReglaRota(region, valoresEnZona)` | Está junto a un ancla, pero la regla de su zona no acepta el número |
| `JugadaValida` | Libre, junto a un ancla, y la zona lo acepta |

Las vecinas salen de `Posicion.vecinas`, que da las 4 ortogonales. En los bordes del
tablero algunas caen fuera de la grilla, y como `tablero.celdaEn` devuelve `null` para
esas, simplemente no cuentan.

La regla de color es la misma pregunta de siempre,
`region.tipo.regla.puedeAgregar(extraerValores(region), valor)`.

`SinAncla` y `ReglaRota` traen lo necesario para explicarle al jugador **por qué** no puede
ponerlo ahí. La pantalla arma mensajes como:

- *"A2 no está junto a ningún 4: el 2 va arriba, abajo, a la izquierda o a la derecha de
  un 4."*
- *"C2 · Zona azul — Todos iguales: las 4 casillas llevan el mismo número. Ya tiene: 4"*,
  con la `descripcion` de cada regla.

`hayJugada(tablero, ancla: a, valor: v)` dice si alguna casilla acepta `v` con `a` de ancla.
Con eso se calculan "no hay jugada" y "la partida terminó".

## PartidaBloc

Es un bloc local, igual que `PreparacionBloc`: se crea en la pantalla de partida con el
tablero que ya tiene los valores iniciales.

### Los eventos

| Evento | Qué hace | Cuándo se ignora |
|---|---|---|
| `DadosTirados` | Saca los dos dados | Si ya hay una tirada pendiente o la partida terminó |
| `DadoElegido(indice)` | Hace ancla al dado 0 o 1 | Si no se ha tirado, o el índice no es 0 ni 1 |
| `ValorColocado(posicion)` | Anota el otro dado y cierra el turno | Sin ancla elegida, o si la jugada no es `JugadaValida` |
| `TurnoPasado` | Cierra el turno sin anotar | Si hay jugada con alguno de los dos dados como ancla |

### El estado

```dart
class PartidaState {
  final Tablero tablero;
  final List<int>? dados;     // null antes de tirar
  final int? dadoElegido;     // el índice del dado ancla
  final int turno;            // empieza en 1
}
```

Lo demás se calcula a partir de esos campos:

- `valorAncla` y `valorAColocar`: el dado ancla y el otro
- `evaluar(posicion)`: el resultado de anotar `valorAColocar` ahí
- `esAncla(posicion)`: si esa casilla tiene el número ancla
- `sinJugada`: se tiró y no hay jugada con ningún dado como ancla
- `terminada` y `casillasLlenas`

## La pantalla

`PantallaPartida` (`lib/ui/pantallas/pantalla_partida.dart`) crea el `PartidaBloc` con
`BlocProvider` y dibuja su estado, de arriba abajo:

- **El turno** y una indicación de qué hacer: tirar, elegir el dado ancla, "pon el 2 junto
  a un 4", pasar el turno o, al final, cuántas casillas se llenaron.
- **El tablero.** Las casillas con el número ancla llevan un ⚓ chiquito en la esquina.
  Cada casilla vacía se ilumina según `state.evaluar(posicion)`:
  - mucho (`Iluminacion.posible`) si es una jugada válida
  - apenas (`Iluminacion.bloqueada`) si está junto a un ancla pero la regla de su zona no
    lo permite
  - nada si no está junto a ningún ancla

  La cuadrícula siempre es negra: lo que cambia es el relleno de la casilla, que se aclara
  hacia el blanco.
- **La explicación.** Al tocar una casilla vacía donde no se puede, aparece debajo del
  tablero por qué: no está junto a ningún ancla, o la regla de la zona lo impide. Al tocar
  una iluminada se anota el número.
- **Los dos dados.** Se toca uno para hacerlo ancla; lleva borde ámbar y un ⚓ debajo.
- **Tirar dados**, o **Pasar turno** cuando no hay jugada.

La explicación que se está mostrando es estado de la pantalla, no del bloc, igual que la
casilla seleccionada en la preparación. Se borra al tirar, al cambiar de ancla y al
colocar.

`CeldaWidget` recibe la `Iluminacion` y `esAncla`, y `TableroWidget` los reparte con
`iluminacionDe` y `esAncla`. Así el tablero no sabe nada de dados ni de reglas: solo dibuja
lo que le dicen.

## Decisión: los dados se inyectan

El constructor recibe `tirarDado`, una función que devuelve una cara del 1 al 6.
`PantallaPartida` también la recibe y se la pasa al bloc. En la app es un `Random`; en los
tests es una secuencia fija, para saber exactamente qué sale y probar casos como "no hay
jugada" sin depender de la suerte.

## Decisión: "pasar" es un evento explícito

Cuando no hay jugada, el bloc no pasa el turno solo: espera `TurnoPasado`. Así el jugador ve
la tirada que le tocó antes de seguir, y el bloc solo lo acepta si de verdad no hay jugada,
de modo que no se puede usar para saltarse un turno que sí tenía dónde anotar.
