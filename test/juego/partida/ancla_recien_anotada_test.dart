import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/partida_bloc.dart';
import 'package:brilliant/juego/partida_event.dart';
import 'package:brilliant/juego/partida_state.dart';

import '../ayudantes.dart';

void main() {
  blocTest<PartidaBloc, PartidaState>(
    'PartidaBloc: un número recién anotado es ancla en el turno siguiente',
    // Turno 1: sale 4 y 3, ancla 4, el 3 va a B1 (junto al 4 de C1).
    // Turno 2: sale 3 y 5, ancla 3.
    build: () => partidaBloc(caras: [4, 3, 3, 5]),
    act: (bloc) => bloc
      ..add(const DadosTirados())
      ..add(const DadoElegido(0))
      ..add(ValorColocado(pos('B1')))
      ..add(const DadosTirados())
      ..add(const DadoElegido(0)),
    verify: (bloc) {
      expect(bloc.state.valorAncla, 3);
      expect(bloc.state.esAncla(pos('B1')), isTrue);
      expect(bloc.state.esAncla(pos('C6')), isTrue);
    },
  );
}
