import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/celda.dart';
import 'package:brilliant/modelo/color5.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';

Future<double> _grosorDelBorde(WidgetTester tester, Celda celda) async {
  await tester.pumpWidget(MaterialApp(home: Center(child: CeldaWidget(celda: celda))));
  final contenedor = tester.widget<Container>(
    find.descendant(of: find.byType(CeldaWidget), matching: find.byType(Container)),
  );
  return ((contenedor.decoration! as BoxDecoration).border! as Border).top.width;
}

void main() {
  testWidgets('CeldaWidget: solo las casillas iniciales llevan el borde grueso', (tester) async {
    const posicion = Posicion(fila: 0, columna: 2);

    final inicial = await _grosorDelBorde(
      tester,
      const Celda(posicion: posicion, color: Color5.azul, esInicial: true),
    );
    final comun = await _grosorDelBorde(
      tester,
      const Celda(posicion: posicion, color: Color5.azul),
    );

    expect(inicial, 3);
    expect(comun, 1);
  });
}
