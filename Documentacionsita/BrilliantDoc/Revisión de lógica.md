# Revisión de lógica

Una revisión de los errores de lógica del proyecto (app y servidor), hecha a pedido el
2026-11-10 y 2026-11-11, después del reporte "no me deja iniciar sesión porque ya aparece
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
| **Cerrar el lobby decía que ganaban los demás** | Si el anfitrión cerraba la sala antes de empezar, los demás veían un resultado con "Nadie ganó" y "El anfitrión se fue: ganan los demás", de una partida que no se jugó; el anfitrión también | Motivo aparte, `sala_cerrada`: los demás ven "El anfitrión cerró la sala." y el anfitrión sale directo (204) | servidor `e6b86a6`, app (bloque 1) |
| **Salir del lobby pedía otro toque** | Tras "Salir" aparecía "Ya no estás en la sala" y había que tocar "Volver" | Salir por cuenta propia vuelve directo a "Elige un mapa" | app (bloque 1) |
| **El tiempo dependía de la hora del teléfono** | Si el teléfono ajustaba su reloj, la cuenta regresiva saltaba y podía aparecer "se perdió la conexión" | Un cronómetro (`relojMonotono`) | app (bloque 1) |
| **Crear o unirse con un doble toque** | Estando ya en una sala, el segundo pedido llegaba al servidor y mostraba "Ya estás en otra sala." | Se ignora | app (bloque 1) |
| **"Entrar" podía quedarse esperando** | Un 401, o un "sí" sin token al iniciar sesión, rompían el bloc | Se avisa "El servidor no aceptó el pedido" / "contestó algo inesperado" | app (bloque 1) |
| **Solo se recordaba un cierre de sesión pendiente** | Un segundo cierre sin servidor pisaba al primero, que quedaba abierto hasta vencer | Una lista (`porcerrar.lista`), sin perder la que se guardó con la versión anterior | app (bloque 1) |
| **Desbordes en el celular chico** | El código de la sala y la fila de puntos del resultado no cabían en 320 px | El código se achica; los "primeros" van debajo de los puntos | `9fe363a` |

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

## Cómo se comprobó

- `dart analyze` sin avisos; 710 tests de la app y 1029 del servidor pasando.
- 18 pruebas contra el servidor real (`--dart-define=CON_SERVIDOR=true`): 4 de cuentas y 14
  de partidas con varios jugadores. Ver [[Pruebas]].
- Cada arreglo se deshizo a propósito y su prueba falló; después se restauró.
- En el emulador: iniciar sesión, crear sala, elegir mapa, unirse un rival por código,
  repartir, jugar una ronda tocando, y cortar la red 14 s: "Reconectando…" y luego
  "Ganó el rival / El anfitrión se fue".
