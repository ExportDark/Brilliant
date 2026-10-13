import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';

import '../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaPreparacion: tocar una chip del resumen selecciona su casilla', (tester) async {
    await abrirPreparacion(tester);

    await tocar(tester, find.byKey(const ValueKey('resumen-E4')));

    expect(celdasDibujadasDonde(tester, (CeldaWidget celda) => celda.seleccionada), {'E4'});
  });
}
