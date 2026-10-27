import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/validacion_jugada.dart';
import 'package:brilliant/modelo/mapa.dart';

import '../ayudantes.dart';

void main() {
  test('evaluarJugada: en el Nivel 3, un número en la zona gris bloquea a las otras grises, '
      'aunque estén lejos', () {
    // La inicial D4, gris, tiene un 2. G2, también gris, está en la otra punta
    // del tablero, junto al 1 de F2.
    final tablero = tableroPreparado(nivel3);

    final otroNumero = evaluarEn(tablero, 'G2', ancla: 1, valor: 5);
    expect(otroNumero, isA<ReglaRota>());
    expect((otroNumero as ReglaRota).valoresEnZona, [2]);

    expect(evaluarEn(tablero, 'G2', ancla: 1, valor: 2), isA<JugadaValida>());
  });
}
