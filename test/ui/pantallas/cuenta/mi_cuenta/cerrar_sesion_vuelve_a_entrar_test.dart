import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/pantallas/pantalla_entrar.dart';
import 'package:brilliant/ui/pantallas/pantalla_mi_cuenta.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaMiCuenta: cerrar sesión vuelve a "Iniciar sesión" y el token ya no sirve', (
    tester,
  ) async {
    final servidor = ServidorFalso();
    await abrirApp(tester, servidor: servidor);
    await tocar(tester, botonMiCuenta);

    await tocar(tester, find.widgetWithText(FilledButton, 'Cerrar sesión'));

    expect(find.byType(PantallaMiCuenta), findsNothing);
    expect(find.byType(PantallaEntrar), findsOneWidget);
    expect(find.text('Cerraste sesión.'), findsOneWidget);
    expect(servidor.sesiones, isEmpty);
    // La cuenta sigue: solo se cerró la sesión.
    expect(servidor.cuentas, contains('ana'));
  });
}
