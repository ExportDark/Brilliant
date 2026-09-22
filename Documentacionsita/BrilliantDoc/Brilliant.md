# Brilliant

Recreación digital en Flutter/Dart del juego de mesa *Brilliant* (Ravensburger) —
imitación casera con fines personales y educativos, sin afiliación oficial.

Repositorio: https://github.com/ExportDark/Brilliant

---

## El juego

- [[Reglas del juego]] — objetivo, reglas por color, desarrollo de un turno
- [[Tablero y regiones]] — el mapa 7×7, las 9 regiones y las casillas iniciales
- [[Puntuación]] — la propuesta de puntaje del manual

## El código

- [[Arquitectura general]] — las 4 capas y qué pregunta responde cada una
- [[Modelo de dominio]] — `Posicion`, `Celda`, `TipoRegion`, `Region`, `Tablero`
- [[Reglas de color en código]] — el contrato `ReglaColor` y las funciones puras
- [[Preparación de la partida]] — repartir los valores iniciales antes de jugar

## Decisiones de diseño

- [[Decisiones de extracción del manual]] — cómo se sacó el tablero del PDF
- [[Sistema de coordenadas]] — fila/columna, y la notación del manual
- [[Modelado de regiones]] — `TipoRegion`, identificador, `completada`, `cantidadCeldas`

## El proyecto

- [[Estado del proyecto]] — qué está construido y qué sigue
- [[Cómo trabajar en el proyecto]] — comandos, rutas y problemas conocidos
