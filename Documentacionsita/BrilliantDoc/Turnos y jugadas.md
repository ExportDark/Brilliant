# Turnos y jugadas

Lo que pasa después de la preparación: tirar los dados, elegir uno y anotarlo donde la
regla de la zona lo permita. Implementado en `lib/juego/`.

Ver también: [[Reglas del juego]] · [[Preparación de la partida]] · [[Reglas de color en código]]

## Un turno

1. Se tiran los **dos dados**.
2. El jugador **ancla** uno de los dos: ese es el número que va a anotar. Mientras no lo
   coloque, puede anclar el otro.
3. Lo anota en una **casilla libre** cuya zona lo acepte. Eso cierra el turno.
4. Si **ninguno de los dos dados** cabe en ningún lado, el turno se pasa sin anotar nada.

La partida **termina** cuando ya ninguna casilla acepta ningún número del 1 al 6. Eso
incluye el tablero lleno, pero también un tablero con casillas libres que ninguna tirada
puede llenar, por ejemplo una zona roja que ya repitió un número.

## La validación de una jugada

`evaluarJugada(tablero, posicion, valor)` (`validacion_jugada.dart`) responde qué pasaría
al anotar `valor` en `posicion`, con uno de tres resultados (`sealed`):

| Resultado | Cuándo |
|---|---|
| `JugadaValida` | La casilla está libre y la regla de su zona acepta el número |
| `CasillaOcupada` | La casilla ya tiene número (por ejemplo, una de las 6 iniciales) |
| `ReglaRota(region, valoresEnZona)` | La casilla está libre pero la regla de su zona no lo permite |

No inventa nada nuevo: es la misma pregunta de siempre,
`region.tipo.regla.puedeAgregar(extraerValores(region), valor)`, más la comprobación de
que la casilla esté libre.

`ReglaRota` trae la región y lo que esa zona ya tiene anotado, para poder explicarle al
jugador **por qué** no puede ponerlo ahí. Junto con la `descripcion` de cada regla, la
pantalla arma mensajes como *"C2 · Zona azul — Todos iguales: las 4 casillas llevan el
mismo número. Ya tiene: 4"*.

`hayLugarPara(tablero, valor)` dice si alguna casilla libre acepta ese número. Con eso se
calculan "ningún dado cabe" y "la partida terminó".

## PartidaBloc

Es un bloc local, igual que `PreparacionBloc`: se crea en la pantalla de partida con el
tablero que ya tiene los valores iniciales.

### Los eventos

| Evento | Qué hace | Cuándo se ignora |
|---|---|---|
| `DadosTirados` | Saca los dos dados | Si ya hay una tirada pendiente o la partida terminó |
| `DadoElegido(indice)` | Ancla el dado 0 o 1 | Si no se ha tirado, o el índice no es 0 ni 1 |
| `ValorColocado(posicion)` | Anota el dado anclado y cierra el turno | Sin dado anclado, o si la jugada no es `JugadaValida` |
| `TurnoPasado` | Cierra el turno sin anotar | Si alguno de los dos dados cabe |

### El estado

```dart
class PartidaState {
  final Tablero tablero;
  final List<int>? dados;     // null antes de tirar
  final int? dadoElegido;     // el índice del dado anclado
  final int turno;            // empieza en 1
}
```

Lo demás se calcula a partir de esos campos: `valorElegido`, `evaluar(posicion)`,
`sinJugada` (se tiró y ningún dado cabe), `terminada` y `casillasLlenas`.

## Decisión: los dados se inyectan

El constructor recibe `tirarDado`, una función que devuelve una cara del 1 al 6. En la
app es un `Random`; en los tests es una secuencia fija, para saber exactamente qué sale y
probar casos como "ningún dado cabe" sin depender de la suerte.

## Decisión: "pasar" es un evento explícito

Cuando ningún dado cabe, el bloc no pasa el turno solo: espera `TurnoPasado`. Así el
jugador ve la tirada que le tocó antes de seguir, y el bloc solo lo acepta si de verdad
no hay jugada, de modo que no se puede usar para saltarse un turno que sí tenía dónde
anotar.
