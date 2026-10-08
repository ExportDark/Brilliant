import 'package:bloc_test/bloc_test.dart';
import 'package:brilliant/juego/partida_bloc.dart';
import 'package:brilliant/juego/partida_event.dart';
import 'package:brilliant/juego/partida_state.dart';
import 'package:brilliant/modelo/posicion.dart';

import '../ayudantes.dart';

void main() {
  blocTest<PartidaBloc, PartidaState>(
    'PartidaBloc: una posición fuera del tablero se ignora sin errores',
    build: partidaBloc,
    act: (bloc) => bloc
      ..add(const DadosTirados())
      ..add(const DadoElegido(0))
      ..add(const ValorColocado(Posicion(fila: 9, columna: 9))),
    skip: 2,
    expect: () => <PartidaState>[],
    errors: () => <Object>[],
  );
}
