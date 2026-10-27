import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/modelo/tablero.dart';

import '../../../juego/ayudantes.dart';
import '../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaPartida: si la zona que rechaza el número está vacía, no dice "Ya tiene"', (
    tester,
  ) async {
    // Un tablero armado a mano: el Nivel 4 sin preparar, con solo un 4 en C2.
    // C1, justo arriba, es de la fila naranja "4-6", que sigue vacía. En una
    // partida normal no pasa, porque E1 es inicial; pero el mensaje no debe
    // quedar con un "Ya tiene:" sin nada.
    await abrirPartida(
      tester,
      mapa: nivel4,
      tablero: Tablero.desdeMapa(nivel4).conValor(pos('C2'), 4),
      caras: [4, 2],
    );
    await tirarYElegirAncla(tester, 0);

    await tocar(tester, casillaTocable('C1'));

    expect(find.text('Zona naranja — Solo del 4 al 6.'), findsOneWidget);
    expect(find.textContaining('Ya tiene'), findsNothing);
  });
}
