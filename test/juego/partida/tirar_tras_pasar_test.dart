import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/partida_bloc.dart';
import 'package:brilliant/juego/partida_event.dart';
import 'package:brilliant/juego/partida_state.dart';

import '../ayudantes.dart';

void main() {
  blocTest<PartidaBloc, PartidaState>(
    'PartidaBloc: después de pasar el turno se vuelve a tirar',
    // Primera tirada 2 y 3: no hay jugada. Segunda tirada 2 y 6: sí la hay.
    build: () => partidaBloc(tablero: soloCabeElSeisEnE5(), caras: [2, 3, 2, 6]),
    act: (bloc) => bloc
      ..add(const DadosTirados())
      ..add(const TurnoPasado())
      ..add(const DadosTirados()),
    verify: (bloc) {
      expect(bloc.state.dados, [2, 6]);
      expect(bloc.state.turno, 2);
      expect(bloc.state.sinJugada, isFalse);
    },
  );
}
