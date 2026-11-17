import 'package:flutter/material.dart';

import '../../modelo/mapa.dart';
import '../../modelo/tablero.dart';
import '../tema.dart';
import 'tablero_widget.dart';

/// Un mapa para elegir: su tablero vacío en miniatura, con las casillas iniciales
/// marcadas, su nombre y cuántas zonas tiene. La usan "Elige un mapa" y el lobby del
/// multijugador.
///
/// Con [alElegir] `null` no responde al toque (cuando solo se muestra cuál se eligió).
/// [seleccionada] la pinta del amarillo de ficha.
class TarjetaDeMapa extends StatelessWidget {
  final Mapa mapa;
  final VoidCallback? alElegir;
  final bool seleccionada;

  const TarjetaDeMapa({
    super.key,
    required this.mapa,
    this.alElegir,
    this.seleccionada = false,
  });

  /// La rejilla de dos columnas con que se muestran los mapas: en un celular angosto las
  /// miniaturas se achican, igual que el tablero de la partida.
  static Widget rejilla({
    required Widget Function(Mapa mapa) tarjeta,
    double separacion = 12,
  }) {
    return LayoutBuilder(
      builder: (context, restricciones) {
        final ancho = (restricciones.maxWidth - separacion) / 2;
        return Wrap(
          spacing: separacion,
          runSpacing: separacion,
          children: [
            for (final mapa in mapas)
              SizedBox(width: ancho, child: tarjeta(mapa)),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Paleta.tinta, width: grosorDeTinta),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: sombraDura(4),
      ),
      child: Material(
        color: seleccionada ? Paleta.ficha : Paleta.cartonClaro,
        shape: forma,
        child: InkWell(
          key: ValueKey('mapa-${mapa.nivel}'),
          customBorder: forma,
          onTap: alElegir,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
            child: Column(
              children: [
                // Sin alTocar: el toque lo recibe la tarjeta entera.
                TableroWidget(tablero: Tablero.desdeMapa(mapa)),
                const SizedBox(height: 10),
                Text(
                  mapa.nombre,
                  style: textos.titleMedium?.copyWith(
                    color: Paleta.tinta,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${mapa.zonas.length} zonas',
                  style: textos.bodySmall?.copyWith(
                    color: seleccionada ? Paleta.tinta : Paleta.tintaSuave,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
