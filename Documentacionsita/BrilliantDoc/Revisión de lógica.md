# Revisión de lógica

Una revisión de los errores de lógica del proyecto (app y servidor), hecha a pedido el
2026-11-10 y 2026-11-11 (y otras el 2026-11-17 y el 2026-11-18, ver abajo), después del reporte "no me deja iniciar sesión porque ya aparece
que está logueado". Cada error que se encontró se arregló con una prueba que lo
reproduce, y se comprobó que esa prueba falla sin el arreglo.

Ver también: [[Multijugador]] · [[Cuentas en la app]] · [[Servidor de cuentas]] · [[Pruebas]]

## Qué se revisó

- **Servidor:** las salas (`salas/dominio.py`: lobby, preparación, rondas, desconexiones,
  puestos y fin), su API (`salas/views.py`), la tabla de puntos (`juego/puntuacion.py`,
  comparada con la tabla del usuario) y las cuentas (sesiones, límite de intentos).
- **App:** `SalaBloc` y las pantallas del multijugador, `SesionBloc` (entrar, salir, el
  cierre pendiente y el latido), `ServidorCubit` y la preparación de la partida.
- **Probando de verdad:** partidas completas contra el servidor real con 2 a 6 clientes, y
  la app en el emulador contra el servidor, con un segundo jugador hecho con un script.

## Errores encontrados y arreglados

| Error | Qué pasaba | Arreglo | Commit |
|---|---|---|---|
| **El cierre de sesión no llegaba** | El servidor cierra las conexiones inactivas a los 5 s y el cliente reusaba una cerrada: "Cerraste sesión." pero la sesión seguía abierta (409 al volver a entrar) | El cliente cierra las suyas a los 2 s y reintenta una vez lo que no cambia nada; las sesiones vencen a los 5 min | `a60ba1e`, servidor `a2d303d` |
| **Un 429 se tomaba como "sin servidor"** | Si el servidor limitaba los intentos, la revisión de la conexión fallaba y "Entrar" quedaba deshabilitado | Cualquier respuesta del servidor cuenta como "está ahí"; el 429 dice cuántos segundos esperar | `293cb0b` |
| **La cuenta regresiva se congelaba** | El servidor contesta 304 cuando nada cambió, sin los segundos nuevos: la ronda marcaba "58 s" hasta que alguien jugaba, y el paso automático a los 60 s tomaba por sorpresa | La app descuenta el tiempo desde que llegó la sala (`SalaState.segundosQueQuedan`), también sin conexión | `3d31d90` |
| **El reparto rechazado bloqueaba la pantalla** | Si el servidor rechazaba los números iniciales, o no le llegaban, la preparación quedaba "confirmada": no se podía cambiar nada y "Inicio" ya no mandaba nada | Tras mandar, la preparación vuelve a ser editable (`PreparacionReabierta`); un segundo envío tardío no muestra error | `fa6776d` |
| **Una jugada tras un silencio se sacaba a sí misma** | Preguntar (`GET`) anotaba el contacto antes de mirar desconexiones, pero jugar (`POST`) no: con todos callados, quien volvía jugando quedaba fuera y no ganaba nadie | Todo pedido anota el contacto primero, igual que preguntar | servidor `09928ab` |
| **Salirse del lobby respondía 403** | El que salía ya no estaba en la sala y la vista de respuesta lo rechazaba | Responde 204 | servidor `ea9679d` |
| **Un código de sala que no era texto daba 500** | Un JSON con una lista o un objeto como código o como mapa rompía el servidor | Se rechaza con su error | servidor `30317f8` |
| **Cerrar el lobby decía que ganaban los demás** | Si el anfitrión cerraba la sala antes de empezar, los demás veían un resultado con "Nadie ganó" y "El anfitrión se fue: ganan los demás", de una partida que no se jugó; el anfitrión también | Motivo aparte, `sala_cerrada`: los demás ven "El anfitrión cerró la sala." y el anfitrión sale directo (204) | servidor `e6b86a6`, app `5c55685` |
| **Salir del lobby pedía otro toque** | Tras "Salir" aparecía "Ya no estás en la sala" y había que tocar "Volver" | Salir por cuenta propia vuelve directo a "Elige un mapa" | app `5c55685` |
| **El tiempo dependía de la hora del teléfono** | Si el teléfono ajustaba su reloj, la cuenta regresiva saltaba y podía aparecer "se perdió la conexión" | Un cronómetro (`relojMonotono`) | app `5c55685` |
| **Crear o unirse con un doble toque** | Estando ya en una sala, el segundo pedido llegaba al servidor y mostraba "Ya estás en otra sala." | Se ignora | app `5c55685` |
| **"Entrar" podía quedarse esperando** | Un 401, o un "sí" sin token al iniciar sesión, rompían el bloc | Se avisa "El servidor no aceptó el pedido" / "contestó algo inesperado" | app `5c55685` |
| **Solo se recordaba un cierre de sesión pendiente** | Un segundo cierre sin servidor pisaba al primero, que quedaba abierto hasta vencer | Una lista (`porcerrar.lista`), sin perder la que se guardó con la versión anterior | app `5c55685` |
| **Desbordes en el celular chico** | El código de la sala y la fila de puntos del resultado no cabían en 320 px | El código se achica; los "primeros" van debajo de los puntos | `9fe363a` |

## Segunda revisión: integridad y lógica (2026-11-17)

Después de la meta de puntos y del tablero chico de cada jugador. Los dos primeros se
comprobaron corriendo el servidor en memoria antes de arreglarlos; cada prueba nueva se
vio fallar sin su arreglo.

| Error | Qué pasaba | Arreglo | Commit |
|---|---|---|---|
| **Quien se iba se llevaba el puesto** | Si alguien llenaba una zona y se rendía (o se desconectaba) antes de que terminara la ronda, al terminar se quedaba con el puesto y sus puntos, y corría a los demás un lugar, aunque ya no podía ganar | Los puestos se reparten solo entre los que siguen jugando (decidido el 2026-11-17; antes una prueba pedía lo contrario) | servidor `31030c8` |
| **Las salas abandonadas no se iban nunca** | El tiempo de una sala solo corre cuando alguien le pregunta: si todos cerraban la app, la sala (en el lobby o jugando) quedaba en memoria para siempre | Al crear una sala se ponen al día todas: las abandonadas terminan y a los 10 min se olvidan | servidor `31030c8` |
| **Una respuesta rara trababa la sala** | Una sala con un campo de otro tipo (un servidor de otra versión) o algo que no es JSON rompía la lectura sin que nadie lo atrapara: los botones quedaban deshabilitados para siempre, y durante la partida las consultas fallaban en silencio | Se avisa "El servidor contestó algo que esta versión de la app no entiende…" como cualquier rechazo | app (este commit) |
| **Las pruebas contra el servidor no se corrían** | Una había quedado vieja desde el 2026-11-11 sin que nadie lo notara | `tool/probar_todo.sh` corre todo junto: servidor, app y las dos contra el servidor de verdad | app (este commit) |

**Pruebas de integridad nuevas** (en las partidas simuladas del servidor, después de cada
ronda y desde la vista de cada jugador, en los 4 mapas, de 2 a 6 jugadores, con gente que
se rinde antes o justo después de anotar): de los demás solo llega lo público (sus
casillas sin números, nunca la de la ronda en curso); `ultima` está entre las ocupadas; la
meta no cambia; la partida termina en la ronda en que alguien llega; quien se fue no suma
más; y con la misma `version` la vista es la misma (si no, el 304 dejaría a la app sin
enterarse). Y que la meta más alta (26) se pueda alcanzar en cada mapa: los primeros
puestos suman 54, 55, 54 y 50. La simulación encontró sola el error del puesto (semilla 14).

**Revisado y está bien:** rendirse con la partida ya terminada muestra el resultado; la
API rechaza con 4xx los tipos raros; la tabla de puntos cubre todas las zonas; con varios
en la meta gana el de más puntos; ningún mapa tiene dos casillas iniciales en una zona (ya
había pruebas en los dos repos), así que validar el reparto casilla por casilla alcanza.

Se comprobó con `tool/probar_todo.sh`: 1093 pruebas del servidor, 790 de la app, y las 4 de
cuentas y las 14 de partidas contra el servidor de verdad, todas pasando.

## Tercera revisión: las animaciones (2026-11-18)

Después de las animaciones de cartoon viejo, que es lo más nuevo. Se leyó todo el código
de las animaciones buscando lo que pudiera fallar; cada prueba nueva se vio fallar sin
su arreglo.

| Error | Qué pasaba | Arreglo | Commit |
|---|---|---|---|
| **Las casillas tocables quedaron partidas para el lector de pantalla** | Para no perder la animación, el toque pasó a una capa encima de la casilla: el lector leía el número en un elemento que no se podía tocar, y encima un botón vacío | La acción de tocar va en la misma casilla que su número, y la capa de encima no se lee | app `d2f0a08` |
| **Un botón podía quedar hundido y aplastado** | Si se deshabilitaba con el dedo encima (por ejemplo, "Empezar" justo cuando se va un jugador), al soltar no se soltaba, y al volver a habilitarse quedaba hundido hasta el próximo toque | Soltar siempre suelta, y al deshabilitarse se suelta solo | app `d2f0a08` |
| **La explicación se fundía con "Quitar animaciones"** | Era la única animación con su duración fija | Usa `Cartoon.duracion`, como todas | app `d2f0a08` |
| **El tablero decidía si era el mismo mapa contando las zonas** | El Nivel 3 y el Nivel 4 tienen 8 cada uno: si un tablero pasaba a ser de otro mapa con números, salía polvo, aparecían números y se meneaban casillas de zonas que no se llenaron (cada casilla compara su número con el de la casilla del mapa anterior). En el juego no llegaba a pasar: las tarjetas del lobby, las únicas que cambian de mapa, van vacías | El tablero compara la forma del mapa (qué casillas tiene cada zona, su color y su regla); con otro mapa, las casillas se dibujan de nuevo, como la primera vez | app `6677211` |
| **El iris no tapaba toda la pantalla** | El del final (solo y en línea) y el de empezar en línea dejaban afuera la barra de arriba, y abajo terminaban donde terminaba el contenido: en una pantalla alta quedaba un pedazo sin tinta | Envuelven toda la pantalla, y el iris ocupa siempre toda su área | app `6677211` |
| **Durante el iris de "Inicio" se podía tocar la partida a ciegas** | Mientras el círculo se cierra sobre la preparación, la partida ya está encima aunque no se vea: un toque rápido (por ejemplo, un doble toque en "Inicio") tiraba los dados sin verlos. Salió al escribir las pruebas de los recorridos | Mientras se cierra, la pantalla nueva no recibe toques | app `a4a9c4d` |

**Pruebas de cada escenario** (22 nuevas, además de las de cada arreglo): hasta ahora se
probaban las piezas sueltas; ahora también los recorridos por la pantalla, jugando solo y
en línea, mirando qué se mueve en cada momento: la tirada y el ancla elegido en el aire,
la ola de casillas, el polvo una sola vez (también cuando el servidor contesta lo mismo o
cuando otro anota), los dados que saltan solo con cada ronda, el iris al empezar por los
dos caminos y al terminar sobre el trofeo (también en el celular chico, con el trofeo
abajo), "Jugar otra vez" con el iris a la mitad, sin iris si se cerró el lobby, todo con
"Quitar animaciones" (una partida entera sin que nada se mueva), dos jugadas seguidas, y
que nada se desborde a mitad de una animación.

**Revisado y está bien:** el toque al dado en el aire llega al dado, y el dado en el aire
no tapa los toques del tablero; el iris al empezar en línea sale por los dos caminos y no
se repite con cada pregunta; ningún controlador de animación queda sin liberar; las
respuestas iguales del servidor no repiten saltos ni festejos; si una zona se llena de
golpe con todas sus casillas nuevas, cada una hace su aparición en lugar de menearse
(en el juego entra un número por jugada, así que no pasa).

Se comprobó con `tool/probar_todo.sh`: 1093 pruebas del servidor, 860 de la app y las 18
contra el servidor de verdad, todas pasando. Y en el emulador, con el APK nuevo: jugando
solo, el iris de "Inicio" a mitad de camino y un doble toque que entra una vez sin tirar
los dados, la tirada y el polvo al anotar; en línea contra un rival hecho con un script,
el iris al empezar sobre toda la pantalla (directo desde el reparto), una ronda jugada, y
al dejar de contestar el rival, "¡Ganaste!" con el iris abriéndose desde el trofeo.

## Riesgos conocidos, sin arreglar

Son de bajo impacto o de diseño; quedan anotados para decidir después.

- **Segundo plano más de 10 s = fuera de la partida.** Si el celular se bloquea o se
  cambia de app, deja de preguntar y el servidor lo saca. Es lo decidido ("fuera al
  instante"), pero conviene avisarlo en la pantalla cuando se haga el diseño.
- **Las salas viven en memoria.** Si el servidor se reinicia, las partidas terminan (la
  app lo dice y vuelve). Es lo decidido.
- **Los intentos de unirse no tienen límite.** Los códigos ya salen de `secrets` (31⁶
  combinaciones) y para unirse hace falta una sesión. Si el servidor se abre a internet,
  conviene limitar los intentos.
- **Si se cierra la app a mitad de una partida de un jugador, se pierde**: no se guarda.
- **La búsqueda de servidores (mDNS) no se puede probar en el emulador**: su red no deja
  pasar el multicast. Solo se verifica en un celular de verdad.
- **Borrar la cuenta en medio de una sala** (2026-11-17): las salas guardan a cada jugador
  por su nombre de usuario, y durante unos 10 s (hasta que el servidor lo da por
  desconectado) el lugar sigue a su nombre. Si en ese rato alguien crea una cuenta con el
  mismo nombre y entra, ocuparía ese lugar. Para llegar a "Mi cuenta" hay que salir de la
  partida (salir es rendirse), y crear cuentas tiene un límite de 10 por hora: riesgo
  bajo.

## Cómo se comprobó

- `dart analyze` sin avisos; 752 tests de la app y 1043 del servidor pasando (2026-11-11).
- 18 pruebas contra el servidor real (`--dart-define=CON_SERVIDOR=true`): 4 de cuentas y 14
  de partidas con varios jugadores. Ver [[Pruebas]].
- Cada arreglo se deshizo a propósito y su prueba falló; después se restauró.
- En el emulador: iniciar sesión, crear sala, elegir mapa, unirse un rival por código,
  repartir, jugar una ronda tocando, y cortar la red 14 s: "Reconectando…" y luego
  "Ganó el rival / El anfitrión se fue".
