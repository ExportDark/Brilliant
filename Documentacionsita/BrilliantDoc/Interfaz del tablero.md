# Interfaz del tablero

Cómo se dibuja el tablero y cómo se resaltan las casillas. Es lo que hacen `CeldaWidget`
y `TableroWidget` (`lib/ui/widgets/`), y lo usan las dos pantallas.

Ver también: [[Turnos y jugadas]] · [[Preparación de la partida]] · [[Tablero y regiones]]

> [!note] Lo visual se va a afinar
> Lo de esta nota es la primera versión, acordada el 2026-10-04. Se quedó en que después
> se trabaja mejor la parte visual; las intensidades están en constantes fáciles de
> cambiar.

## La grilla

- 7×7 casillas de 48 px, con las letras de columna (A–G) arriba y los números de fila
  (1–7) a la izquierda, igual que en el manual.
- Cada casilla tiene el color de su zona: amarillo, verde, morado, azul o rojo.
- **La cuadrícula siempre es negra.** Las 6 casillas iniciales llevan un borde más grueso
  (3 px en vez de 1), también negro.
- El número anotado va al centro, en blanco y negrita.

## Cómo se resalta una casilla

Para resaltar una casilla **nunca se pinta el borde**: se **ilumina el relleno**, que se
aclara hacia el blanco sin perder el color de su zona.

| Caso | Cuánto se aclara | Dónde se usa |
|---|---|---|
| Normal | nada | — |
| `Iluminacion.posible` | mucho (`_aclaradoFuerte = 0.55`) | Partida: ahí se puede anotar el dado |
| `Iluminacion.bloqueada` | poco (`_aclaradoSuave = 0.25`) | Partida: junto al ancla, pero la regla de color no lo acepta |
| `seleccionada` | mucho, igual que `posible` | Preparación: la casilla donde va a caer el próximo número |

Sobre una casilla muy aclarada el número blanco ya no se lee, así que ahí va en negro.

Las dos constantes están al principio de `lib/ui/widgets/celda_widget.dart`.

## La marca de ancla

En la partida, las casillas que tienen el número del dado ancla muestran un **⚓
chiquito** en la esquina superior derecha, sobre un círculo claro para que se vea en
cualquier color. Ver [[Turnos y jugadas]].

## Los dados

Cuadros de 64 px con el número. El dado que es ancla lleva borde ámbar grueso, fondo
ámbar claro y un ⚓ debajo. El borde ámbar es del dado, no de la cuadrícula.

## La explicación

Al tocar una casilla vacía donde no se puede jugar, aparece debajo del tablero un
recuadro rojo claro con el motivo. Puede ser que no está junto a ningún ancla, o la regla
de la zona con lo que la zona ya tiene. Ver [[Turnos y jugadas]].

## Cómo se decidió

- **2026-10-04, primera versión:** las jugadas válidas se marcaban con borde blanco y las
  bloqueadas se oscurecían, y la casilla seleccionada en la preparación llevaba borde
  ámbar.
- **2026-10-04, corrección:** el borde blanco hacía que la cuadrícula se viera blanca, y
  la idea era iluminar la casilla, no el borde. Se dejó la cuadrícula siempre negra y se
  pasó a aclarar el relleno. Las bloqueadas, en vez de oscurecerse, se iluminan un poco.
- **Cómo se pinta:** `CeldaWidget` no sabe nada de dados ni de reglas. Recibe
  `iluminacion`, `seleccionada` y `esAncla`, y `TableroWidget` se los reparte con
  `iluminacionDe` y `esAncla`. Quien decide qué se ilumina es la pantalla, a partir de
  `state.evaluar(posicion)` del bloc.
