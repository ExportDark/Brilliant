import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/partida_bloc.dart';
import 'package:brilliant/juego/partida_event.dart';
import 'package:brilliant/juego/partida_state.dart';
import 'package:brilliant/modelo/tablero.dart';

import '../ayudantes.dart';

void main() {
  blocTest<PartidaBloc, PartidaState>(
    'PartidaBloc: si ningún dado sacó un número que esté en el tablero, no hay jugada',
    // El tablero solo tiene un 4 en C1, y salen 3 y 5: no hay dónde buscar.
    build: () => partidaBloc(
      tablero: Tablero.mapaOriginal().conValor(pos('C1'), 4),
      caras: [3, 5],
    ),
    act: (bloc) => bloc..add(const DadosTirados()),
    verify: (bloc) {
      expect(bloc.state.sinJugada, isTrue);
      // Con otra tirada (un 4) sí habría jugada: la partida no terminó.
      expect(bloc.state.terminada, isFalse);
    },
  );
}
