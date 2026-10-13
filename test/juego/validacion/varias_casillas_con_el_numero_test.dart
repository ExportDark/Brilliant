import 'package:flutter_test/flutter_test.dart';

import '../ayudantes.dart';

void main() {
  test('evaluarJugada: con dos casillas que tienen el número buscado, cuentan las vecinas de las dos', () {
    // Además del 4 inicial de C1, hay un 4 en G4, en la otra punta del tablero.
    final tablero = tableroPartida1(ademas: {'G4': 4});

    // Junto a C1: B1 y D1 (C2 no, por la zona azul). Junto a G4: G3, F4 y G5.
    expect(posiblesEn(tablero, ancla: 4, valor: 3), {'B1', 'D1', 'G3', 'F4', 'G5'});
    expect(bloqueadasEn(tablero, ancla: 4, valor: 3), {'C2'});
  });
}
