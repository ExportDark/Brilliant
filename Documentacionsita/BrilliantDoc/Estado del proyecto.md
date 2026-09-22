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
- [x] **Anotar valores en el tablero** — `Tablero.conValor` / `sinValor`,
      `Region.conCasilla` / `sinCasilla`, `Celda.sinValor`, todos devolviendo copias
      nuevas sin mutar nada
- [x] **`PreparacionBloc`** — el reparto de los valores iniciales, que no deja empezar
      la partida hasta tener las 6 casillas llenas ([[Preparación de la partida]])

**El módulo `modelo/` está completo** y la capa `juego/` ya arrancó. 91 tests, todos
pasando.

## Qué falta

- [ ] **`TableroWidget`** — dibujar la grilla 7×7 real. Es la única forma de verificar
      con los ojos que la transcripción del layout coincide con la imagen del PDF: las
      validaciones confirman que la grilla está *completa*, pero no que cada color esté
      en la casilla correcta
- [ ] **UI de la fase de preparación** — repartir los 1-6 en las 6 casillas iniciales
- [ ] **Resto de `juego/`** — dados (2d6), turnos, validación de movimientos contra las
      reglas de color, detección de fin de partida
- [ ] **`puntuacion/`** — el cálculo de puntaje ([[Puntuación]])
- [ ] **UI jugable completa** — poder jugar una partida de principio a fin
- [ ] Tests de integración reproduciendo las Partidas 1 y 2 del manual

## Cómo se viene trabajando

Construcción **incremental, módulo por módulo**: cada pieza se agrega con sus tests y su
commit propio, con la documentación actualizada en el mismo commit. Nada de commits
gigantes que mezclen varias cosas.

Para ver qué se hizo y cuándo, el historial está en el repositorio: `git log --oneline`,
o en https://github.com/ExportDark/Brilliant/commits.
