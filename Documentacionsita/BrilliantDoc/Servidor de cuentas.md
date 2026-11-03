# Servidor de cuentas

Un programa aparte de la app, en `servidor/`: guarda las cuentas de los jugadores y les da
sesiones. La app se registra ahí, inicia sesión, y puede cerrar la sesión y borrar la
cuenta. Cómo se usa está en `servidor/README.md`; esta nota cuenta las decisiones.

Ver también: [[Arquitectura general]] · [[Cómo trabajar en el proyecto]] · [[Pruebas]]

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

Solo existen las cinco rutas que usa la app. Se declaran una por una en
`cuentas/urls.py`, en vez de incluir todas las de djoser:

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
  corto para buscarlo), los tokens vencen (7 días, y se renuevan al usarse) y cada
  aparato tiene el suyo: cerrar sesión en uno no cierra los demás.
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
  `SECRET_KEY` generada en `servidor/.env`, que no se sube.

## HTTPS con una autoridad local

Las contraseñas y los tokens viajan por la WiFi, así que el servidor solo habla HTTPS.
Como corre en la PC y no tiene un dominio, no hay un certificado público:
`generar_certificados.py` crea uno propio.

1. **Una autoridad certificadora local**, una sola vez, que dura 10 años.
2. **El certificado del servidor**, firmado por ella, para `localhost`, `127.0.0.1`,
   `10.0.2.2` (cómo ve el emulador a la PC) y las IPs de la PC en la red. Se regenera
   cada vez que se levanta el servidor, así que sigue sirviendo si cambia la IP.
3. **El certificado público de la autoridad se copia a la app**
   (`assets/certificados/brilliant_ca.pem`), y la app **solo confía en él** para hablar con
   el servidor. Es como fijar el certificado: aunque alguien en la red tuviera un
   certificado válido de otra autoridad, la app no lo aceptaría.

Las claves privadas se quedan en `servidor/certificados/` y no se suben al repo.

Se comprobó con el servidor de verdad:

- sin la autoridad, la conexión se rechaza (`SSLCertVerificationError`);
- con ella funciona por `localhost` y por la IP de la red;
- CORS responde a `http://127.0.0.1:8765` y no a un sitio ajeno.

> [!note] `curl` de Windows no sirve para probarlo
> El `curl` que trae Windows usa schannel y no respeta `--cacert`: siempre rechaza el
> certificado. Para probar a mano se usa Python, con
> `ssl.create_default_context(cafile='certificados/ca.pem')`.

## Tests

29 tests con pytest en `servidor/cuentas/tests/`, un archivo por tema:

| Archivo | Qué prueba |
|---|---|
| `test_crear_cuenta.py` | Crea la cuenta y no devuelve la contraseña; usuario repetido; contraseñas débiles (corta, común, numérica, parecida al usuario); contraseñas que no coinciden; mensajes en español; límite de cuentas por IP |
| `test_entrar.py` | Devuelve un token que vence; un token distinto cada vez; el mismo error con contraseña mala o usuario inexistente; límite de intentos |
| `test_quien_soy.py` | Sin token, con un token inventado o con uno vencido da 401; con el token, el usuario |
| `test_salir.py` | Cerrar sesión invalida ese token y no los de otros aparatos |
| `test_borrar_cuenta.py` | Sin contraseña, con una mala o sin sesión no borra; con la buena borra la cuenta y todos sus tokens, y ya no se puede entrar |
| `test_privacidad.py` | No se puede listar, pedir ni borrar la cuenta de otro, y borrar la propia no toca las demás |
| `test_almacenamiento.py` | La contraseña está en Argon2id y nunca en texto; el token completo no está en la base |

Cada test vacía la caché antes y después, porque ahí se cuentan los intentos: si no,
un test heredaría el límite del anterior.

Se comprobó que detectan errores: si borrar la cuenta no pidiera la contraseña (otro
serializer de djoser), fallan dos tests de `test_borrar_cuenta.py`.
