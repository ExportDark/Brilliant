# Pruebas

Cómo está probado el proyecto: qué cubre cada carpeta de `test/`, cómo están organizadas
las pruebas y qué se aprendió de ellas. 369 tests, todos pasando (2026-10-26).

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
| `test/modelo/` | 80 | `Posicion` (notación, vecinas), `Celda`, `Region`, `extraerValores`, `TipoRegion`, `Tablero` (layout del manual, anotar y vaciar casillas) y los 4 mapas |
| `test/reglas/` | 46 | Las funciones puras de cada restricción, las clases de cada color (con el gris y el naranja) y su `descripcion`. Algunos casos usan datos reales de la Partida 1 del manual |
| `test/juego/` | 128 | `PreparacionBloc`, `PartidaBloc`, `PartidaState`, `evaluarJugada` / `hayJugada`, las casillas exactas que se iluminan, y las partidas completas simuladas y el camino feliz en los 4 mapas |
| `test/ui/` | 114 | `CeldaWidget`, `TableroWidget`, `DadoWidget`, el tema, la elección de mapa, la pantalla de preparación y la de partida, las pantallas en 5 tamaños, del celular chico al escritorio, y el camino feliz por la pantalla en los 4 mapas |
| `test/main/` | 1 | Que la app arranque en la pantalla para elegir el mapa |

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
    la Partida 1: C1=4, F2=1, B4=2, E4=5, C6=3, E7=6), `repartoDePrueba(mapa)` y
    `tableroPreparado(mapa)` (lo mismo en cualquier mapa), `llenoMenos('E5')`,
    `soloCabeElSeisEnE5()`, `dadoConCaras([4, 3])`, `partidaBloc()`, `evaluarEn()`, y
    `posiblesEn()` / `bloqueadasEn()` / `casillasDonde()`, que dan en notación las casillas
    que se iluminan. Para partidas enteras: `enviar()`, `jugarHastaElFinal()` (el jugador
    automático), `expectZonasCumplenSusReglas()` y `dadosConTodasLasCombinaciones()`.
  - `test/ui/pantallas/ayudantes_pantallas.dart`: `abrirApp()` (la app entera, con dados
    fijos), `abrirPreparacion()`, `abrirPartida()`,
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
| `reglas/descripcion/no_dicen_cuantas_casillas_test.dart` | Ninguna descripción dice cuántas casillas tiene la zona, porque cambia según el mapa |

### Mapas

Los de `mapa_test.dart` se repiten en los 4 mapas. Ver [[Mapas]].

| Archivo | Qué prueba |
|---|---|
| `modelo/mapa_test.dart` | Los 4 niveles en orden; cada mapa se arma, tiene 49 casillas vacías, y cada color tiene las zonas y los tamaños de su tarjeta |
| `modelo/mapa/colores_coinciden_con_la_foto_test.dart` | El color de las 49 casillas de cada mapa coincide con una tabla escrita a mano en el test, leída de la foto |
| `modelo/mapa/iniciales_en_zonas_distintas_test.dart` | Las 6 iniciales de cada mapa son las de la estrellita de su tarjeta, cada una en una zona distinta |
| `modelo/tablero/acepta_como_inicial_test.dart` | `aceptaComoInicial`: en el Nivel 4, E1 solo acepta del 4 al 6 y B7 del 1 al 3; las demás iniciales, y las de los otros mapas, cualquier número |
| `modelo/mapa/nivel_1_es_el_mapa_de_siempre_test.dart` | El Nivel 1 arma exactamente el mismo tablero que tenía el juego antes de los mapas |
| `juego/validacion/naranja_fuera_de_rango_test.dart` | En el Nivel 4, la fila "4-6" (con el 4 de E1) rechaza un 2 en D1 y acepta un 5 |
| `juego/validacion/gris_lejano_bloquea_test.dart` | En el Nivel 3, el número de la inicial D4 bloquea otro distinto en G2: la zona gris está dispersa |

Las reglas nuevas tienen su archivo, como las demás: `reglas/regla_rango_test.dart`,
`reglas/regla_naranja_test.dart` y `reglas/regla_gris_test.dart`.

### Preparación

| Archivo | Qué prueba |
|---|---|
| `juego/preparacion/aleatorio_con_una_vacia_test.dart` | Si falta una sola casilla, Aleatorio pone justo el número que falta |
| `juego/preparacion/aleatorio_reproducible_test.dart` | Con la misma semilla, Aleatorio reparte exactamente igual |
| `juego/preparacion/naranja_solo_admite_su_rango_test.dart` | En el Nivel 4, E1 no acepta un 2 pero sí un 5, y B7 acepta un 2 (2 casos) |
| `juego/preparacion/aleatorio_respeta_los_rangos_test.dart` | En el Nivel 4, con 20 semillas, Aleatorio pone del 4 al 6 en E1 y del 1 al 3 en B7 |
| `juego/preparacion/aleatorio_sin_salida_revuelve_todo_test.dart` | Si el 4, el 5 y el 6 ya están usados con E1 vacía, Aleatorio revuelve todo y respeta los rangos |
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
| `ui/widgets/celda/aro_solo_en_iniciales_test.dart` | Solo las casillas iniciales llevan el aro tenue de 2 px, y no es negro |
| `ui/widgets/celda/numero_legible_sobre_cada_color_test.dart` | `tintaSobre`: el número va oscuro sobre los 7 colores suaves y blanco sobre un fondo oscuro |
| `ui/widgets/tablero/sin_coordenadas_test.dart` | El tablero no muestra las letras A–G ni los números 1–7 |
| `ui/widgets/dado/puntos_segun_el_valor_test.dart` | Del 1 al 6, el dado tiene tantos puntos como su valor y se anuncia como "Dado: N" (6 casos) |
| `ui/pantallas/preparacion/seleccion_salta_a_la_siguiente_test.dart` | Al poner un número, la selección salta a la siguiente casilla vacía |
| `ui/pantallas/preparacion/tocar_casilla_inicial_la_selecciona_test.dart` | Tocar una casilla inicial la selecciona |
| `ui/pantallas/preparacion/solo_iniciales_tocables_test.dart` | En cada mapa, solo se pueden tocar sus 6 casillas iniciales (4 casos) |
| `ui/pantallas/preparacion/fichas_segun_el_rango_test.dart` | En el Nivel 4, con E1 seleccionada solo se pueden tocar el 4, el 5 y el 6; con B7, del 1 al 3; con C3, todas |
| `ui/pantallas/preparacion/aleatorio_en_el_nivel_4_test.dart` | En el Nivel 4, Aleatorio en la pantalla respeta los rangos naranjas |
| `ui/pantallas/preparacion/aleatorio_e_inicio_test.dart` | Aleatorio y luego Inicio arranca la partida con los 6 números |
| `ui/pantallas/partida/indicaciones_test.dart` | La indicación acompaña cada paso del turno |
| `ui/pantallas/partida/pasar_turno_reemplaza_tirar_test.dart` | Sin jugada, "Pasar turno" ocupa el lugar de "Tirar dados" |
| `ui/pantallas/partida/explicacion_se_borra_al_cambiar_de_dado_test.dart` | Al cambiar de dado ancla, la explicación anterior desaparece |
| `ui/pantallas/partida/casilla_ocupada_no_responde_test.dart` | Tocar una casilla ocupada no hace nada |
| `ui/pantallas/partida/tras_colocar_nada_iluminado_test.dart` | Al anotar se apaga toda la iluminación del turno |
| `ui/pantallas/partida/solo_el_numero_exacto_se_resalta_test.dart` | Solo se resalta el número exacto que sacó el dado ancla |
| `ui/pantallas/partida/pantalla_coincide_con_la_validacion_test.dart` | La pantalla ilumina exactamente lo que la validación acepta y rechaza |
| `ui/pantallas/partida/barra_de_progreso_test.dart` | La barra de progreso cuenta las casillas llenas: 6 de 49 al empezar, 7 de 49 tras una jugada |
| `ui/pantallas/pantalla_eleccion_de_mapa_test.dart` | La elección muestra los 4 mapas con su nombre y su miniatura de 49 casillas; las miniaturas son los mapas de verdad, con sus iniciales; tocar "Nivel 3" abre su preparación (3 casos) |
| `ui/pantallas/eleccion/flecha_atras_vuelve_a_elegir_test.dart` | Desde la preparación, la flecha de atrás vuelve a elegir el mapa |
| `ui/pantallas/partida/jugar_otra_vez_mismo_mapa_test.dart` | Al terminar el Nivel 4, "Jugar otra vez" prepara el Nivel 4 |
| `ui/pantallas/partida/explicacion_zona_naranja_test.dart` | Un 2 en D1, en la fila naranja "4-6", se explica como "Zona naranja — Solo del 4 al 6. Ya tiene: 4" |
| `ui/pantallas/partida/explicacion_zona_vacia_sin_ya_tiene_test.dart` | En un tablero armado a mano con la zona naranja vacía, el mensaje no dice "Ya tiene" |
| `ui/pantallas/partida/salir_pide_confirmacion_test.dart` | A mitad de partida, la flecha de atrás pregunta: "Seguir jugando" se queda y "Salir" vuelve a elegir el mapa |
| `ui/pantallas/partida/salir_al_terminar_sin_preguntar_test.dart` | Con la partida terminada, la flecha de atrás sale sin preguntar |
| `ui/pantallas/partida/fin_de_partida_y_jugar_otra_vez_test.dart` | Con el tablero lleno sale "¡Tablero completo!", y "Jugar otra vez" vuelve a la preparación |
| `main/arranca_en_eleccion_de_mapa_test.dart` | La app arranca en la pantalla para elegir el mapa (hasta el 2026-10-24, `arranca_en_preparacion_test`) |
| `ui/widgets/tablero/se_adapta_al_ancho_test.dart` | Las fichas miden 48 si caben y se achican si no: 42 con 336 px, 36 con 296 px |

### Tamaños de pantalla

Cada uno se repite en 5 tamaños, de `tamanosDePantalla` (en
`ayudantes_pantallas.dart`): celular chico 320×568, celular 360×640, celular grande
412×915, tablet 768×1024 y escritorio 1280×800, en píxeles lógicos.

| Archivo | Qué prueba |
|---|---|
| `ui/pantallas/tamanos/eleccion_sin_desbordes_test.dart` | La elección de mapa se abre sin desbordarse y las 4 tarjetas caben a lo ancho |
| `ui/pantallas/tamanos/preparacion_sin_desbordes_test.dart` | La preparación se abre sin desbordarse |
| `ui/pantallas/tamanos/partida_sin_desbordes_test.dart` | La partida no se desborda ni en su estado más alto: con dados, dado ancla y explicación |
| `ui/pantallas/tamanos/tablero_entero_a_lo_ancho_test.dart` | Las 49 casillas caben a lo ancho de la pantalla, en los 4 mapas (20 casos) |
| `ui/pantallas/tamanos/turno_jugable_en_cada_tamano_test.dart` | Se puede jugar un turno entero, haciendo scroll si los botones quedan abajo |

Se comprobó que detectan el problema de verdad: con el tablero fijo de 48 px, los 8 casos
de celular fallan ("A RenderFlex overflowed by 32 pixels" a 360 de ancho y por 72 a 320),
y con el tablero adaptable pasan todos. Ver [[Versión Android]].

Tres de estos archivos se llamaban antes `ancla_recien_anotada_test.dart`,
`jugar_junto_al_ancla_nueva_test.dart` y `lejos_del_ancla_gana_test.dart`. Se renombraron el
2026-10-09, cuando el ancla pasó a ser solo un dado.

Otros cuatro cambiaron con el rediseño del 2026-10-18, porque probaban cosas que ya no
se ven. Ver [[Interfaz del tablero]].

| Antes | Ahora | Por qué |
|---|---|---|
| `celda/borde_grueso_solo_iniciales_test` | `celda/aro_solo_en_iniciales_test` | Ya no hay cuadrícula negra: las iniciales llevan un aro tenue de su color |
| `celda/numero_negro_en_seleccionada_test` | `celda/numero_legible_sobre_cada_color_test` | El color del número depende del fondo |
| `tablero/etiquetas_de_notacion_test` | `tablero/sin_coordenadas_test` | Al jugador ya no se le muestran coordenadas |
| `preparacion/chip_selecciona_casilla_test` | `preparacion/tocar_casilla_inicial_la_selecciona_test` | Se quitaron las chips del resumen |

También se actualizaron a propósito los tests que leían textos o formas que cambiaron:
los mensajes sin "C2 ·", los dados como `DadoWidget(valor)`, las acciones de la
preparación como botones de texto, y `celda_widget_test`, que ahora prueba la ficha
redondeada, el orden de iluminación y el aro blanco con brillo de las encendidas. Como la
casilla anima su color, esos tests esperan a que termine la transición
(`pumpAndSettle`) antes de mirarlo.

## Los dados en las pruebas

`PartidaBloc` y `PantallaPartida` reciben `tirarDado`, una función que devuelve la cara
del dado. En las pruebas se le pasa una secuencia fija (`dadoConCaras([4, 3])`) para saber
exactamente qué sale, y así probar casos como "no hay jugada" sin depender de la suerte.
Lo mismo con `PreparacionBloc`, que recibe un `Random` con semilla para el botón
Aleatorio. Ver [[Turnos y jugadas]].

El dado de verdad (sin `tirarDado`) también tiene su prueba: `dado_por_defecto_test`
comprueba que saque caras del 1 al 6 y que salgan todas.

## Partidas completas simuladas

`test/juego/partida_completa_test.dart` juega **10 partidas enteras en cada uno de los 4
mapas** con el `PartidaBloc`, cada una con una semilla fija (1 a 10), así que si alguna
falla se puede repetir exactamente igual. En cada partida:

1. La preparación es una permutación al azar del 1 al 6 en la que cada número cabe en su
   casilla (en el Nivel 4, E1 lleva del 4 al 6 y B7 del 1 al 3).
2. Un jugador automático tira, elige como ancla el dado que tenga jugada, anota en la
   primera casilla válida, y pasa el turno cuando no hay jugada.
3. Al final se comprueba que la partida **terminó** (antes de 2000 turnos, para detectar
   un ciclo infinito de pasar turno), que **cada jugada fue aceptada** y que **ninguna
   zona rompe su regla de color**.

Las 40 corren en unos 3 segundos. Con el Nivel 1, las semillas dan exactamente las mismas
partidas que antes de que hubiera mapas.

> [!info] Lo que mostraron: la partida siempre llena el tablero
> Las 10 partidas del Nivel 1 terminaron con **49 de 49 casillas**, en 58 a 104 turnos, y
> lo mismo pasa en los otros tres mapas (ver [[Mapas]]). No es casualidad: con las reglas actuales ninguna zona se queda sin salida (a la roja siempre
> le falta un número de la corrida, la morada ya eligió sus dos números, la azul repite
> el suyo) y toda casilla vacía tarde o temprano queda junto a una llena. Por eso contar
> casillas llenas no distinguiría a nadie. Ver [[Puntuación]].

## Camino feliz: una partida entera

`test/juego/camino_feliz/partida_entera_test.dart` es el **happy path** del juego: una
partida en la que todo sale bien, de punta a punta, sin pantalla, **en cada uno de los 4
mapas**. Es el único unit test que encadena los dos blocs:

1. **Preparación.** `PreparacionBloc` reparte el `repartoDePrueba` del mapa en sus
   casillas iniciales, en orden, y se confirma: los números de la Partida 1 (4, 1, 2,
   5, 3, 6), salvo en el Nivel 4, donde se cambian de lugar el 3 y el 6 para que B7, en
   la zona "1-3", lleve un 3.
2. **Paso a la partida.** El tablero se arma igual que al oprimir Inicio:
   `Tablero.desdeMapa(mapa).conValores(preparacion.state.valores)`.
3. **Partida.** `PartidaBloc` con dados **sin azar** que recorren las 36 combinaciones de
   dos dados en orden, (1,1), (1,2), …, (6,6), y vuelven a empezar
   (`dadosConTodasLasCombinaciones()`). Como el dado ancla puede ser cualquiera de los
   dos, toda jugada que haga falta sale a más tardar en 36 turnos, así que la partida
   siempre avanza. El jugador automático es `jugarHastaElFinal()`.
4. **Final.** Termina con **las 49 casillas llenas**, los 6 iniciales en su lugar, y
   cada zona cumpliendo las reglas de las tarjetas:
   - las rojas y la amarilla, sin repetir;
   - cada azul y cada gris, con un solo número;
   - cada morada, con dos números como máximo;
   - cada naranja, solo con números de su rango.

Como no hay azar, cada mapa juega siempre la misma partida, con 43 números anotados:

| Mapa | Turnos | Pasados |
|---|---|---|
| Nivel 1 | 73 | 30 |
| Nivel 2 | 73 | 30 |
| Nivel 3 | 51 | 8 |
| Nivel 4 | 52 | 9 |

> [!tip] Las reglas del final se revisan a mano
> El final no usa las clases de reglas del código para juzgarse: revisa cada color con su
> regla escrita directo en el test. Se comprobó rompiendo el código a propósito. Si la
> regla de "todos diferentes" dejara pasar repetidos, este test falla ("la zona #1
> (amarillo) con [1, 2, 3, 1, 2]: no puede repetir"); una verificación que usara la
> misma regla rota no lo notaría. Si la preparación entregara mal los números, también
> falla. Y si la regla naranja aceptara cualquier número, falla el Nivel 4 ("la zona #7
> (naranja) con [5, 6, 6, 1, 1, 5, 6]: solo números de {4, 5, 6}").

### El mismo camino, tocando la pantalla

`test/ui/camino_feliz/partida_entera_por_la_pantalla_test.dart` es el happy path como
**widget test**, uno por mapa: juega la partida tocando la app como una persona, sin
mandarle nada a los blocs.

1. Abre la app entera (`BrilliantApp`, con `abrirApp()`), con los mismos dados sin azar,
   y toca la tarjeta del mapa.
2. En la preparación toca cada casilla con aro y su número (el `repartoDePrueba`), y
   comprueba que cada número aparece en el tablero y que Inicio se habilita.
3. Toca **Inicio** y juega turno por turno. Toca **Tirar dados**. Si aparece **Pasar
   turno**, lo toca. Si no, toca el primer dado como ancla y, si no se enciende ninguna
   casilla, el segundo. Después toca la primera casilla encendida y comprueba que ahí
   quedó el número del otro dado, que el turno avanza y que la barra cuenta una casilla
   más.
4. Al final ve "¡Tablero completo!", "49 de 49 casillas" y en cuántos turnos se jugó,
   los 6 iniciales en su lugar, y ninguna zona rompiendo su regla.
5. Toca **Jugar otra vez** y vuelve a una preparación vacía **del mismo mapa**.

Por la pantalla, cada mapa dura distinto que en el unit test:

| Mapa | Por la pantalla | En el unit test |
|---|---|---|
| Nivel 1 | 56 turnos (13 pasados) | 73 |
| Nivel 2 | 55 turnos (12 pasados) | 73 |
| Nivel 3 | 49 turnos (6 pasados) | 51 |
| Nivel 4 | 55 turnos (12 pasados) | 52 |

Es porque eligen otra casilla: este toma la primera encendida en el orden en que se lee
el tablero, y el jugador del unit test la primera de `tablero.celdas`, que va zona por
zona. Son partidas distintas, y todas llenan el tablero. Cada mapa corre en unos 9
segundos, así que la suite entera tarda unos 50.

Para que los dados lleguen fijos desde el arranque, `BrilliantApp`,
`PantallaEleccionDeMapa` y `PantallaPreparacion` reciben un `tirarDado` opcional que
pasan a la partida, igual que `PantallaPartida`. En la app no se pasa, y los dados salen al azar.

> [!tip] Se comprobó que detecta errores de la pantalla
> Si la pantalla encendiera también las casillas que rompen la regla de su zona, el test
> falla en el turno 4 ("en E2 tenía que quedar el 4"): toca una casilla encendida y el
> bloc no la acepta. El unit test no lo notaría, porque no mira la pantalla.

## Verificación en la app real

Además de los tests, cada cambio visual se revisa en la app compilada para web, con
Edge sin ventana, sacando capturas. Ver [[Cómo trabajar en el proyecto]].
