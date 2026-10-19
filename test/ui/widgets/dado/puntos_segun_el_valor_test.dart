import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/widgets/dado_widget.dart';

void main() {
  group('DadoWidget: tiene tantos puntos como su valor', () {
    for (var valor = 1; valor <= 6; valor++) {
      testWidgets('el $valor', (tester) async {
        await tester.pumpWidget(MaterialApp(home: Center(child: DadoWidget(valor: valor))));

        expect(find.byKey(const ValueKey('punto-del-dado')), findsNWidgets(valor));
        // Para lectores de pantalla, el dado dice su valor.
        expect(find.bySemanticsLabel('Dado: $valor'), findsOneWidget);
      });
    }
  });
}
