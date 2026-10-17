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
| `app-arm64-v8a-release.apk` | 15,1 MB | **El del teléfono**: cualquier Android de los últimos años |
| `app-armeabi-v7a-release.apk` | 12,6 MB | Teléfonos muy viejos, de 32 bits |
| `app-x86_64-release.apk` | 16,5 MB | Emuladores en la PC |

La primera compilación tardó unos 7 minutos, porque Gradle descargó e instaló solo lo que
faltaba del SDK (NDK 28, Build-Tools 36 y CMake). Las siguientes tardan segundos.

### Qué hace falta en la PC

- **Android SDK**, en `C:\Users\expor\AppData\Local\Android\sdk`, con sus licencias
  aceptadas.
- **Android Studio**: solo se usa su Java (`jbr`), que Flutter encuentra solo.
- `flutter doctor` avisa que faltan las *cmdline-tools*, pero no hacen falta para compilar.
  Sí harían falta para `flutter doctor --android-licenses` o para crear emuladores con
  `avdmanager`. Se instalan desde Android Studio: *SDK Manager → SDK Tools → Android SDK
  Command-line Tools*.

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

Para volver a usarlo:

```bash
%LOCALAPPDATA%\Android\Sdk\emulator\emulator.exe -avd Brilliant_360dp
%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe install -r build\app\outputs\flutter-apk\app-x86_64-release.apk
```
