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
  testWidgets('TableroWidget: las fichas miden 48 si caben y se achican si no', (tester) async {
    // El tablero ocupa 7 fichas, 4 px de separación por ficha y 6 px de
    // relleno de cada lado: con 48 px por ficha, 376 px en total.
    expect(await _tamanoDeCasillaCon(tester, 600), 48);
    expect(await _tamanoDeCasillaCon(tester, 376), 48);
    // Un celular de 360 px, menos 12 px de margen de cada lado.
    expect(await _tamanoDeCasillaCon(tester, 336), 42);
    // Un celular de 320 px.
    expect(await _tamanoDeCasillaCon(tester, 296), 36);
  });
}
