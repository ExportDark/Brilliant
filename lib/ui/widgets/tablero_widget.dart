import 'package:flutter/material.dart';

import '../../modelo/posicion.dart';
import '../../modelo/tablero.dart';
import '../tema.dart';
import 'celda_widget.dart';

/// Dibuja el tablero completo de un [Tablero]: las 49 fichas con el color de
/// su región y el número que tengan anotado, separadas entre sí y apoyadas
/// sobre una base redondeada. No muestra coordenadas: las letras y números
/// del manual solo existen en el código.
///
/// Las celdas para las que [esTocable] devuelve verdadero responden al toque
/// llamando a [alTocar] con su posición. [iluminacionDe] decide cómo se
/// resalta cada celda; sin él, ninguna se resalta. Las celdas para las que
/// [numeroResaltadoEn] devuelve verdadero iluminan su número.
///
/// El tablero se adapta al ancho que tenga: las fichas miden hasta
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

  /// El espacio entre ficha y ficha.
  static const separacion = 4.0;

  /// El borde de la base alrededor de las fichas.
  static const relleno = 6.0;

  /// El tamaño de ficha que cabe en [anchoDisponible], sin pasar del máximo:
  /// el tablero ocupa 7 fichas, sus separaciones y el relleno de la base. Se
  /// redondea hacia abajo para que no sobre ni medio píxel.
  double _tamanoQueCabe(double anchoDisponible) {
    if (!anchoDisponible.isFinite) return tamanoMaximoCelda;
    final queCabe =
        ((anchoDisponible - 2 * relleno) / Tablero.columnas - separacion).floorToDouble();
    return queCabe < tamanoMaximoCelda ? queCabe : tamanoMaximoCelda;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricciones) {
        final tamano = _tamanoQueCabe(restricciones.maxWidth);

        return Container(
          padding: const EdgeInsets.all(relleno),
          decoration: BoxDecoration(
            color: Paleta.baseTablero,
            borderRadius: BorderRadius.circular(tamano * 0.35),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var fila = 0; fila < Tablero.filas; fila++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var columna = 0; columna < Tablero.columnas; columna++)
                      Padding(
                        padding: const EdgeInsets.all(separacion / 2),
                        child: _celda(Posicion(fila: fila, columna: columna), tamano),
                      ),
                  ],
                ),
            ],
          ),
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
}
