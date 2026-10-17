import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/tablero.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';
import 'package:brilliant/ui/widgets/tablero_widget.dart';

/// El tamaño de las casillas cuando el tablero tiene [ancho] disponible.
Future<double> _tamanoDeCasillaCon(WidgetTester tester, double ancho) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Center(
        child: SizedBox(width: ancho, child: TableroWidget(tablero: Tablero.mapaOriginal())),
      ),
    ),
  );
  return tester.widget<CeldaWidget>(find.byType(CeldaWidget).first).tamano;
}

void main() {
  testWidgets('TableroWidget: las casillas miden 48 si caben y se achican si no', (tester) async {
    // El tablero ocupa 7,5 casillas de ancho: 7 columnas y media de etiquetas.
    expect(await _tamanoDeCasillaCon(tester, 600), 48);
    expect(await _tamanoDeCasillaCon(tester, 360), 48);
    expect(await _tamanoDeCasillaCon(tester, 328), 43);
    expect(await _tamanoDeCasillaCon(tester, 288), 38);
  });
}
