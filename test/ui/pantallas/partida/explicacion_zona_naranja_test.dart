import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';

import '../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaPartida: la zona naranja vacía explica su rango, sin "Ya tiene"', (
    tester,
  ) async {
    // En el Nivel 4 hay un 4 en C2. Con el 4 de ancla se pone el 2, y C1, justo
    // arriba, es de la fila naranja "4-6", que todavía está vacía.
    await abrirPartida(tester, mapa: nivel4, caras: [4, 2]);
    await tirarYElegirAncla(tester, 0);
    expect(celdaEn(tester, 'C1').iluminacion, Iluminacion.bloqueada);

    await tocar(tester, casillaTocable('C1'));

    expect(find.text('Zona naranja — Solo del 4 al 6.'), findsOneWidget);
    expect(find.textContaining('Ya tiene'), findsNothing);
    expect(celdaEn(tester, 'C1').celda.valor, isNull);
  });
}
