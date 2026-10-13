import 'package:flutter_test/flutter_test.dart';

import '../ayudantes.dart';

void main() {
  test('evaluarJugada: un número amarillo bloquea a las otras casillas amarillas, aunque estén lejos', () {
    // Hay un 3 amarillo en A1 y un 5 en G6. Dado ancla 5 (en E4 y G6), se anota un 3.
    final tablero = tableroPartida1(ademas: {'A1': 3, 'G6': 5});

    // D4 (junto a E4) y G7 (junto a G6) son amarillas: el 3 de A1 las bloquea.
    // G5 y F6 son de la zona azul de G6, que ya tiene un 5.
    expect(bloqueadasEn(tablero, ancla: 5, valor: 3), {'D4', 'G7', 'G5', 'F6'});
    expect(posiblesEn(tablero, ancla: 5, valor: 3), {'E3', 'E5', 'F4'});
  });
}
