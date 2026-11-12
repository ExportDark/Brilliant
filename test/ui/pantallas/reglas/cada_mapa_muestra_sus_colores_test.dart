import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/ui/widgets/hoja_de_reglas.dart';

void main() {
  for (final mapa in mapas) {
    testWidgets('Las reglas del ${mapa.nombre} muestran cada color de zona una sola vez', (
      tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: HojaDeReglas(mapa: mapa))));

      final tipos = HojaDeReglas.tiposDe(mapa);
      final esperados = {for (final zona in mapa.zonas) zona.tipo};
      expect(tipos.toSet(), esperados);
      expect(tipos, hasLength(esperados.length), reason: 'sin repetir');
      for (final tipo in tipos) {
        expect(
          find.byKey(ValueKey('regla-${tipo.color.name}-${tipo.regla.descripcion}')),
          findsOneWidget,
        );
      }
    });
  }

  testWidgets('En el Nivel 4 las dos naranjas aparecen con su rango', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: HojaDeReglas(mapa: nivel4))));

    expect(find.text('Solo del 1 al 3.'), findsOneWidget);
    expect(find.text('Solo del 4 al 6.'), findsOneWidget);
  });

  testWidgets('En línea, la hoja también dice cómo se ganan los puntos', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: HojaDeReglas(mapa: nivel2, enLinea: true))),
    );

    expect(find.textContaining('cada zona da puntos al que la llena primero'), findsOneWidget);
  });
}
