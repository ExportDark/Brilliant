import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/tema.dart';

import '../ayudantes_pantallas.dart';

void main() {
  testWidgets('La hoja de reglas es de cartón, no del verde de la mesa: la letra oscura se lee', (
    tester,
  ) async {
    await abrirPartida(tester);

    await tocar(tester, find.byKey(const ValueKey('boton-reglas')));

    final hoja = tester.widget<BottomSheet>(find.byType(BottomSheet));
    expect(hoja.backgroundColor, Paleta.carton);
    expect(hoja.backgroundColor, isNot(Paleta.mesa));
  });
}
