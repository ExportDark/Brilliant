import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../cuenta/ayudantes_cuenta.dart';
import '../ayudantes_pantallas.dart';

void main() {
  group('Las pantallas de cuenta se abren sin desbordarse', () {
    for (final MapEntry(key: nombre, value: tamano) in tamanosDePantalla.entries) {
      final medidas = '${tamano.width.toInt()}×${tamano.height.toInt()}';

      testWidgets('iniciar sesión, el servidor y crear cuenta, en $nombre ($medidas)', (tester) async {
        // Con dos servidores en la red, uno con un nombre largo.
        final servidor = ServidorFalso()..otrasDirecciones.add('192.168.137.40');
        final buscador = BuscadorFalso([
          anunciado('servidor.test'),
          anunciado('192.168.137.40', pc: 'LA-COMPUTADORA-DEL-CUARTO-DE-ARRIBA'),
        ]);
        await abrirApp(
          tester,
          servidor: servidor,
          conSesion: false,
          tamano: tamano,
          buscador: buscador,
        );
        expect(tester.takeException(), isNull);

        await tocar(tester, botonServidor);
        expect(find.text('Brilliant en ORION'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'el diálogo del servidor');
        await tocar(tester, find.widgetWithText(TextButton, 'Cancelar'));

        await tocar(tester, enlaceCrearCuenta);
        await tocar(tester, botonCrearCuenta);
        expect(tester.takeException(), isNull, reason: 'crear cuenta, con los errores a la vista');

        // Los errores más largos: el de los caracteres del usuario y el de la
        // contraseña larga.
        await crearCuentaCon(tester, 'ana pérez', 'x' * 129);
        expect(tester.takeException(), isNull, reason: 'crear cuenta, con los errores largos');
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
