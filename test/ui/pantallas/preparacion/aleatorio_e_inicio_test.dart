import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/tablero.dart';
import 'package:brilliant/ui/pantallas/pantalla_partida.dart';

import '../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaPreparacion: Aleatorio y luego Inicio arranca la partida con los 6 números', (
    tester,
  ) async {
    await abrirPreparacion(tester);

    await tocar(tester, find.widgetWithText(OutlinedButton, 'Aleatorio'));
    await tocar(tester, find.widgetWithText(FilledButton, 'Inicio'));

    expect(find.byType(PantallaPartida), findsOneWidget);
    final numeros = {for (final casilla in casillasIniciales) celdaEn(tester, casilla).celda.valor};
    expect(numeros, {1, 2, 3, 4, 5, 6});
  });
}
