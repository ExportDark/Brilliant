import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaEntrar: la primera vez, el campo del usuario está vacío', (tester) async {
    await abrirApp(tester, conSesion: false);

    final usuario = tester.widget<TextFormField>(find.byKey(const ValueKey('campo-usuario')));
    expect(usuario.controller!.text, isEmpty);
  });
}
