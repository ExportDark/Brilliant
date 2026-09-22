import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/preparacion_bloc.dart';
import 'package:brilliant/juego/preparacion_event.dart';
import 'package:brilliant/juego/preparacion_state.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/tablero.dart';

Posicion _pos(String notacion) => Posicion.desdeNotacion(notacion);

/// Las casillas iniciales del mapa, que es lo que la pantalla le pasaría al bloc.
final _casillas = casillasIniciales.map(_pos).toList();

/// Un reparto válido: un número distinto en cada casilla.
final _repartoCompleto = {
  for (final (indice, casilla) in _casillas.indexed) casilla: indice + 1,
};

PreparacionBloc _nuevoBloc() => PreparacionBloc(_casillas);

/// Reparte todas las casillas salvo las últimas [faltantes].
void _repartir(PreparacionBloc bloc, {int faltantes = 0}) {
  final entradas = _repartoCompleto.entries.toList();
  for (final entrada in entradas.take(entradas.length - faltantes)) {
    bloc.add(ValorAsignado(entrada.key, entrada.value));
  }
}

void main() {
  group('PreparacionBloc — estado inicial', () {
    test('arranca sin ningún valor repartido', () {
      final bloc = _nuevoBloc();

      expect(bloc.state.casillas, hasLength(6));
      expect(bloc.state.valores, isEmpty);
      expect(bloc.state.disponibles, valoresPosibles);
      expect(bloc.state.completa, isFalse);
      expect(bloc.state.confirmada, isFalse);
    });

    test('recibe las casillas que se le pasan, sin deducirlas de un tablero', () {
      final casillas = [_pos('A1'), _pos('B2')];

      final bloc = PreparacionBloc(casillas);

      expect(bloc.state.casillas, casillas);
      expect(bloc.state.completa, isFalse);
    });
  });

  group('PreparacionBloc — repartir valores', () {
    blocTest<PreparacionBloc, PreparacionState>(
      'anota el valor y lo saca de los disponibles',
      build: _nuevoBloc,
      act: (bloc) => bloc.add(ValorAsignado(_pos('C1'), 4)),
      verify: (bloc) {
        expect(bloc.state.valorDe(_pos('C1')), 4);
        expect(bloc.state.disponibles, {1, 2, 3, 5, 6});
      },
    );

    blocTest<PreparacionBloc, PreparacionState>(
      'rechaza un número ya usado en otra casilla',
      build: _nuevoBloc,
      act: (bloc) => bloc
        ..add(ValorAsignado(_pos('C1'), 4))
        ..add(ValorAsignado(_pos('F2'), 4)),
      verify: (bloc) {
        expect(bloc.state.valorDe(_pos('F2')), isNull);
        expect(bloc.state.valores, hasLength(1));
      },
    );

    blocTest<PreparacionBloc, PreparacionState>(
      'rechaza números fuera del 1 al 6',
      build: _nuevoBloc,
      act: (bloc) => bloc
        ..add(ValorAsignado(_pos('C1'), 0))
        ..add(ValorAsignado(_pos('C1'), 7)),
      expect: () => <PreparacionState>[],
    );

    blocTest<PreparacionBloc, PreparacionState>(
      'rechaza casillas que no son de las iniciales',
      build: _nuevoBloc,
      act: (bloc) => bloc.add(ValorAsignado(_pos('A1'), 3)),
      expect: () => <PreparacionState>[],
    );

    blocTest<PreparacionBloc, PreparacionState>(
      'permite cambiar el número de una casilla ya asignada',
      build: _nuevoBloc,
      act: (bloc) => bloc
        ..add(ValorAsignado(_pos('C1'), 4))
        ..add(ValorAsignado(_pos('C1'), 2)),
      verify: (bloc) {
        expect(bloc.state.valorDe(_pos('C1')), 2);
        expect(bloc.state.disponibles, {1, 3, 4, 5, 6});
      },
    );

    blocTest<PreparacionBloc, PreparacionState>(
      'quitar un valor lo devuelve a los disponibles',
      build: _nuevoBloc,
      act: (bloc) => bloc
        ..add(ValorAsignado(_pos('C1'), 4))
        ..add(ValorQuitado(_pos('C1'))),
      verify: (bloc) {
        expect(bloc.state.valorDe(_pos('C1')), isNull);
        expect(bloc.state.disponibles, valoresPosibles);
      },
    );

    blocTest<PreparacionBloc, PreparacionState>(
      'quitar una casilla vacía no hace nada',
      build: _nuevoBloc,
      act: (bloc) => bloc.add(ValorQuitado(_pos('C1'))),
      expect: () => <PreparacionState>[],
    );
  });

  group('PreparacionBloc — no se puede empezar sin los 6 valores', () {
    blocTest<PreparacionBloc, PreparacionState>(
      'no confirma si no se repartió ningún valor',
      build: _nuevoBloc,
      act: (bloc) => bloc.add(const PreparacionConfirmada()),
      expect: () => <PreparacionState>[],
      verify: (bloc) => expect(bloc.state.confirmada, isFalse),
    );

    blocTest<PreparacionBloc, PreparacionState>(
      'no confirma si falta una sola casilla',
      build: _nuevoBloc,
      act: (bloc) {
        _repartir(bloc, faltantes: 1);
        bloc.add(const PreparacionConfirmada());
      },
      verify: (bloc) {
        expect(bloc.state.completa, isFalse);
        expect(bloc.state.confirmada, isFalse);
      },
    );

    blocTest<PreparacionBloc, PreparacionState>(
      'confirma con las 6 casillas llenas',
      build: _nuevoBloc,
      act: (bloc) {
        _repartir(bloc);
        bloc.add(const PreparacionConfirmada());
      },
      verify: (bloc) {
        expect(bloc.state.completa, isTrue);
        expect(bloc.state.confirmada, isTrue);
        expect(bloc.state.disponibles, isEmpty);
      },
    );

    blocTest<PreparacionBloc, PreparacionState>(
      'lo repartido son 6 números distintos del 1 al 6',
      build: _nuevoBloc,
      act: _repartir,
      verify: (bloc) {
        expect(bloc.state.valores.values.toSet(), valoresPosibles);
        expect(bloc.state.valores.keys.toSet(), _casillas.toSet());
      },
    );

    blocTest<PreparacionBloc, PreparacionState>(
      'una vez confirmada, ya no acepta cambios',
      build: _nuevoBloc,
      act: (bloc) {
        _repartir(bloc);
        bloc.add(const PreparacionConfirmada());
        bloc.add(ValorQuitado(_casillas.first));
      },
      verify: (bloc) {
        expect(bloc.state.confirmada, isTrue);
        expect(bloc.state.valores, hasLength(6));
      },
    );
  });

  group('PreparacionBloc — reiniciar', () {
    blocTest<PreparacionBloc, PreparacionState>(
      'borra lo repartido y vuelve a empezar',
      build: _nuevoBloc,
      act: (bloc) {
        _repartir(bloc);
        bloc.add(const PreparacionConfirmada());
        bloc.add(const PreparacionReiniciada());
      },
      verify: (bloc) {
        expect(bloc.state.valores, isEmpty);
        expect(bloc.state.confirmada, isFalse);
        expect(bloc.state.disponibles, valoresPosibles);
      },
    );
  });
}
