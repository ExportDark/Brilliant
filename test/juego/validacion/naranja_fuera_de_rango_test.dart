import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/validacion_jugada.dart';
import 'package:brilliant/modelo/mapa.dart';

import '../ayudantes.dart';

void main() {
  test('evaluarJugada: en el Nivel 4, la fila de arriba solo acepta del 4 al 6, aunque esté vacía', () {
    // C2 tiene un 4, y C1 está justo arriba, en la zona naranja "4-6".
    final tablero = tableroPreparado(nivel4);

    final conUnDos = evaluarEn(tablero, 'C1', ancla: 4, valor: 2);
    expect(conUnDos, isA<ReglaRota>());
    expect((conUnDos as ReglaRota).valoresEnZona, isEmpty);

    expect(evaluarEn(tablero, 'C1', ancla: 4, valor: 5), isA<JugadaValida>());
  });
}
