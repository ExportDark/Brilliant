import 'package:brilliant/ui/widgets/explicacion_de_jugada.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudantes_animacion.dart';

Future<void> linea(WidgetTester tester, {Explicacion? explicacion}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: LineaDeIndicacion(
            indicacion: 'Toca una casilla',
            explicacion: explicacion,
          ),
        ),
      ),
    ),
  );
}

/// Si la línea está a mitad de un fundido.
bool fundiendo(WidgetTester tester) => tester
    .widgetList<FadeTransition>(
      find.descendant(
        of: find.byType(LineaDeIndicacion),
        matching: find.byType(FadeTransition),
      ),
    )
    .any((f) => f.opacity.value < 1);

void main() {
  const porQue = Explicacion('Esa casilla no está junto a ningún 3.');

  testWidgets('La explicación aparece y se va con un fundido', (tester) async {
    await linea(tester);
    await linea(tester, explicacion: porQue);
    await tester.pump(const Duration(milliseconds: 60));
    expect(fundiendo(tester), isTrue);
    await tester.pumpAndSettle();
    expect(fundiendo(tester), isFalse);
  });

  testWidgets(
    'Con movimiento reducido, la explicación aparece y se va de una vez, sin '
    'fundido',
    (tester) async {
      conMovimientoReducido(tester);
      await linea(tester);

      await linea(tester, explicacion: porQue);
      await tester.pump();
      expect(fundiendo(tester), isFalse);
      expect(find.text('Toca una casilla'), findsNothing);
      expect(find.byKey(const ValueKey('explicacion')), findsOneWidget);
      expectQuieto(tester);

      await linea(tester);
      await tester.pump();
      expect(fundiendo(tester), isFalse);
      expect(find.byKey(const ValueKey('explicacion')), findsNothing);
      expect(find.text('Toca una casilla'), findsOneWidget);
      expectQuieto(tester);
    },
  );
}
