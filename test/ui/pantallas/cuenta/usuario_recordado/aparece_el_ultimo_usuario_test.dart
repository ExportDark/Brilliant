import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaEntrar: aparece el último usuario que entró y el cursor queda en la '
      'contraseña', (tester) async {
    final almacen = AlmacenEnMemoria()..ultimoUsuario = 'ana';
    await abrirApp(tester, conSesion: false, almacen: almacen);

    final usuario = tester.widget<TextFormField>(find.byKey(const ValueKey('campo-usuario')));
    expect(usuario.controller!.text, 'ana');
    final contrasena = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const ValueKey('campo-contrasena')),
        matching: find.byType(EditableText),
      ),
    );
    expect(contrasena.focusNode.hasFocus, isTrue);
    expect(contrasena.controller.text, isEmpty);
  });
}
