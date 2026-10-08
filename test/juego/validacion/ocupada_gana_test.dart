import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/validacion_jugada.dart';

import '../ayudantes.dart';

void main() {
  test('evaluarJugada: ocupada gana, aunque tampoco haya un ancla al lado', () {
    // C1 ya tiene el 4, y además no hay ningún 6 a su lado.
    expect(evaluarEn(tableroPartida1(), 'C1', ancla: 6, valor: 3), isA<CasillaOcupada>());
  });
}
