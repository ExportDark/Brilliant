import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/tablero.dart';
import 'package:brilliant/ui/widgets/tablero_widget.dart';

void main() {
  testWidgets('TableroWidget: muestra las letras A-G de las columnas y los números 1-7 de las filas', (
    tester,
  ) async {
    // Tablero vacío: ningún número de casilla se confunde con las etiquetas.
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: Center(child: TableroWidget(tablero: Tablero.mapaOriginal())))),
    );

    for (final letra in ['A', 'B', 'C', 'D', 'E', 'F', 'G']) {
      expect(find.text(letra), findsOneWidget, reason: 'falta la columna $letra');
    }
    for (var fila = 1; fila <= 7; fila++) {
      expect(find.text('$fila'), findsOneWidget, reason: 'falta la fila $fila');
    }
  });
}
