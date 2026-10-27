import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/validacion_jugada.dart';
import 'package:brilliant/modelo/mapa.dart';

import '../ayudantes.dart';

void main() {
  test('evaluarJugada: en el Nivel 4, la fila de arriba solo acepta del 4 al 6', () {
    // La inicial E1, en la fila naranja "4-6", tiene un 4. D1 está a su lado.
    final tablero = tableroPreparado(nivel4);

    final conUnDos = evaluarEn(tablero, 'D1', ancla: 4, valor: 2);
    expect(conUnDos, isA<ReglaRota>());
    expect((conUnDos as ReglaRota).valoresEnZona, [4]);

    expect(evaluarEn(tablero, 'D1', ancla: 4, valor: 5), isA<JugadaValida>());
  });
}
