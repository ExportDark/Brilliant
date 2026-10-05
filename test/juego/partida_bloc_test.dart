import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/partida_bloc.dart';
import 'package:brilliant/juego/partida_event.dart';
import 'package:brilliant/juego/partida_state.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/tablero.dart';

Posicion _pos(String notacion) => Posicion.desdeNotacion(notacion);

/// El tablero con los valores iniciales de la Partida 1 del manual.
final _inicial = Tablero.mapaOriginal().conValores({
  _pos('C1'): 4,
  _pos('F2'): 1,
  _pos('B4'): 2,
  _pos('E4'): 5,
  _pos('C6'): 3,
  _pos('E7'): 6,
});

/// Todo el tablero lleno menos [libre]. Las casillas sin valor en [valores]
/// llevan un 1; no se revisan las reglas al llenarlo.
Tablero _llenoMenos(String libre, {Map<String, int> valores = const {}}) {
  final base = Tablero.mapaOriginal();
  return base.conValores({
    for (final celda in base.celdas)
      if (celda.posicion != _pos(libre)) celda.posicion: valores[celda.posicion.notacion] ?? 1,
  });
}

/// Un dado que va sacando [caras] en orden, para que los tests sepan qué sale.
int Function() _dado(List<int> caras) {
  var siguiente = 0;
  return () => caras[siguiente++ % caras.length];
}

PartidaBloc _nuevoBloc({Tablero? tablero, List<int> caras = const [3, 5]}) =>
    PartidaBloc(tablero ?? _inicial, tirarDado: _dado(caras));

void main() {
  group('PartidaBloc — estado inicial', () {
    test('arranca en el turno 1, sin dados', () {
      final bloc = _nuevoBloc();

      expect(bloc.state.turno, 1);
      expect(bloc.state.dados, isNull);
      expect(bloc.state.valorElegido, isNull);
      expect(bloc.state.terminada, isFalse);
      expect(bloc.state.casillasLlenas, 6);
    });
  });

  group('PartidaBloc — tirar y anclar un dado', () {
    blocTest<PartidaBloc, PartidaState>(
      'tirar saca los dos dados, sin ninguno anclado',
      build: _nuevoBloc,
      act: (bloc) => bloc.add(const DadosTirados()),
      verify: (bloc) {
        expect(bloc.state.dados, [3, 5]);
        expect(bloc.state.dadoElegido, isNull);
      },
    );

    blocTest<PartidaBloc, PartidaState>(
      'no se puede volver a tirar sin colocar o pasar',
      build: _nuevoBloc,
      act: (bloc) => bloc
        ..add(const DadosTirados())
        ..add(const DadosTirados()),
      skip: 1,
      expect: () => <PartidaState>[],
    );

    blocTest<PartidaBloc, PartidaState>(
      'anclar un dado lo vuelve el número a anotar',
      build: _nuevoBloc,
      act: (bloc) => bloc
        ..add(const DadosTirados())
        ..add(const DadoElegido(1)),
      verify: (bloc) => expect(bloc.state.valorElegido, 5),
    );

    blocTest<PartidaBloc, PartidaState>(
      'el dado anclado se puede cambiar por el otro',
      build: _nuevoBloc,
      act: (bloc) => bloc
        ..add(const DadosTirados())
        ..add(const DadoElegido(1))
        ..add(const DadoElegido(0)),
      verify: (bloc) => expect(bloc.state.valorElegido, 3),
    );

    blocTest<PartidaBloc, PartidaState>(
      'no se puede anclar un dado antes de tirar',
      build: _nuevoBloc,
      act: (bloc) => bloc.add(const DadoElegido(0)),
      expect: () => <PartidaState>[],
    );

    blocTest<PartidaBloc, PartidaState>(
      'solo hay dos dados para anclar',
      build: _nuevoBloc,
      act: (bloc) => bloc
        ..add(const DadosTirados())
        ..add(const DadoElegido(2)),
      skip: 1,
      expect: () => <PartidaState>[],
    );
  });

  group('PartidaBloc — colocar', () {
    blocTest<PartidaBloc, PartidaState>(
      'una jugada válida anota el número y cierra el turno',
      build: _nuevoBloc,
      act: (bloc) => bloc
        ..add(const DadosTirados())
        ..add(const DadoElegido(0))
        ..add(ValorColocado(_pos('A2'))),
      verify: (bloc) {
        expect(bloc.state.tablero.celdaEn(_pos('A2'))!.valor, 3);
        expect(bloc.state.dados, isNull);
        expect(bloc.state.dadoElegido, isNull);
        expect(bloc.state.turno, 2);
      },
    );

    blocTest<PartidaBloc, PartidaState>(
      'sin un dado anclado no se coloca nada',
      build: _nuevoBloc,
      act: (bloc) => bloc
        ..add(const DadosTirados())
        ..add(ValorColocado(_pos('A2'))),
      skip: 1,
      expect: () => <PartidaState>[],
    );

    blocTest<PartidaBloc, PartidaState>(
      'no se coloca en una casilla ocupada',
      build: _nuevoBloc,
      act: (bloc) => bloc
        ..add(const DadosTirados())
        ..add(const DadoElegido(0))
        ..add(ValorColocado(_pos('C1'))),
      skip: 2,
      expect: () => <PartidaState>[],
    );

    blocTest<PartidaBloc, PartidaState>(
      'no se coloca donde la regla de la zona no lo permite',
      build: _nuevoBloc,
      // La zona azul ya tiene un 4 en C1: el 3 no entra en C2.
      act: (bloc) => bloc
        ..add(const DadosTirados())
        ..add(const DadoElegido(0))
        ..add(ValorColocado(_pos('C2'))),
      skip: 2,
      expect: () => <PartidaState>[],
      verify: (bloc) => expect(bloc.state.tablero.celdaEn(_pos('C2'))!.valor, isNull),
    );
  });

  group('PartidaBloc — sin jugada y fin de partida', () {
    // E5 es la última casilla libre y su zona roja ya tiene del 1 al 5: solo el 6 cabe.
    final soloCabeElSeis = _llenoMenos(
      'E5',
      valores: {'F5': 1, 'E6': 2, 'D6': 3, 'D7': 4, 'E7': 5},
    );

    blocTest<PartidaBloc, PartidaState>(
      'si ningún dado cabe, se puede pasar el turno',
      build: () => _nuevoBloc(tablero: soloCabeElSeis, caras: [2, 3]),
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
      build: () => _nuevoBloc(tablero: soloCabeElSeis, caras: [2, 3]),
      act: (bloc) => bloc.add(const DadosTirados()),
      verify: (bloc) => expect(bloc.state.sinJugada, isTrue),
    );

    blocTest<PartidaBloc, PartidaState>(
      'si algún dado cabe, no se puede pasar',
      build: () => _nuevoBloc(tablero: soloCabeElSeis, caras: [2, 6]),
      act: (bloc) => bloc
        ..add(const DadosTirados())
        ..add(const TurnoPasado()),
      skip: 1,
      expect: () => <PartidaState>[],
      verify: (bloc) => expect(bloc.state.sinJugada, isFalse),
    );

    blocTest<PartidaBloc, PartidaState>(
      'sin tirar no se puede pasar',
      build: _nuevoBloc,
      act: (bloc) => bloc.add(const TurnoPasado()),
      expect: () => <PartidaState>[],
    );

    blocTest<PartidaBloc, PartidaState>(
      'cuando ninguna casilla acepta nada, la partida termina y ya no se tira',
      // La zona roja #9 ya tiene 1 repetido: E5 no acepta ningún número.
      build: () => _nuevoBloc(tablero: _llenoMenos('E5')),
      act: (bloc) => bloc.add(const DadosTirados()),
      expect: () => <PartidaState>[],
      verify: (bloc) {
        expect(bloc.state.terminada, isTrue);
        expect(bloc.state.casillasLlenas, 48);
      },
    );
  });
}
