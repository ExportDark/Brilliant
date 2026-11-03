import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/pantallas/pantalla_entrar.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaMiCuenta: con la contraseña buena borra la cuenta y vuelve a "Iniciar sesión"', (
    tester,
  ) async {
    final servidor = ServidorFalso();
    await abrirApp(tester, servidor: servidor);
    await tocar(tester, botonMiCuenta);
    await tocar(tester, find.widgetWithText(TextButton, 'Borrar cuenta'));

    await escribir(tester, 'campo-contrasena-borrar', contrasenaDePrueba);
    await tocar(tester, find.widgetWithText(FilledButton, 'Borrar cuenta'));

    // Se cerraron el diálogo y "Mi cuenta": la raíz muestra "Iniciar sesión".
    expect(find.text('¿Borrar tu cuenta?'), findsNothing);
    expect(find.byType(PantallaEntrar), findsOneWidget);
    expect(find.text('Tu cuenta se borró.'), findsOneWidget);
    expect(servidor.cuentas, isEmpty);
    expect(servidor.sesiones, isEmpty);
  });
}
