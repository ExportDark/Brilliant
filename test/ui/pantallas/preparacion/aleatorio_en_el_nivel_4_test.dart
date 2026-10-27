import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/mapa.dart';

import '../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaPreparacion: en el Nivel 4, Aleatorio respeta los rangos naranjas', (
    tester,
  ) async {
    await abrirPreparacion(tester, mapa: nivel4);

    // La app usa dados y reparto al azar de verdad: se prueba varias veces.
    for (var vez = 0; vez < 5; vez++) {
      await tocar(tester, find.widgetWithText(TextButton, 'Aleatorio'));

      expect(celdaEn(tester, 'E1').celda.valor, inInclusiveRange(4, 6));
      expect(celdaEn(tester, 'B7').celda.valor, inInclusiveRange(1, 3));
    }
  });
}
