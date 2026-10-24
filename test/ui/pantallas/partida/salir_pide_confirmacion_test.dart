import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/mapa.dart';

import '../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaPartida: a mitad de partida, la flecha de atrás pregunta antes de salir', (
    tester,
  ) async {
    await abrirApp(tester);
    await tocar(tester, tarjetaDe(nivel1));
    await tocar(tester, find.widgetWithText(TextButton, 'Aleatorio'));
    await tocar(tester, find.widgetWithText(FilledButton, 'Inicio'));
    expect(find.text('Turno 1'), findsOneWidget);

    // "Seguir jugando" se queda en la partida.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('¿Salir de la partida?'), findsOneWidget);
    await tocar(tester, find.text('Seguir jugando'));
    expect(find.text('¿Salir de la partida?'), findsNothing);
    expect(find.text('Turno 1'), findsOneWidget);

    // "Salir" vuelve a elegir el mapa.
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tocar(tester, find.widgetWithText(FilledButton, 'Salir'));
    expect(find.text('Elige un mapa'), findsOneWidget);
  });
}
