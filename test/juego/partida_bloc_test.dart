import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/fase_partida.dart';
import 'package:brilliant/juego/partida_bloc.dart';
import 'package:brilliant/juego/partida_event.dart';
import 'package:brilliant/juego/partida_state.dart';
import 'package:brilliant/modelo/posicion.dart';

/// Las 6 casillas iniciales del mapa, con una permutación válida del 1 al 6.
const _repartoCompleto = {
  'C1': 1,
  'F2': 2,
  'B4': 3,
  'E4': 4,
  'C6': 5,
  'E7': 6,
};

Posicion _pos(String notacion) => Posicion.desdeNotacion(notacion);

/// Deja la preparación terminada salvo las últimas [faltantes] casillas.
void _repartir(PartidaBloc bloc, {int faltantes = 0}) {
  final entradas = _repartoCompleto.entries.toList();
  for (final entrada in entradas.take(entradas.length - faltantes)) {
    bloc.add(ValorInicialAsignado(_pos(entrada.key), entrada.value));
  }
}

void main() {
  group('PartidaBloc — estado inicial', () {
    test('arranca en fase de preparación con las 6 casillas iniciales vacías', () {
      final bloc = PartidaBloc();

      expect(bloc.state.fase, FasePartida.preparando);
      expect(bloc.state.casillasIniciales, hasLength(6));
      expect(bloc.state.casillasIniciales.every((c) => c.estaVacia), isTrue);
      expect(bloc.state.preparacionCompleta, isFalse);
      expect(bloc.state.valoresDisponibles, valoresPosibles);
    });

    test('las casillas iniciales son las 6 que marca el manual', () {
      final bloc = PartidaBloc();

      final notaciones =
          bloc.state.casillasIniciales.map((c) => c.posicion.notacion).toSet();

      expect(notaciones, {'C1', 'F2', 'B4', 'E4', 'C6', 'E7'});
    });
  });

  group('PartidaBloc — repartir los valores iniciales', () {
    blocTest<PartidaBloc, PartidaState>(
      'anota el valor en la casilla inicial y lo saca de los disponibles',
      build: PartidaBloc.new,
      act: (bloc) => bloc.add(ValorInicialAsignado(_pos('C1'), 4)),
      verify: (bloc) {
        expect(bloc.state.tablero.celdaEn(_pos('C1'))!.valor, 4);
        expect(bloc.state.valoresDisponibles, {1, 2, 3, 5, 6});
      },
    );

    blocTest<PartidaBloc, PartidaState>(
      'rechaza anotar en una casilla que no es inicial',
      build: PartidaBloc.new,
      act: (bloc) => bloc.add(ValorInicialAsignado(_pos('A1'), 4)),
      expect: () => <PartidaState>[],
    );

    blocTest<PartidaBloc, PartidaState>(
      'rechaza un valor ya usado en otra casilla inicial',
      build: PartidaBloc.new,
      act: (bloc) => bloc
        ..add(ValorInicialAsignado(_pos('C1'), 4))
        ..add(ValorInicialAsignado(_pos('F2'), 4)),
      verify: (bloc) {
        expect(bloc.state.tablero.celdaEn(_pos('F2'))!.estaVacia, isTrue);
        expect(bloc.state.valoresDisponibles, {1, 2, 3, 5, 6});
      },
    );

    blocTest<PartidaBloc, PartidaState>(
      'rechaza valores fuera del rango 1-6',
      build: PartidaBloc.new,
      act: (bloc) => bloc
        ..add(ValorInicialAsignado(_pos('C1'), 0))
        ..add(ValorInicialAsignado(_pos('C1'), 7)),
      expect: () => <PartidaState>[],
    );

    blocTest<PartidaBloc, PartidaState>(
      'permite reasignar otro valor a la misma casilla',
      build: PartidaBloc.new,
      act: (bloc) => bloc
        ..add(ValorInicialAsignado(_pos('C1'), 4))
        ..add(ValorInicialAsignado(_pos('C1'), 2)),
      verify: (bloc) {
        expect(bloc.state.tablero.celdaEn(_pos('C1'))!.valor, 2);
        expect(bloc.state.valoresDisponibles, {1, 3, 4, 5, 6});
      },
    );

    blocTest<PartidaBloc, PartidaState>(
      'quitar un valor lo devuelve a los disponibles',
      build: PartidaBloc.new,
      act: (bloc) => bloc
        ..add(ValorInicialAsignado(_pos('C1'), 4))
        ..add(ValorInicialQuitado(_pos('C1'))),
      verify: (bloc) {
        expect(bloc.state.tablero.celdaEn(_pos('C1'))!.estaVacia, isTrue);
        expect(bloc.state.valoresDisponibles, valoresPosibles);
      },
    );

    blocTest<PartidaBloc, PartidaState>(
      'quitar una casilla que ya estaba vacía no hace nada',
      build: PartidaBloc.new,
      act: (bloc) => bloc.add(ValorInicialQuitado(_pos('C1'))),
      expect: () => <PartidaState>[],
    );
  });

  group('PartidaBloc — el gate de la preparación', () {
    blocTest<PartidaBloc, PartidaState>(
      'no avanza a jugar sin haber repartido ningún valor',
      build: PartidaBloc.new,
      act: (bloc) => bloc.add(const PreparacionConfirmada()),
      expect: () => <PartidaState>[],
      verify: (bloc) => expect(bloc.state.fase, FasePartida.preparando),
    );

    blocTest<PartidaBloc, PartidaState>(
      'no avanza a jugar si falta una sola casilla inicial',
      build: PartidaBloc.new,
      act: (bloc) {
        _repartir(bloc, faltantes: 1);
        bloc.add(const PreparacionConfirmada());
      },
      verify: (bloc) {
        expect(bloc.state.preparacionCompleta, isFalse);
        expect(bloc.state.fase, FasePartida.preparando);
      },
    );

    blocTest<PartidaBloc, PartidaState>(
      'avanza a jugar con las 6 casillas iniciales repartidas',
      build: PartidaBloc.new,
      act: (bloc) {
        _repartir(bloc);
        bloc.add(const PreparacionConfirmada());
      },
      verify: (bloc) {
        expect(bloc.state.preparacionCompleta, isTrue);
        expect(bloc.state.fase, FasePartida.jugando);
        expect(bloc.state.valoresDisponibles, isEmpty);
      },
    );

    blocTest<PartidaBloc, PartidaState>(
      'ya en fase de juego, ignora cambios sobre las casillas iniciales',
      build: PartidaBloc.new,
      act: (bloc) {
        _repartir(bloc);
        bloc.add(const PreparacionConfirmada());
        bloc.add(ValorInicialQuitado(_pos('C1')));
      },
      verify: (bloc) {
        expect(bloc.state.fase, FasePartida.jugando);
        expect(bloc.state.tablero.celdaEn(_pos('C1'))!.valor, 1);
      },
    );
  });

  group('PartidaBloc — reiniciar', () {
    blocTest<PartidaBloc, PartidaState>(
      'PartidaIniciada vuelve a dejar el tablero vacío en preparación',
      build: PartidaBloc.new,
      act: (bloc) {
        _repartir(bloc);
        bloc.add(const PreparacionConfirmada());
        bloc.add(const PartidaIniciada());
      },
      verify: (bloc) {
        expect(bloc.state.fase, FasePartida.preparando);
        expect(bloc.state.valoresDisponibles, valoresPosibles);
        expect(bloc.state.tablero.celdas.every((c) => c.estaVacia), isTrue);
      },
    );
  });
}
