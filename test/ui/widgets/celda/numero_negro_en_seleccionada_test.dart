import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/celda.dart';
import 'package:brilliant/modelo/color5.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';

const _conCuatro = Celda(posicion: Posicion(fila: 0, columna: 2), color: Color5.azul, valor: 4);

Future<Color?> _colorDelNumero(WidgetTester tester, {required bool seleccionada}) async {
  await tester.pumpWidget(
    MaterialApp(home: Center(child: CeldaWidget(celda: _conCuatro, seleccionada: seleccionada))),
  );
  return tester.widget<Text>(find.text('4')).style!.color;
}

void main() {
  testWidgets('CeldaWidget: en la casilla seleccionada, muy iluminada, el número va en negro', (
    tester,
  ) async {
    expect(await _colorDelNumero(tester, seleccionada: true), Colors.black87);
    expect(await _colorDelNumero(tester, seleccionada: false), Colors.white);
  });
}
