import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('DialogoDelServidor: "Restablecer" vuelve a la dirección de siempre', (tester) async {
    final almacen = AlmacenEnMemoria();
    await abrirApp(tester, conSesion: false, almacen: almacen);

    // Con la dirección de siempre no hay nada que restablecer.
    await tocar(tester, botonServidor);
    expect(find.widgetWithText(TextButton, 'Restablecer'), findsNothing);
    await tocar(tester, find.widgetWithText(TextButton, 'Cancelar'));

    await cambiarServidor(tester, '10.0.0.9');
    expect(find.text('Servidor: 10.0.0.9'), findsOneWidget);

    await tocar(tester, botonServidor);
    await tocar(tester, find.widgetWithText(TextButton, 'Restablecer'));

    expect(find.text('Servidor: servidor.test'), findsOneWidget);
    expect(almacen.servidor, isNull);
  });
}
