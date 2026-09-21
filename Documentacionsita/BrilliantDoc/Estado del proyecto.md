# Estado del proyecto

Última actualización: 2026-09-21 · Repo: https://github.com/ExportDark/Brilliant

Ver también: [[Cómo trabajar en el proyecto]] · [[Arquitectura general]]

## Qué está construido

- [x] **Scaffold** del proyecto Flutter (solo plataformas `windows` y `web`)
- [x] **`Posicion`** — value object con notación del manual ([[Sistema de coordenadas]])
- [x] **`Celda`** + `CeldaWidget` para renderizarla
- [x] **Las 5 reglas de color** — rojo, amarillo, verde, azul, morado
      ([[Reglas de color en código]])
- [x] **`TipoRegion`, `Region`, `extraerValores`** ([[Modelado de regiones]])
- [x] **`Tablero`** — las 9 regiones del mapa, con autovalidación del layout
      ([[Tablero y regiones]])

**El módulo `modelo/` está completo.** 69 tests, todos pasando.

## Qué falta

- [ ] **`TableroWidget`** — dibujar la grilla 7×7 real. Es la única forma de verificar
      con los ojos que la transcripción del layout coincide con la imagen del PDF: las
      validaciones confirman que la grilla está *completa*, pero no que cada color esté
      en la casilla correcta
- [ ] **`juego/`** — dados (2d6), fases de partida, turnos, validación de movimientos
- [ ] **Fase de preparación** — asignar la permutación 1-6 a las 6 casillas iniciales
- [ ] **`puntuacion/`** — el cálculo de puntaje ([[Puntuación]])
- [ ] **UI jugable completa** — poder jugar una partida de principio a fin
- [ ] Tests de integración reproduciendo las Partidas 1 y 2 del manual

## Historial de commits

| Commit | Fecha | Qué agregó |
|---|---|---|
| `918664f` | 2026-09-21 | `Tablero` con las 9 regiones y notación en `Posicion` |
| `9d2b697` | 2026-09-09 | `TipoRegion`, `Region` y `extraerValores` |
| `befd8da` | 2026-09-09 | `Posicion` como value object; `Celda` la usa |
| `c36f24c` | 2026-09-03 | Regla morado (máximo 2 valores distintos) |
| `12b0b29` | 2026-09-03 | Regla azul (todos iguales) |
| `55a14d3` | 2026-09-03 | Regla verde (cualquiera) |
| `a97670e` | 2026-09-03 | Regla amarillo (región única dispersa) |
| `e4cc27a` | 2026-09-03 | Regla rojo (todos diferentes) |
| `0fe18ee` | 2026-09-03 | `Celda`, su widget y el scaffold del proyecto |

## Cómo se viene trabajando

Construcción **incremental, módulo por módulo**: cada pieza se agrega con sus tests y su
commit propio, con la documentación actualizada en el mismo commit. Nada de commits
gigantes que mezclen varias cosas.
