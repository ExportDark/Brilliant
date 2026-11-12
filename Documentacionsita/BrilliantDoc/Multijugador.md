# Multijugador

Partidas en línea de 2 a 6 jugadores, en salas a las que se entra con un código.
**El servidor manda:** tira los dados, valida cada jugada, reparte los puestos de las
zonas y calcula los puntos. La app solo dibuja lo que el servidor le dice y le manda lo
que toca el jugador. Construido el 2026-11-10; por ahora es **jugable, sin diseño**.

Ver también: [[Puntuación]] · [[Servidor de cuentas]] · [[Cuentas en la app]] ·
[[Revisión de lógica]] · [[Pruebas]]

## Decisiones

| Tema | Decisión |
|---|---|
| Conexión | HTTP: la app le pregunta al servidor cada segundo (`GET /salas/<código>/?version=N`, 304 si no cambió) |
| Quién manda | El servidor. Tiene las reglas del juego portadas a Python, y una prueba de paridad exige que den lo mismo que las de la app |
| Salirse o desconectarse | Fuera al instante. Con 2 jugadores, gana el otro. **Si se va el anfitrión, ganan los demás.** Con 3 o más, si se va otro, la partida sigue; si queda uno solo, gana |
| Privacidad | Nadie ve los números ni las casillas de los demás: el servidor manda a cada uno solo su tablero |
| Fin | Cuando todos llenaron su tablero o ya nadie puede jugar |
| Salas | Viven en la memoria del servidor: si se reinicia, las partidas terminan |

## Cómo se juega

1. **Crear o unirse.** Desde "Elige un mapa", el botón de personas abre "Jugar con otros":
   "Crear sala" da un código de 6 caracteres, sin los que se confunden al dictarlo (0/O,
   1/I/L). Quien lo recibe lo escribe en "Código de la sala" y toca "Unirme".
2. **El lobby.** El código grande (con botón para copiarlo), los jugadores (el anfitrión
   con estrella, hasta 6) y el mapa. **El mapa se elige con las mismas tarjetas de "Elige
   un mapa"**, con su tablero en miniatura (`TarjetaDeMapa`); la elegida lleva un borde de
   color. Quien no es el anfitrión ve solo la tarjeta del mapa elegido. "Empezar" se
   habilita con 2 o más. **Salir del lobby** (o la flecha de atrás) vuelve directo a
   "Elige un mapa". Si el anfitrión cierra la sala, los demás ven "El anfitrión cerró la
   sala." (no un resultado: no hubo partida).
3. **La preparación.** La misma pantalla del modo de un jugador (`PantallaPreparacion`, con
   `alConfirmar` y `titulo`), a pantalla completa, con la cuenta regresiva en el título
   ("Reparte tus números · 60 s"). Al tocar "Inicio" el reparto va al servidor y se espera
   a los demás, viendo quién ya terminó. A los 60 s, el servidor reparte al azar a quien
   no lo hizo. Si el servidor rechaza el reparto, o no le llega, la pantalla vuelve a ser
   editable con los mismos números (`PreparacionReabierta`) para corregirlo.
4. **La partida.** Mi tablero, los dos dados (los mismos para todos), la ronda y su cuenta
   regresiva, los jugadores con sus puntos y quién ya jugó, y el **panel de zonas**. Se
   toca un dado (el ancla) y una casilla iluminada; las casillas legales las calcula el
   servidor. Quien no tiene jugada con la tirada pasa solo; quien no juega en 60 s, pasa.
   Las casillas que la regla de su zona bloquea se ven un poco apagadas y, al tocar una
   casilla que no vale, la línea de arriba explica por qué, igual que jugando solo (con
   las reglas de la app; la jugada nunca se manda).
5. **El resultado.** Quién ganó y por qué ("Todos llenaron su tablero", "Ya nadie puede
   jugar", "El anfitrión se fue: ganan los demás"…), el ranking con puntos y primeros
   puestos, y cómo quedaron las zonas.

"Rendirse" pide confirmación; salir de la pantalla a mitad de partida es rendirse. Quien
se rinde o se desconecta conserva sus puntos, pero no puede ganar.

## El panel de zonas

Una fila por zona del mapa: su color y cuántas casillas tiene, los puestos que ya se
tomaron (quién y en qué ronda) y cuántos puntos da el siguiente puesto libre, o
"Agotada" si ya se tomaron los tres que pagan. Así se sabe qué zonas siguen dando puntos
sin ver los tableros de nadie. Los puntos de cada puesto están en [[Puntuación]].

## Desconexiones

- La app pregunta cada segundo; preguntar (o cualquier otro pedido) es lo que le dice al
  servidor que el jugador sigue ahí.
- **3 s sin respuesta:** "Reconectando con el servidor…". **10 s:** "Se perdió la conexión.
  Si no vuelve, quedas fuera de la partida." Mientras tanto se sigue viendo el tablero.
- **El servidor saca a quien pasa más de 10 s sin hablarle.** Un corte más corto no cuenta.
- La cuenta regresiva de la ronda se descuenta en la app (`SalaState.segundosQueQuedan`):
  el 304 no trae los segundos nuevos, y sin esto el tiempo se quedaba congelado. Nunca baja
  de "0 s".
- El tiempo se mide con un cronómetro (`relojMonotono`), no con la hora del teléfono: si
  el teléfono ajusta su reloj a mitad de partida, la cuenta no salta.
- Si el servidor se reinició, la sala ya no existe: la app lo dice y deja volver.
- ⚠️ Si el celular pasa a segundo plano más de 10 s, queda fuera.

## Código

- **App:** `lib/multijugador/` (modelos, `ClienteSalas` con `ClienteSalasHttp`, `SalaBloc`,
  sus eventos y su estado) y `lib/ui/pantallas/multijugador/` (una vista por etapa,
  `ListaDeJugadores`, `PanelDeZonas`). El token no sale del `SesionBloc`: el cliente de salas
  lo pide prestado con `conToken`.
- **Servidor:** `Brilliant-servidor/salas/` (`dominio.py`, Python puro con un reloj que los
  tests controlan; `views.py`, la API) y `juego/` (las reglas y los puntos). La API está en
  el README del servidor.
- **Las reglas compartidas:** la app genera `tool/exportado/mapas.json` y
  `casos_de_jugadas.json` (`dart run tool/exportar_para_el_servidor.dart`), que se copian a
  mano a `Brilliant-servidor/juego/datos/`. Un test de cada lado falla si no coinciden.

## Pruebas

En la app, un archivo por situación en `test/multijugador/` y
`test/ui/pantallas/multijugador/` (lobby, preparación, partida, desconexión, privacidad,
resultado), más los 5 tamaños de pantalla. Contra el servidor real, 14 partidas con
varios clientes. En el servidor, 239 tests de salas. El detalle, en [[Pruebas]].

## Pendiente

- El diseño de las pantallas (por ahora son funcionales).
- Probar con varios celulares de verdad en la misma WiFi.
