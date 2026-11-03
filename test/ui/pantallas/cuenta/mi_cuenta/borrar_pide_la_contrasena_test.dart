import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/pantallas/pantalla_mi_cuenta.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaMiCuenta: borrar la cuenta pide la contraseña, y se puede cancelar', (
    tester,
  ) async {
    final servidor = ServidorFalso();
    await abrirApp(tester, servidor: servidor);
    await tocar(tester, botonMiCuenta);

    await tocar(tester, find.widgetWithText(TextButton, 'Borrar cuenta'));
    expect(find.text('¿Borrar tu cuenta?'), findsOneWidget);

    // Sin escribir la contraseña, no se manda nada.
    await tocar(tester, find.widgetWithText(FilledButton, 'Borrar cuenta'));
    expect(find.text('Escribe tu contraseña para confirmar'), findsOneWidget);

    await tocar(tester, find.widgetWithText(TextButton, 'Cancelar'));
    expect(find.text('¿Borrar tu cuenta?'), findsNothing);
    expect(find.byType(PantallaMiCuenta), findsOneWidget);
    expect(servidor.cuentas, contains('ana'));
    expect(servidor.pedidos.where((pedido) => pedido.method == 'DELETE'), isEmpty);
  });
}
