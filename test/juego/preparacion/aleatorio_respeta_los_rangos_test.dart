import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/preparacion_bloc.dart';
import 'package:brilliant/juego/preparacion_event.dart';
import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/modelo/tablero.dart';

import '../ayudantes.dart';

void main() {
  test('PreparacionBloc: en el Nivel 4, Aleatorio pone del 4 al 6 en E1 y del 1 al 3 en B7', () async {
    // Con 20 semillas distintas: si alguna rompiera un rango, se nota.
    for (var semilla = 1; semilla <= 20; semilla++) {
      final bloc = PreparacionBloc(
        nivel4.casillasIniciales.map(pos).toList(),
        azar: Random(semilla),
        admite: Tablero.desdeMapa(nivel4).aceptaComoInicial,
      );
      addTearDown(bloc.close);

      bloc.add(const RepartoAleatorio());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.completa, isTrue, reason: 'semilla $semilla');
      expect(bloc.state.valores.values.toSet(), {1, 2, 3, 4, 5, 6}, reason: 'semilla $semilla');
      expect(bloc.state.valorDe(pos('E1')), inInclusiveRange(4, 6), reason: 'semilla $semilla');
      expect(bloc.state.valorDe(pos('B7')), inInclusiveRange(1, 3), reason: 'semilla $semilla');
    }
  });
}
