import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/preparacion_bloc.dart';
import 'package:brilliant/juego/preparacion_event.dart';
import 'package:brilliant/juego/preparacion_state.dart';
import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/modelo/tablero.dart';

import '../ayudantes.dart';

void main() {
  blocTest<PreparacionBloc, PreparacionState>(
    'PreparacionBloc: si lo ya puesto no deja completar el reparto, Aleatorio revuelve todo',
    build: () => PreparacionBloc(
      nivel4.casillasIniciales.map(pos).toList(),
      azar: Random(1),
      admite: Tablero.desdeMapa(nivel4).aceptaComoInicial,
    ),
    act: (bloc) => bloc
      // El 4, el 5 y el 6 ya están usados, y E1 (fila "4-6") sigue vacía: no
      // hay forma de completar respetando lo puesto.
      ..add(ValorAsignado(pos('C3'), 4))
      ..add(ValorAsignado(pos('F3'), 5))
      ..add(ValorAsignado(pos('A4'), 6))
      ..add(const RepartoAleatorio()),
    verify: (bloc) {
      expect(bloc.state.completa, isTrue);
      expect(bloc.state.valores.values.toSet(), {1, 2, 3, 4, 5, 6});
      expect(bloc.state.valorDe(pos('E1')), inInclusiveRange(4, 6));
      expect(bloc.state.valorDe(pos('B7')), inInclusiveRange(1, 3));
    },
  );
}
