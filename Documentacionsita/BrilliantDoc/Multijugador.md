# Multijugador

Salas con código en línea. **El servidor manda**: tira los dados, valida cada jugada y calcula los puntos. La app solo dibuja lo que el servidor le dice (ver [[Servidor de cuentas]] para el servidor y [[Puntuación]] para los puntos).

## Flujo
- "Elige un mapa" → botón multijugador → crear sala o unirse con código (6 caracteres, sin 0/O/1/I/L).
- Lobby: hasta 6 jugadores; el anfitrión elige mapa y empieza con 2 o más.
- Preparación: la misma pantalla de un jugador (`PantallaPreparacion` con `alConfirmar` y `titulo`), a pantalla completa; 60 s, si no se reparte al azar. Al confirmar se espera a los demás.
- Partida: mi tablero, dados compartidos, puntos de cada uno y panel de zonas (puestos tomados y puntos del siguiente, o "agotada"). Rendirse pide confirmación; salir de la pantalla equivale a rendirse.
- Resultado: ranking, motivo del fin y zonas.

## Privacidad
Nadie ve números ni casillas de los demás: el servidor solo manda el tablero propio; de los demás, nombre, estado, puntos y si ya jugaron.

## Desconexiones
La app pregunta cada segundo (`SalaBloc`). 3 s sin respuesta: "Reconectando…"; 10 s: conexión perdida. El servidor saca al instante a quien lleva 10 s sin preguntar; si se va el anfitrión ganan los demás. Sala desaparecida (reinicio del servidor): se avisa y se vuelve.

## Código
`lib/multijugador/` (modelos, `ClienteSalas`, `SalaBloc`) y `lib/ui/pantallas/multijugador/`. Tests en `test/multijugador/` y `test/ui/pantallas/multijugador/` (un archivo por situación).

## Pendiente
Diseño visual; prueba con dos clientes contra el servidor real; prueba de tamaños de pantalla.
