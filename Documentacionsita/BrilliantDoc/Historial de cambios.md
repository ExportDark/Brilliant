# Historial de cambios

Todo lo que se fue construyendo, por fecha, del más reciente al más viejo. Cada entrada
dice qué cambió, por qué y en qué commit. El detalle de cada pieza está en su nota.

Ver también: [[Estado del proyecto]] · [[Pruebas]]

---

## 2026-11-11 — Más agujeros de lógica, explicación sutil, marcador y búsqueda por la red

- **Lógica** (app `5c55685`, servidor `e6b86a6`): si el anfitrión cerraba el lobby, los
  demás veían "Nadie ganó / ganan los demás" de una partida que no se jugó (ahora "El
  anfitrión cerró la sala"); salir del lobby vuelve directo; el tiempo ya no depende de la
  hora del teléfono; crear o unirse con doble toque no manda nada; "Entrar" ya no se
  queda esperando con una respuesta rara; se recuerdan varios cierres de sesión pendientes;
  los códigos de sala salen de `secrets`. Y pruebas de todos los relojes en sus bordes,
  en el servidor y en la app. Ver [[Revisión de lógica]].
- **Por qué no se puede anotar, sutil y en los dos modos** (`41e0056`, `642a2bb`): en la
  línea de arriba del tablero, con un punto del color de la zona, sin recuadro, y un aro
  suave en la casilla tocada; se va sola a los 4 s. En la partida en línea también se
  apagan un poco las casillas que la regla bloquea. Ver [[Interfaz del tablero]].
- **Marcador y panel de zonas** (`4dfde0e`, servidor `57a1bd3`): tarjetas blancas; el
  marcador ordenado, con el puesto, los puntos grandes y un punto por zona llena; cada
  zona con sus tres premios. Ver [[Multijugador#El marcador y el panel de zonas]].
- **Encontrar el servidor sin escribir la IP aunque mDNS no llegue** (`dcd19e4`, servidor
  `b4ea067`): la app prueba el puerto 8443 en las direcciones de su red, a la vez que
  busca el anuncio, y le pregunta su nombre con `GET /servidor/`. Verificado en el
  emulador: el registro del servidor muestra la consulta del nombre. Ver
  [[Cuentas en la app#Si no contesta, se busca en la red]].

## 2026-11-11 — Revisión de lógica

- Se revisaron la app y el servidor buscando errores de lógica; los que salieron se
  arreglaron con su prueba, y cada prueba se comprobó fallando sin el arreglo. Todo, con
  los riesgos que quedan, en [[Revisión de lógica]].
- **La cuenta regresiva se congelaba** (`3d31d90`): el servidor contesta 304 cuando nada
  cambió, sin los segundos nuevos. La app ahora descuenta el tiempo ella misma.
- **Un reparto rechazado bloqueaba la preparación** (`fa6776d`): ya se puede corregir y
  volver a mandar sin empezar de cero.
- **Servidor** (`09928ab`): una jugada después de un silencio cuenta como contacto, igual
  que preguntar; antes quien volvía jugando se sacaba a sí mismo.

## 2026-11-10 — Multijugador, y el login más fácil de usar

- **Las reglas en los dos repos** (app `28c0d86`, servidor `ba67a92`): el servidor tiene las
  reglas del juego en Python. La app genera `mapas.json` y `casos_de_jugadas.json` y un
  test de cada lado exige que coincidan; cambiar una regla en Python hizo fallar 185.
- **Las salas en el servidor** (`30317f8`, `ea9679d`): lobby con código, preparación,
  rondas con dados compartidos, puestos por zona, desconexiones y fin, con 236 tests y una
  partida de 6 jugadores simulada de principio a fin. Ver [[Multijugador]].
- **El multijugador en la app** (`29b0959`, `69ad4ca`): `ClienteSalas`, `SalaBloc` y las
  pantallas del lobby, la preparación, la partida con el panel de zonas y el resultado.
  Sin diseño todavía: primero, que sea jugable. La tabla de puntos, en [[Puntuación]].
- **La carpeta de la app, solo con lo de la app** (`f45599d`): se quitó `windows/`, y las
  notas sueltas pasaron a `notas-sueltas/` (fuera de git).
- **Pantallas chicas** (`9fe363a`): el código de la sala y el resultado se desbordaban en
  320 px.
- **Pruebas contra el servidor real con varios clientes** (`8fa9569`, `cef7fec`): partidas
  completas en los 4 mapas, 6 jugadores, dos partidas a la vez, rendirse y varias clases de
  desconexión (14 casos). Y en el emulador, la app real contra el servidor con un rival
  hecho con un script.
- **El mapa del lobby, como en el inicio** (`8ef3fd4`): tarjetas con el tablero en
  miniatura en vez de "Nivel 1, 2, 3, 4".
- **El login** ([[Cuentas en la app]]):
  - con **varios servidores en la red**, la lista aparece en "Iniciar sesión" y "Crear
    cuenta" para tocar uno (`a778143`, `dd962a3`);
  - **"Entrar" y "Crear cuenta" esperan al servidor**: deshabilitados sin él, y se
    habilitan solos cuando aparece (`dd962a3`);
  - **recuerda el último usuario** y deja el cursor en la contraseña, que nunca se
    guarda (`7204535`);
  - **mensajes más claros**: "Demasiados intentos… espera N segundos", y "el servidor
    tardó demasiado" distinto de "no se pudo conectar" (`293cb0b`, `c3b2fb7`). De paso,
    un servidor que limita los intentos ya no se toma por "sin servidor".

## 2026-11-10 — El servidor pasa a su propio repositorio

- **El servidor vive ahora en `Brilliant-servidor`**, una carpeta hermana de esta, con su
  propio repositorio, README, `.venv` y 86 tests. Se separó con `git subtree split`, así
  que conserva su historial (4 commits). La app y el servidor solo se hablan por HTTPS y
  no comparten código.
- **El certificado ya no viaja solo:** `generar_certificados.py` dejó de copiar la
  autoridad a la app. `certificados/ca.pem` se copia a mano a
  `assets/certificados/brilliant_ca.pem`, una sola vez (dura 10 años). Se comprobó que la
  que ya tiene la app es idéntica a la del servidor nuevo: no hace falta recompilar.
- Tus datos (`db.sqlite3`, `.env`, `certificados/`) se copiaron y se verificaron por hash
  antes de borrar la carpeta vieja. El `.venv` se creó de nuevo, porque no se puede mover.
- Se comprobó: los 86 tests del servidor pasan en el repo nuevo, `iniciar.bat` levanta
  desde ahí y las 3 pruebas de la app contra el servidor de verdad pasan.
- **Para el multijugador:** compartir las reglas del juego entre la app y el servidor
  pasa a ser entre dos repos; hay que replantearlo.

## 2026-11-10 — El cierre de sesión se perdía en silencio

- **Síntoma:** se cerraba sesión en la app ("Cerraste sesión.") y el servidor seguía con
  la sesión abierta, así que entrar de nuevo daba 409; reiniciar el servidor no ayudaba
  (las sesiones están en la base).
- **Causa, reproducida en el emulador con el servidor de verdad:** el servidor (uvicorn)
  cierra las conexiones inactivas a los 5 segundos, y el cliente HTTP intentaba reusar
  una ya cerrada: el primer pedido tras una pausa fallaba **sin llegar al servidor**
  (en el registro no aparecía ningún `POST /auth/token/logout/`). `SesionBloc._alSalir`
  se traga todos los errores, así que la app decía que había cerrado sesión. Afectaba a
  cualquier primer pedido después de una pausa, no solo a cerrar sesión.
- **Arreglo:** el cliente cierra sus conexiones inactivas a los 2 segundos (antes que el
  servidor) y reintenta una vez los pedidos que no cambian nada si el primero falla por
  conexión. Crear la cuenta y borrarla no se reintentan solos, y un tiempo agotado
  tampoco (el pedido pudo llegar).
- **Tests:** 5 del cliente (reintento una vez, con el mismo token; se rinde al segundo
  fallo; sin reintento para crear y borrar ni en un tiempo agotado), uno del bloc (salir
  después de entrar con "Entrar" manda el cierre; antes ningún test lo comprobaba) y la
  prueba contra el servidor de verdad ahora espera 8 s antes de salir.
- **Servidor, el mismo día:**
  - la sesión **vence a los 5 minutos sin uso** (antes 7 días), así que un cierre que no
    llegó no bloquea la cuenta más de 5 minutos; el 409 dice cuántos minutos faltan;
  - **reiniciar cierra todas las sesiones** (`manage.py cerrar_sesiones`, desde
    `iniciar.bat`);
  - el 403 de knox, en inglés, se traduce; si ya hay un servidor en el puerto 8443, lo dice
    claro en vez de un traceback, y `iniciar.bat` ya no sale en silencio con código 0;
  - 86 tests con pytest (10 nuevos); se rompió a propósito el TTL y `cerrar_sesiones`
    y sus tests fallaron.
- **App, el mismo día:** si el cierre de sesión de verdad no llega (sin red), la app ya no
  dice "Cerraste sesión." a secas: lo dice con la verdad, guarda la **sesión por cerrar** y
  la reintenta al abrir, antes de entrar o crear cuenta, y en cada latido. En tu mismo
  celular el caso de "ya aparece que está logueado" se resuelve solo.
- **Verificado en el emulador con el servidor de verdad:**
  - tras 12 s de conexión inactiva, cerrar sesión llega (`POST logout → 204`; antes no
    aparecía en el registro);
  - con la red cortada, el aviso dice que el servidor no contestó y la sesión sigue
    abierta en el servidor; al volver la red y entrar de nuevo, la app manda primero el
    logout pendiente (204) y luego entra (200), sin 409;
  - al arrancar, el servidor cerró las sesiones abiertas.
- **Tests:** 524 de la app (más 3 contra el servidor) y 86 del servidor. Se rompió a
  propósito el cierre antes de entrar y la anotación de la sesión por cerrar, y sus
  tests fallaron. Los tests contra el servidor de verdad chocan con el límite de 5
  inicios de sesión por minuto si se repiten seguidos: hay que esperar o reiniciar el
  servidor.

## 2026-11-04 — Las reglas de las cuentas, en la app

- **"Crear cuenta" revisa las reglas antes de mandar nada**, con los mismos mensajes que
  el servidor: usuario de 3 a 20 letras sin acento, números, `.`, `_` y `-` (el campo no
  deja escribir más de 20 y lo explica debajo); contraseña de 8 a 128, nunca recortada.
  Están en `lib/cuenta/reglas_de_cuenta.dart`. Ver [[Cuentas en la app#Las reglas de las cuentas]].
- **El latido:** con la app en primer plano, cada 2 minutos y al volver a ella, se le
  avisa al servidor que la sesión sigue en uso, para que cuente como activa. Si el
  servidor la cerró, la app vuelve a "Iniciar sesión" con un aviso.
- **Entrar con la cuenta activa en otro aparato** muestra el mensaje del servidor. Los
  mensajes de knox, que vienen en `error`, ya no se pierden.
- `ServidorFalso` imita las reglas nuevas, con un reloj que los tests adelantan.
- **Tests:** las reglas (26 casos), el cliente, el bloc, 10 widget tests nuevos y 1
  contra el servidor de verdad. Se rompió a propósito cada pieza para ver que su test
  falla.
- **En el emulador, con el servidor de verdad:** "ana@x" avisa sin mandar nada, y con la
  cuenta abierta desde un script que hace de otro celular, entrar escribiendo el nombre en
  mayúsculas dice que la cuenta tiene la sesión iniciada en otro aparato.
- 512 tests de la app (más 3 contra el servidor).

## 2026-11-04 — Las reglas de las cuentas, en el servidor

- **Por qué:** al revisar todas las validaciones de las cuentas aparecieron huecos y dos
  errores. Ver [[Servidor de cuentas#Las reglas de las cuentas]].
- **Error: una contraseña con espacios al borde no dejaba entrar nunca.** djoser los
  recortaba al crear la cuenta y knox no al entrar. Ahora se recibe tal cual.
- **Error: el aparato número 11 con la misma cuenta fallaba en silencio**, con un 403 en
  inglés que la app no mostraba.
- **Nombre de usuario:**
  - de 3 a 20 caracteres, solo letras sin acento, números, `.`, `_` y `-`; antes
    aceptaba de 1 a 150, con letras de cualquier alfabeto;
  - "Ana" y "ana" son la misma cuenta, también al entrar, con un índice único en la
    base.
- **Contraseña:** como mucho 128 caracteres.
- **Una sola sesión activa por cuenta.** Si se usó en otro aparato en los últimos 5
  minutos, entrar responde 409; si no, la entrada nueva cierra la vieja.
- 76 tests con pytest (42 nuevos). Se rompió a propósito cada regla para ver que su test
  falla, y eso encontró un test que no probaba nada.

## 2026-11-04 — El servidor disponible, a la vista

- **"Iniciar sesión" muestra si se puede entrar**, antes de intentarlo: un punto verde y
  "Servidor disponible" (con su dirección, y su nombre si lo encontró buscando), uno rojo
  y "Sin servidor", o una ruedita mientras busca. Tocándolo se abre "Servidor", donde cada
  servidor de la red dice "Disponible". Ver [[Cuentas en la app#Si está disponible, a la vista]].
- **Vuelve a revisar solo:** al abrir, al volver a la app, cuando cambia la red del
  aparato (paquete connectivity_plus) y cada 10 segundos mientras no hay servidor. Si no
  contesta, lo busca en la red. Así, si la PC y el celular se pasan a otra WiFi, la app
  lo encuentra en la nueva.
- **`ServidorCubit`**, aparte del `SesionBloc`: sabe dónde está el servidor y si
  contesta. La sesión le pide buscarlo cuando un pedido no llega, y le avisa cuando
  contesta. Revisar espera 4 segundos como mucho.
- **Tests:** los del cubit (18), los del bloc con el cubit, y widget tests del
  indicador, del cambio de red, de volver a la app y de cuando el servidor se enciende.
  Se comprobó que cada uno falla si se quita lo que prueba. Ver [[Pruebas]].
- **En el emulador, con el servidor de verdad:** "Servidor disponible"; al cortarle la red
  pasa solo a "Sin servidor", y al devolvérsela vuelve solo a "Servidor disponible".
  Crear una cuenta y borrarla funcionan.
- 468 tests de la app (más 2 contra el servidor).

## 2026-11-03 — La app encuentra el servidor

- **La dirección del servidor es dinámica.** En "Iniciar sesión", **"Servidor: …"** abre
  un diálogo con los servidores que encuentra en la WiFi, para tocar uno, o para escribir
  la IP a mano. Lo elegido se recuerda, y "Restablecer" vuelve a la de partida.
- **Si el servidor no contesta, lo busca solo**: al abrir con la sesión guardada, al
  entrar, al crear la cuenta y al borrarla. Les pregunta a los que se anuncian, con el
  cliente que solo confía en la autoridad de Brilliant:
  - si contesta uno, se cambia a él y repite el pedido;
  - si contestan varios, pide elegir;
  - si no contesta ninguno, da el error de siempre.

  Ver [[Cuentas en la app#Encontrar el servidor]].
- **Piezas nuevas:**
  - `direccion_del_servidor.dart`;
  - `BuscadorDeServidores`, con el paquete nsd en Android y sin buscar en la web;
  - `DialogoDelServidor`;
  - el permiso `CHANGE_WIFI_MULTICAST_STATE`.
- **Tests:**
  - `BuscadorFalso`;
  - `ServidorFalso` solo contesta en su dirección, como la PC;
  - casos nuevos del cliente, del bloc y de las pantallas, y el diálogo en los 5 tamaños.

  Encontraron que "Buscar de nuevo" no hacía nada (un `setState` que devolvía un
  `Future`). Ver [[Pruebas]].
- **En el emulador:**
  - escribir la IP nueva conecta;
  - la búsqueda corre, pero no encuentra el servidor de la PC, porque el NAT del
    emulador no deja pasar el multicast. Falta probarlo en un celular.
- 451 tests de la app (más 2 contra el servidor).

## 2026-11-03 — El servidor se anuncia en la red

- **Por qué:** la PC se conectó a otra WiFi y su IP pasó de `192.168.100.5` a
  `192.168.137.252`. El APK, compilado con la vieja, dejó de encontrar el servidor.
- **Las IPs de todas las interfaces** (`red_local.py`, con psutil). Antes se sacaban con
  `socket.gethostbyname_ex`, que se salta interfaces, así que al certificado y a
  `ALLOWED_HOSTS` les faltaban IPs.
- **Se anuncia en la WiFi** con mDNS / DNS-SD (`servir.py`, con zeroconf): un servicio
  `_brilliant._tcp` llamado "Brilliant en <PC>", con sus IPs y el puerto 8443.
- **Se vuelve a levantar solo si la PC cambia de red.** `servir.py` revisa las IPs cada
  5 segundos; si cambian, termina con el código 3, e `iniciar.bat` regenera el
  certificado y lo levanta con el anuncio nuevo.
- **zeroconf va en Python puro**, porque el Control de Aplicaciones de Windows bloquea sus
  DLL compiladas (`--no-binary zeroconf` y `SKIP_CYTHON=1`).
- `generar_certificados.py` muestra la IP de la PC, por si hay que escribirla en la app.
- 34 tests con pytest (5 nuevos). Se comprobó desde la PC que el anuncio se encuentra.
  Ver [[Servidor de cuentas#Cuando la PC cambia de red]].

## 2026-11-02 — Cuentas en la app

- **Sin sesión no se juega.** La app abre en **"Iniciar sesión"**, con un enlace a
  **"Crear cuenta"**, y la sesión se recuerda entre una vez y otra. En "Elige un mapa",
  el ícono de persona abre **"Mi cuenta"**: cerrar sesión y **borrar la cuenta**, con
  un diálogo que pide la contraseña. Ver [[Cuentas en la app]].
- **Una capa nueva, `lib/cuenta/`:**
  - `ClienteCuentas` habla con el servidor;
  - el token se guarda cifrado con `flutter_secure_storage`;
  - `SesionBloc` atiende los pedidos de a uno.

  En Android y Windows la app solo confía en la autoridad local del servidor.
- **El APK pide el permiso de internet**, que el de release no traía. Para el celular se
  compila con `--dart-define=SERVIDOR=https://<IP de la PC>:8443`. Ver [[Versión Android]].
- El recuadro de la explicación de la partida pasó a ser `RecuadroDeAviso`, compartido
  con las pantallas de cuenta.
- **Tests:**
  - unit del cliente y del bloc;
  - widget tests de cada pantalla;
  - el camino feliz de las cuentas;
  - tamaños;
  - una prueba contra el servidor de verdad que se pide con
    `--dart-define=CON_SERVIDOR=true`.

  Los tests del juego entran con una sesión guardada. Ver [[Pruebas]].
- Se probó con el servidor de verdad, en el emulador y en Edge: crear la cuenta, reabrir
  la app con la sesión guardada, una contraseña mala al borrar, y borrar.
- 419 tests de la app (más 2 contra el servidor) y 29 del servidor.

## 2026-11-02 — Servidor de cuentas

- **Un programa aparte, en `servidor/`**, donde se registran los jugadores: Django con
  djoser (crear, ver y borrar la cuenta) y django-rest-knox (los tokens de sesión). Se
  descartó FastAPI + fastapi-users porque solo funciona con correo, y las cuentas son
  con nombre de usuario. Ver [[Servidor de cuentas]].
- **Seguridad:**
  - contraseñas con Argon2id y los validadores de Django;
  - tokens que se guardan con hash, vencen y se revocan;
  - borrar la cuenta pide la contraseña;
  - nadie toca la cuenta de otro;
  - límite de intentos;
  - solo HTTPS, con una autoridad local cuyo certificado público lleva la app.
- Se levanta con `servidor\iniciar.bat`. Se probó de verdad por HTTPS, por `localhost` y
  por la IP de la red.
- 29 tests con pytest. Se comprobó que fallan si borrar la cuenta no pide la contraseña.
- Todavía falta la parte de la app: las pantallas de crear la cuenta, iniciar sesión y
  borrarla.

## 2026-10-26 — Las casillas iniciales reales de cada mapa

- **Las iniciales son las de la estrellita** de cada tarjeta, como dicen las reglas del
  juego. El usuario las marcó en la foto y se detectaron por píxel. Las del Nivel 1 ya
  estaban bien; las de los niveles 2 a 4 se habían elegido a criterio propio y eran
  otras. Ver [[Mapas]].

  | Mapa | Antes | Ahora |
  |---|---|---|
  | Nivel 2 | C1, F2, B4, E4, C6, E7 | E1, A3, C4, F5, B6, E7 |
  | Nivel 3 | C1, F2, B4, E4, C6, E7 | C2, F2, D4, B5, G5, C7 |
  | Nivel 4 | C2, F2, B4, D4, B6, G6 | E1, C3, F3, A4, E6, B7 |

- **En el Nivel 4, dos iniciales caen en las zonas naranjas**: E1 en la "4-6" y B7 en
  la "1-3". La preparación ahora respeta esos rangos: apaga las fichas que no caben, el
  bloc ignora un número que no cabe, y Aleatorio solo reparte números que caben. Lo
  decide `Tablero.aceptaComoInicial`, y el bloc lo recibe como una función `admite`,
  sin conocer el tablero. Ver [[Preparación de la partida]].
- Tests de cada mapa: las iniciales contra la tarjeta, qué casillas se pueden tocar en
  la preparación, y los rangos del Nivel 4 en el tablero, el bloc y la pantalla. Se
  comprobó que fallan si la pantalla no le pasa el rango al bloc o si Aleatorio no lo
  revisa. Todos los mapas siguen llenando las 49 casillas. Ver [[Pruebas]].
- 369 tests.

## 2026-10-24 — Elegir el mapa en la app

- **La app abre en "Elige un mapa"** (`PantallaEleccionDeMapa`): los 4 niveles en
  tarjetas de dos columnas, cada una con su tablero en miniatura, su nombre y cuántas
  zonas tiene. Al tocar una se pasa a la preparación de ese mapa. Ver
  [[Interfaz del tablero]].
- La preparación y la partida reciben el `Mapa`, y su barra superior dice el nivel.
  **"Jugar otra vez" repite el mismo mapa**, y la flecha de atrás vuelve a elegir.
- **Salir a mitad de partida pide confirmación** ("¿Salir de la partida?"), porque
  ahora la partida tiene flecha de atrás, y en Android un toque sin querer la perdería.
  Con la partida terminada sale sin preguntar.
- Con la regla naranja, una zona vacía ya puede rechazar un número. En ese caso la
  explicación no dice "Ya tiene:": queda "Zona naranja — Solo del 4 al 6.".
- El camino feliz por la pantalla corre en los 4 mapas, y hay tests de la elección, de
  la flecha de atrás, de la confirmación y de la explicación naranja. Ver [[Pruebas]].
- Se revisó en Edge (PC y celular) y en el emulador Android de 360 px, y se recompiló el
  APK.
- 357 tests.

## 2026-10-24 — Los 4 mapas oficiales, en el modelo

- **Los 4 mapas** de las tarjetas ("Level 1" a "Level 4") en `lib/modelo/mapa.dart`, y
  `Tablero.desdeMapa(mapa)` para armar cualquiera. Se transcribieron de una foto, midiendo
  el color de cada casilla; el Level 1 coincidió casilla por casilla con el mapa que ya
  había, que es el `nivel1`. Ver [[Mapas]].
- **Dos colores nuevos:** el gris ("=", todos iguales, como el azul) y el naranja ("1-3"
  o "4-6", solo números de ese rango). Reglas nuevas: `ReglaGris`, `ReglaNaranja` y la
  función pura `puedeAgregarEnRango`. Ver [[Reglas de color en código]].
- **Casillas iniciales por mapa.** Las tarjetas no las marcan: los niveles 2 y 3 usan
  las del Nivel 1, y el Nivel 4 usa C2, F2, B4, D4, B6, G6, para que cada una caiga en
  una zona distinta y ninguna en una naranja. La constante global `casillasIniciales`
  pasó a ser de cada mapa.
- **Las partidas simuladas y el camino feliz corren en los 4 mapas.** Todos llenan las 49
  casillas. Tests nuevos de cada mapa: colores contra una tabla escrita a mano, zonas y
  tamaños, iniciales, y que el Nivel 1 sea el mapa de siempre. Se comprobó que fallan
  si una zona se transcribe con otro color o si la regla naranja acepta cualquier
  número. Ver [[Pruebas]].
- 326 tests.

## 2026-10-24 — El modelo, listo para más de un mapa

Primer paso para jugar los 4 mapas oficiales. Es un refactor: el juego no cambia.

- **`Color5` pasa a llamarse `ColorZona`**, porque los otros mapas suman colores (gris y
  naranja).
- **`TipoRegion` ya no fija el tamaño de la zona** (`cantidadCeldas`), porque una misma
  zona azul tiene 4 casillas en un mapa y 5 o 6 en otro. El tamaño lo pone cada mapa.
  Ver [[Modelado de regiones]].
- **Las descripciones de las reglas no dicen cuántas casillas tiene la zona**: "Todos
  iguales: todas las casillas llevan el mismo número". Un test nuevo lo cuida.
- 254 tests.

## 2026-10-19 — Camino feliz por la pantalla

- **El happy path como widget test**: abre la app entera, reparte los 6 números tocando
  casillas y fichas, toca Inicio, juega la partida completa tocando Tirar dados, el dado
  ancla y una casilla encendida (o Pasar turno), llega a "¡Tablero completo!" y toca
  "Jugar otra vez". Dura 56 turnos. Se comprobó que falla si la pantalla enciende una
  casilla que el bloc no acepta. Ver [[Pruebas]].
- `BrilliantApp` y `PantallaPreparacion` reciben un `tirarDado` opcional que pasan a la
  partida, para que el test juegue con dados fijos desde el arranque. En la app siguen
  saliendo al azar. Ver [[Turnos y jugadas]].
- 253 tests.

## 2026-10-18 — Interfaz suave

- **Rediseño de la interfaz**, para que sea lo más amigable posible: un estilo suave, sin
  tanto detalle pero pulido. Se eligieron fichas redondeadas, dados con puntos y colores
  suaves. La lógica del juego no cambió. Ver [[Interfaz del tablero]].
  - **Tema propio** (`lib/ui/tema.dart`): fondo crema, acento lavanda, botones
    redondeados y una paleta suave para las 5 zonas. El número elige su color según el
    fondo para que siempre se lea.
  - **Sin coordenadas a la vista**: se quitaron las letras A–G y los números 1–7 del
    tablero, las chips "C1 = 4" de la preparación y el "C2 ·" de los mensajes. En el
    código siguen existiendo.
  - **Sin cuadrícula negra**, que se había pedido el 2026-10-04: las casillas son fichas
    redondeadas, separadas, sobre una base. Las iniciales llevan un aro tenue de su color.
  - **Casillas encendidas**: las que se pueden usar llevan aro blanco y brillo lavanda,
    porque con los colores suaves una casilla solo aclarada parecía apagada. Los cambios
    de iluminación son una transición suave.
  - **Dados con puntos** (`DadoWidget`), y el dado ancla con aro y la palabra "ancla".
  - **Preparación:** "Prepara tu tablero", cuántos faltan, los números como fichas
    redondas en una sola fila, y Aleatorio / Quitar / Reiniciar como acciones discretas.
    Ver [[Preparación de la partida]].
  - **Partida:** barra de progreso con "12 de 49 casillas", mensajes sin coordenadas en un
    recuadro suave, "Tirar dados" escondido mientras hay dados en la mesa, y una tarjeta
    de fin de partida con **Jugar otra vez**, que vuelve a la preparación. Ver
    [[Turnos y jugadas]].
  - El contenido de las pantallas va arriba en vez de centrado, para que el tablero no
    salte cuando aparecen los dados o la explicación.
- Se revisó en Edge (PC y celular) y en el emulador Android de 360 px, y se recompiló el
  APK.
- 4 tests renombrados porque probaban cosas que ya no se ven, varios actualizados a los
  textos nuevos, y 8 nuevos: los puntos del dado, la barra de progreso y el fin de partida
  con "Jugar otra vez". Ver [[Pruebas]].
- 252 tests.

## 2026-10-18 — Camino feliz

- **Unit test del happy path** (`4ed780c`): una partida entera, de la preparación al final, sin
  pantalla. Encadena `PreparacionBloc` → tablero → `PartidaBloc`, con dados sin azar que
  recorren las 36 combinaciones, y termina con las 49 casillas llenas y cada zona
  cumpliendo las reglas del manual, revisadas a mano en el test. Dura siempre 73 turnos.
  Se comprobó que falla si la preparación entrega mal los números o si una regla deja
  pasar repetidos. Ver [[Pruebas]].
- El jugador automático y la verificación de zonas pasaron de `partida_completa_test` a
  los ayudantes compartidos.
- 243 tests.

## 2026-10-17 — Versión Android

- **El tablero se adapta al ancho de la pantalla** (`96b8a4c`). Medía siempre 360 px y,
  con los márgenes, necesitaba 392: en un celular de 360 se desbordaba 32 px. Ahora las
  casillas miden el ancho disponible entre 7,5, con 48 px como máximo (43 en un celular de
  360). Las pantallas van dentro de `SafeArea`. Se sumaron 21 widget tests de tamaños, y
  se comprobó que fallan con el tablero fijo. Ver [[Interfaz del tablero]] y [[Pruebas]].
- **Plataforma Android**: nombre "Brilliant", paquete `com.exportdark.brilliant`, solo
  vertical. El APK (`app-arm64-v8a-release.apk`, 15,1 MB) se instala en el teléfono como
  cualquier app. Se probó en un emulador de 360 px: preparación, partida, un turno
  completo, y que no gire. Ver [[Versión Android]].
- **Comandos corregidos:** para web se usa `-d edge`, porque en esta PC no hay Chrome, y
  `-d windows` necesita Visual Studio, que no está instalado. Ver
  [[Cómo trabajar en el proyecto]].
- 242 tests.

## 2026-10-13 — Tests de todo lo que faltaba

- **41 tests nuevos** para cubrir lo que había quedado sin probar desde el inicio del
  proyecto hasta la regla del dado ancla, cada uno en su propio archivo. Ver [[Pruebas]]:
  - **Modelo:** `Region.conCasilla` / `sinCasilla`, `Celda.sinValor`, y cuántas vecinas
    tiene cada casilla dentro del tablero.
  - **Reglas:** la `descripcion` de cada color.
  - **Preparación:** Aleatorio con una sola casilla vacía, Aleatorio reproducible con la
    misma semilla, y que no se pueda reasignar tras confirmar.
  - **Partida:** el dado de verdad saca del 1 al 6, el estado sin dado ancla, índice
    negativo, tirar tras pasar, dado ancla sin jugada, ningún número en el tablero, y cómo
    crece la iluminación al anotar.
  - **Casillas iluminadas:** los conjuntos exactos para los 6 números iniciales, con
    varias casillas con el número, en la esquina, con una vecina ocupada, y el amarillo
    que bloquea desde lejos.
  - **Interfaz:** borde grueso solo en iniciales, número negro en la seleccionada,
    etiquetas A–G / 1–7, la selección que salta, las chips, solo iniciales tocables,
    Aleatorio + Inicio, las indicaciones, Pasar turno en lugar de Tirar, la explicación
    que se borra, casilla ocupada, la iluminación que se apaga al anotar, solo el número
    exacto resaltado, y que la pantalla coincida con la validación.
  - **App:** arranca en la pantalla de preparación.
- Ayudantes nuevos: `posiblesEn` / `bloqueadasEn` / `casillasDonde` en
  `test/juego/ayudantes.dart`, y `test/ui/pantallas/ayudantes_pantallas.dart` para los
  tests de pantallas.
- Ningún test destapó un bug: no se tocó código de `lib/`.
- 221 tests.

## 2026-10-09 — El ancla es solo un dado

- **Cambio de concepto, no de mecánica.** "Ancla" pasa a referirse **solo a uno de los dos
  dados**. En el tablero no hay anclas: hay casillas con números. Con 2 y 4 y el 4 como
  dado ancla, se buscan en el tablero las casillas que tienen un 4, y el 2 va pegado a
  alguna de ellas, igual que antes. Ver [[Turnos y jugadas]].
- **Pantalla:** se quitó la ⚓ de las casillas del tablero. En su lugar, las casillas que
  tienen el número del dado ancla **iluminan su número**: va en negro sobre un círculo
  blanco. La ⚓ queda solo debajo del dado ancla. Ver [[Interfaz del tablero]].
- **Código:** `SinAncla` pasó a ser `SinVecinoConNumero`; `PartidaState.esAncla`, a
  `tieneNumeroBuscado`; y el `esAncla` de `CeldaWidget` / `TableroWidget`, a
  `numeroResaltado` / `numeroResaltadoEn`. El mensaje dice ahora "...de una casilla con 4".
- **Tests:** los que hablaban de un ancla en el tablero se renombraron:
  `numero_recien_anotado_test`, `jugar_junto_al_numero_nuevo_test` y
  `lejos_del_numero_gana_test`. Se agregaron 3: el ancla se ve solo en los dados, y el
  número resaltado va en negro sobre un círculo (y sin resaltar, en blanco y sin
  círculo). Ver [[Pruebas]].
- 180 tests.

## 2026-10-08 — Más pruebas de la regla del ancla

- **Pruebas nuevas de la lógica del juego** (`02e2904`): un número recién anotado sirve
  de ancla en el turno siguiente, los dos dados iguales, qué explicación gana cuando
  fallan dos cosas, el fin de la partida justo después de la última jugada y una
  posición fuera del tablero. Además, **10 partidas completas simuladas** con dados al
  azar (semillas fijas): todas terminan y ninguna zona rompe su regla. Ver [[Pruebas]].
- **Hallazgo:** las 10 partidas simuladas terminaron con el **tablero lleno (49 de 49)**.
  Con las reglas actuales ninguna zona se queda sin salida, así que cualquier partida
  acaba llenando el tablero; lo único que cambia es cuántos turnos tarda (entre 58 y 104
  en las simuladas). Esto importa para el puntaje. Ver [[Puntuación]].
- **Un archivo por prueba** (`81ad4f1`): los 7 casos puntuales de la regla del ancla
  pasan a vivir cada uno en su archivo, en `test/juego/partida/` y
  `test/juego/validacion/`, con sus ayudantes compartidos en `test/juego/ayudantes.dart`.
  Ver [[Pruebas]] y [[Cómo trabajar en el proyecto]].
- **El vault, al día con todo lo anterior**: notas nuevas [[Historial de cambios]],
  [[Pruebas]] e [[Interfaz del tablero]]; [[Puntuación]], [[Reglas del juego]] y
  [[Turnos y jugadas]] con el hallazgo del tablero lleno; [[Cómo trabajar en el proyecto]]
  con cómo probar la app en Edge, cómo leer el PDF y qué archivos no se suben. Desde
  ahora, todo cambio suma su entrada aquí.
- 177 tests.

## 2026-10-04 — La partida se puede jugar

- **Botón Aleatorio** en la preparación (`27336ab`): completa al azar las casillas
  iniciales vacías con los números que faltan, respetando lo ya puesto. Con las 6 llenas,
  revuelve todo. Ver [[Preparación de la partida]].
- **`PartidaBloc` y validación de jugadas** (`cce467c`): tirar 2 dados, elegir uno, pasar
  turno y fin de partida. `evaluarJugada` dice si una jugada vale y, si no, por qué. Cada
  regla de color suma su `descripcion` para explicársela al jugador. Ver
  [[Turnos y jugadas]] y [[Reglas de color en código]].
- **Pantalla de partida** (`44548a7`): deja de ser provisional. Muestra los dados, ilumina
  dónde se puede jugar y explica la regla al tocar una casilla donde no se puede.
- **Corrección visual: cuadrícula siempre negra** (`4c80c18`): se dejó de pintar el borde
  de las casillas. Lo que se ilumina ahora es el relleno: mucho donde se puede jugar,
  poco donde la regla lo impide. Ver [[Interfaz del tablero]].
- **Corrección de la mecánica: la regla del ancla** (`8878f92`): el dado elegido es el
  **ancla** y el **otro** se anota pegado (arriba, abajo, izquierda o derecha, sin
  diagonales) a una casilla que tenga el número del ancla. Las casillas ancla llevan un ⚓.
  **Difiere del PDF**, que permitía cualquier casilla libre: es una decisión del
  proyecto. Ver [[Turnos y jugadas]] y [[Reglas del juego]].
- 160 tests.

## 2026-09-30 — Layout verificado contra el PDF

- **El mapa del código coincide con el PDF** (`710a09d`). El PDF resultó ser dibujo
  vectorial, así que se leyó el color exacto de cada casilla de sus 5 tableros y se
  comparó con `Tablero.mapaOriginal()`: coinciden las 49 casillas y las 6 iniciales. La
  pantalla también se revisó por píxeles. Ver [[Decisiones de extracción del manual]].

## 2026-09-27 — Primeras pantallas

- **`TableroWidget`** (`598e568`): la grilla 7×7 con el color de cada región, los números
  anotados y la notación A–G / 1–7. `Tablero.conValores` aplica un reparto entero de una
  vez.
- **Pantalla de preparación** (`e3390a8`): la app arranca ahí. El jugador reparte los
  números del 1 al 6 tocando las casillas iniciales, y **Inicio** solo se habilita con
  las 6 llenas. Se agrega `flutter_bloc`. Ver [[Preparación de la partida]].

## 2026-09-21 — Tablero, vault y la preparación

- **`Tablero`** (`918664f`): las 9 regiones del mapa, declaradas con la notación del
  manual, con autovalidación del layout al construirse. Ver [[Tablero y regiones]].
- **Este vault** (`53d3bc9`): 12 notas enlazadas con las reglas, la arquitectura, el
  modelo y las decisiones de diseño. Se le quitaron después las referencias al proyecto
  previo y al plano cartesiano (`0af9913`). Ver [[Sistema de coordenadas]].
- **Primer `PartidaBloc`** (`7608191`): un bloc de toda la partida, con un gate que no
  dejaba jugar sin los 6 valores iniciales. El mismo día se reemplazó por
  **`PreparacionBloc`** (`9b37ce8`), un bloc local que solo se ocupa del reparto inicial y
  no conoce el tablero. El `PartidaBloc` actual es otro, del 2026-10-04.

## 2026-09-09 — Posiciones y regiones

- **`Posicion`** como value object propio (`befd8da`), que usa `Celda`.
- **`TipoRegion`, `Region` y `extraerValores`** (`9d2b697`). Ver [[Modelado de regiones]].

## 2026-09-03 — Arranque

- **Scaffold del proyecto**, la entidad **`Celda`** y su widget (`0fe18ee`).
- **Las 5 reglas de color**, una por commit: rojo (`e4cc27a`), amarillo (`a97670e`),
  verde (`55a14d3`), azul (`12b0b29`) y morado (`c36f24c`). Ver
  [[Reglas de color en código]].
