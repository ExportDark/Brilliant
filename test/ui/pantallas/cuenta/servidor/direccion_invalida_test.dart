import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('DialogoDelServidor: una dirección inválida o con http no se guarda', (tester) async {
    final almacen = AlmacenEnMemoria();
    await abrirApp(tester, conSesion: false, almacen: almacen);
    await tocar(tester, botonServidor);

    for (final mala in ['mi pc', 'http://192.168.137.252:8443', '']) {
      await escribir(tester, 'campo-servidor', mala);
      await tocar(tester, find.widgetWithText(FilledButton, 'Guardar'));
      expect(
        find.text('Escribe una dirección como 192.168.137.252'),
        findsOneWidget,
        reason: '"$mala"',
      );
    }

    expect(find.text('Servidor'), findsOneWidget);
    expect(almacen.servidor, isNull);
  });
}
