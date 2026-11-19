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
  _ => 'Zona', // un color de un servidor más nuevo: nunca el código tal cual
};

/// Por qué terminó la partida.
String motivoDelFin(String motivo, {int? meta}) => switch (motivo) {
  'meta_alcanzada' =>
    meta == null ? 'Alguien llegó a la meta de puntos.' : 'Se alcanzó la meta: $meta puntos.',
  'tablero_lleno' => 'Todos llenaron su tablero.',
  'sin_jugadas' => 'Ya nadie puede jugar.',
  'anfitrion_se_fue' => 'El anfitrión se fue: ganan los demás.',
  'sala_cerrada' => 'El anfitrión cerró la sala.',
  'ultimo_jugador' => 'Los demás salieron: gana el último que quedó.',
  'todos_se_fueron' => 'Todos salieron: nadie gana.',
  // Un motivo de un servidor más nuevo: nunca el código tal cual.
  _ => 'La partida terminó.',
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

/// La línea de abajo del nombre en el marcador y el resultado: "Tú", si se fue y, al
/// final, cuántos primeros puestos sacó. Por ejemplo, "Tú, se rindió, 1 primer puesto".
/// `null` si no hay nada que decir.
String? etiquetasDeJugador({
  required bool mia,
  required String estado,
  int primeros = 0,
}) {
  final etiquetas = [
    if (mia) 'tú',
    if (estado != 'activo') estadoDeSalida(estado),
    if (primeros == 1) '1 primer puesto',
    if (primeros > 1) '$primeros primeros puestos',
  ].where((e) => e.isNotEmpty).join(', ');
  return etiquetas.isEmpty ? null : '${etiquetas[0].toUpperCase()}${etiquetas.substring(1)}';
}

/// La regla de la meta, para el lobby, el marcador y las reglas.
String ganaQuienLlegaA(int meta) => 'Gana el primero que llegue a $meta puntos.';

/// Por qué [yo] ya no juega: se rindió o se desconectó (el servidor lo sacó).
String textoDeFuera(MiVista yo) =>
    yo.estado == 'se_rindio' ? 'Te rendiste.' : 'Te desconectaste de la partida.';
