# Turnos y jugadas

Lo que pasa después de la preparación: tirar los dados, elegir uno como **dado ancla** y
anotar el otro junto a una casilla que tenga el número del dado ancla. Implementado en
`lib/juego/`.

Ver también: [[Reglas del juego]] · [[Preparación de la partida]] · [[Reglas de color en código]]

> [!important] El ancla es solo un dado
> "Ancla" se refiere únicamente a uno de los dos dados. **En el tablero no hay anclas**: hay
> casillas que tienen números. El dado ancla dice qué número buscar en el tablero, y el
> otro dado se anota junto a alguna casilla que tenga ese número (decisión del
> 2026-10-09).

## Un turno

1. Se tiran los **dos dados**. Por ejemplo, salen 2 y 4.
2. El jugador elige uno como **dado ancla**, por ejemplo el 4. El otro dado (el 2) es el
   número que va a anotar. Mientras no lo coloque, puede cambiar el ancla al otro dado.
3. Se buscan en el tablero **las casillas que tienen un 4**, y el 2 se anota en una
   **casilla libre pegada a alguna de ellas**: arriba, abajo, a la izquierda o a la
   derecha. **Las diagonales no cuentan.** Además, la regla de color de la zona donde cae
   tiene que aceptar el 2. Anotar cierra el turno.
4. Si **no hay jugada con ninguno de los dos dados como ancla**, el turno se pasa sin
   anotar.

Cualquier casilla con el número sirve, sea inicial o anotada en un turno anterior: un 3
que anotaste hoy cuenta igual que el 3 inicial cuando mañana el dado ancla saque 3.

La partida **termina** cuando ninguna tirada posible tiene jugada: no hay combinación de
dado ancla y número del 1 al 6 que quepa en ningún lado.

En la práctica eso es **el tablero lleno**. Jugando, ninguna zona se queda sin salida, y
toda casilla vacía tarde o temprano queda junto a una llena, así que la partida siempre
acaba con las 49 casillas (lo confirmaron las partidas simuladas de [[Pruebas]]). Un
tablero con casillas libres que nadie puede llenar, como una zona roja con un número
repetido, solo se puede armar a mano en los tests, saltándose las reglas. Ver
[[Puntuación]] para lo que esto significa al contar puntos.

Al empezar siempre hay jugada: la preparación pone los 6 números, uno en cada casilla
inicial, así que saque lo que saque el dado ancla, hay al menos una casilla con ese
número.

> [!warning] Difiere del manual (decisión del 2026-10-04)
> El PDF dice que el número se anota en *cualquier* casilla libre. En este proyecto se
> decidió que el otro dado vaya pegado a una casilla con el número del dado ancla, para
> que cada jugada dependa de lo que ya hay en el tablero. Ver [[Reglas del juego]].

## La validación de una jugada

`evaluarJugada(tablero, posicion, ancla: a, valor: v)` (`validacion_jugada.dart`) responde
qué pasaría al anotar `v` en `posicion` cuando el dado ancla sacó `a`. Revisa en este orden
y devuelve uno de cuatro resultados (`sealed`):

| Resultado | Cuándo |
|---|---|
| `CasillaOcupada` | La casilla ya tiene número (por ejemplo, una de las 6 iniciales) |
| `SinVecinoConNumero(numero)` | Ninguna de sus vecinas (arriba, abajo, izquierda, derecha) tiene el número que se busca |
| `ReglaRota(region, valoresEnZona)` | Está junto a una casilla con el número, pero la regla de su zona no acepta el valor |
| `JugadaValida` | Libre, junto a una casilla con el número, y la zona lo acepta |

Las vecinas salen de `Posicion.vecinas`, que da las 4 ortogonales. En los bordes del
tablero algunas caen fuera de la grilla, y como `tablero.celdaEn` devuelve `null` para
esas, simplemente no cuentan.

La regla de color es la misma pregunta de siempre,
`region.tipo.regla.puedeAgregar(extraerValores(region), valor)`.

`SinVecinoConNumero` y `ReglaRota` traen lo necesario para explicarle al jugador **por
qué** no puede ponerlo ahí. La pantalla arma mensajes como estos, **sin coordenadas**:

- *"Esa casilla no está junto a ningún 4: el 2 va arriba, abajo o a un lado de un 4."*
- *"Zona azul — Todos iguales: las 4 casillas llevan el mismo número. Ya tiene: 4"*, con
  la `descripcion` de cada regla.

Entre "un" y el número va un espacio que no se corta (` `), para que el número nunca
quede solo en la línea de abajo.

`hayJugada(tablero, ancla: a, valor: v)` dice si alguna casilla acepta `v` cuando el dado
ancla sacó `a`. Con eso se calculan "no hay jugada" y "la partida terminó".

## PartidaBloc

Es un bloc local, igual que `PreparacionBloc`: se crea en la pantalla de partida con el
tablero que ya tiene los valores iniciales.

### Los eventos

| Evento | Qué hace | Cuándo se ignora |
|---|---|---|
| `DadosTirados` | Saca los dos dados | Si ya hay una tirada pendiente o la partida terminó |
| `DadoElegido(indice)` | Hace dado ancla al dado 0 o 1 | Si no se ha tirado, o el índice no es 0 ni 1 |
| `ValorColocado(posicion)` | Anota el otro dado y cierra el turno | Sin dado ancla elegido, o si la jugada no es `JugadaValida` |
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

- `valorAncla` y `valorAColocar`: lo que sacó el dado ancla y lo que sacó el otro
- `evaluar(posicion)`: el resultado de anotar `valorAColocar` ahí
- `tieneNumeroBuscado(posicion)`: si esa casilla tiene el número que sacó el dado ancla
- `sinJugada`: se tiró y no hay jugada con ningún dado como ancla
- `terminada` y `casillasLlenas`

## La pantalla

`PantallaPartida` (`lib/ui/pantallas/pantalla_partida.dart`) crea el `PartidaBloc` con
`BlocProvider` y dibuja su estado, de arriba abajo:

- **El turno** ("Turno 3", o "Partida terminada" al final), y debajo una **barra de
  progreso** fina con la cuenta de casillas llenas: "12 de 49 casillas".
- **Una indicación** de qué hacer:

  | Momento | Indicación |
  |---|---|
  | Antes de tirar | "Tira los dados." |
  | Sin dado ancla | "Toca un dado para usarlo de ancla: el otro va junto a una casilla con ese número." |
  | Con dado ancla | "Pon el 2 en una casilla iluminada, junto a un 4." |
  | Sin jugada | "Ningún dado tiene jugada. Pasa el turno." |

- **El tablero.** Las casillas que tienen el número del dado ancla **iluminan su número**:
  va en tinta oscura sobre un círculo blanco. Cada casilla vacía se ilumina según
  `state.evaluar(posicion)`:
  - mucho, y queda encendida con aro blanco y brillo (`Iluminacion.posible`), si es una
    jugada válida
  - apenas (`Iluminacion.bloqueada`) si está junto a una casilla con el número pero la
    regla de su zona no lo permite
  - nada si no está junto a ninguna casilla con el número

  **En el tablero no aparece ninguna ⚓ ni ninguna coordenada.** Ver
  [[Interfaz del tablero]].
- **La explicación.** Al tocar una casilla vacía donde no se puede, aparece debajo del
  tablero, en un recuadro suave con ícono de información, por qué: no está junto a
  ninguna casilla con el número, o la regla de la zona lo impide. Al tocar una iluminada
  se anota el número.
- **Los dos dados**, dibujados con sus puntos (`DadoWidget`). Se toca uno para hacerlo
  dado ancla: lleva aro lavanda y debajo ⚓ "ancla". Es el único lugar donde aparece el
  ancla.
- **Tirar dados**, que solo se ve mientras no hay dados en la mesa: con la tirada
  pendiente, lo que toca es elegir el ancla y colocar. Cuando no hay jugada, en su lugar
  aparece **Pasar turno**.
- **Al terminar**, una tarjeta con un trofeo: "¡Tablero completo!" (o "Fin de la partida"
  si quedaron casillas libres, algo que solo pasa en los tests), "Lo jugaste en 73
  turnos." y el botón **Jugar otra vez**, que vuelve a la preparación con un tablero
  nuevo.

La explicación que se está mostrando es estado de la pantalla, no del bloc, igual que la
casilla seleccionada en la preparación. Se borra al tirar, al cambiar de dado ancla y al
colocar.

`CeldaWidget` recibe la `Iluminacion` y `numeroResaltado`, y `TableroWidget` los reparte con
`iluminacionDe` y `numeroResaltadoEn`. Así el tablero no sabe nada de dados ni de reglas:
solo dibuja lo que le dicen.

## Decisión: los dados se inyectan

El constructor recibe `tirarDado`, una función que devuelve una cara del 1 al 6.
`PantallaPartida` también la recibe y se la pasa al bloc. En la app es un `Random`; en los
tests es una secuencia fija, para saber exactamente qué sale y probar casos como "no hay
jugada" sin depender de la suerte.

## Decisión: "pasar" es un evento explícito

Cuando no hay jugada, el bloc no pasa el turno solo: espera `TurnoPasado`. Así el jugador ve
la tirada que le tocó antes de seguir, y el bloc solo lo acepta si de verdad no hay jugada,
de modo que no se puede usar para saltarse un turno que sí tenía dónde anotar.

## Decisión: el ancla es solo un dado (2026-10-09)

Al principio la pantalla marcaba con un ⚓ las casillas del tablero que tenían el número del
dado ancla, y el código las llamaba "anclas" (`esAncla`, `SinAncla`). Eso mezclaba dos
cosas: el ancla es una decisión sobre los dados, y lo que hay en el tablero son solo
números. Se dejó el ancla únicamente en los dados, y en el tablero:

- la ⚓ se reemplazó por **iluminar el número** de esas casillas;
- en el código, `SinAncla` pasó a ser `SinVecinoConNumero`, `esAncla` pasó a ser
  `tieneNumeroBuscado`, y el `esAncla` de los widgets pasó a ser `numeroResaltado` /
  `numeroResaltadoEn`;
- los tests que hablaban de "ancla nueva" o "lejos del ancla" ahora hablan del número.

La mecánica no cambió: sigue siendo la misma regla.
