import 'package:flutter_test/flutter_test.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';
import 'ayudantes_tiempos.dart';

void main() {
  testWidgets('La cuenta regresiva de la ronda se queda en "0 s", nunca negativa, hasta que el '
      'servidor pasa a la ronda siguiente', (tester) async {
    final (:salas, :pasar) = await abrirConReloj(
      tester,
      vistaDePrueba(estado: 'jugando', ronda: 3, dados: const [1, 3], segundosRestantes: 2),
    );

    await pasar(5);
    expect(rondaYTiempo(tester), 'Ronda 3 · 0 s');

    salas.vista = vistaDePrueba(
      version: 7,
      estado: 'jugando',
      ronda: 4,
      dados: const [2, 2],
      segundosRestantes: 60,
      accion: 'paso',
    );
    await pasar(1);
    expect(rondaYTiempo(tester), 'Ronda 4 · 60 s');
  });
}
