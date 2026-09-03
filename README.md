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
- [ ] Reglas de color (rojo, amarillo, verde, azul, morado)
- [ ] Tablero completo (7×7, 9 zonas)
- [ ] Motor de partida (dados, turnos, casillas iniciales)
- [ ] Puntuación
- [ ] UI jugable completa

## Estructura

```
lib/
  modelo/   entidades de dominio (Celda, Color5, ...)
  reglas/   reglas de colocación por color
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

## Módulo: Celda (`lib/modelo/celda.dart`)

Entidad inmutable que representa una casilla del tablero:

- `fila`, `columna`: posición fija en la grilla.
- `color`: el `Color5` de su zona (determina qué regla aplica).
- `valor`: el número 1-6 anotado, o `null` si sigue vacía.
- `esInicial`: si es una de las 6 casillas fijas que se llenan en la preparación
  de la partida (antes de tirar dados).

`conValor(nuevoValor)` devuelve una copia con el valor anotado, sin mutar la original.

`CeldaWidget` (`lib/ui/widgets/celda_widget.dart`) la renderiza como un cuadro del color
de su zona, con borde grueso si es inicial y el valor centrado.
