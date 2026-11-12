import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import 'ayudantes_tiempos.dart';

void main() {
  testWidgets('Al terminar la partida la app deja de preguntarle al servidor', (tester) async {
    final (:salas, :pasar) = await abrirConReloj(tester, partidaEnJuego());
    await pasar(2);
    expect(salas.preguntas, greaterThanOrEqualTo(2));

    salas.vista = vistaDePrueba(
      version: 20,
      estado: 'terminada',
      resultado: {'motivo': 'tablero_lleno', 'ganadores': ['ana'], 'ranking': []},
    );
    await pasar(1);
    final alTerminar = salas.preguntas;

    await pasar(5);

    expect(salas.preguntas, alTerminar);
  });

  testWidgets('Si el servidor tarda en contestar, las preguntas no se amontonan', (tester) async {
    final (:salas, :pasar) = await abrirConReloj(tester, partidaEnJuego());
    final antes = salas.preguntas;
    final respuesta = Completer<void>();
    salas.esperaAntesDeContestar = respuesta.future;

    await pasar(5);
    // Una sola pregunta en camino, aunque pasaron 5 segundos.
    expect(salas.preguntas - antes, 1);

    respuesta.complete();
    salas.esperaAntesDeContestar = null;
    await pasar(1);
    expect(salas.preguntas - antes, lessThanOrEqualTo(3));
  });
}
