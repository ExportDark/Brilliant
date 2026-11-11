import '../../../multijugador/modelos.dart';

/// Los textos del multijugador: cómo se llama cada color, por qué terminó la partida...

String nombreDeColor(String color) => switch (color) {
  'amarillo' => 'Amarilla',
  'verde' => 'Verde',
  'morado' => 'Morada',
  'azul' => 'Azul',
  'rojo' => 'Roja',
  'gris' => 'Gris',
  'naranja' => 'Naranja',
  _ => color,
};

/// Por qué terminó la partida.
String motivoDelFin(String motivo) => switch (motivo) {
  'tablero_lleno' => 'Todos llenaron su tablero.',
  'sin_jugadas' => 'Ya nadie puede jugar.',
  'anfitrion_se_fue' => 'El anfitrión se fue: ganan los demás.',
  'ultimo_jugador' => 'Los demás salieron: gana el último que quedó.',
  'todos_se_fueron' => 'Todos salieron: nadie gana.',
  _ => motivo,
};

/// De un jugador que ya no está en la partida.
String estadoDeSalida(String estado) => switch (estado) {
  'se_rindio' => 'se rindió',
  'desconectado' => 'se desconectó',
  _ => '',
};

/// "1.º", "2.º"...
String ordinal(int puesto) => '$puesto.º';

/// Una línea sobre quién llenó una zona: "1.º ana (ronda 3), 2.º beto (ronda 5)".
String puestosDe(ZonaEnSala zona) => [
  for (final p in zona.puestos)
    '${ordinal(p.puesto)} ${p.usuario} (ronda ${p.ronda})',
].join(', ');
