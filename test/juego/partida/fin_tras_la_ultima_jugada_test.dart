import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/partida_bloc.dart';
import 'package:brilliant/juego/partida_event.dart';
import 'package:brilliant/juego/partida_state.dart';

import '../ayudantes.dart';

void main() {
  blocTest<PartidaBloc, PartidaState>(
    'PartidaBloc: al anotar la última jugada posible, la partida termina y ya no se tira',
    build: () => partidaBloc(tablero: soloCabeElSeisEnE5(), caras: [2, 6]),
    // Dado ancla 2: E5 está junto al 2 de E6, y el 6 completa ahí la corrida roja.
    act: (bloc) => bloc
      ..add(const DadosTirados())
      ..add(const DadoElegido(0))
      ..add(ValorColocado(pos('E5')))
      ..add(const DadosTirados()),
    skip: 3,
    expect: () => <PartidaState>[],
    verify: (bloc) {
      expect(bloc.state.tablero.celdaEn(pos('E5'))!.valor, 6);
      expect(bloc.state.terminada, isTrue);
      expect(bloc.state.casillasLlenas, 49);
      expect(bloc.state.dados, isNull);
    },
  );
}
