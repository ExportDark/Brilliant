import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/partida_bloc.dart';
import 'package:brilliant/juego/partida_event.dart';

import '../ayudantes.dart';

void main() {
  test('PartidaBloc: el dado de la app saca caras del 1 al 6, y salen todas', () async {
    final caras = <int>{};

    // 100 tiradas de dos dados con el azar de verdad (sin `tirarDado`).
    for (var tirada = 0; tirada < 100; tirada++) {
      final bloc = PartidaBloc(tableroPartida1());
      bloc.add(const DadosTirados());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.dados, everyElement(inInclusiveRange(1, 6)));
      caras.addAll(bloc.state.dados!);
      await bloc.close();
    }

    // Que en 200 dados falte una cara es prácticamente imposible.
    expect(caras, {1, 2, 3, 4, 5, 6});
  });
}
