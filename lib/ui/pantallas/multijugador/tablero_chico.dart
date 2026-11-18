import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../modelo/mapa.dart';
import '../../../modelo/tablero.dart';
import '../../tema.dart';

/// El tablero chico de un jugador en el marcador: qué casillas tiene ocupadas, nunca con
/// qué número. Las ocupadas van con el color pleno de su zona; las vacías, aclaradas hacia
/// el cartón, así se distinguen por la claridad y no solo por el color. La que ocupó en la
/// última ronda lleva un aro amarillo, dibujado sobre la tinta de alrededor para que se
/// vea aunque la casilla sea amarilla.
///
/// Se dibuja con un solo `CustomPainter`: el marcador se redibuja cada vez que llega la
/// sala, y así no son 49 widgets por jugador.
class TableroChico extends StatelessWidget {
  final Mapa mapa;
  final String usuario;
  final Set<String> ocupadas;
  final String? ultima;

  /// Si el jugador ya no está en la partida: se ve apagado.
  final bool apagado;

  const TableroChico({
    super.key,
    required this.mapa,
    required this.usuario,
    required this.ocupadas,
    this.ultima,
    this.apagado = false,
  });

  /// El tamaño de cada casilla, el espacio entre ellas y el borde de la base.
  static const celda = 7.0;
  static const separacion = 1.5;
  static const borde = 3.0;

  /// El lado del tablero entero.
  static const lado = 7 * celda + 6 * separacion + 2 * borde;

  /// El color de una casilla de una zona de color [zona]: pleno si está ocupada, y si no,
  /// aclarado hacia el cartón.
  static Color colorDeCasilla(Color zona, {required bool ocupada}) =>
      ocupada ? zona : Color.lerp(zona, Paleta.cartonClaro, 0.72)!;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Tablero de $usuario: ${ocupadas.length} de 49 casillas ocupadas',
      child: Opacity(
        opacity: apagado ? 0.5 : 1,
        child: CustomPaint(
          size: const Size.square(lado),
          painter: _PintorDelTableroChico(
            celdas: _celdasDe(mapa),
            ocupadas: ocupadas,
            ultima: ultima,
          ),
        ),
      ),
    );
  }

  /// Las 49 casillas de cada mapa (dónde va cada una y de qué color), calculadas una
  /// sola vez por mapa.
  static final _cache = <int, List<_CeldaChica>>{};

  static List<_CeldaChica> _celdasDe(Mapa mapa) => _cache.putIfAbsent(
    mapa.nivel,
    () => [
      for (final celda in Tablero.desdeMapa(mapa).celdas)
        _CeldaChica(
          notacion: celda.posicion.notacion,
          fila: celda.posicion.fila,
          columna: celda.posicion.columna,
          color: coloresDeZona[celda.color]!,
        ),
    ],
  );
}

class _CeldaChica {
  final String notacion;
  final int fila;
  final int columna;
  final Color color;

  const _CeldaChica({
    required this.notacion,
    required this.fila,
    required this.columna,
    required this.color,
  });
}

class _PintorDelTableroChico extends CustomPainter {
  final List<_CeldaChica> celdas;
  final Set<String> ocupadas;
  final String? ultima;

  _PintorDelTableroChico({
    required this.celdas,
    required this.ocupadas,
    required this.ultima,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const paso = TableroChico.celda + TableroChico.separacion;

    // La base de tinta, como la del tablero grande.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(4)),
      Paint()..color = Paleta.tinta,
    );

    Rect? marco;
    for (final celda in celdas) {
      final rect = Rect.fromLTWH(
        TableroChico.borde + celda.columna * paso,
        TableroChico.borde + celda.fila * paso,
        TableroChico.celda,
        TableroChico.celda,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(1.5)),
        Paint()
          ..color = TableroChico.colorDeCasilla(
            celda.color,
            ocupada: ocupadas.contains(celda.notacion),
          ),
      );
      if (celda.notacion == ultima) marco = rect;
    }

    // El aro de la última, en el espacio de tinta alrededor de la casilla.
    if (marco != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(marco.inflate(1.2), const Radius.circular(2)),
        Paint()
          ..color = Paleta.ficha
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    }
  }

  @override
  bool shouldRepaint(_PintorDelTableroChico antes) =>
      !identical(celdas, antes.celdas) ||
      ultima != antes.ultima ||
      !setEquals(ocupadas, antes.ocupadas);
}
