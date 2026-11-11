import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudantes_pantallas.dart';
import 'ayudantes_servidores.dart';

void main() {
  testWidgets('Crear cuenta: sin servidor elegido el botón espera, y se elige desde la misma '
      'pantalla', (tester) async {
    await abrirConVariosServidores(tester);
    await tocar(tester, enlaceCrearCuenta);

    expect(listaDeVarios, findsOneWidget);
    expect(habilitado(tester, botonCrearCuenta), isFalse);

    await tocar(tester, find.byKey(const ValueKey('servidor-192.168.137.40')));

    expect(listaDeVarios, findsNothing);
    expect(habilitado(tester, botonCrearCuenta), isTrue);
  });
}
