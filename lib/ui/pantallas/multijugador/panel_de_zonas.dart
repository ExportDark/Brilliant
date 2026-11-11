import 'package:flutter/material.dart';

import '../../../modelo/color_zona.dart';
import '../../../multijugador/modelos.dart';
import '../../tema.dart';
import 'textos_multijugador.dart';

/// Qué zonas siguen dando puntos y cuáles ya se llenaron, a la vista de todos: una fila
/// por zona, con su color, cuántos puntos da la siguiente que la llene (o "Agotada") y
/// quién la llenó ya, en qué puesto. Nadie ve los números de los demás: solo esto.
class PanelDeZonas extends StatelessWidget {
  final List<ZonaEnSala> zonas;

  const PanelDeZonas({super.key, required this.zonas});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Zonas y puntos', style: textos.titleMedium),
        const SizedBox(height: 8),
        for (final zona in zonas)
          Padding(
            key: ValueKey('zona-${zona.id}'),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3, right: 10),
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: _colorDe(zona.color),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${nombreDeColor(zona.color)}, ${zona.casillas.length} casillas',
                        style: textos.bodyMedium,
                      ),
                      if (zona.puestos.isNotEmpty)
                        Text(
                          puestosDe(zona),
                          style: textos.bodySmall?.copyWith(
                            color: Paleta.tintaSuave,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  zona.agotada ? 'Agotada' : 'Da ${zona.puntosSiguiente}',
                  key: ValueKey('puntos-zona-${zona.id}'),
                  style: textos.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: zona.agotada ? Paleta.tintaSuave : Paleta.tinta,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static Color _colorDe(String color) {
    final zona = ColorZona.values.where((c) => c.name == color).firstOrNull;
    return zona == null ? Colors.grey : coloresDeZona[zona]!;
  }
}
