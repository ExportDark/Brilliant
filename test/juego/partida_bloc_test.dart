import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/partida_bloc.dart';
import 'package:brilliant/juego/partida_event.dart';
import 'package:brilliant/juego/partida_state.dart';

import 'ayudantes.dart';

// Los casos de la regla del ancla viven uno por archivo en `partida/`.

void main() {
  group('PartidaBloc — estado inicial', () {
    test('arranca en el turno 1, sin dados', () {
      final bloc = partidaBloc();

      expect(bloc.state.turno, 1);
      expect(bloc.state.dados, isNull);
      expect(bloc.state.valorAncla, isNull);
      expect(bloc.state.valorAColocar, isNull);
      expect(bloc.state.terminada, isFalse);
      expect(bloc.state.casillasLlenas, 6);
    });
  });

  group('PartidaBloc — tirar y elegir el ancla', () {
    blocTest<PartidaBloc, PartidaState>(
      'tirar saca los dos dados, sin ancla elegida',
      build: partidaBloc,
      act: (bloc) => bloc.add(const DadosTirados()),
      verify: (bloc) {
        expect(bloc.state.dados, [4, 3]);
        expect(bloc.state.dadoElegido, isNull);
      },
    );

    blocTest<PartidaBloc, PartidaState>(
      'no se puede volver a tirar sin colocar o pasar',
      build: partidaBloc,
      act: (bloc) => bloc
        ..add(const DadosTirados())
        ..add(const DadosTirados()),
      skip: 1,
      expect: () => <PartidaState>[],
    );

    blocTest<PartidaBloc, PartidaState>(
      'el dado elegido es el ancla y el otro es el que se anota',
      build: partidaBloc,
      act: (bloc) => bloc
        ..add(const DadosTirados())
        ..add(const DadoElegido(0)),
      verify: (bloc) {
        expect(bloc.state.valorAncla, 4);
        expect(bloc.state.valorAColocar, 3);
      },
    );

    blocTest<PartidaBloc, PartidaState>(
      'cambiar de ancla intercambia los dos números',
      build: partidaBloc,
      act: (bloc) => bloc
        ..add(const DadosTirados())
        ..add(const DadoElegido(0))
        ..add(const DadoElegido(1)),
      verify: (bloc) {
        expect(bloc.state.valorAncla, 3);
        expect(bloc.state.valorAColocar, 4);
      },
    );

    blocTest<PartidaBloc, PartidaState>(
      'las casillas con el número ancla son anclas',
      build: partidaBloc,
      act: (bloc) => bloc
        ..add(const DadosTirados())
        ..add(const DadoElegido(0)),
      verify: (bloc) {
        final anclas = bloc.state.tablero.celdas
            .map((celda) => celda.posicion)
            .where(bloc.state.esAncla);
        expect(anclas, [pos('C1')]);
      },
    );

    blocTest<PartidaBloc, PartidaState>(
      'no se puede anclar un dado antes de tirar',
      build: partidaBloc,
      act: (bloc) => bloc.add(const DadoElegido(0)),
      expect: () => <PartidaState>[],
    );

    blocTest<PartidaBloc, PartidaState>(
      'solo hay dos dados para anclar',
      build: partidaBloc,
      act: (bloc) => bloc
        ..add(const DadosTirados())
        ..add(const DadoElegido(2)),
      skip: 1,
      expect: () => <PartidaState>[],
    );
  });

  group('PartidaBloc — colocar', () {
    blocTest<PartidaBloc, PartidaState>(
      'junto al ancla, anota el otro dado y cierra el turno',
      build: partidaBloc,
      act: (bloc) => bloc
        ..add(const DadosTirados())
        ..add(const DadoElegido(0))
        ..add(ValorColocado(pos('B1'))),
      verify: (bloc) {
        expect(bloc.state.tablero.celdaEn(pos('B1'))!.valor, 3);
        expect(bloc.state.dados, isNull);
        expect(bloc.state.dadoElegido, isNull);
        expect(bloc.state.turno, 2);
      },
    );

    blocTest<PartidaBloc, PartidaState>(
      'sin ancla elegida no se coloca nada',
      build: partidaBloc,
      act: (bloc) => bloc
        ..add(const DadosTirados())
        ..add(ValorColocado(pos('B1'))),
      skip: 1,
      expect: () => <PartidaState>[],
    );

    blocTest<PartidaBloc, PartidaState>(
      'no se coloca lejos de las casillas con el número ancla',
      build: partidaBloc,
      act: (bloc) => bloc
        ..add(const DadosTirados())
        ..add(const DadoElegido(0))
        ..add(ValorColocado(pos('A2'))),
      skip: 2,
      expect: () => <PartidaState>[],
    );

    blocTest<PartidaBloc, PartidaState>(
      'no se coloca en una casilla ocupada',
      build: partidaBloc,
      act: (bloc) => bloc
        ..add(const DadosTirados())
        ..add(const DadoElegido(0))
        ..add(ValorColocado(pos('C1'))),
      skip: 2,
      expect: () => <PartidaState>[],
    );

    blocTest<PartidaBloc, PartidaState>(
      'no se coloca donde la regla de la zona no lo permite',
      build: partidaBloc,
      // La zona azul ya tiene un 4 en C1: el 3 no entra en C2.
      act: (bloc) => bloc
        ..add(const DadosTirados())
        ..add(const DadoElegido(0))
        ..add(ValorColocado(pos('C2'))),
      skip: 2,
      expect: () => <PartidaState>[],
      verify: (bloc) => expect(bloc.state.tablero.celdaEn(pos('C2'))!.valor, isNull),
    );
  });

  group('PartidaBloc — sin jugada y fin de partida', () {
    final soloCabeElSeis = soloCabeElSeisEnE5();

    blocTest<PartidaBloc, PartidaState>(
      'si ningún dado cabe, se puede pasar el turno',
      build: () => partidaBloc(tablero: soloCabeElSeis, caras: [2, 3]),
      act: (bloc) => bloc
        ..add(const DadosTirados())
        ..add(const TurnoPasado()),
      verify: (bloc) {
        expect(bloc.state.dados, isNull);
        expect(bloc.state.turno, 2);
        expect(bloc.state.terminada, isFalse);
      },
    );

    blocTest<PartidaBloc, PartidaState>(
      'con la tirada sin jugada, el estado lo avisa',
      build: () => partidaBloc(tablero: soloCabeElSeis, caras: [2, 3]),
      act: (bloc) => bloc.add(const DadosTirados()),
      verify: (bloc) => expect(bloc.state.sinJugada, isTrue),
    );

    blocTest<PartidaBloc, PartidaState>(
      'si algún dado cabe, no se puede pasar',
      build: () => partidaBloc(tablero: soloCabeElSeis, caras: [2, 6]),
      act: (bloc) => bloc
        ..add(const DadosTirados())
        ..add(const TurnoPasado()),
      skip: 1,
      expect: () => <PartidaState>[],
      verify: (bloc) => expect(bloc.state.sinJugada, isFalse),
    );

    blocTest<PartidaBloc, PartidaState>(
      'sin tirar no se puede pasar',
      build: partidaBloc,
      act: (bloc) => bloc.add(const TurnoPasado()),
      expect: () => <PartidaState>[],
    );

    blocTest<PartidaBloc, PartidaState>(
      'cuando ninguna casilla acepta nada, la partida termina y ya no se tira',
      // La zona roja #9 ya tiene 1 repetido: E5 no acepta ningún número.
      build: () => partidaBloc(tablero: llenoMenos('E5')),
      act: (bloc) => bloc.add(const DadosTirados()),
      expect: () => <PartidaState>[],
      verify: (bloc) {
        expect(bloc.state.terminada, isTrue);
        expect(bloc.state.casillasLlenas, 48);
      },
    );
  });
}
