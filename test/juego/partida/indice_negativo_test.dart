import 'package:bloc_test/bloc_test.dart';
import 'package:brilliant/juego/partida_bloc.dart';
import 'package:brilliant/juego/partida_event.dart';
import 'package:brilliant/juego/partida_state.dart';

import '../ayudantes.dart';

void main() {
  blocTest<PartidaBloc, PartidaState>(
    'PartidaBloc: un índice de dado negativo se ignora',
    build: partidaBloc,
    act: (bloc) => bloc
      ..add(const DadosTirados())
      ..add(const DadoElegido(-1)),
    skip: 1,
    expect: () => <PartidaState>[],
    errors: () => <Object>[],
  );
}
