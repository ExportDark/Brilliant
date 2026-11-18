import 'package:flutter/material.dart';

import '../../modelo/color_zona.dart';
import '../animacion/cartoon.dart';
import '../tema.dart';

/// El logo de las pantallas de cuenta: cinco fichas con los colores de las
/// zonas, como una fila del tablero, y el nombre del juego.
///
/// Al aparecer, las fichas caen una tras otra y rebotan al tocar la bandeja, como en
/// los dibujos animados viejos. Una sola vez; después no se mueven.
class LogoBrilliant extends StatefulWidget {
  const LogoBrilliant({super.key});

  static const colores = [
    ColorZona.rojo,
    ColorZona.amarillo,
    ColorZona.verde,
    ColorZona.azul,
    ColorZona.morado,
  ];

  @override
  State<LogoBrilliant> createState() => _LogoBrilliantState();
}

class _LogoBrilliantState extends State<LogoBrilliant> with SingleTickerProviderStateMixin {
  late final _caida = AnimationController(vsync: this, duration: Cartoon.logo, value: 1);
  var _porCaer = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_porCaer) {
      _porCaer = false;
      if (!Cartoon.quieto(context)) _caida.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _caida.dispose();
    super.dispose();
  }

  /// Dónde está la ficha [i]: si ya se ve, cuánto le falta para caer y cuánto se aplasta.
  ({bool visible, double alto, double aplastado}) _ficha(int i) {
    if (_caida.value >= 1) return (visible: true, alto: 0, aplastado: 0);
    // Cada ficha cae medio camino después de la anterior.
    final u = ((_caida.value - i * 0.1) / 0.5).clamp(0.0, 1.0);
    if (u <= 0) return (visible: false, alto: 0, aplastado: 0);
    if (u < 0.6) {
      // Cae acelerando, como con gravedad.
      final caida = u / 0.6;
      return (visible: true, alto: 40 * (1 - caida * caida), aplastado: -0.1 * caida);
    }
    // Toca la bandeja: se aplasta y rebota hasta asentarse.
    final r = (u - 0.6) / 0.4;
    return (
      visible: true,
      alto: 0,
      aplastado: 0.25 * (1 - const CurvaDeGoma(rebotes: 1).transform(r)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _caida,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              for (final (i, color) in LogoBrilliant.colores.indexed)
                Builder(
                  builder: (context) {
                    final ficha = _ficha(i);
                    return Opacity(
                      opacity: ficha.visible ? 1 : 0,
                      child: Transform.translate(
                        key: ValueKey('ficha-del-logo-$i'),
                        offset: Offset(0, -ficha.alto),
                        child: AplastarYEstirar(
                          aplastado: ficha.aplastado,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: coloresDeZona[color],
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(color: Paleta.tinta, width: grosorDeTinta),
                              boxShadow: sombraDura(3),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Brilliant',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Paleta.tinta),
        ),
      ],
    );
  }
}
