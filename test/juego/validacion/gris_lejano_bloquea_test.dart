import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/validacion_jugada.dart';
import 'package:brilliant/modelo/mapa.dart';

import '../ayudantes.dart';

void main() {
  test('evaluarJugada: en el Nivel 3, un número en la zona gris bloquea a las otras grises, '
      'aunque estén lejos', () {
    // D1 está junto al 4 de C1. D4, también gris, queda tres filas más abajo.
    final tablero = tableroPreparado(nivel3, ademas: {'D4': 3});

    final otroNumero = evaluarEn(tablero, 'D1', ancla: 4, valor: 5);
    expect(otroNumero, isA<ReglaRota>());
    expect((otroNumero as ReglaRota).valoresEnZona, [3]);

    expect(evaluarEn(tablero, 'D1', ancla: 4, valor: 3), isA<JugadaValida>());
  });
}
