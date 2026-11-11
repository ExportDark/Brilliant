# Servidor de cuentas

Un programa aparte de la app, en `Brilliant-servidor/` (una carpeta hermana, con su propio
repositorio desde el 2026-11-10): guarda las cuentas de los jugadores y les da sesiones, y
desde el 2026-11-10 también lleva las **salas del multijugador** (`/salas/`, ver
[[Multijugador]]). La app se registra ahí, inicia sesión, y puede cerrar la sesión y borrar
la cuenta. Cómo se usa está en `Brilliant-servidor/README.md`; esta nota cuenta las
decisiones de las cuentas.

Ver también: [[Cuentas en la app]] · [[Arquitectura general]] · [[Cómo trabajar en el proyecto]] · [[Pruebas]]

## Qué se pidió

- Un servidor aparte, donde se registren los clientes (la app).
- Autenticación segura, pudiendo usar paquetes que ya la implementen.
- Sin partir de sockets: un paquete, una biblioteca o un framework (nota del usuario).

## Por qué Django + djoser + knox

Las cuentas son con **nombre de usuario y contraseña**, y el servidor corre **en la PC**,
donde hay Python 3.12 pero no Docker ni PostgreSQL.

| Opción | Por qué no, o por qué sí |
|---|---|
| FastAPI + fastapi-users | Fue la primera elección, pero fastapi-users solo funciona con correo: usar nombre de usuario obliga a reescribir partes del paquete |
| Dart + Shelf | El mismo lenguaje que la app, pero no hay un paquete de autenticación completo: habría que armar la seguridad a mano |
| Serverpod | Necesita PostgreSQL y Docker, que no hay |
| **Django + djoser + knox** | Django trae de fábrica cuentas con usuario y contraseña, los validadores y Argon2; djoser da los endpoints; knox, tokens seguros. **Elegido (2026-11-02)** |

El código propio de autenticación es mínimo:

- **`Entrar`:** una vista que adapta el login de knox para recibir usuario y contraseña
  en JSON. La vista de knox espera que el usuario ya venga autenticado; esta los revisa
  primero con el serializer de DRF, como indica la documentación de knox.
- **`Usuarios`:** el `UserViewSet` de djoser, con un límite de intentos al crear la
  cuenta.

## La API

Para las cuentas solo existen las cinco rutas que usa la app. Se declaran una por una en
`cuentas/urls.py`, en vez de incluir todas las de djoser (las de las salas están en el
README del servidor):

| Método y ruta | Qué hace |
|---|---|
| `POST /auth/users/` | Crear la cuenta (`username`, `password`, `re_password`) |
| `POST /auth/token/login/` | Iniciar sesión → `token` y `expiry` |
| `GET /auth/users/me/` | Quién soy |
| `POST /auth/token/logout/` | Cerrar esta sesión |
| `DELETE /auth/users/me/` | Borrar la cuenta (`current_password`) |

Los errores vienen en español y por campo, como `{"password": [...]}`, o en
`non_field_errors` cuando no son de un campo. La app los muestra tal cual.

## Las decisiones de seguridad

- **Argon2id para las contraseñas.** Es el algoritmo que se recomienda hoy, y en la base
  queda algo como `argon2$argon2id$...`. PBKDF2 queda configurado solo para poder leer
  una contraseña vieja.
- **Los validadores de Django:** mínimo 8 caracteres, que no sea común, que no sea solo
  números y que no se parezca al usuario.
- **knox en vez del token de DRF.** DRF guarda el token tal cual en la base, así que si se
  filtrara, cualquiera podría usarlo. knox guarda solo su hash SHA-512 (y un prefijo
  corto para buscarlo), y los tokens vencen (7 días, y se renuevan al usarse).
- **Las reglas del nombre de usuario y de la contraseña**, y **una sola sesión activa por
  cuenta**: ver [[#Las reglas de las cuentas]].
- **Borrar la cuenta pide la contraseña actual**, aunque haya sesión: si alguien agarra
  el celular con la sesión abierta, no puede borrar la cuenta. Al borrarla se borran
  todos sus tokens.
- **El mismo error si la contraseña está mal o si el usuario no existe**, para que no se
  pueda averiguar qué cuentas existen.
- **Nadie ve ni toca la cuenta de otro.** No hay rutas por id, solo las de `me`.
- **Límite de intentos por IP:** 5 inicios de sesión por minuto (contra probar
  contraseñas a lo bruto) y 10 cuentas nuevas por hora.
- **Solo JSON:** sin la página navegable de DRF.
- **CORS solo para la web local** (`localhost` y `127.0.0.1`).
- **`DEBUG` apagado**, `ALLOWED_HOSTS` solo con las direcciones de la PC, y la
  `SECRET_KEY` generada en `Brilliant-servidor/.env`, que no se sube.

## Las reglas de las cuentas

Se agregaron el 2026-11-04, al revisar todas las validaciones de las cuentas.

### El nombre de usuario

- **De 3 a 20 caracteres: letras sin acento, números, `.`, `_` y `-`.** Django acepta de
  1 a 150, con letras de cualquier alfabeto, `@` y `+`. Así, "аna", con una "а"
  cirílica, se hacía pasar por "ana". Ahora lo rechaza con "Solo puede tener letras sin
  acento, números, punto, guion y guion bajo.".
- **"Ana" y "ana" son la misma cuenta.** No se puede crear la otra, y se entra
  escribiéndola de cualquier forma: un backend de autenticación,
  `SinDistinguirMayusculas`, busca la cuenta con `iexact` y deja el resto al de Django.
  El nombre se guarda como se escribió.
- **Un índice único sobre `lower(username)`** (la migración de `cuentas`), por si dos
  registros llegan a la vez y los dos pasan la revisión.
- Las reglas están en `cuentas/serializers.py` (`CrearCuenta`), que reemplaza al
  serializer de djoser con `DJOSER['SERIALIZERS']`. El campo `username` se declara
  aparte para que solo valgan estas reglas, con sus mensajes.

### La contraseña

- **Se recibe tal cual.** DRF recorta los espacios del borde de cualquier texto: djoser
  los recortaba al crear la cuenta y al borrarla, pero knox no al entrar. Quien pusiera
  un espacio al principio o al final **no podía entrar nunca**. Ahora los tres campos
  (`password`, `re_password`, `current_password`) y el de entrar usan
  `trim_whitespace=False`.
- **De 8 a 128 caracteres.** Sin un máximo, alguien podría mandar una contraseña gigante
  para que el servidor se cansara calculando su hash con Argon2.
- Se aceptan ñ, acentos y emojis.

### Una sola sesión activa por cuenta

Si se entra con una cuenta que tiene la sesión **activa** en otro aparato, responde **409**:
"Esta cuenta ya tiene la sesión iniciada en otro aparato. Ciérrala allá, o espera unos
minutos si ya no la usas."

- **Una sesión vence a los 5 minutos sin usarse** (`SESION_SIN_USO`, que es también el
  `TOKEN_TTL` de knox). knox renueva el vencimiento cada vez que se usa el token, así que
  una sesión sin vencer es una usada hace poco. La app, mientras está abierta, avisa cada
  2 minutos. (Antes duraba 7 días y "activa" era una ventana aparte de 5 minutos; se
  simplificó el 2026-11-10.)
- **La entrada nueva borra las sesiones vencidas.** Si no, reinstalar la app, borrar sus
  datos o perder el celular dejaría la cuenta bloqueada.
- **El 409 dice cuántos minutos faltan** para que venza la otra sesión.
- **Reiniciar el servidor cierra todas las sesiones** (`manage.py cerrar_sesiones`, desde
  `iniciar.bat`): viven en la base de datos y sobrevivían al reinicio. No corre cuando
  `servir.py` se relanza solo por un cambio de red.
- **El 403 de knox** (dos entradas al mismo tiempo), que salía en inglés, se traduce al
  mismo 409.
- **Arranque doble:** si el puerto 8443 ya está ocupado, `servir.py` lo dice y termina
  con el código 2 en vez de un traceback de zeroconf; si otra PC se llama igual,
  zeroconf cambia el nombre del anuncio.
- **El aviso solo sale con la contraseña correcta**: con una mala, el error de siempre.
- `TOKEN_LIMIT_PER_USER` pasó de 10 a 1, como respaldo. Con 10, el aparato número 11
  recibía un 403 en inglés (`{"error": ...}`) que la app no mostraba.

## HTTPS con una autoridad local

Las contraseñas y los tokens viajan por la WiFi, así que el servidor solo habla HTTPS.
Como corre en la PC y no tiene un dominio, no hay un certificado público:
`generar_certificados.py` crea uno propio.

1. **Una autoridad certificadora local**, una sola vez, que dura 10 años.
2. **El certificado del servidor**, firmado por ella, para `localhost`, `127.0.0.1`,
   `10.0.2.2` (cómo ve el emulador a la PC) y las IPs de la PC en la red. Se regenera
   cada vez que se levanta el servidor, así que sigue sirviendo si cambia la IP (ver
   [[#Cuando la PC cambia de red]]).
3. **El certificado público de la autoridad se copia a la app**
   (`assets/certificados/brilliant_ca.pem`), y la app **solo confía en él** para hablar con
   el servidor. Es como fijar el certificado: aunque alguien en la red tuviera un
   certificado válido de otra autoridad, la app no lo aceptaría.

Las claves privadas se quedan en `Brilliant-servidor/certificados/` y no se suben al repo.

Se comprobó con el servidor de verdad:

- sin la autoridad, la conexión se rechaza (`SSLCertVerificationError`);
- con ella funciona por `localhost` y por la IP de la red;
- CORS responde a `http://127.0.0.1:8765` y no a un sitio ajeno.

> [!note] `curl` de Windows no sirve para probarlo
> El `curl` que trae Windows usa schannel y no respeta `--cacert`: siempre rechaza el
> certificado. Para probar a mano se usa Python, con
> `ssl.create_default_context(cafile='certificados/ca.pem')`.

## Cuando la PC cambia de red

El servidor corre en la PC, y la IP de la PC depende de la red. Pasó de verdad: en otra
WiFi la PC pasó de `192.168.100.5` a `192.168.137.252`, y el celular dejó de encontrar el
servidor. Tres cosas lo resuelven:

1. **Las IPs de todas las interfaces** (`red_local.py`, con psutil). Antes se sacaban con
   `socket.gethostbyname_ex`, que se salta interfaces: el certificado y `ALLOWED_HOSTS`
   no traían todas las IPs. Ahora entran las de todas las interfaces encendidas, sin las
   de loopback ni las link-local (`169.254.*`). Para decirle al jugador qué escribir, o
   para anunciarse, se quitan además las de máquinas virtuales (VMware, VirtualBox,
   Hyper-V, WSL), porque el celular no llega a esas.
2. **El servidor se anuncia en la red** (`servir.py`, con zeroconf), con mDNS / DNS-SD, lo
   mismo con lo que se descubren las impresoras: un servicio `_brilliant._tcp` llamado
   "Brilliant en <PC>", con sus IPs y el puerto 8443. La app lo busca y se conecta sola
   (ver [[Cuentas en la app#Encontrar el servidor]]).
3. **Se vuelve a levantar solo.** `servir.py` revisa las IPs cada 5 segundos. Si cambian,
   detiene uvicorn y termina con el código 3, e `iniciar.bat` vuelve a generar el
   certificado y a levantarlo con el anuncio de la red nueva.

`servir.py` reemplaza a la línea de uvicorn que había en `iniciar.bat`: levanta uvicorn
desde Python (`uvicorn.Server`), para poder anunciarlo mientras corre y detenerlo si
cambia la red. Al terminar, retira el anuncio.

> [!warning] zeroconf sin partes compiladas
> zeroconf trae DLL compiladas con Cython, sin firmar, y el Control de Aplicaciones de
> Windows de esta PC las bloquea: "DLL load failed while importing _cache: An
> Application Control policy has blocked this file". Se instala en Python puro:
> `requirements.txt` empieza con `--no-binary zeroconf` e `iniciar.bat` pone
> `SKIP_CYTHON=1`. Va un poco más lento, pero solo anuncia un servicio.

Se comprobó desde la PC, con un `ServiceBrowser` de zeroconf: encuentra "Brilliant en
ORION" en `192.168.137.252`, puerto 8443.

## Tests

86 tests con pytest en `Brilliant-servidor/cuentas/tests/`, un archivo por tema:

| Archivo | Qué prueba |
|---|---|
| `test_crear_cuenta.py` | Crea la cuenta y no devuelve la contraseña; usuario repetido; contraseñas débiles (corta, común, numérica, parecida al usuario); contraseñas que no coinciden; mensajes en español; límite de cuentas por IP |
| `test_nombre_de_usuario.py` | De 3 a 20 letras sin acento, números, `.`, `_` y `-`; rechaza, con su mensaje, otros largos, espacios, acentos, ñ, cirílico, `@`, `+`, emojis, `<script>`, `' OR 1=1 --`, tabs y saltos de línea; vacíos, nulos y lo que no es texto; recorta los espacios del borde; "Ana" y "ana" son la misma, y la base tampoco deja las dos |
| `test_contrasena.py` | Con espacios al borde se crea, se entra y se borra la cuenta; con ñ, acentos y emoji; 128 sí y 129 no, ni al crear ni al entrar |
| `test_entrar.py` | Devuelve un token que vence; un token distinto cada vez; sin distinguir mayúsculas; lo que no es texto no entra; el mismo error con contraseña mala o usuario inexistente; límite de intentos |
| `test_una_sesion_por_cuenta.py` | Con una sesión sin vencer en otro aparato, 409 con los minutos que faltan (en singular y plural) y la otra sigue; tampoco con otras mayúsculas; con la contraseña mala no dice nada de la sesión; cerrada allá, deja entrar; vencida (5 minutos sin uso), la entrada nueva la borra y la vieja da 401; usarla le devuelve los 5 minutos; una vencida no se reactiva usándola; otra cuenta no se ve afectada |
| `test_cerrar_sesiones.py` | `cerrar_sesiones` borra las sesiones de todas las cuentas, se puede volver a entrar y sin sesiones lo dice |
| `test_arranque_doble.py` | Un puerto libre y uno ocupado; si el puerto está ocupado, lo dice y no se levanta |
| `test_quien_soy.py` | Sin token, con un token inventado o con uno vencido da 401; con el token, el usuario |
| `test_salir.py` | Cerrar sesión invalida ese token y deja entrar desde otro aparato |
| `test_borrar_cuenta.py` | Sin contraseña, con una mala o sin sesión no borra; con la buena borra la cuenta y todos sus tokens, y ya no se puede entrar |
| `test_privacidad.py` | No se puede listar, pedir ni borrar la cuenta de otro, y borrar la propia no toca las demás |
| `test_almacenamiento.py` | La contraseña está en Argon2id y nunca en texto; el token completo no está en la base |
| `test_red_local.py` | Entran las IPs de todas las interfaces encendidas, sin las apagadas, loopback ni link-local; a la app no se le ofrecen las de máquinas virtuales |
| `test_anuncio.py` | El anuncio es `_brilliant._tcp` con el nombre de la PC, sus IPs y el puerto; si cambian las IPs, pide volver a levantar el servidor, y si no, no toca nada |

Cada test vacía la caché antes y después, porque ahí se cuentan los intentos: si no,
un test heredaría el límite del anterior.

Se comprobó que detectan errores, rompiendo cada cosa a propósito:

- si borrar la cuenta no pidiera la contraseña (otro serializer de djoser), fallan dos
  tests de `test_borrar_cuenta.py`;
- si "Ana" y "ana" pudieran ser dos cuentas, si la contraseña se volviera a recortar, si
  no se revisara la sesión activa, si knox no renovara la sesión al usarla o si se
  entrara distinguiendo mayúsculas, falla cada vez el test de eso.

Ese ejercicio encontró un test que no probaba nada: "usarla la mantiene activa" partía
de una sesión todavía activa, así que pasaba aunque knox no la renovara. Ahora parte de
una sin usar.
