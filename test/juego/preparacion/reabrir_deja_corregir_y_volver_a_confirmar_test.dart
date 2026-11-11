import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/preparacion_bloc.dart';
import 'package:brilliant/juego/preparacion_event.dart';
import 'package:brilliant/juego/preparacion_state.dart';
import 'package:brilliant/modelo/mapa.dart';

import '../ayudantes.dart';

void main() {
  blocTest<PreparacionBloc, PreparacionState>(
    'PreparacionBloc: reabrir una preparación confirmada conserva los números, deja '
    'cambiarlos y volver a confirmar',
    build: () => PreparacionBloc(nivel1.casillasIniciales.map(pos).toList()),
    act: (bloc) => bloc
      ..add(ValorAsignado(pos('C1'), 1))
      ..add(ValorAsignado(pos('F2'), 2))
      ..add(ValorAsignado(pos('B4'), 3))
      ..add(ValorAsignado(pos('E4'), 4))
      ..add(ValorAsignado(pos('C6'), 5))
      ..add(ValorAsignado(pos('E7'), 6))
      ..add(const PreparacionConfirmada())
      ..add(const PreparacionReabierta())
      // Se corrige: se cambian el 1 y el 6 de lugar.
      ..add(ValorQuitado(pos('C1')))
      ..add(ValorQuitado(pos('E7')))
      ..add(ValorAsignado(pos('C1'), 6))
      ..add(ValorAsignado(pos('E7'), 1))
      ..add(const PreparacionConfirmada()),
    verify: (bloc) {
      expect(bloc.state.confirmada, isTrue);
      expect(bloc.state.valorDe(pos('C1')), 6);
      expect(bloc.state.valorDe(pos('E7')), 1);
      expect(bloc.state.valorDe(pos('B4')), 3);
    },
  );

  blocTest<PreparacionBloc, PreparacionState>(
    'PreparacionBloc: reabrir una preparación que no estaba confirmada no hace nada',
    build: () => PreparacionBloc(nivel1.casillasIniciales.map(pos).toList()),
    act: (bloc) => bloc.add(const PreparacionReabierta()),
    expect: () => <PreparacionState>[],
  );
}
