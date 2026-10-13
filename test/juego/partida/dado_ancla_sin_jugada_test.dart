import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/partida_bloc.dart';
import 'package:brilliant/juego/partida_event.dart';
import 'package:brilliant/juego/partida_state.dart';
import 'package:brilliant/juego/validacion_jugada.dart';

import '../ayudantes.dart';

Set<String> _posibles(PartidaState estado) =>
    casillasDonde(estado.tablero, (posicion) => estado.evaluar(posicion) is JugadaValida);

void main() {
  blocTest<PartidaBloc, PartidaState>(
    'PartidaBloc: elegir un dado ancla sin jugada no ilumina nada, y el otro dado sí',
    // Solo E5 está libre y salen 6 y 2. No hay ningún 6 en el tablero, pero
    // E5 está junto al 2 de E6, y su zona roja acepta el 6.
    build: () => partidaBloc(tablero: soloCabeElSeisEnE5(), caras: [6, 2]),
    act: (bloc) => bloc
      ..add(const DadosTirados())
      ..add(const DadoElegido(0))
      ..add(const DadoElegido(1)),
    skip: 1,
    expect: () => [
      isA<PartidaState>()
          .having((estado) => estado.valorAncla, 'dado ancla', 6)
          .having(_posibles, 'casillas posibles', isEmpty)
          .having((estado) => estado.sinJugada, 'sinJugada', isFalse),
      isA<PartidaState>()
          .having((estado) => estado.valorAncla, 'dado ancla', 2)
          .having(_posibles, 'casillas posibles', {'E5'}),
    ],
  );
}
