# Cómo trabajar en el proyecto

Ver también: [[Estado del proyecto]] · [[Arquitectura general]] · [[Pruebas]]

## Dónde está todo

| Qué | Dónde |
|---|---|
| Proyecto Flutter | `Escritorio/Algara The Final Chapter/Brilliant/` |
| Este vault | `Brilliant/Documentacionsita/BrilliantDoc/` |
| Repo remoto | https://github.com/ExportDark/Brilliant |
| Manual del juego | `Brilliant_Imitacion_Manual_y_Partidas.pdf`, en `C:\Users\expor\Downloads\` (fuera del repo) |

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
flutter test                                    # correr todos los tests
flutter test test/ui test/main                  # solo los widget tests
dart analyze                                    # análisis estático
flutter run -d edge                             # correr en web (en Edge)
flutter build web                               # compilar para web
flutter build apk --release --split-per-abi     # compilar el APK de Android
flutter run -d windows                          # correr en escritorio (ver abajo)
```

En esta PC no hay Chrome, así que para web se usa Edge (`-d edge`). Para escritorio,
`flutter doctor` avisa que falta **Visual Studio** con el paquete "Desarrollo para el
escritorio con C++": sin eso, `flutter run -d windows` no compila. Para Android, ver
[[Versión Android]].

VS Code tiene instaladas las extensiones `dart-code.dart-code` y `dart-code.flutter`, así
que los archivos `.dart` se reconocen solos (resaltado, análisis, botón Run/Debug).

## Probar la app en el navegador (sin Chrome)

En esta máquina no hay Chrome, pero sí Edge y Node. Así se revisa la app de verdad y se
le sacan capturas, que es como se verificó cada cambio visual:

1. Compilar: `C:\src\flutter\bin\flutter.bat build web` (tarda alrededor de un minuto).
2. Servir `build/web`: `python -m http.server 8765 --bind 127.0.0.1`.
3. En una carpeta temporal (no en el repo), instalar `playwright-core` y abrir Edge sin
   ventana: `chromium.launch({ channel: 'msedge', headless: true })`.
4. Flutter web dibuja todo en un canvas. Para poder encontrar botones hay que activar la
   semántica haciendo clic en `flt-semantics-placeholder` desde JavaScript.
   - Los botones son `flt-semantics[role="button"]` con su texto adentro.
   - Las chips del resumen (`C1 = 4`) tienen el texto en `aria-label`.
   - Las casillas del tablero no tienen etiqueta: se tocan por coordenadas, a partir de
     la etiqueta de columna "A". Son 48 px por casilla.
5. Revisar las capturas y cerrar el servidor del puerto 8765.

## Leer el PDF del manual

El PDF no es una imagen: es dibujo vectorial (salió de Excel). Cada casilla del tablero
es un rectángulo con su color exacto, así que se puede leer con precisión en vez de a ojo:

- Con PyMuPDF (`pip install --target <carpeta temporal> pymupdf`),
  `page.get_drawings()` da cada rectángulo con su color de relleno, y
  `page.get_text()` da los números de las partidas.
- Los tableros están en las páginas 1, 4, 5, 6 y 8. Las casillas iniciales son las que
  tienen el recuadro grueso.

Así se verificó el layout el 2026-09-30. Ver [[Decisiones de extracción del manual]].

## Archivos que no se suben al repo

- `NOTITAS.txt`: notas personales de pendientes.
- `devtools_options.yaml`: lo crea Flutter DevTools al correr la app desde VS Code.
- `.obsidian/workspace.json` y `.obsidian/graph.json`: Obsidian los reescribe solo al
  abrir o cerrar paneles.
- En `android/`, lo que ignora su propio `.gitignore`: `local.properties` (la ruta del
  SDK de esta PC), el wrapper de Gradle, `GeneratedPluginRegistrant.java` y cualquier
  `keystore`. Flutter los regenera solo al compilar.

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
- **Pruebas sueltas, una por archivo**: todo test que se agrega para cubrir un caso
  puntual vive en su propio archivo, en una subcarpeta con el nombre de lo que prueba
  (`test/modelo/region/`, `test/juego/partida/`, `test/juego/validacion/`,
  `test/ui/pantallas/partida/`…). El nombre del archivo dice qué prueba, por ejemplo
  `dados_iguales_test.dart`. Los ayudantes que comparten están en
  `test/juego/ayudantes.dart` y `test/ui/pantallas/ayudantes_pantallas.dart`, que no
  terminan en `_test.dart`, así que `flutter test` no los corre solos. La lista completa
  está en [[Pruebas]]
- **Funciones puras** para la lógica de reglas, testeables en aislado
- **Entidades inmutables** (`Celda.conValor()` devuelve una copia, no muta)
- **Commits incrementales**: una pieza por commit, con sus tests y el README
  actualizado en el mismo commit; mensajes breves
- **Todo cambio queda en el vault**: se actualiza la nota del tema y se agrega una entrada
  en [[Historial de cambios]], con la fecha, el porqué y el commit. Ver también
  [[Pruebas]] para cómo están organizados los tests
