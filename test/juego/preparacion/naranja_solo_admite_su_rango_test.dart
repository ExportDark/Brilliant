import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/preparacion_bloc.dart';
import 'package:brilliant/juego/preparacion_event.dart';
import 'package:brilliant/juego/preparacion_state.dart';
import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/modelo/tablero.dart';

import '../ayudantes.dart';

PreparacionBloc _preparacionDelNivel4() => PreparacionBloc(
      nivel4.casillasIniciales.map(pos).toList(),
      admite: Tablero.desdeMapa(nivel4).aceptaComoInicial,
    );

void main() {
  blocTest<PreparacionBloc, PreparacionState>(
    'PreparacionBloc: en el Nivel 4, la inicial de la fila "4-6" no acepta un 2',
    build: _preparacionDelNivel4,
    act: (bloc) => bloc.add(ValorAsignado(pos('E1'), 2)),
    expect: () => <PreparacionState>[],
  );

  blocTest<PreparacionBloc, PreparacionState>(
    'PreparacionBloc: en el Nivel 4, la inicial de la fila "4-6" acepta un 5, y la de la "1-3" '
    'un 2',
    build: _preparacionDelNivel4,
    act: (bloc) => bloc
      ..add(ValorAsignado(pos('E1'), 5))
      ..add(ValorAsignado(pos('B7'), 2)),
    verify: (bloc) {
      expect(bloc.state.valorDe(pos('E1')), 5);
      expect(bloc.state.valorDe(pos('B7')), 2);
    },
  );
}
