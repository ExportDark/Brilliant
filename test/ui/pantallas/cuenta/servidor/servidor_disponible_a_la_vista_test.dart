import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/tema.dart';

import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaEntrar: muestra a la vista que el servidor está disponible', (tester) async {
    await abrirApp(tester, conSesion: false);

    expect(indicadorDelServidor(tester), 'Servidor disponible · servidor.test');
    // Un punto verde.
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == Paleta.disponible,
      ),
      findsOneWidget,
    );
  });
}
