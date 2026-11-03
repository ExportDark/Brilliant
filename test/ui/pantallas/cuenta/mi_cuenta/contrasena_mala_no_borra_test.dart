import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaMiCuenta: con una contraseña mala, el diálogo muestra el error y no borra', (
    tester,
  ) async {
    final servidor = ServidorFalso();
    await abrirApp(tester, servidor: servidor);
    await tocar(tester, botonMiCuenta);
    await tocar(tester, find.widgetWithText(TextButton, 'Borrar cuenta'));

    await escribir(tester, 'campo-contrasena-borrar', 'no-es-la-buena');
    await tocar(tester, find.widgetWithText(FilledButton, 'Borrar cuenta'));

    expect(find.text('¿Borrar tu cuenta?'), findsOneWidget);
    expect(find.text('Contraseña inválida.'), findsOneWidget);
    expect(servidor.cuentas, contains('ana'));
  });
}
