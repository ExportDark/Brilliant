import 'package:flutter/material.dart';

import '../../widgets/confirmacion.dart';

/// Pregunta antes de rendirse: el mismo diálogo desde el botón "Rendirme" y desde la
/// flecha de atrás, durante el reparto o la partida.
Future<bool> confirmarRendirse(BuildContext context) => confirmar(
  context,
  titulo: '¿Rendirte?',
  texto: 'Quedarás fuera de la partida.',
  si: 'Rendirme',
  claveSi: const ValueKey('confirmar-rendirse'),
);

/// Pregunta al anfitrión antes de cerrar la sala desde el lobby: los demás quedan fuera.
Future<bool> confirmarCerrarSala(BuildContext context) => confirmar(
  context,
  titulo: '¿Cerrar la sala?',
  texto: 'Los demás quedarán fuera.',
  si: 'Cerrar',
  no: 'Seguir en la sala',
  claveSi: const ValueKey('confirmar-cerrar-sala'),
);
