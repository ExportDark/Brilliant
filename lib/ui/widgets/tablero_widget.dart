import 'package:flutter/material.dart';

import '../../modelo/posicion.dart';
import '../../modelo/tablero.dart';
import 'celda_widget.dart';

/// Dibuja la grilla completa de un [Tablero]: cada celda con el color de su
/// región y el número que tenga anotado, más las letras de columna (A-G) y
/// los números de fila (1-7) de la notación del manual.
///
/// Las celdas para las que [esTocable] devuelve verdadero responden al toque
/// llamando a [alTocar] con su posición. [iluminacionDe] decide cómo se
/// resalta cada celda; sin él, ninguna se resalta. Las celdas para las que
/// [numeroResaltadoEn] devuelve verdadero iluminan su número.
///
/// El tablero se adapta al ancho que tenga: las casillas miden hasta
/// [tamanoMaximoCelda], y se achican si no caben, como en un celular angosto.
class TableroWidget extends StatelessWidget {
  final Tablero tablero;
  final Posicion? seleccionada;
  final void Function(Posicion)? alTocar;
  final bool Function(Posicion)? esTocable;
  final Iluminacion Function(Posicion)? iluminacionDe;
  final bool Function(Posicion)? numeroResaltadoEn;
  final double tamanoMaximoCelda;

  const TableroWidget({
    super.key,
    required this.tablero,
    this.seleccionada,
    this.alTocar,
    this.esTocable,
    this.iluminacionDe,
    this.numeroResaltadoEn,
    this.tamanoMaximoCelda = 48,
  });

  /// Cuántas casillas de ancho ocupa el tablero entero: las 7 columnas más la
  /// media casilla de los números de fila.
  static const _anchoEnCasillas = Tablero.columnas + 0.5;

  /// El tamaño de casilla que cabe en [anchoDisponible], sin pasar del máximo.
  /// Se redondea hacia abajo para que no sobre ni medio píxel.
  double _tamanoQueCabe(double anchoDisponible) {
    if (!anchoDisponible.isFinite) return tamanoMaximoCelda;
    final queCabe = (anchoDisponible / _anchoEnCasillas).floorToDouble();
    return queCabe < tamanoMaximoCelda ? queCabe : tamanoMaximoCelda;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricciones) {
        final tamano = _tamanoQueCabe(restricciones.maxWidth);
        final margen = tamano / 2;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _etiqueta('', ancho: margen, alto: margen),
                for (var columna = 0; columna < Tablero.columnas; columna++)
                  _etiqueta(
                    String.fromCharCode('A'.codeUnitAt(0) + columna),
                    ancho: tamano,
                    alto: margen,
                  ),
              ],
            ),
            for (var fila = 0; fila < Tablero.filas; fila++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _etiqueta('${fila + 1}', ancho: margen, alto: tamano),
                  for (var columna = 0; columna < Tablero.columnas; columna++)
                    _celda(Posicion(fila: fila, columna: columna), tamano),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _celda(Posicion posicion, double tamano) {
    final celda = CeldaWidget(
      celda: tablero.celdaEn(posicion)!,
      tamano: tamano,
      seleccionada: posicion == seleccionada,
      iluminacion: iluminacionDe?.call(posicion) ?? Iluminacion.normal,
      numeroResaltado: numeroResaltadoEn?.call(posicion) ?? false,
    );

    final tocable = alTocar != null && (esTocable?.call(posicion) ?? true);
    if (!tocable) return celda;

    return GestureDetector(
      key: ValueKey('casilla-${posicion.notacion}'),
      onTap: () => alTocar!(posicion),
      child: MouseRegion(cursor: SystemMouseCursors.click, child: celda),
    );
  }

  Widget _etiqueta(String texto, {required double ancho, required double alto}) {
    return SizedBox(
      width: ancho,
      height: alto,
      child: Center(child: Text(texto, style: const TextStyle(fontWeight: FontWeight.bold))),
    );
  }
}
