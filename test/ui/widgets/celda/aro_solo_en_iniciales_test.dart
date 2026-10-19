import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/celda.dart';
import 'package:brilliant/modelo/color5.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';

Future<Border?> _borde(WidgetTester tester, Celda celda) async {
  await tester.pumpWidget(MaterialApp(home: Center(child: CeldaWidget(celda: celda))));
  // El aro cambia con una transición suave: se espera a que termine.
  await tester.pumpAndSettle();
  final contenedor = tester.widget<Container>(
    find.descendant(of: find.byType(CeldaWidget), matching: find.byType(Container)).first,
  );
  return (contenedor.decoration! as BoxDecoration).border as Border?;
}

void main() {
  testWidgets('CeldaWidget: solo las casillas iniciales llevan el aro tenue', (tester) async {
    const posicion = Posicion(fila: 0, columna: 2);

    final inicial = await _borde(
      tester,
      const Celda(posicion: posicion, color: Color5.azul, esInicial: true),
    );
    final comun = await _borde(tester, const Celda(posicion: posicion, color: Color5.azul));

    // El aro es de 2 px, en un tono más oscuro del mismo azul; no es negro.
    expect(inicial, isNotNull);
    expect(inicial!.top.width, 2);
    expect(inicial.top.color, isNot(Colors.black));
    expect(comun, isNull);
  });
}
