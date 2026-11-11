import 'package:flutter/material.dart';

import '../../../multijugador/modelos.dart';
import '../../tema.dart';
import 'panel_de_zonas.dart';
import 'textos_multijugador.dart';

/// El final de la partida: quién ganó y por qué terminó, el ranking con los puntos de
/// cada uno y cómo se repartieron las zonas. No muestra los tableros: nadie los ve.
class VistaResultado extends StatelessWidget {
  final VistaDeSala sala;

  const VistaResultado({super.key, required this.sala});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final resultado = sala.resultado!;
    final gane = resultado.ganadores.contains(sala.yo.usuario);

    final titulo = gane
        ? (resultado.ganadores.length > 1
              ? '¡Empataste y ganaste!'
              : '¡Ganaste!')
        : resultado.ganadores.isEmpty
        ? 'Nadie ganó'
        : 'Ganó ${resultado.ganadores.join(' y ')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      key: const ValueKey('resultado'),
      children: [
        Text(
          titulo,
          key: const ValueKey('titulo-del-resultado'),
          textAlign: TextAlign.center,
          style: textos.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          motivoDelFin(resultado.motivo),
          key: const ValueKey('motivo-del-fin'),
          textAlign: TextAlign.center,
          style: textos.bodyLarge?.copyWith(color: Paleta.tintaSuave),
        ),
        const SizedBox(height: 20),
        Text('Puntos', style: textos.titleMedium),
        const SizedBox(height: 6),
        for (final (indice, fila) in resultado.ranking.indexed)
          Padding(
            key: ValueKey('fila-${fila.usuario}'),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(width: 28, child: Text('${indice + 1}.')),
                Expanded(
                  child: Text(
                    '${fila.usuario}${resultado.ganadores.contains(fila.usuario) ? ' ★' : ''}'
                    '${fila.estado == 'activo' ? '' : ' (${estadoDeSalida(fila.estado)})'}',
                    style: textos.bodyLarge?.copyWith(
                      fontWeight: resultado.ganadores.contains(fila.usuario)
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ),
                Text('${fila.puntos} pts', style: textos.bodyLarge),
                if (fila.primeros > 0) Text('  · ${fila.primeros} primeros'),
              ],
            ),
          ),
        const SizedBox(height: 20),
        PanelDeZonas(zonas: sala.zonas),
      ],
    );
  }
}
