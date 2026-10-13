import 'package:flutter_test/flutter_test.dart';

import '../ayudantes.dart';

/// Para cada número inicial de la Partida 1 (C1=4, F2=1, B4=2, E4=5, C6=3,
/// E7=6): qué sale en el dado ancla, qué se anota, y qué casillas se iluminan.
const _casos = [
  (ancla: 4, valor: 3, posibles: {'B1', 'D1'}, bloqueadas: {'C2'}),
  (ancla: 1, valor: 3, posibles: {'F1', 'E2', 'F3', 'G2'}, bloqueadas: <String>{}),
  (ancla: 2, valor: 2, posibles: {'A4', 'C4'}, bloqueadas: {'B3', 'B5'}),
  (ancla: 3, valor: 4, posibles: {'C5', 'C7', 'B6', 'D6'}, bloqueadas: <String>{}),
  (ancla: 5, valor: 6, posibles: {'E3', 'D4', 'F4'}, bloqueadas: {'E5'}),
  // E7 está en el borde de abajo: solo tiene 3 vecinas.
  (ancla: 6, valor: 3, posibles: {'E6', 'D7', 'F7'}, bloqueadas: <String>{}),
];

void main() {
  group('evaluarJugada: las casillas que se iluminan junto a cada número inicial', () {
    for (final caso in _casos) {
      test('dado ancla ${caso.ancla}, se anota el ${caso.valor}', () {
        final tablero = tableroPartida1();

        expect(posiblesEn(tablero, ancla: caso.ancla, valor: caso.valor), caso.posibles);
        expect(bloqueadasEn(tablero, ancla: caso.ancla, valor: caso.valor), caso.bloqueadas);
      });
    }
  });
}
