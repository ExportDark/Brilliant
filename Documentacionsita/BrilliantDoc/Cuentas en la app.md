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
| `sesion_bloc.dart` (+ `_event`, `_state`) | `SesionBloc`: la sesión del jugador, arriba de toda la app |

Las pantallas están en `lib/ui/pantallas/`:

- `pantalla_entrar.dart`;
- `pantalla_crear_cuenta.dart`;
- `pantalla_mi_cuenta.dart`, con el diálogo de borrar;
- `dialogo_del_servidor.dart`, que se abre con "Servidor: …" en "Iniciar sesión";
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
  sesión con las credenciales proporcionadas."). La app solo revisa lo básico antes de
  mandar: que no falte nada, el largo de la contraseña y que las dos coincidan.
- **Al escribir de nuevo, el error anterior se va**, y también al pasar de una pantalla de
  cuenta a otra (`AvisosDescartados`).
- **Cerrar sesión sin conexión la cierra igual** en el aparato: el token se olvida, y en
  el servidor vence solo.
- **Al entrar o salir, se vuelve a la raíz.** Un `BlocListener` arriba del `MaterialApp`
  cierra todo lo que haya encima (crear cuenta, mi cuenta, el diálogo de borrar) cuando
  cambia la etapa de la sesión.

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

### Si no contesta, se busca en la red

El servidor se anuncia en la WiFi con mDNS / DNS-SD, como un servicio `_brilliant._tcp`
(ver [[Servidor de cuentas]]). Cuando un pedido da `SinConexion` (al abrir con la sesión
guardada, al entrar, al crear la cuenta o al borrarla), el bloc:

1. busca en la red los servidores que se anuncian, unos 3 segundos;
2. le pregunta a cada dirección si contesta, con el mismo cliente que solo confía en la
   autoridad de Brilliant. Si un servidor se anuncia con varias IPs, queda la primera que
   contesta;
3. según cuántos contestan:
   - **uno**: se cambia a él, lo guarda y repite el pedido. El jugador no nota nada;
   - **varios**: no elige, porque cada uno tiene sus propias cuentas. Pide elegir uno en
     "Servidor";
   - **ninguno**: el error de siempre, con la dirección que se intentó.

Mientras el servidor contesta, no se busca nada.

### El diálogo "Servidor"

En "Iniciar sesión", el botón **"Servidor: 192.168.137.252"** abre un diálogo con:

- **"En tu red"**: los servidores que encuentra al abrirse, como "Brilliant en ORION".
  Basta con tocar uno; el que se usa ahora lleva una palomita. Si no hay ninguno, lo dice
  y deja **buscar de nuevo**;
- **la dirección a mano**, por si no aparece: la IP que muestra `servidor\iniciar.bat`;
- **Restablecer**, que vuelve a la dirección de partida.

Al elegir o guardar, el bloc prueba que el servidor conteste y avisa "Conectado con el
servidor en …". Solo se cambia sin sesión: la sesión es de un servidor en particular.

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
- **El buscador se inyecta** en `BrilliantApp` y en el bloc, como el cliente y el almacén:
  los tests usan `BuscadorFalso`, que "encuentra" lo que cada test anuncia.

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
  dirección nueva en "Servidor" muestra "Conectado con el servidor en 192.168.137.252.".
- **La búsqueda en la red**, en el emulador: el registro de Android muestra que la app
  toma el permiso de multicast y busca `_brilliant._tcp.local` durante 3 segundos, y el
  diálogo pasa de "Buscando servidores…" a "No se encontró ningún servidor". El emulador
  no puede encontrar el de la PC, porque su red (NAT) no deja pasar el multicast. Eso se
  prueba en un celular de verdad.
- **El anuncio**, desde la PC: un `ServiceBrowser` de zeroconf encuentra "Brilliant en
  ORION" en 192.168.137.252, puerto 8443.
