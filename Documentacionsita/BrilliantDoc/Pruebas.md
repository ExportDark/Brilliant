# Pruebas

Cómo está probado el proyecto: qué cubre cada carpeta de `test/`, cómo están organizadas
las pruebas y qué se aprendió de ellas. 242 tests, todos pasando (2026-10-17).

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
| `test/modelo/` | 52 | `Posicion` (notación, vecinas), `Celda`, `Region`, `extraerValores`, `TipoRegion` y `Tablero` (layout del manual, anotar y vaciar casillas) |
| `test/reglas/` | 34 | Las funciones puras de cada restricción, las 5 clases de color y su `descripcion`. Algunos casos usan datos reales de la Partida 1 del manual |
| `test/juego/` | 88 | `PreparacionBloc`, `PartidaBloc`, `PartidaState`, `evaluarJugada` / `hayJugada`, las casillas exactas que se iluminan y las partidas completas simuladas |
| `test/ui/` | 67 | `CeldaWidget`, `TableroWidget`, la pantalla de preparación y la de partida, y las dos pantallas en 5 tamaños, del celular chico al escritorio |
| `test/main/` | 1 | Que la app arranque en la pantalla de preparación |

## Cómo están organizadas

- **Un archivo de test por archivo de lógica**, con la misma estructura de carpetas que
  `lib/`. Por ejemplo, `lib/juego/partida_bloc.dart` se prueba en
  `test/juego/partida_bloc_test.dart`. Son los tests que se escribieron junto con cada
  pieza.
- **Las pruebas sueltas, una por archivo.** Todo test que se agrega después para cubrir un
  caso puntual vive en su propio archivo, dentro de una subcarpeta con el nombre de lo que
  prueba (`test/modelo/region/`, `test/juego/partida/`, `test/ui/pantallas/partida/`…). El
  nombre del archivo dice qué prueba. La lista completa está abajo.
- **Ayudantes compartidos**, en archivos que no terminan en `_test.dart` (así `flutter test`
  no los corre solos):
  - `test/juego/ayudantes.dart`: `pos('C1')`, `tableroPartida1()` (los valores iniciales de
    la Partida 1: C1=4, F2=1, B4=2, E4=5, C6=3, E7=6), `llenoMenos('E5')`,
    `soloCabeElSeisEnE5()`, `dadoConCaras([4, 3])`, `partidaBloc()`, `evaluarEn()`, y
    `posiblesEn()` / `bloqueadasEn()` / `casillasDonde()`, que dan en notación las casillas
    que se iluminan.
  - `test/ui/pantallas/ayudantes_pantallas.dart`: `abrirPreparacion()`, `abrirPartida()`,
    `tocar()`, `tirarYElegirAncla()`, `celdaEn()`, `celdasDibujadasDonde()` y los
    buscadores de botones, dados y casillas.

## Las pruebas sueltas

Todas las rutas son dentro de `test/`.

### Modelo y reglas

| Archivo | Qué prueba |
|---|---|
| `modelo/region/con_casilla_test.dart` | `Region.conCasilla` anota solo esa casilla, conserva la región y no muta la original |
| `modelo/region/sin_casilla_test.dart` | `Region.sinCasilla` vacía solo esa casilla |
| `modelo/region/con_casilla_fuera_de_la_region_test.dart` | Una casilla que no es de la región no cambia nada |
| `modelo/celda/sin_valor_conserva_datos_test.dart` | `Celda.sinValor` vacía y conserva posición, color y si es inicial |
| `modelo/posicion/vecinas_dentro_del_tablero_test.dart` | En el tablero, las esquinas tienen 2 vecinas, los bordes 3 y el interior 4 |
| `reglas/descripcion/cada_regla_se_describe_test.dart` | Cada color se describe con el nombre de su regla del manual |

### Preparación

| Archivo | Qué prueba |
|---|---|
| `juego/preparacion/aleatorio_con_una_vacia_test.dart` | Si falta una sola casilla, Aleatorio pone justo el número que falta |
| `juego/preparacion/aleatorio_reproducible_test.dart` | Con la misma semilla, Aleatorio reparte exactamente igual |
| `juego/preparacion/asignar_tras_confirmar_test.dart` | Una vez confirmada, no acepta ni siquiera reasignar el mismo número |

### Partida (el bloc y su estado)

| Archivo | Qué prueba |
|---|---|
| `juego/partida/numero_recien_anotado_test.dart` | Un número recién anotado ya cuenta al buscar en el turno siguiente |
| `juego/partida/jugar_junto_al_numero_nuevo_test.dart` | Se puede jugar junto a ese número nuevo, aunque quede lejos de las iniciales |
| `juego/partida/iluminacion_crece_con_la_cadena_test.dart` | Con un 4 anotado en C2, sus vecinas se suman a las que se iluminan: {B1, D1, B2, C3}, y D2 apenas |
| `juego/partida/dados_iguales_test.dart` | Con 4 y 4, el dado ancla y el número a anotar son el mismo |
| `juego/partida/dado_ancla_sin_jugada_test.dart` | Elegir un dado ancla sin jugada no ilumina nada, y el otro dado sí |
| `juego/partida/ningun_numero_en_el_tablero_test.dart` | Si ningún dado sacó un número que esté en el tablero, no hay jugada |
| `juego/partida/tirar_tras_pasar_test.dart` | Después de pasar el turno se vuelve a tirar |
| `juego/partida/fin_tras_la_ultima_jugada_test.dart` | Al anotar la última jugada posible la partida termina y ya no deja tirar |
| `juego/partida/estado_sin_dado_ancla_test.dart` | Sin dado ancla elegido, el estado no evalúa ni resalta nada |
| `juego/partida/dado_por_defecto_test.dart` | El dado de la app saca caras del 1 al 6, y en 200 dados salen todas |
| `juego/partida/indice_negativo_test.dart` | Un índice de dado negativo se ignora |
| `juego/partida/posicion_fuera_del_tablero_test.dart` | Una posición fuera del tablero se ignora sin errores |

### Validación: qué casillas se iluminan

| Archivo | Qué prueba |
|---|---|
| `juego/validacion/seis_numeros_iniciales_test.dart` | Para cada uno de los 6 números iniciales, las casillas exactas que se iluminan mucho y poco (6 casos) |
| `juego/validacion/varias_casillas_con_el_numero_test.dart` | Con dos casillas que tienen el número, cuentan las vecinas de las dos |
| `juego/validacion/numero_en_la_esquina_test.dart` | Un número en la esquina solo tiene 2 vecinas donde jugar |
| `juego/validacion/ocupada_junto_al_numero_test.dart` | Una vecina ya ocupada no se ilumina |
| `juego/validacion/amarillo_bloquea_lejos_test.dart` | Un número amarillo bloquea a las otras casillas amarillas, aunque estén lejos |
| `juego/validacion/lejos_del_numero_gana_test.dart` | Si una casilla está lejos del número y además rompe la regla, se explica lo del número |
| `juego/validacion/ocupada_gana_test.dart` | Una casilla ocupada gana sobre todo lo demás |

### Interfaz

| Archivo | Qué prueba |
|---|---|
| `ui/widgets/celda/borde_grueso_solo_iniciales_test.dart` | Solo las casillas iniciales llevan el borde grueso |
| `ui/widgets/celda/numero_negro_en_seleccionada_test.dart` | En la casilla seleccionada, muy iluminada, el número va en negro |
| `ui/widgets/tablero/etiquetas_de_notacion_test.dart` | Se ven las letras A–G y los números 1–7 |
| `ui/pantallas/preparacion/seleccion_salta_a_la_siguiente_test.dart` | Al poner un número, la selección salta a la siguiente casilla vacía |
| `ui/pantallas/preparacion/chip_selecciona_casilla_test.dart` | Tocar una chip del resumen selecciona su casilla |
| `ui/pantallas/preparacion/solo_iniciales_tocables_test.dart` | Solo se pueden tocar las 6 casillas iniciales |
| `ui/pantallas/preparacion/aleatorio_e_inicio_test.dart` | Aleatorio y luego Inicio arranca la partida con los 6 números |
| `ui/pantallas/partida/indicaciones_test.dart` | La indicación acompaña cada paso del turno |
| `ui/pantallas/partida/pasar_turno_reemplaza_tirar_test.dart` | Sin jugada, "Pasar turno" ocupa el lugar de "Tirar dados" |
| `ui/pantallas/partida/explicacion_se_borra_al_cambiar_de_dado_test.dart` | Al cambiar de dado ancla, la explicación anterior desaparece |
| `ui/pantallas/partida/casilla_ocupada_no_responde_test.dart` | Tocar una casilla ocupada no hace nada |
| `ui/pantallas/partida/tras_colocar_nada_iluminado_test.dart` | Al anotar se apaga toda la iluminación del turno |
| `ui/pantallas/partida/solo_el_numero_exacto_se_resalta_test.dart` | Solo se resalta el número exacto que sacó el dado ancla |
| `ui/pantallas/partida/pantalla_coincide_con_la_validacion_test.dart` | La pantalla ilumina exactamente lo que la validación acepta y rechaza |
| `main/arranca_en_preparacion_test.dart` | La app arranca en la pantalla de preparación |
| `ui/widgets/tablero/se_adapta_al_ancho_test.dart` | Las casillas miden 48 si caben y se achican si no: 43 con 328 px, 38 con 288 px |

### Tamaños de pantalla

Cada uno se repite en 5 tamaños, de `tamanosDePantalla` (en
`ayudantes_pantallas.dart`): celular chico 320×568, celular 360×640, celular grande
412×915, tablet 768×1024 y escritorio 1280×800, en píxeles lógicos.

| Archivo | Qué prueba |
|---|---|
| `ui/pantallas/tamanos/preparacion_sin_desbordes_test.dart` | La preparación se abre sin desbordarse |
| `ui/pantallas/tamanos/partida_sin_desbordes_test.dart` | La partida no se desborda ni en su estado más alto: con dados, dado ancla y explicación |
| `ui/pantallas/tamanos/tablero_entero_a_lo_ancho_test.dart` | Las 49 casillas caben a lo ancho de la pantalla |
| `ui/pantallas/tamanos/turno_jugable_en_cada_tamano_test.dart` | Se puede jugar un turno entero, haciendo scroll si los botones quedan abajo |

Se comprobó que detectan el problema de verdad: con el tablero fijo de 48 px, los 8 casos
de celular fallan ("A RenderFlex overflowed by 32 pixels" a 360 de ancho y por 72 a 320),
y con el tablero adaptable pasan todos. Ver [[Versión Android]].

Tres de estos archivos se llamaban antes `ancla_recien_anotada_test.dart`,
`jugar_junto_al_ancla_nueva_test.dart` y `lejos_del_ancla_gana_test.dart`. Se renombraron el
2026-10-09, cuando el ancla pasó a ser solo un dado.

## Los dados en las pruebas

`PartidaBloc` y `PantallaPartida` reciben `tirarDado`, una función que devuelve la cara
del dado. En las pruebas se le pasa una secuencia fija (`dadoConCaras([4, 3])`) para saber
exactamente qué sale, y así probar casos como "no hay jugada" sin depender de la suerte.
Lo mismo con `PreparacionBloc`, que recibe un `Random` con semilla para el botón
Aleatorio. Ver [[Turnos y jugadas]].

El dado de verdad (sin `tirarDado`) también tiene su prueba: `dado_por_defecto_test`
comprueba que saque caras del 1 al 6 y que salgan todas.

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
