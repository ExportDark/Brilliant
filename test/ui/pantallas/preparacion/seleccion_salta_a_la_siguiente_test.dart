import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaPreparacion: al poner un número, la selección salta a la siguiente casilla vacía', (
    tester,
  ) async {
    await abrirPreparacion(tester);
    expect(celdaEn(tester, 'C1').seleccionada, isTrue);

    await tocar(tester, find.byKey(const ValueKey('numero-4')));

    // El orden es el del manual: C1, F2, B4, E4, C6, E7.
    expect(celdaEn(tester, 'C1').seleccionada, isFalse);
    expect(celdaEn(tester, 'F2').seleccionada, isTrue);
  });
}
