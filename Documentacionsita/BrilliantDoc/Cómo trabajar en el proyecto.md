# Cómo trabajar en el proyecto

Ver también: [[Estado del proyecto]] · [[Arquitectura general]]

## Dónde está todo

| Qué | Dónde |
|---|---|
| Proyecto Flutter | `Escritorio/Algara The Final Chapter/Brilliant/` |
| Este vault | `Brilliant/Documentacionsita/BrilliantDoc/` |
| Repo remoto | https://github.com/ExportDark/Brilliant |
| Intento previo (referencia) | `Escritorio/Algara The Final Chapter/Brilliant Beta/` |
| Manual del juego | `Brilliant_Imitacion_Manual_y_Partidas.pdf` |

## El SDK de Flutter no está en el PATH

Está instalado en `C:\src\flutter\bin\`, pero **no está en el PATH**, así que desde la
terminal hay que invocarlo con ruta completa:

```bash
C:\src\flutter\bin\flutter.bat test
C:\src\flutter\bin\dart.bat analyze
```

Versión del SDK de Dart: 3.13.2 (stable).

## Comandos

```bash
flutter test              # correr todos los tests
dart analyze              # análisis estático
flutter run -d chrome     # correr en web
flutter run -d windows    # correr en escritorio
flutter build web         # compilar para web
```

VS Code tiene instaladas las extensiones `dart-code.dart-code` y `dart-code.flutter`, así
que los archivos `.dart` se reconocen solos (resaltado, análisis, botón Run/Debug).

## Problema conocido: Application Control de Windows

En algún punto `flutter test` y `dart run` empezaron a fallar con:

```
ProcessStarter::StartForExec failed: An Application Control policy has blocked this file
```

Es una política de control de aplicaciones de Windows (Smart App Control / WDAC) que
bloquea la ejecución de binarios generados dinámicamente por Dart. Detalles observados:

- `dart analyze` **sí** funciona (solo análisis estático, no ejecuta código)
- `flutter_tester.exe` invocado directamente **sí** corre
- `flutter test` y `dart run` fallaban de forma consistente en Bash y PowerShell

El bloqueo se resolvió solo después de unos días. Si vuelve a aparecer, `dart analyze`
sirve como verificación de respaldo (confirma que todo compila, aunque no que los tests
pasen), y se puede revisar en Configuración → Privacidad y seguridad → Seguridad de
Windows → Control de aplicaciones y del explorador.

## Convenciones del proyecto

- **Nombres en español**, consistentes con el dominio del juego (`Celda`, `Region`,
  `Tablero`, `puedeAgregar`, `casillas`)
- **Un test por archivo de lógica**, en `test/` con la misma estructura que `lib/`
- **Funciones puras** para la lógica de reglas, testeables en aislado
- **Entidades inmutables** (`Celda.conValor()` devuelve una copia, no muta)
- **Commits incrementales**: una pieza por commit, con sus tests y el README
  actualizado en el mismo commit; mensajes breves
