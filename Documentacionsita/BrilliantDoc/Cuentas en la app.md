# Cuentas en la app

Cómo la app crea la cuenta, inicia y cierra la sesión, y borra la cuenta, hablando con el
[[Servidor de cuentas]]. Sin sesión no se puede jugar.

Ver también: [[Servidor de cuentas]] · [[Arquitectura general]] · [[Pruebas]]

## El recorrido

1. **Al abrir la app**, si hay una sesión guardada, se revisa con el servidor (`quién
   soy`):
   - si el token sirve, entra directo a **"Elige un mapa"**;
   - si venció, lo olvida y muestra **"Iniciar sesión"** con el aviso "Tu sesión venció";
   - si el servidor no contesta, lo busca en la red (ver [[#Encontrar el servidor]]); si
     tampoco así, deja jugar igual: el juego no necesita el servidor, y la sesión se
     vuelve a revisar la próxima vez.
2. **"Iniciar sesión"** pide usuario y contraseña. Desde ahí, **"Crear cuenta"** pide el
   usuario y la contraseña dos veces. Al crearla, la sesión se inicia sola.
3. En **"Elige un mapa"**, el ícono de persona abre **"Mi cuenta"**, con el usuario y dos
   acciones:
   - **Cerrar sesión**;
   - **Borrar cuenta**, en rojo. Abre un diálogo que avisa que no se puede deshacer y
     pide la contraseña.
4. Al cerrar sesión o borrar la cuenta, la app vuelve sola a "Iniciar sesión", con el
   aviso "Cerraste sesión." o "Tu cuenta se borró.".

La sesión se recuerda: al cerrar la app y volverla a abrir no hay que escribir la
contraseña otra vez.

## El código: la capa `lib/cuenta/`

| Archivo | Qué hace |
|---|---|
| `cliente_cuentas.dart` | `ClienteCuentas`: un método por cada ruta de la API (`crearCuenta`, `entrar`, `quienSoy`, `salir`, `borrarCuenta`). Convierte las respuestas en errores con tipo: `ErrorDeCuenta` (los mensajes del servidor, por campo y generales), `SesionVencida` (401) y `SinConexion` |
| `cliente_http.dart` + `_io` / `_web` | Crean el cliente HTTP de cada plataforma (import condicional) |
| `direccion_del_servidor.dart` | La dirección por defecto, leer la que escribe el jugador (`192.168.137.252`, `ip:puerto` o una URL `https`) y mostrarla corta |
| `buscador_de_servidores.dart` + `_io` / `_web` | `BuscadorDeServidores`: busca en la red los servidores que se anuncian. En Android, `BuscadorNsd`, con el paquete nsd; en la web, `SinBuscar` |
| `almacen_de_sesion.dart` | `AlmacenSeguro` guarda el usuario, el token y la dirección del servidor elegida con `flutter_secure_storage`: cifrados, con una clave del Keystore de Android. La contraseña nunca se guarda |
| `reglas_de_cuenta.dart` | Las reglas del nombre de usuario y de la contraseña, las mismas del servidor y con los mismos mensajes: `problemaConElUsuario` y `problemaConLaContrasena` |
| `servidor_cubit.dart` (+ `_state`) | `ServidorCubit`: dónde está el servidor y si contesta (`revisando`, `disponible`, `noDisponible`), arriba de toda la app |
| `sesion_bloc.dart` (+ `_event`, `_state`) | `SesionBloc`: la sesión del jugador, arriba de toda la app |

Las pantallas están en `lib/ui/pantallas/`:

- `pantalla_entrar.dart`;
- `pantalla_crear_cuenta.dart`;
- `pantalla_mi_cuenta.dart`, con el diálogo de borrar;
- `dialogo_del_servidor.dart`, que se abre tocando el indicador del servidor en "Iniciar
  sesión";
- `puerta_de_sesion.dart`, la raíz: muestra "Iniciar sesión" o "Elige un mapa" según la
  sesión.

Tres piezas son compartidas:

- `CampoDeContrasena`: el campo con el ojo para mostrar la contraseña;
- `LogoBrilliant`: cinco fichas con los colores de las zonas;
- `RecuadroDeAviso`: el recuadro arena de los avisos, que antes era solo la explicación
  de la partida.

## Decisiones

- **La app solo confía en la autoridad local.** En Android y Windows, el cliente HTTP usa
  un `SecurityContext(withTrustedRoots: false)` con el certificado de la autoridad del
  servidor (`assets/certificados/brilliant_ca.pem`). Es como fijar el certificado: un
  certificado de otra autoridad, aunque sea válido, no sirve. En la web decide el
  navegador. Ver [[Servidor de cuentas]].
- **El token no sale del bloc.** Las pantallas solo ven el usuario; el token lo guarda
  el almacén cifrado y lo usa el bloc.
- **Los pedidos se atienden de a uno, en orden.** El bloc tiene un solo manejador con un
  transformador secuencial (`asyncExpand`). Por defecto, bloc atiende los eventos al
  mismo tiempo: un segundo toque a "Entrar", o cerrar sesión mientras se revisa la sesión
  guardada, se cruzaban con el pedido anterior. Lo encontraron los tests del bloc.
- **Los errores del servidor se muestran tal cual**, en español, debajo de su campo
  ("Ya existe un usuario con este nombre.") o en el recuadro de avisos ("No puede iniciar
  sesión con las credenciales proporcionadas."). También los de knox, que vienen en
  `error`: antes se perdían. Ver [[#Las reglas de las cuentas]].
- **Al escribir de nuevo, el error anterior se va**, y también al pasar de una pantalla de
  cuenta a otra (`AvisosDescartados`).
- **Cerrar sesión sin conexión la cierra igual** en el aparato: el token se olvida, y en
  el servidor vence solo.
- **Al entrar o salir, se vuelve a la raíz.** Un `BlocListener` arriba del `MaterialApp`
  cierra todo lo que haya encima (crear cuenta, mi cuenta, el diálogo de borrar) cuando
  cambia la etapa de la sesión.

## Las reglas de las cuentas

Las mismas del servidor (ver [[Servidor de cuentas#Las reglas de las cuentas]]). La app
las revisa en "Crear cuenta" antes de mandar nada, con los mismos mensajes:

| Qué | Regla en la app |
|---|---|
| Nombre de usuario | De 3 a 20 caracteres: letras sin acento, números, punto, guion y guion bajo. El campo no deja escribir más de 20 y lo explica debajo. Se recortan los espacios del borde |
| Contraseña | De 8 a 128 caracteres. **Nunca se recorta**: los espacios del borde son parte de ella |
| Las dos contraseñas | Tienen que coincidir |

Lo que solo sabe el servidor lo dice él, en su campo o en el recuadro de avisos:

- que el nombre ya existe, también con otras mayúsculas: "ANA" choca con "ana";
- que la contraseña es común o se parece al usuario;
- que la cuenta tiene la sesión activa en otro aparato.

"Iniciar sesión" no revisa reglas: manda lo escrito, con el usuario recortado, y se entra
escribiéndolo con cualquier mayúscula.

Los largos se cuentan en caracteres (runas), como Python, y no en unidades de UTF-16:
un emoji cuenta como uno.

### Cerrar sesión llega al servidor

El servidor cierra las conexiones inactivas a los 5 segundos. El cliente HTTP
(`cliente_http_io.dart`) cierra las suyas a los 2, y `ClienteCuentas._pedir` reintenta una
vez, por una conexión nueva, los pedidos que no cambian nada (todos menos crear y borrar la
cuenta) cuando el primero falla por conexión. Antes, el primer pedido después de una pausa
fallaba sin llegar y el cierre de sesión se perdía. Ver [[Historial de cambios]].

### Si el cierre de sesión no llega: "sesión por cerrar"

Al cerrar sesión, `SesionBloc` le avisa al servidor (pasando por `_conElServidor`, así
lo encuentra si cambió de IP). En este aparato la sesión se cierra siempre, pero:

- si el servidor se enteró (204, o 401 porque ya no valía), dice "Cerraste sesión.";
- si no, guarda el token como **sesión por cerrar** (`AlmacenDeSesion.leerPorCerrar` /
  `guardarPorCerrar`) y lo dice con la verdad: "Cerraste sesión en este aparato. El
  servidor no contestó: se le avisará al volver a conectar, y si no, la sesión vence sola
  en 5 minutos."

`_cerrarPendiente()` lo reintenta **al abrir la app, antes de entrar o de crear la cuenta**
(así, en el mismo celular, nunca te bloquea el 409 de tu propia sesión) **y en cada latido
sin sesión**. Si el servidor ya no sabe de esa sesión (se reinició o venció), se da por
cerrada. Antes, `_alSalir` se tragaba el error y decía "Cerraste sesión." aunque la sesión
siguiera abierta en el servidor.

### Una sola sesión activa: el latido

Una cuenta tiene una sola sesión **activa**: usada en los últimos 5 minutos. Para que la
del aparato que se está usando cuente como activa:

- **cada 2 minutos, con la app en primer plano**, `BrilliantApp` manda `SesionLatido`, y
  el `SesionBloc` pregunta "quién soy" con el token;
- **al volver a la app**, también;
- **en segundo plano no**: un celular guardado en el bolsillo deja de contar como activo
  y se puede entrar en otro.

Si el latido recibe 401 (la sesión venció a los 5 minutos sin uso, el servidor se
reinició o se entró con la cuenta en otro aparato), la app vuelve a "Iniciar sesión" con el
aviso "Tu sesión se cerró: pasó mucho tiempo sin usarla, el servidor se reinició o se entró
con tu cuenta en otro aparato. Vuelve a iniciar sesión.". Sin conexión no cierra nada: el
juego sigue.

Entrar con la cuenta activa en otro aparato muestra el mensaje del servidor en el recuadro
de avisos: "Esta cuenta ya tiene la sesión iniciada en otro aparato. Ciérrala allá, o
espera unos minutos si ya no la usas."

## Encontrar el servidor

El servidor corre en la PC, y la IP de la PC cambia con la red: en otra WiFi, el APK
compilado con la IP vieja ya no lo encontraba. Por eso la dirección es dinámica.

### La dirección de partida

Se elige al compilar, con `--dart-define=SERVIDOR=...`. Sin eso:

| Dónde corre la app | Dónde busca el servidor primero |
|---|---|
| Emulador de Android | `https://10.0.2.2:8443` (así ve el emulador a la PC) |
| Web y Windows | `https://localhost:8443` |

Si el jugador elige otra, se guarda en el aparato y se usa desde que se abre la app.

### Si está disponible, a la vista

En "Iniciar sesión", debajo de los botones, el **indicador del servidor** dice si se puede
entrar, antes de intentarlo:

| Se ve | Cuándo |
|---|---|
| Una ruedita y "Buscando el servidor…" | Mientras revisa o busca |
| Un punto verde y **"Servidor disponible"**, con la dirección (y el nombre, como "Brilliant en ORION", si lo encontró buscando) | El servidor contesta |
| Un punto rojo y **"Sin servidor"**: "No contesta en 10.0.2.2. Toca para buscar otro." | No contesta, y en la red no se encontró otro |

Tocándolo se abre el diálogo "Servidor".

Lo lleva el `ServidorCubit`, que **vuelve a revisar solo**:

- al abrir la app;
- al volver a la app desde segundo plano (por ejemplo, después de cambiar de WiFi en los
  ajustes), con un `AppLifecycleListener`;
- cuando cambia la red del aparato (otra WiFi, o se queda sin red), con el paquete
  connectivity_plus;
- cada 10 segundos mientras no hay servidor, para notar cuando se enciende;
- cuando un pedido de la sesión no llega.

Revisar es preguntar "quién soy" sin token, esperando 4 segundos como mucho: el servidor
contesta 401, y eso es que está. Si no contesta, se busca en la red.

### Si no contesta, se busca en la red

El servidor se anuncia en la WiFi con mDNS / DNS-SD, como un servicio `_brilliant._tcp`
(ver [[Servidor de cuentas]]). Cuando el servidor no contesta, al revisarlo o en un pedido
de la sesión (al abrir con la sesión guardada, al entrar, al crear la cuenta o al
borrarla), el `ServidorCubit`:

1. busca en la red los servidores que se anuncian, unos 3 segundos;
2. le pregunta a cada dirección si contesta, con el mismo cliente que solo confía en la
   autoridad de Brilliant. Si un servidor se anuncia con varias IPs, queda la primera que
   contesta;
3. según cuántos contestan:
   - **uno**: se cambia a él y lo guarda; si era un pedido, el `SesionBloc` lo repite. El
     jugador no nota nada;
   - **varios**: no elige, porque cada uno tiene sus propias cuentas. Pide elegir uno en
     "Servidor";
   - **ninguno**: "Sin servidor", y en un pedido, el error de siempre con la dirección
     que se intentó.

Mientras el servidor contesta, no se busca nada. Así, **si la PC y el celular se pasan a
otra WiFi**, el servidor se vuelve a levantar y a anunciar en la nueva, y la app, al
notar el cambio de red, lo encuentra ahí.

### El diálogo "Servidor"

El indicador abre un diálogo con:

- **"En tu red"**: los servidores que encuentra al abrirse, cada uno con "Disponible" y su
  dirección, como "Brilliant en ORION". Solo aparecen los que contestan. Basta con tocar
  uno; el que se usa ahora lleva una palomita. Si no hay ninguno, lo dice y deja
  **buscar de nuevo**;
- **la dirección a mano**, por si no aparece: la IP que muestra `Brilliant-servidor\iniciar.bat`;
- **Restablecer**, que vuelve a la dirección de partida.

Al elegir o guardar, el `ServidorCubit` lo guarda y revisa que conteste, y el indicador lo
muestra. El diálogo solo se abre desde "Iniciar sesión": la sesión es de un servidor en
particular.

### Decisiones

- **mDNS con paquetes**, como pide "Desiciones NETWORK.txt": zeroconf en el servidor y
  nsd en la app, que usa el `NsdManager` de Android. Nada de sockets a mano.
- **Que se anuncie no lo hace confiable.** Antes de usar un servidor encontrado se le
  pregunta por HTTPS con la autoridad de Brilliant: uno ajeno que se anunciara igual no
  pasa.
- **En la web no se busca**: el navegador no deja hacer mDNS. Ahí solo se escribe la
  dirección.
- **El permiso `CHANGE_WIFI_MULTICAST_STATE`** en `AndroidManifest.xml`, para que Android
  deje recibir el multicast de mDNS. Además del de internet, que el APK de release no
  traía. Ver [[Versión Android]].
- **Un cubit aparte para el servidor**, no un pedazo del `SesionBloc`: dónde está el
  servidor y si contesta no es lo mismo que quién inició sesión, y así cualquier pantalla
  puede mostrarlo. Es un cubit y no un bloc con eventos porque la sesión necesita la
  respuesta de `buscarOtro` para saber si puede repetir el pedido.
- **Revisar, buscar y elegir van de a uno** en el cubit, y dos revisiones pedidas antes de
  empezar son una sola: al cambiar de WiFi llegan varios avisos de red seguidos.
- **Si mientras tanto ya se cambió a otro**, la sesión no vuelve a buscar: al abrir con la
  sesión guardada, la revisión del cubit y la de la sesión no buscan dos veces.
- **Todo se inyecta en `BrilliantApp`**: el cliente, el almacén, el buscador, los avisos
  de cambio de red y cada cuánto revisar. Los tests usan `BuscadorFalso`, que
  "encuentra" lo que cada test anuncia, y un `StreamController` como red.

## Cómo se probó

- **Tests**, con un servidor falso en memoria (`ServidorFalso`, en
  `test/cuenta/ayudantes_cuenta.dart`). Contesta como el de verdad: las mismas rutas,
  los mismos códigos y los mismos mensajes. Ver [[Pruebas]].
- **Contra el servidor de verdad**, con
  `flutter test --dart-define=CON_SERVIDOR=true test/cuenta/contra_el_servidor_test.dart`:
  - crear la cuenta, entrar, quién soy, salir y borrarla, por HTTPS;
  - un cliente que confía en las autoridades del sistema, y no en la de Brilliant, no se
    conecta.
- **En el emulador de 360 px**, con el servidor levantado:
  - crear la cuenta lleva a elegir el mapa;
  - al cerrar y reabrir la app, sigue la sesión;
  - en "Mi cuenta", una contraseña mala muestra "Contraseña inválida." y con la buena
    la cuenta se borra.
- **En Edge sin ventana** (ignorando el certificado): crear la cuenta, mi cuenta y
  borrarla en la versión web.
- **Al cambiar la PC de red** (a 192.168.137.252), en el emulador: escribir la
  dirección nueva en "Servidor" conecta.
- **Las reglas, con el servidor de verdad** (2026-11-04):
  - las 3 pruebas de `contra_el_servidor_test.dart` pasan;
  - en el emulador, "ana@x" muestra "Solo puede tener letras sin acento…" sin mandar
    nada;
  - con la cuenta abierta desde un script de Python que hace de otro celular, entrar en
    el emulador escribiendo el nombre en mayúsculas muestra "Esta cuenta ya tiene la
    sesión iniciada en otro aparato…".
- **El indicador, con el servidor de verdad**, en el emulador (2026-11-04):
  - al abrir, "Servidor disponible · 10.0.2.2";
  - al apagarle la WiFi y los datos al emulador (`adb shell svc wifi disable`), la app
    lo nota sola y pasa a "Sin servidor";
  - al prenderlos, vuelve sola a "Servidor disponible", sin tocar nada;
  - crear una cuenta lleva a "Elige un mapa", y borrarla vuelve a "Iniciar sesión" con el
    indicador en verde.
- **La búsqueda en la red**, en el emulador: el registro de Android muestra que la app
  toma el permiso de multicast y busca `_brilliant._tcp.local` durante 3 segundos, y el
  diálogo pasa de "Buscando servidores…" a "No se encontró ningún servidor". El emulador
  no puede encontrar el de la PC, porque su red (NAT) no deja pasar el multicast. Eso se
  prueba en un celular de verdad.
- **El anuncio**, desde la PC: un `ServiceBrowser` de zeroconf encuentra "Brilliant en
  ORION" en 192.168.137.252, puerto 8443.

## Varios servidores en la red

Si en la red contestan varios servidores, `ServidorCubit` no elige: pasa a `Disponibilidad.variosEncontrados` y guarda la lista en `ServidorState.encontrados`, para que el jugador elija (cada servidor tiene sus cuentas). `buscarEnLaRed()` vuelve a buscar sin revisar antes el servidor de ahora.
