import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../ayudantes_pantallas.dart';

void main() {
  group('Las pantallas de cuenta se abren sin desbordarse', () {
    for (final MapEntry(key: nombre, value: tamano) in tamanosDePantalla.entries) {
      final medidas = '${tamano.width.toInt()}×${tamano.height.toInt()}';

      testWidgets('iniciar sesión y crear cuenta, en $nombre ($medidas)', (tester) async {
        await abrirApp(tester, conSesion: false, tamano: tamano);
        expect(tester.takeException(), isNull);

        await tocar(tester, enlaceCrearCuenta);
        await tocar(tester, botonCrearCuenta);
        expect(tester.takeException(), isNull, reason: 'crear cuenta, con los errores a la vista');
      });

      testWidgets('mi cuenta y el diálogo de borrar, en $nombre ($medidas)', (tester) async {
        await abrirApp(tester, tamano: tamano);

        await tocar(tester, botonMiCuenta);
        expect(tester.takeException(), isNull);

        await tocar(tester, find.widgetWithText(TextButton, 'Borrar cuenta'));
        await tocar(tester, find.widgetWithText(FilledButton, 'Borrar cuenta'));
        expect(tester.takeException(), isNull, reason: 'el diálogo, con el error a la vista');
      });
    }
  });
}
