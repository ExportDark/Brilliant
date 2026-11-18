import 'package:brilliant/ui/widgets/dado_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudantes_animacion.dart';

/// Cuánto subió el dado (positivo: en el aire).
double alturaDe(WidgetTester tester) => -tester
    .widget<Transform>(find.byKey(const ValueKey('salto-del-dado')))
    .transform
    .getTranslation()
    .y;

/// Si está girado.
bool girado(WidgetTester tester) => !tester
    .widget<Transform>(find.byKey(const ValueKey('giro-del-dado')))
    .transform
    .isIdentity();

int puntosVisibles(WidgetTester tester) =>
    find.byKey(const ValueKey('punto-del-dado')).evaluate().length;

Future<void> dibujar(
  WidgetTester tester, {
  int valor = 4,
  int? tirada,
  bool anclado = false,
  bool saltaAlAparecer = false,
  VoidCallback? alTocar,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: DadoWidget(
            valor: valor,
            tirada: tirada,
            anclado: anclado,
            saltaAlAparecer: saltaAlAparecer,
            alTocar: alTocar,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('Al tirarlo salta: sube girando, con las caras cambiando, y cae en su cara '
      'quieto y derecho', (tester) async {
    await dibujar(tester, saltaAlAparecer: true);

    await tester.pump(const Duration(milliseconds: 200));
    expect(alturaDe(tester), greaterThan(10));
    expect(girado(tester), isTrue);
    // Lo que lee un lector de pantalla es la cara real, aunque esté en el aire.
    expect(find.bySemanticsLabel('Dado: 4'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(alturaDe(tester), 0);
    expect(girado(tester), isFalse);
    expect(puntosVisibles(tester), 4);
    expectQuieto(tester);
  });

  testWidgets('Se puede tocar aunque esté en el aire', (tester) async {
    var toques = 0;
    await dibujar(tester, saltaAlAparecer: true, alTocar: () => toques++);
    await tester.pump(const Duration(milliseconds: 120));

    await tester.tap(find.bySemanticsLabel('Dado: 4'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(toques, 1);
  });

  testWidgets(
    'Salta cuando cambia la tirada (la ronda en línea), no si sigue la misma',
    (tester) async {
      await dibujar(tester, tirada: 1);
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        alturaDe(tester),
        0,
        reason: 'sin saltaAlAparecer, al dibujarse no salta',
      );

      await dibujar(tester, tirada: 1, valor: 4);
      await tester.pump(const Duration(milliseconds: 200));
      expect(alturaDe(tester), 0);

      await dibujar(tester, tirada: 2, valor: 6);
      await tester.pump(const Duration(milliseconds: 200));
      expect(alturaDe(tester), greaterThan(10));

      await tester.pumpAndSettle();
      expect(puntosVisibles(tester), 6);
    },
  );

  testWidgets('Al elegirlo como ancla da un brinco y queda hundido', (
    tester,
  ) async {
    await dibujar(tester, tirada: 1);
    await dibujar(tester, tirada: 1, anclado: true);

    await tester.pump(const Duration(milliseconds: 70));
    expect(alturaDe(tester), greaterThan(3));

    await tester.pumpAndSettle();
    expect(alturaDe(tester), 0);
  });

  testWidgets('Con movimiento reducido no salta ni brinca', (tester) async {
    conMovimientoReducido(tester);
    await dibujar(tester, saltaAlAparecer: true, tirada: 1);
    await tester.pump(const Duration(milliseconds: 200));
    expect(alturaDe(tester), 0);
    expect(girado(tester), isFalse);

    await dibujar(tester, tirada: 2, anclado: true);
    await tester.pump(const Duration(milliseconds: 100));
    expect(alturaDe(tester), 0);
    expectQuieto(tester);
  });
}
