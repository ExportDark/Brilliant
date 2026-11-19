import 'package:brilliant/multijugador/sala_bloc.dart';
import 'package:brilliant/multijugador/sala_event.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudantes_salas.dart';

/// La jugada (y pasar) lleva la ronda que el jugador veía al tocar, no la que tenga la sala
/// cuando el bloc la manda: si antes entra una pregunta con la ronda siguiente, la jugada
/// vieja no puede salir como si fuera de la nueva.
void main() {
  late SalasFalsas salas;
  late SalaBloc bloc;

  setUp(() {
    salas = SalasFalsas();
    bloc = SalaBloc(salas, intervalo: null);
  });
  tearDown(() => bloc.close());

  Future<void> enLaRonda1() async {
    salas.vista = partidaEnJuego();
    bloc.add(const SalaCreada());
    await pumpEventQueue();
  }

  /// La ronda 2, como la contestaría el servidor a la próxima pregunta.
  void llegaLaRonda2() => salas.vista = vistaDePrueba(
    version: 20,
    estado: 'jugando',
    ronda: 2,
    dados: const [2, 5],
    segundosRestantes: 60,
  );

  test('Una jugada tocada en la ronda 1 sale como de la ronda 1, aunque antes llegue la 2', () async {
    await enLaRonda1();
    llegaLaRonda2();

    bloc
      ..add(const Preguntar())
      ..add(const JugadaEnviada(ronda: 1, dadoAncla: 1, casilla: 'D1'));
    await pumpEventQueue();

    expect(salas.llamadas, contains('jugar 1 1 D1'));
    expect(salas.llamadas, isNot(contains('jugar 2 1 D1')));
  });

  test(
    'Pasar en la ronda 1 sale como de la ronda 1, aunque antes llegue la 2',
    () async {
      await enLaRonda1();
      llegaLaRonda2();

      bloc
        ..add(const Preguntar())
        ..add(const RondaPasada(ronda: 1));
      await pumpEventQueue();

      expect(salas.llamadas, contains('pasar 1'));
      expect(salas.llamadas, isNot(contains('pasar 2')));
    },
  );
}
