# Cuentas en la app

Cómo la app crea la cuenta, inicia y cierra la sesión, y borra la cuenta, hablando con el
[[Servidor de cuentas]]. Sin sesión no se puede jugar.

Ver también: [[Servidor de cuentas]] · [[Arquitectura general]] · [[Pruebas]]

## El recorrido

1. **Al abrir la app**, si hay una sesión guardada, se revisa con el servidor (`quién
   soy`):
   - si el token sirve, entra directo a **"Elige un mapa"**;
   - si venció, lo olvida y muestra **"Iniciar sesión"** con el aviso "Tu sesión venció";
   - si no hay conexión, deja jugar igual: el juego no necesita el servidor, y la sesión
     se vuelve a revisar la próxima vez.
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
| `cliente_http.dart` + `_io` / `_web` | Crean el cliente HTTP de cada plataforma (import condicional) y eligen la dirección del servidor |
| `almacen_de_sesion.dart` | `AlmacenSeguro` guarda el usuario y el token con `flutter_secure_storage`: cifrados, con una clave del Keystore de Android. La contraseña nunca se guarda |
| `sesion_bloc.dart` (+ `_event`, `_state`) | `SesionBloc`: la sesión del jugador, arriba de toda la app |

Las pantallas están en `lib/ui/pantallas/`:

- `pantalla_entrar.dart`;
- `pantalla_crear_cuenta.dart`;
- `pantalla_mi_cuenta.dart`, con el diálogo de borrar;
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

## La dirección del servidor

Se elige al compilar, con `--dart-define=SERVIDOR=...`. Sin eso:

| Dónde corre la app | Dónde busca el servidor |
|---|---|
| Emulador de Android | `https://10.0.2.2:8443` (así ve el emulador a la PC) |
| Web y Windows | `https://localhost:8443` |
| Celular | Hay que compilarlo con `--dart-define=SERVIDOR=https://<IP de la PC>:8443` |

El APK necesita además el permiso de internet en `AndroidManifest.xml`, que el de
release no traía. Ver [[Versión Android]].

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
