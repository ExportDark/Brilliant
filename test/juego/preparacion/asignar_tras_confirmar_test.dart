import 'package:bloc_test/bloc_test.dart';
import 'package:brilliant/juego/preparacion_bloc.dart';
import 'package:brilliant/juego/preparacion_event.dart';
import 'package:brilliant/juego/preparacion_state.dart';
import 'package:brilliant/modelo/mapa.dart';

import '../ayudantes.dart';

void main() {
  blocTest<PreparacionBloc, PreparacionState>(
    'PreparacionBloc: una vez confirmada, ya no acepta ni siquiera reasignar el mismo número',
    build: () => PreparacionBloc(nivel1.casillasIniciales.map(pos).toList()),
    act: (bloc) {
      for (final (indice, casilla) in nivel1.casillasIniciales.indexed) {
        bloc.add(ValorAsignado(pos(casilla), indice + 1));
      }
      bloc.add(const PreparacionConfirmada());
      // Antes de confirmar, volver a poner el 1 en C1 emitiría un estado nuevo.
      bloc.add(ValorAsignado(pos('C1'), 1));
    },
    skip: 7,
    expect: () => <PreparacionState>[],
  );
}
