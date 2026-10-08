import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/partida_bloc.dart';
import 'package:brilliant/juego/partida_event.dart';
import 'package:brilliant/juego/partida_state.dart';

import '../ayudantes.dart';

void main() {
  blocTest<PartidaBloc, PartidaState>(
    'PartidaBloc: con los dos dados iguales, el ancla y el número a anotar son el mismo',
    build: () => partidaBloc(caras: [4, 4]),
    // C2 está junto al 4 de C1, y la zona azul acepta otro 4.
    act: (bloc) => bloc
      ..add(const DadosTirados())
      ..add(const DadoElegido(0))
      ..add(ValorColocado(pos('C2'))),
    skip: 1,
    expect: () => [
      isA<PartidaState>()
          .having((state) => state.valorAncla, 'valorAncla', 4)
          .having((state) => state.valorAColocar, 'valorAColocar', 4),
      isA<PartidaState>().having(
        (state) => state.tablero.celdaEn(pos('C2'))!.valor,
        'valor en C2',
        4,
      ),
    ],
  );
}
