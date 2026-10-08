import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/partida_bloc.dart';
import 'package:brilliant/juego/partida_event.dart';
import 'package:brilliant/juego/partida_state.dart';

import '../ayudantes.dart';

void main() {
  blocTest<PartidaBloc, PartidaState>(
    'PartidaBloc: se puede jugar junto al ancla nueva, aunque quede lejos de las iniciales',
    // Turno 1: sale 4 y 3, ancla 4, el 3 va a B1 (junto al 4 de C1).
    // Turno 2: sale 3 y 5, ancla 3, el 5 va a A1. A1 solo toca a B1: ninguna
    // casilla inicial tiene un 3 a su lado.
    build: () => partidaBloc(caras: [4, 3, 3, 5]),
    act: (bloc) => bloc
      ..add(const DadosTirados())
      ..add(const DadoElegido(0))
      ..add(ValorColocado(pos('B1')))
      ..add(const DadosTirados())
      ..add(const DadoElegido(0))
      ..add(ValorColocado(pos('A1'))),
    verify: (bloc) {
      expect(bloc.state.tablero.celdaEn(pos('A1'))!.valor, 5);
      expect(bloc.state.turno, 3);
    },
  );
}
