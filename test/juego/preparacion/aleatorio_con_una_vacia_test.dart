import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/preparacion_bloc.dart';
import 'package:brilliant/juego/preparacion_event.dart';
import 'package:brilliant/juego/preparacion_state.dart';
import 'package:brilliant/modelo/tablero.dart';

import '../ayudantes.dart';

void main() {
  blocTest<PreparacionBloc, PreparacionState>(
    'PreparacionBloc: si falta una sola casilla, Aleatorio pone justo el número que falta',
    build: () => PreparacionBloc(casillasIniciales.map(pos).toList(), azar: Random(1)),
    act: (bloc) => bloc
      ..add(ValorAsignado(pos('C1'), 1))
      ..add(ValorAsignado(pos('F2'), 2))
      ..add(ValorAsignado(pos('B4'), 3))
      ..add(ValorAsignado(pos('E4'), 4))
      ..add(ValorAsignado(pos('C6'), 5))
      ..add(const RepartoAleatorio()),
    verify: (bloc) {
      // No hay nada que sortear: E7 solo puede llevar el 6.
      expect(bloc.state.valorDe(pos('E7')), 6);
      expect(bloc.state.valorDe(pos('C1')), 1);
      expect(bloc.state.completa, isTrue);
    },
  );
}
