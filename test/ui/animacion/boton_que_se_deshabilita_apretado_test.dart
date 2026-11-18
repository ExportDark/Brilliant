import 'package:brilliant/ui/animacion/cartoon.dart';
import 'package:brilliant/ui/widgets/piezas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudantes_animacion.dart';

Future<void> boton(WidgetTester tester, {required bool habilitado}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: PiezaPresionable(
            child: FilledButton(
              onPressed: habilitado ? () {} : null,
              child: const Text('Empezar'),
            ),
          ),
        ),
      ),
    ),
  );
}

double aplastado(WidgetTester tester) => tester
    .widget<AplastarYEstirar>(find.byKey(const ValueKey('aplastar-y-estirar')))
    .aplastado;

Rect dondeEsta(WidgetTester tester) =>
    tester.getRect(find.byType(FilledButton));

void main() {
  testWidgets(
    'Si el botón se deshabilita con el dedo encima (por ejemplo, "Empezar" justo '
    'cuando se va un jugador), al volver a habilitarse no queda hundido ni aplastado',
    (tester) async {
      await boton(tester, habilitado: true);
      final enReposo = dondeEsta(tester);

      final dedo = await tester.startGesture(
        tester.getCenter(find.text('Empezar')),
      );
      await tester.pump();
      expect(aplastado(tester), greaterThan(0));

      await boton(tester, habilitado: false);
      await dedo.up();
      await tester.pumpAndSettle();

      await boton(tester, habilitado: true);
      await tester.pumpAndSettle();
      expect(aplastado(tester), 0);
      expect(dondeEsta(tester), enReposo);
      expectQuieto(tester);
    },
  );

  testWidgets(
    'Y si se vuelve a habilitar antes de soltar, al soltar tampoco queda hundido',
    (tester) async {
      await boton(tester, habilitado: true);
      final enReposo = dondeEsta(tester);

      final dedo = await tester.startGesture(
        tester.getCenter(find.text('Empezar')),
      );
      await tester.pump();
      await boton(tester, habilitado: false);
      await tester.pump();
      await boton(tester, habilitado: true);
      await tester.pump();
      await dedo.up();
      await tester.pumpAndSettle();

      expect(aplastado(tester), 0);
      expect(dondeEsta(tester), enReposo);
    },
  );
}
