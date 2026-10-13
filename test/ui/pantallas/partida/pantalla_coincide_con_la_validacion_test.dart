import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';

import '../../../juego/ayudantes.dart';
import '../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaPartida: ilumina exactamente las casillas que la validación acepta y rechaza', (
    tester,
  ) async {
    await abrirPartida(tester);

    await tirarYElegirAncla(tester, 0);

    // Lo que dice la validación para dado ancla 4 y valor 3, sin pasar por la pantalla.
    final tablero = tableroPartida1();
    expect(
      celdasDibujadasDonde(tester, (CeldaWidget celda) => celda.iluminacion == Iluminacion.posible),
      posiblesEn(tablero, ancla: 4, valor: 3),
    );
    expect(
      celdasDibujadasDonde(tester, (CeldaWidget celda) => celda.iluminacion == Iluminacion.bloqueada),
      bloqueadasEn(tablero, ancla: 4, valor: 3),
    );
  });
}
