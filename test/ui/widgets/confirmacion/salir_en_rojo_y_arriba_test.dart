import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/ui/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../pantallas/ayudantes_pantallas.dart';

void main() {
  testWidgets('Salir de la partida va en rojo con letra clara, y en un celular chico, donde '
      'los botones no caben en fila, va arriba de "Seguir jugando" y centrado', (tester) async {
    await abrirApp(tester, tamano: tamanosDePantalla['celular chico']!);
    await tocar(tester, tarjetaDe(nivel1));
    await tocar(tester, find.widgetWithText(TextButton, 'Aleatorio'));
    await tocar(tester, find.widgetWithText(FilledButton, 'Inicio'));
    await tester.pageBack();
    await tester.pumpAndSettle();

    final salir = find.widgetWithText(FilledButton, 'Salir');
    final estilo = tester.widget<FilledButton>(salir).style!;
    expect(estilo.backgroundColor!.resolve({}), Paleta.peligro);
    expect(estilo.foregroundColor!.resolve({}), Paleta.cartonClaro);

    final seguir = find.widgetWithText(TextButton, 'Seguir jugando');
    expect(tester.getCenter(salir).dy, lessThan(tester.getCenter(seguir).dy));
    expect(tester.getCenter(salir).dx, moreOrLessEquals(tester.getCenter(seguir).dx, epsilon: 1));
  });
}
