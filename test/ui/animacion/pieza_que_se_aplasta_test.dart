import 'package:brilliant/ui/animacion/cartoon.dart';
import 'package:brilliant/ui/widgets/piezas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudantes_animacion.dart';

Future<void> abrirBoton(WidgetTester tester, {bool habilitado = true}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: PiezaPresionable(
            child: FilledButton(
              onPressed: habilitado ? () {} : null,
              child: const Text('Tirar'),
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

void main() {
  testWidgets('Al apretarla se aplasta, al soltarla rebota (se estira un instante) y se '
      'asienta como era', (tester) async {
    await abrirBoton(tester);
    expect(aplastado(tester), 0);

    final dedo = await tester.startGesture(
      tester.getCenter(find.text('Tirar')),
    );
    await tester.pump();
    expect(aplastado(tester), greaterThan(0));

    await dedo.up();
    await tester.pump();
    // Durante el rebote pasa por estirada (negativo): la goma se pasa de largo.
    var seEstiro = false;
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      if (aplastado(tester) < 0) seEstiro = true;
    }
    expect(seEstiro, isTrue);

    await tester.pumpAndSettle();
    expect(aplastado(tester), 0);
    expectQuieto(tester);
  });

  testWidgets('Con movimiento reducido no se aplasta ni rebota', (
    tester,
  ) async {
    conMovimientoReducido(tester);
    await abrirBoton(tester);

    final dedo = await tester.startGesture(
      tester.getCenter(find.text('Tirar')),
    );
    await tester.pump();
    expect(aplastado(tester), 0);
    await dedo.up();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(aplastado(tester), 0);
    }
    // La onda del botón (de Material) sí se mueve; después, nada.
    await tester.pumpAndSettle();
    expectQuieto(tester);
  });

  testWidgets('Deshabilitado, no se aplasta', (tester) async {
    await abrirBoton(tester, habilitado: false);

    final dedo = await tester.startGesture(
      tester.getCenter(find.text('Tirar')),
    );
    await tester.pump();
    expect(aplastado(tester), 0);
    await dedo.up();
  });
}
