# Pruebas

Cómo está probado el proyecto: qué cubre cada carpeta de `test/`, cómo están organizadas
las pruebas y qué se aprendió de ellas. 180 tests, todos pasando (2026-10-09).

Ver también: [[Cómo trabajar en el proyecto]] · [[Estado del proyecto]] · [[Historial de cambios]]

## Correrlas

```bash
C:\src\flutter\bin\flutter.bat test                       # todas
C:\src\flutter\bin\flutter.bat test test/juego             # solo una carpeta
C:\src\flutter\bin\flutter.bat test test/juego/partida/dados_iguales_test.dart
```

Si `flutter test` vuelve a fallar por el Application Control de Windows,
`dart analyze` sirve de respaldo. Ver [[Cómo trabajar en el proyecto]].

## Qué cubre cada carpeta

| Carpeta | Tests | Qué prueba |
|---|---|---|
| `test/modelo/` | 47 | `Posicion` (notación, vecinas), `Celda`, `Region`, `extraerValores`, `TipoRegion` y `Tablero` (layout del manual, anotar y vaciar casillas) |
| `test/reglas/` | 33 | Las funciones puras de cada restricción y las 5 clases de color. Algunos casos usan datos reales de la Partida 1 del manual |
| `test/juego/` | 68 | `PreparacionBloc`, `PartidaBloc`, `evaluarJugada` / `hayJugada`, los casos sueltos de la regla del dado ancla y las partidas completas simuladas |
| `test/ui/` | 32 | `CeldaWidget` (iluminación y número resaltado), `TableroWidget`, la pantalla de preparación y la de partida (incluido que el ancla se vea solo en los dados) |

## Cómo están organizadas

- **Un archivo de test por archivo de lógica**, con la misma estructura de carpetas que
  `lib/`. Por ejemplo, `lib/juego/partida_bloc.dart` se prueba en
  `test/juego/partida_bloc_test.dart`.
- **Los casos sueltos de la regla del dado ancla, uno por archivo**, con un nombre que dice
  qué prueban:

  | Archivo | Qué prueba |
  |---|---|
  | `test/juego/partida/numero_recien_anotado_test.dart` | Un número recién anotado ya cuenta al buscar en el turno siguiente |
  | `test/juego/partida/jugar_junto_al_numero_nuevo_test.dart` | Se puede jugar junto a ese número nuevo, aunque quede lejos de las iniciales |
  | `test/juego/partida/dados_iguales_test.dart` | Con 4 y 4, el dado ancla y el número a anotar son el mismo |
  | `test/juego/partida/fin_tras_la_ultima_jugada_test.dart` | Al anotar la última jugada posible la partida termina y ya no deja tirar |
  | `test/juego/partida/posicion_fuera_del_tablero_test.dart` | Una posición fuera del tablero se ignora sin errores |
  | `test/juego/validacion/lejos_del_numero_gana_test.dart` | Si una casilla está lejos del número buscado y además rompe la regla, se explica lo del número |
  | `test/juego/validacion/ocupada_gana_test.dart` | Una casilla ocupada gana sobre todo lo demás |

  Los tres primeros archivos se llamaban `ancla_recien_anotada_test.dart`,
  `jugar_junto_al_ancla_nueva_test.dart` y `lejos_del_ancla_gana_test.dart`. Se renombraron
  el 2026-10-09, cuando el ancla pasó a ser solo un dado.

- **Ayudantes compartidos** en `test/juego/ayudantes.dart`: `pos('C1')`,
  `tableroPartida1()` (los valores iniciales de la Partida 1: C1=4, F2=1, B4=2, E4=5,
  C6=3, E7=6), `llenoMenos('E5')`, `soloCabeElSeisEnE5()`, `dadoConCaras([4, 3])`,
  `partidaBloc()` y `evaluarEn()`. Como no termina en `_test.dart`, `flutter test` no lo
  corre solo.

## Los dados en las pruebas

`PartidaBloc` y `PantallaPartida` reciben `tirarDado`, una función que devuelve la cara
del dado. En las pruebas se le pasa una secuencia fija (`dadoConCaras([4, 3])`) para saber
exactamente qué sale, y así probar casos como "no hay jugada" sin depender de la suerte.
Lo mismo con `PreparacionBloc`, que recibe un `Random` con semilla para el botón
Aleatorio. Ver [[Turnos y jugadas]].

## Partidas completas simuladas

`test/juego/partida_completa_test.dart` juega **10 partidas enteras** con el
`PartidaBloc`, cada una con una semilla fija (1 a 10), así que si alguna falla se puede
repetir exactamente igual. En cada partida:

1. La preparación es una permutación al azar del 1 al 6.
2. Un jugador automático tira, elige como ancla el dado que tenga jugada, anota en la
   primera casilla válida, y pasa el turno cuando no hay jugada.
3. Al final se comprueba que la partida **terminó** (antes de 2000 turnos, para detectar
   un ciclo infinito de pasar turno), que **cada jugada fue aceptada** y que **ninguna de
   las 9 zonas rompe su regla de color**.

Las 10 corren en alrededor de un segundo.

> [!info] Lo que mostraron: la partida siempre llena el tablero
> Las 10 partidas terminaron con **49 de 49 casillas**, en 58 a 104 turnos. No es
> casualidad: con las reglas actuales ninguna zona se queda sin salida (a la roja siempre
> le falta un número de la corrida, la morada ya eligió sus dos números, la azul repite
> el suyo) y toda casilla vacía tarde o temprano queda junto a una llena. Por eso contar
> casillas llenas no distinguiría a nadie. Ver [[Puntuación]].

## Verificación en la app real

Además de los tests, cada cambio visual se revisa en la app compilada para web, con
Edge sin ventana, sacando capturas. Ver [[Cómo trabajar en el proyecto]].
