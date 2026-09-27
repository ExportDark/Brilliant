import 'package:flutter/material.dart';

import '../../modelo/posicion.dart';
import '../../modelo/tablero.dart';
import 'celda_widget.dart';

/// Dibuja la grilla completa de un [Tablero]: cada celda con el color de su
/// región y el número que tenga anotado, más las letras de columna (A-G) y
/// los números de fila (1-7) de la notación del manual.
///
/// Las celdas para las que [esTocable] devuelve verdadero responden al toque
/// llamando a [alTocar] con su posición.
class TableroWidget extends StatelessWidget {
  final Tablero tablero;
  final Posicion? seleccionada;
  final void Function(Posicion)? alTocar;
  final bool Function(Posicion)? esTocable;
  final double tamanoCelda;

  const TableroWidget({
    super.key,
    required this.tablero,
    this.seleccionada,
    this.alTocar,
    this.esTocable,
    this.tamanoCelda = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _etiqueta('', ancho: _margen, alto: _margen),
            for (var columna = 0; columna < Tablero.columnas; columna++)
              _etiqueta(
                String.fromCharCode('A'.codeUnitAt(0) + columna),
                ancho: tamanoCelda,
                alto: _margen,
              ),
          ],
        ),
        for (var fila = 0; fila < Tablero.filas; fila++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _etiqueta('${fila + 1}', ancho: _margen, alto: tamanoCelda),
              for (var columna = 0; columna < Tablero.columnas; columna++)
                _celda(Posicion(fila: fila, columna: columna)),
            ],
          ),
      ],
    );
  }

  Widget _celda(Posicion posicion) {
    final celda = CeldaWidget(
      celda: tablero.celdaEn(posicion)!,
      tamano: tamanoCelda,
      seleccionada: posicion == seleccionada,
    );

    final tocable = alTocar != null && (esTocable?.call(posicion) ?? true);
    if (!tocable) return celda;

    return GestureDetector(
      key: ValueKey('casilla-${posicion.notacion}'),
      onTap: () => alTocar!(posicion),
      child: MouseRegion(cursor: SystemMouseCursors.click, child: celda),
    );
  }

  /// Espacio que ocupan las letras de columna y los números de fila.
  double get _margen => tamanoCelda / 2;

  Widget _etiqueta(String texto, {required double ancho, required double alto}) {
    return SizedBox(
      width: ancho,
      height: alto,
      child: Center(child: Text(texto, style: const TextStyle(fontWeight: FontWeight.bold))),
    );
  }
}
