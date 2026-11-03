import 'package:flutter/material.dart';

import '../../modelo/color_zona.dart';
import '../tema.dart';

/// El logo de las pantallas de cuenta: cinco fichas con los colores de las
/// zonas, como una fila del tablero, y el nombre del juego.
class LogoBrilliant extends StatelessWidget {
  const LogoBrilliant({super.key});

  static const _colores = [
    ColorZona.rojo,
    ColorZona.amarillo,
    ColorZona.verde,
    ColorZona.azul,
    ColorZona.morado,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            for (final color in _colores)
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: coloresDeZona[color],
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Brilliant',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Paleta.tinta,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}
