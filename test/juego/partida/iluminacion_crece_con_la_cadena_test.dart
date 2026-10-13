import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/partida_bloc.dart';
import 'package:brilliant/juego/partida_event.dart';
import 'package:brilliant/juego/partida_state.dart';
import 'package:brilliant/juego/validacion_jugada.dart';

import '../ayudantes.dart';

void main() {
  blocTest<PartidaBloc, PartidaState>(
    'PartidaBloc: al anotar un número, sus vecinas se suman a las casillas que se iluminan',
    // Turno 1: salen 4 y 4, el 4 va a C2 (junto al 4 de C1; la zona azul lo acepta).
    // Turno 2: salen 4 y 3, dado ancla 4: ahora hay dos 4, en C1 y en C2.
    build: () => partidaBloc(caras: [4, 4, 4, 3]),
    act: (bloc) => bloc
      ..add(const DadosTirados())
      ..add(const DadoElegido(0))
      ..add(ValorColocado(pos('C2')))
      ..add(const DadosTirados())
      ..add(const DadoElegido(0)),
    verify: (bloc) {
      final estado = bloc.state;
      // Junto a C1: B1 y D1. Junto a C2: B2 y C3. D2 toca a C2, pero la zona
      // azul ya tiene dos 4 y no acepta el 3.
      expect(
        casillasDonde(estado.tablero, (p) => estado.evaluar(p) is JugadaValida),
        {'B1', 'D1', 'B2', 'C3'},
      );
      expect(
        casillasDonde(estado.tablero, (p) => estado.evaluar(p) is ReglaRota),
        {'D2'},
      );
    },
  );
}
