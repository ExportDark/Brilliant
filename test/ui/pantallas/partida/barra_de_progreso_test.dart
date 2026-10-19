import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../ayudantes_pantallas.dart';

double _progreso(WidgetTester tester) =>
    tester.widget<LinearProgressIndicator>(find.byKey(const ValueKey('progreso'))).value!;

void main() {
  testWidgets('PantallaPartida: la barra de progreso cuenta las casillas llenas', (tester) async {
    await abrirPartida(tester);

    // Al empezar, solo las 6 iniciales.
    expect(find.text('6 de 49 casillas'), findsOneWidget);
    expect(_progreso(tester), closeTo(6 / 49, 1e-9));

    await tirarYElegirAncla(tester, 0);
    await tocar(tester, casillaTocable('B1'));

    expect(find.text('7 de 49 casillas'), findsOneWidget);
    expect(_progreso(tester), closeTo(7 / 49, 1e-9));
  });
}
