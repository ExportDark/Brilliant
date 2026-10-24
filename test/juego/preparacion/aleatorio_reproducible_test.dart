import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/preparacion_bloc.dart';
import 'package:brilliant/juego/preparacion_event.dart';
import 'package:brilliant/modelo/mapa.dart';

import '../ayudantes.dart';

Future<PreparacionBloc> _repartidoConSemilla(int semilla) async {
  final bloc = PreparacionBloc(nivel1.casillasIniciales.map(pos).toList(), azar: Random(semilla));
  addTearDown(bloc.close);
  bloc.add(const RepartoAleatorio());
  await Future<void>.delayed(Duration.zero);
  return bloc;
}

void main() {
  test('PreparacionBloc: con la misma semilla, Aleatorio reparte exactamente igual', () async {
    final primero = await _repartidoConSemilla(42);
    final segundo = await _repartidoConSemilla(42);

    expect(primero.state.completa, isTrue);
    expect(segundo.state.valores, primero.state.valores);
  });
}
