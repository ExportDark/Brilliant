import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('Al cerrar sesión el usuario queda escrito, pero la contraseña no', (tester) async {
    final servidor = ServidorFalso()..cuentas['ana'] = contrasenaDePrueba;
    final almacen = AlmacenEnMemoria();
    await abrirApp(tester, servidor: servidor, conSesion: false, almacen: almacen);
    await entrarCon(tester, 'ana', contrasenaDePrueba);

    await tocar(tester, botonMiCuenta);
    await tocar(tester, find.widgetWithText(FilledButton, 'Cerrar sesión'));
    await tester.pumpAndSettle();

    final usuario = tester.widget<TextFormField>(find.byKey(const ValueKey('campo-usuario')));
    expect(usuario.controller!.text, 'ana');
    final contrasena = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const ValueKey('campo-contrasena')),
        matching: find.byType(EditableText),
      ),
    );
    expect(contrasena.controller.text, isEmpty);
    expect(almacen.sesion, isNull);
  });
}
