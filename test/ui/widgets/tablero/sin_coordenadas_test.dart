import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/tablero.dart';
import 'package:brilliant/ui/widgets/tablero_widget.dart';

void main() {
  testWidgets('TableroWidget: no muestra las letras A-G ni los números 1-7 de las coordenadas', (
    tester,
  ) async {
    // Tablero vacío: si apareciera algún texto, solo podría ser una coordenada.
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: Center(child: TableroWidget(tablero: Tablero.mapaOriginal())))),
    );

    for (final letra in ['A', 'B', 'C', 'D', 'E', 'F', 'G']) {
      expect(find.text(letra), findsNothing, reason: 'se ve la columna $letra');
    }
    for (var fila = 1; fila <= 7; fila++) {
      expect(find.text('$fila'), findsNothing, reason: 'se ve la fila $fila');
    }
  });
}
