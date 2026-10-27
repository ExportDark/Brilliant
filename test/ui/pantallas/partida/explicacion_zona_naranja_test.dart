import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';

import '../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaPartida: un número fuera del rango de la zona naranja explica el rango', (
    tester,
  ) async {
    // En el Nivel 4, la inicial E1 tiene un 4. Con el 4 de ancla se pone el 2,
    // y D1, a su lado, es de la fila naranja "4-6".
    await abrirPartida(tester, mapa: nivel4, caras: [4, 2]);
    await tirarYElegirAncla(tester, 0);
    expect(celdaEn(tester, 'D1').iluminacion, Iluminacion.bloqueada);

    await tocar(tester, casillaTocable('D1'));

    expect(find.text('Zona naranja — Solo del 4 al 6. Ya tiene: 4'), findsOneWidget);
    expect(celdaEn(tester, 'D1').celda.valor, isNull);
  });
}
