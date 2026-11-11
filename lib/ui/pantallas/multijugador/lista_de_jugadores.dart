import 'package:flutter/material.dart';

import '../../../multijugador/modelos.dart';
import '../../tema.dart';
import 'textos_multijugador.dart';

/// Los jugadores de la sala: el anfitrión marcado, sus puntos, y si ya jugó la ronda
/// (o ya repartió, en la preparación). Solo lo público: nunca sus números.
class ListaDeJugadores extends StatelessWidget {
  final List<JugadorEnSala> jugadores;
  final String yo;

  /// Si se muestran los puntos (en el lobby todavía no hay).
  final bool conPuntos;

  /// Si se muestra quién ya jugó o ya repartió.
  final bool conListo;

  const ListaDeJugadores({
    super.key,
    required this.jugadores,
    required this.yo,
    this.conPuntos = false,
    this.conListo = false,
  });

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final jugador in jugadores)
          Padding(
            key: ValueKey('jugador-${jugador.usuario}'),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  jugador.anfitrion
                      ? Icons.star_rounded
                      : Icons.person_outline_rounded,
                  size: 20,
                  color: jugador.activo ? Paleta.acento : Paleta.tintaSuave,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _nombre(jugador),
                    style: textos.bodyLarge?.copyWith(
                      color: jugador.activo ? Paleta.tinta : Paleta.tintaSuave,
                      decoration: jugador.activo
                          ? null
                          : TextDecoration.lineThrough,
                    ),
                  ),
                ),
                if (conPuntos)
                  Text(
                    '${jugador.puntos} pts',
                    key: ValueKey('puntos-${jugador.usuario}'),
                    style: textos.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (conListo && jugador.activo) ...[
                  const SizedBox(width: 10),
                  Icon(
                    jugador.listo
                        ? Icons.check_circle_rounded
                        : Icons.hourglass_empty_rounded,
                    key: ValueKey('listo-${jugador.usuario}'),
                    size: 20,
                    color: jugador.listo
                        ? Paleta.disponible
                        : Paleta.tintaSuave,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  String _nombre(JugadorEnSala jugador) {
    final etiquetas = [
      if (jugador.usuario == yo) 'tú',
      if (jugador.anfitrion) 'anfitrión',
      if (!jugador.activo) estadoDeSalida(jugador.estado),
    ];
    return etiquetas.isEmpty
        ? jugador.usuario
        : '${jugador.usuario} (${etiquetas.join(', ')})';
  }
}
