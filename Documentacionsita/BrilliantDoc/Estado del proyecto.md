# Estado del proyecto

Última actualización: 2026-11-11 · Repos: https://github.com/ExportDark/Brilliant (la app)
y https://github.com/ExportDark/Brilliant-Servidor (el servidor, en la carpeta hermana
`Brilliant-servidor`)

Ver también: [[Cómo trabajar en el proyecto]] · [[Arquitectura general]] · [[Historial de cambios]]

## Qué está construido

- [x] **Scaffold** del proyecto Flutter, con las plataformas `web` y, desde el
      2026-10-17, `android` (`windows` se quitó el 2026-11-10: no se usaba)
- [x] **`Posicion`** — value object con notación del manual ([[Sistema de coordenadas]])
- [x] **`Celda`** + `CeldaWidget` para renderizarla
- [x] **Las 5 reglas de color** — rojo, amarillo, verde, azul, morado
      ([[Reglas de color en código]])
- [x] **`TipoRegion`, `Region`, `extraerValores`** ([[Modelado de regiones]])
- [x] **`Tablero`** — las 9 regiones del mapa, con autovalidación del layout
      ([[Tablero y regiones]])
- [x] **Anotar valores en el tablero** — `Tablero.conValor` / `conValores` / `sinValor`,
      `Region.conCasilla` / `sinCasilla`, `Celda.sinValor`, todos devolviendo copias
      nuevas sin mutar nada
- [x] **`TableroWidget`** — las 7×7 fichas con el color de cada región y el número
      anotado en cada casilla, sin coordenadas a la vista
- [x] **`PreparacionBloc`** — el reparto de los valores iniciales, que no deja empezar
      la partida hasta tener las 6 casillas llenas ([[Preparación de la partida]])
- [x] **Pantalla de preparación** — el jugador reparte los 1-6 tocando las casillas del
      tablero y ve cada número en su posición. El botón **Inicio** solo se habilita con
      las 6 llenas y lleva a la pantalla de partida
- [x] **Botón Aleatorio** en la preparación — completa al azar las casillas que falten
- [x] **Layout verificado contra el PDF** (2026-09-30) — se compararon los colores de las
      49 casillas de los 5 tableros del PDF con el modelo y con la pantalla, y coinciden
      todas, igual que las 6 casillas iniciales ([[Decisiones de extracción del manual]])
- [x] **`PartidaBloc` y validación de jugadas** — dados (2d6), turnos, la **regla del
      dado ancla** (el otro dado va pegado, sin diagonales, a una casilla con el número
      del dado ancla), las reglas de color, pasar turno y fin de partida
      ([[Turnos y jugadas]])
- [x] **Pantalla de partida** — tirar los dados, elegir el dado ancla, iluminar el número
      de las casillas que lo tienen, iluminar dónde cabe el otro dado (y apenas dónde la
      regla de color lo impide), explicar al tocar por qué no se puede; pasar turno y fin
      de partida. La ⚓ solo aparece en los dados
- [x] **El ancla es solo un dado** (2026-10-09) — en el tablero no hay anclas, solo
      casillas con números; el código, los tests y la pantalla ya hablan así
- [x] **Partidas completas simuladas** — 10 partidas con dados al azar (semillas fijas)
      jugadas hasta el final por el `PartidaBloc`: todas terminan y ninguna zona rompe su
      regla de color (`test/juego/partida_completa_test.dart`). Ver [[Pruebas]]
- [x] **Un archivo por prueba** para los casos sueltos, con ayudantes compartidos en
      `test/juego/ayudantes.dart` y `test/ui/pantallas/ayudantes_pantallas.dart`
- [x] **Tests de todo lo que faltaba** (2026-10-13) — 41 pruebas sueltas que cubren desde
      el modelo hasta las pantallas: casillas exactas que se iluminan, el dado de verdad,
      la preparación, las indicaciones y el arranque de la app. Ver [[Pruebas]]
- [x] **Versión Android** (2026-10-17) — APK instalable en el teléfono, solo vertical, con
      el tablero que se adapta al ancho de la pantalla; probada en un emulador de 360 px.
      Ver [[Versión Android]]
- [x] **Camino feliz** (2026-10-18) — una partida entera sin pantalla, de la preparación
      al tablero lleno, con dados que recorren las 36 combinaciones. Ver [[Pruebas]]
- [x] **Camino feliz por la pantalla** (2026-10-19) — la misma idea como widget test:
      la app entera, jugada tocando, de la preparación a "Jugar otra vez". Ver [[Pruebas]]
- [x] **Interfaz suave** (2026-10-18) — tema crema con colores suaves, fichas
      redondeadas sin cuadrícula negra, **ninguna coordenada a la vista**, dados con
      puntos (`DadoWidget`), casillas encendidas con aro blanco y brillo, barra de
      progreso y una tarjeta de fin de partida con "Jugar otra vez". Ver
      [[Interfaz del tablero]]
- [x] **Los 4 mapas oficiales en el modelo** (2026-10-24) — `nivel1` a `nivel4`, con el
      gris y el naranja, sus casillas iniciales (las de la estrellita, desde el
      2026-10-26), y las partidas simuladas y el camino feliz corriendo en los cuatro.
      Ver [[Mapas]]
- [x] **Elegir el mapa en la app** (2026-10-24) — la app abre en "Elige un mapa", con
      los 4 niveles en miniatura. "Jugar otra vez" repite el mismo mapa, y salir a mitad
      de partida pide confirmación. Ver [[Mapas]]
- [x] **Servidor de cuentas** (2026-11-02) — un programa aparte en `Brilliant-servidor/`, con
      Django, djoser y knox: crear la cuenta, iniciar y cerrar sesión, y borrarla, por
      HTTPS con una autoridad local. Desde el 2026-11-03 se anuncia en la WiFi (mDNS) y
      se vuelve a levantar solo si la PC cambia de red. Desde el 2026-11-04, con reglas
      para el nombre de usuario y la contraseña, y una sola sesión activa por cuenta.
      76 tests. Ver [[Servidor de cuentas]]
- [x] **Las cuentas en la app** (2026-11-02) — "Iniciar sesión", "Crear cuenta" y
      "Mi cuenta" (cerrar sesión y borrar la cuenta, con la contraseña). Sin sesión no
      se juega, y la sesión se recuerda. Ver [[Cuentas en la app]]
- [x] **La app encuentra el servidor** (2026-11-03) — si no contesta, lo busca en la WiFi
      (mDNS) y se cambia solo. En "Iniciar sesión" > Servidor se elige de la lista de los
      que encuentra, o se escribe la IP. Ya no hay que recompilar el APK si cambia la IP
      de la PC. Ver [[Cuentas en la app#Encontrar el servidor]]
- [x] **El servidor disponible, a la vista** (2026-11-04) — "Iniciar sesión" muestra
      "Servidor disponible" con un punto verde, o "Sin servidor" con uno rojo. Lo vuelve
      a revisar solo al abrir, al volver a la app, al cambiar la red del aparato y cada
      10 segundos mientras no hay. Ver [[Cuentas en la app#Si está disponible, a la vista]]
- [x] **Las reglas de las cuentas** (2026-11-04) — usuario de 3 a 20 letras sin acento,
      números, `.`, `_` y `-`; "Ana" y "ana" son la misma cuenta; contraseña de 8 a 128,
      sin recortar; y una sola sesión activa por cuenta, con un aviso cada 2 minutos. En
      el servidor y en la app, con los mismos mensajes. Ver
      [[Cuentas en la app#Las reglas de las cuentas]]
- [x] **El servidor en su propio repositorio** (2026-11-10) — `Brilliant-servidor`, con su
      historial. La app y el servidor solo se hablan por HTTPS. Ver [[Servidor de cuentas]]
- [x] **El cierre de sesión llega** (2026-11-10) — antes se perdía en silencio; las sesiones
      vencen a los 5 minutos sin uso y reiniciar el servidor las cierra todas
- [x] **Multijugador** (2026-11-10) — salas con código de 2 a 6 jugadores, lobby con los
      mapas en tarjetas, preparación con cuenta regresiva, rondas con dados compartidos,
      panel de zonas, rendirse, desconexiones y resultado. El servidor manda; nadie ve el
      tablero de otro. Jugable, sin diseño. Ver [[Multijugador]]
- [x] **Puntos del multijugador** (2026-11-10) — la tabla por mapa y color, por puesto en
      que se llena cada zona. Ver [[Puntuación]]
- [x] **El login más fácil** (2026-11-10) — la lista de servidores en la misma pantalla
      cuando hay varios, "Entrar" espera al servidor, se recuerda el último usuario, y
      mensajes claros para el límite de intentos y el servidor lento. Ver
      [[Cuentas en la app]]
- [x] **Revisión de lógica** (2026-11-11) — 8 errores arreglados con su prueba, y los
      riesgos que quedan anotados. Ver [[Revisión de lógica]]

**Ya se puede jugar solo y en línea**, en la PC (web) y en un teléfono Android: solo, de
la preparación hasta que ninguna tirada tiene jugada; en línea, de 2 a 6 jugadores con
puntos por zona. 710 tests de la app y 1029 del servidor, todos pasando, más 18 que
juegan contra el servidor de verdad.

## Qué falta

- [ ] **Probar en un celular de verdad que encuentra el servidor solo.** En el emulador
      la búsqueda corre, pero no puede encontrar el de la PC: su red (NAT) no deja pasar
      el multicast
- [ ] **El diseño del multijugador y del login.** Por ahora son pantallas funcionales
- [ ] **Probar el multijugador con varios celulares** de verdad en la misma WiFi
- [ ] **Decidir cómo se puntúa jugando solo.** Con las reglas actuales el tablero
      **siempre** termina lleno, así que contar casillas no distingue a nadie
      ([[Puntuación]]). En línea ya hay puntos
- [ ] Tests de integración reproduciendo las Partidas 1 y 2 del manual. Ojo: esas partidas
      se jugaron con la regla del PDF (cualquier casilla libre), sin la regla del dado
      ancla. Sirven para validar las reglas de color, no la del dado ancla
- [ ] Ícono propio para la app de Android (hoy usa el de Flutter)

## Cómo se viene trabajando

Construcción **incremental, módulo por módulo**: cada pieza se agrega con sus tests y su
commit propio, con la documentación actualizada en el mismo commit. Nada de commits
gigantes que mezclen varias cosas.

Qué se hizo y cuándo, con su porqué, está en [[Historial de cambios]]. El detalle exacto
de cada commit está en el repositorio: `git log --oneline`, o en
https://github.com/ExportDark/Brilliant/commits.
