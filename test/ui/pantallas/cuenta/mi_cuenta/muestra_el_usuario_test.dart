import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/pantallas/pantalla_mi_cuenta.dart';

import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaMiCuenta: se abre desde "Elige un mapa" y muestra el usuario', (
    tester,
  ) async {
    await abrirApp(tester);

    await tocar(tester, botonMiCuenta);

    expect(find.byType(PantallaMiCuenta), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('usuario-de-la-sesion'))).data,
      'ana',
    );
    expect(find.widgetWithText(FilledButton, 'Cerrar sesión'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Borrar cuenta'), findsOneWidget);
  });
}
