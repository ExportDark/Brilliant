import 'package:flutter_test/flutter_test.dart';

import '../ayudantes.dart';

void main() {
  test('evaluarJugada: una vecina ya ocupada no se ilumina, aunque esté junto al número', () {
    // B1, a la izquierda del 4 de C1, ya tiene un 3.
    final tablero = tableroPartida1(ademas: {'B1': 3});

    expect(posiblesEn(tablero, ancla: 4, valor: 3), {'D1'});
    expect(bloqueadasEn(tablero, ancla: 4, valor: 3), {'C2'});
  });
}
