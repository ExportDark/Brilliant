import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/tablero.dart';

import '../ayudantes.dart';

void main() {
  test('evaluarJugada: un número en la esquina solo tiene 2 vecinas donde jugar', () {
    // El único número del tablero es un 5 en A1, la esquina de arriba a la izquierda.
    final tablero = Tablero.mapaOriginal().conValor(pos('A1'), 5);

    expect(posiblesEn(tablero, ancla: 5, valor: 2), {'B1', 'A2'});
  });
}
