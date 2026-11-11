# Versión Android

Cómo se compila Brilliant para Android y cómo se instala en un teléfono. Se agregó el
2026-10-17 para poder jugar desde el celular, como una app instalada (APK).

Ver también: [[Cómo trabajar en el proyecto]] · [[Interfaz del tablero]] · [[Estado del proyecto]]

## Qué tiene la app

| Qué | Valor |
|---|---|
| Nombre visible | **Brilliant** |
| Paquete (applicationId) | `com.exportdark.brilliant` |
| Orientación | Solo vertical (`android:screenOrientation="portrait"`) |
| Versión | La de `pubspec.yaml` (hoy `1.0.0+1`) |
| Ícono | El de Flutter, por ahora |
| Firma | La clave de depuración de la PC (`~/.android/debug.keystore`) |

Todo eso vive en `android/`, que creó `flutter create --platforms=android --org
com.exportdark .`. Lo único que se tocó a mano es `android/app/src/main/AndroidManifest.xml`:
el nombre y la orientación.

## Compilar el APK

```bash
C:\src\flutter\bin\flutter.bat build apk --release --split-per-abi
```

Deja tres archivos en `build/app/outputs/flutter-apk/`:

| Archivo | Tamaño | Para qué |
|---|---|---|
| `app-arm64-v8a-release.apk` | 16,8 MB | **El del teléfono**: cualquier Android de los últimos años |
| `app-armeabi-v7a-release.apk` | 14,3 MB | Teléfonos muy viejos, de 32 bits |
| `app-x86_64-release.apk` | 18,2 MB | Emuladores en la PC |

La primera compilación tardó unos 7 minutos, porque Gradle descargó e instaló solo lo que
faltaba del SDK (NDK 28, Build-Tools 36 y CMake). Las siguientes tardan segundos.

Si falla con `Gradle task assembleRelease failed with exit code 1` y ningún error más, se
vuelve a correr: es OneDrive bloqueando archivos de la compilación. Ver
[[Cómo trabajar en el proyecto]].

### Qué hace falta en la PC

- **Android SDK**, en `C:\Users\expor\AppData\Local\Android\sdk`, con sus licencias
  aceptadas.
- **Android Studio**: solo se usa su Java (`jbr`), que Flutter encuentra solo.
- `flutter doctor` avisa que faltan las *cmdline-tools*, pero no hacen falta para compilar.
  Sí harían falta para `flutter doctor --android-licenses` o para crear emuladores con
  `avdmanager`. Se instalan desde Android Studio: *SDK Manager → SDK Tools → Android SDK
  Command-line Tools*.

### El servidor de cuentas

Sin sesión no se puede jugar, y la sesión se pide al [[Servidor de cuentas]], que corre en
la PC. El APK de siempre lo busca primero en `10.0.2.2`, que es como el **emulador** ve a
la PC. **En el celular lo encuentra solo**: si ahí no contesta, lo busca en la WiFi (el
servidor se anuncia con mDNS) y se cambia a él. Si no aparece, en "Iniciar sesión" >
Servidor se elige de la lista o se escribe la IP que muestra `Brilliant-servidor\iniciar.bat`. Ver
[[Cuentas en la app#Encontrar el servidor]].

Se le puede dar una dirección de partida al compilar, para que no tenga que buscar la
primera vez:

```bash
C:\src\flutter\bin\flutter.bat build apk --release --split-per-abi --dart-define=SERVIDOR=https://192.168.137.252:8443
```

El celular tiene que estar en la misma WiFi que la PC, con el servidor levantado
(`Brilliant-servidor\iniciar.bat`), y Windows tiene que dejar entrar conexiones al puerto 8443.
Ya no hace falta recompilar si cambia la IP de la PC.

El manifiesto principal pide dos permisos:

- `android.permission.INTERNET`, para hablar con el servidor. El de release no lo traía:
  solo el de depuración;
- `android.permission.CHANGE_WIFI_MULTICAST_STATE`, para buscar el servidor en la WiFi
  (mDNS usa multicast).

El paquete connectivity_plus, con el que la app nota los cambios de red, agrega solo el
permiso `ACCESS_NETWORK_STATE` desde su propio manifiesto.

> [!note] El emulador no encuentra el servidor de la PC
> Su red pasa por un NAT que no deja pasar el multicast. En el emulador la búsqueda corre
> pero no encuentra nada; se usa `10.0.2.2`. Buscar se prueba en un celular de verdad.

## Instalarlo en el teléfono

1. Pasar `app-arm64-v8a-release.apk` al teléfono, por cable USB, Google Drive o un
   mensaje a uno mismo.
2. Abrirlo en el teléfono. Android pide permiso para "instalar apps desconocidas" desde la
   app con que se abrió (Archivos, Drive…): se permite una vez.
3. Si Play Protect avisa que no conoce la app, se elige **Instalar de todos modos**.

**Para actualizar**, se compila de nuevo y se instala encima, sin desinstalar. Funciona
mientras el APK se compile siempre en esta misma PC, porque va firmado con su clave de
depuración. Si algún día se compila en otra PC, hay que desinstalar la app primero.

> [!warning] La firma de depuración es solo para uso personal
> Para publicar en Play Store haría falta una clave propia (un `keystore` y
> `key.properties`, que nunca se suben al repo). No es parte de esta versión.

## Que quepa en el celular

El tablero medía siempre 360 px y, con los márgenes, necesitaba 392 px: en un celular de
360 px se desbordaba. Ahora se adapta al ancho (ver [[Interfaz del tablero]]), y las dos
pantallas van dentro de `SafeArea` para no quedar debajo de la barra de navegación. Los
widget tests de tamaños lo comprueban en 5 tamaños, del celular chico (320 px) al
escritorio. Ver [[Pruebas]].

## Cómo se verificó

Se creó un emulador **Brilliant_360dp** (1080×2400 a densidad 480, o sea 360 px lógicos de
ancho, el caso más justo) con la imagen de Android 36 que ya estaba descargada. Como no
hay *cmdline-tools*, se definió a mano en `~/.android/avd/`; se puede borrar desde el
Device Manager de Android Studio. En él se instaló el APK de x86_64 y se jugó con `adb`:

- la app abre en vertical y el tablero se ve entero a lo ancho;
- Aleatorio reparte los 6 números, y con scroll se llega a Inicio;
- en la partida se tiran los dados, el dado ancla ilumina el número buscado y sus
  vecinas, y anotar pasa al turno 2;
- aunque se fuerce la pantalla a horizontal, la app se queda en vertical.

Con el rediseño del 2026-10-18 se recompiló y se volvió a probar en el mismo emulador.
Todo cabe a 360 px: el tablero de fichas de 42 px, los seis números en una fila, los
dados con sus puntos, las casillas encendidas, la explicación y la barra de progreso. Ver
[[Interfaz del tablero]].

Con los 4 mapas (2026-10-24) se volvió a probar: la elección de mapa cabe a 360 px con
las 4 miniaturas, el Nivel 2 se prepara y se juega un turno, y el botón de atrás de
Android pide confirmación antes de salir de la partida. Ver [[Mapas]].

Para volver a usarlo:

```bash
%LOCALAPPDATA%\Android\Sdk\emulator\emulator.exe -avd Brilliant_360dp
%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe install -r build\app\outputs\flutter-apk\app-x86_64-release.apk
```
