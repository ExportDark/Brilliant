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
- [ ] Reglas de color: [x] rojo, [x] amarillo, [ ] verde, [ ] azul, [ ] morado
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
