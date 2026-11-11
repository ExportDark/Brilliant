import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('Al borrar la cuenta, su usuario ya no se recuerda', (tester) async {
    final servidor = ServidorFalso()..cuentas['ana'] = contrasenaDePrueba;
    final almacen = AlmacenEnMemoria();
    await abrirApp(tester, servidor: servidor, conSesion: false, almacen: almacen);
    await entrarCon(tester, 'ana', contrasenaDePrueba);
    expect(almacen.ultimoUsuario, 'ana');

    await tocar(tester, botonMiCuenta);
    await tocar(tester, find.widgetWithText(TextButton, 'Borrar cuenta'));
    await escribir(tester, 'campo-contrasena-borrar', contrasenaDePrueba);
    await tocar(tester, find.widgetWithText(FilledButton, 'Borrar cuenta'));

    expect(almacen.ultimoUsuario, isNull);
    final usuario = tester.widget<TextFormField>(find.byKey(const ValueKey('campo-usuario')));
    expect(usuario.controller!.text, isEmpty);
  });
}
