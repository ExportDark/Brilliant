import 'package:brilliant/multijugador/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudantes_salas.dart';

void main() {
  test('De cada jugador llegan sus casillas ocupadas y la de la última ronda', () {
    final jugador = JugadorEnSala.desdeJson(
      jugadorJson('beto', ocupadas: ['A3', 'D1', 'E1'], ultima: 'D1'),
    );

    expect(jugador.ocupadas, ['A3', 'D1', 'E1']);
    expect(jugador.ultima, 'D1');
  });

  test('Con un servidor viejo, que no las manda, no hay casillas ni última', () {
    final json = jugadorJson('beto')
      ..remove('ocupadas')
      ..remove('ultima');

    final jugador = JugadorEnSala.desdeJson(json);

    expect(jugador.ocupadas, isEmpty);
    expect(jugador.ultima, isNull);
  });
}
