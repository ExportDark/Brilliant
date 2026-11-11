# Brilliant

Recreación digital en Flutter/Dart del juego de mesa *Brilliant* (Ravensburger) —
imitación casera con fines personales y educativos, sin afiliación oficial.

Repositorios: https://github.com/ExportDark/Brilliant (la app) y
https://github.com/ExportDark/Brilliant-Servidor (el servidor)

---

## El juego

- [[Reglas del juego]] — objetivo, reglas por color, desarrollo de un turno
- [[Tablero y regiones]] — el Nivel 1: el mapa 7×7, las 9 regiones y las casillas iniciales
- [[Mapas]] — los 4 mapas oficiales, sus zonas, las reglas por símbolo y cómo se sacaron de la foto
- [[Puntuación]] — los puntos por zona del multijugador, y por qué jugando solo todavía no hay
- [[Multijugador]] — salas con código de 2 a 6 jugadores: el lobby, la partida en línea, el panel de zonas y las desconexiones

## El código

- [[Arquitectura general]] — las 4 capas y qué pregunta responde cada una
- [[Modelo de dominio]] — `Posicion`, `Celda`, `TipoRegion`, `Region`, `Mapa`, `Tablero`
- [[Reglas de color en código]] — el contrato `ReglaColor` y las funciones puras
- [[Preparación de la partida]] — repartir los valores iniciales antes de jugar
- [[Turnos y jugadas]] — los dados, la regla del ancla y la validación de cada jugada
- [[Interfaz del tablero]] — el tema suave, cómo se iluminan las casillas y los dados
- [[Pruebas]] — qué cubren los tests, cómo están organizados y las partidas simuladas
- [[Servidor de cuentas]] — el programa aparte (`Brilliant-servidor`) con las cuentas y las salas, y su seguridad
- [[Cuentas en la app]] — crear la cuenta, iniciar y cerrar sesión, borrarla, encontrar el servidor en la red y elegirlo de la lista

## Decisiones de diseño

- [[Decisiones de extracción del manual]] — cómo se sacó el tablero del PDF
- [[Sistema de coordenadas]] — fila/columna, y la notación del manual
- [[Modelado de regiones]] — `TipoRegion`, identificador, `completada`, el tamaño de cada zona

## El proyecto

- [[Estado del proyecto]] — qué está construido y qué sigue
- [[Historial de cambios]] — todo lo que se hizo, por fecha, con su porqué y su commit
- [[Revisión de lógica]] — los errores de lógica que se encontraron y arreglaron, y los riesgos que quedan
- [[Cómo trabajar en el proyecto]] — comandos, rutas y problemas conocidos
- [[Versión Android]] — compilar el APK e instalarlo en el teléfono
