import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/tablero.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';
import 'package:brilliant/ui/widgets/tablero_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudantes_animacion.dart';

Posicion pos(String notacion) => Posicion.desdeNotacion(notacion);

Future<void> mostrar(WidgetTester tester, Tablero tablero) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: Center(child: TableroWidget(tablero: tablero)),
    ),
  ),
);

/// Las casillas movidas (sacudidas, saltando o meneándose).
List<String> movidas(WidgetTester tester) => [
  for (final celda in tester.widgetList<CeldaWidget>(find.byType(CeldaWidget)))
    if (!tester
        .widget<Transform>(
          find.descendant(
            of: find.byWidget(celda),
            matching: find.byKey(const ValueKey('efecto-de-celda')),
          ),
        )
        .transform
        .isIdentity())
      celda.celda.posicion.notacion,
];

/// Las casillas cuyo número está apareciendo (escala distinta de 1).
List<String> apareciendo(WidgetTester tester) => [
  for (final celda in tester.widgetList<CeldaWidget>(find.byType(CeldaWidget)))
    if (tester
            .widget<Transform>(
              find.descendant(
                of: find.byWidget(celda),
                matching: find.byKey(const ValueKey('numero-que-aparece')),
              ),
            )
            .transform
            .entry(0, 0) !=
        1)
      celda.celda.posicion.notacion,
];

RenderObject polvo(WidgetTester tester) =>
    tester.renderObject(find.byKey(const ValueKey('polvo-del-tablero')));

/// La zona más chica de [mapa]: sus casillas.
List<Posicion> zonaChica(Mapa mapa) => [
  for (final celda
      in Tablero.desdeMapa(mapa).regiones
          .reduce((a, b) => a.casillas.length <= b.casillas.length ? a : b)
          .casillas)
    celda.posicion,
];

/// El tablero de [mapa] con un 3 en cada casilla de [casillas].
Tablero conNumeros(Mapa mapa, Iterable<Posicion> casillas) {
  var tablero = Tablero.desdeMapa(mapa);
  for (final p in casillas) {
    tablero = tablero.conValor(p, 3);
  }
  return tablero;
}

void main() {
  test('El Nivel 3 y el Nivel 4 tienen las mismas zonas (8): contarlas no alcanza para '
      'saber si es el mismo mapa', () {
    expect(
      Tablero.desdeMapa(nivel3).regiones.length,
      Tablero.desdeMapa(nivel4).regiones.length,
    );
  });

  testWidgets('Si el tablero pasa a ser de otro mapa con números, no sale polvo ni aparece '
      'ningún número', (tester) async {
    await mostrar(tester, Tablero.desdeMapa(nivel3));
    await mostrar(
      tester,
      conNumeros(nivel4, [...zonaChica(nivel4), pos('D4')]),
    );

    for (final espera in [40, 120, 200]) {
      await tester.pump(Duration(milliseconds: espera));
      expect(polvo(tester), isNot(paints..circle()), reason: '$espera ms');
      expect(apareciendo(tester), isEmpty, reason: '$espera ms');
    }
    await tester.pumpAndSettle();
    expectQuieto(tester);
  });

  testWidgets(
    'Y con los mismos números en otras zonas, no se menea ninguna (la zona del '
    'mismo lugar en la lista no es la misma zona)',
    (tester) async {
      final numeros = zonaChica(nivel4);
      final antes = conNumeros(nivel3, numeros);
      final despues = conNumeros(nivel4, numeros);
      // La zona que está en el mismo lugar de la lista no estaba llena en el Nivel 3.
      final i = despues.regiones.indexWhere((r) => r.completada);
      expect(antes.regiones[i].completada, isFalse);

      await mostrar(tester, antes);
      await mostrar(tester, despues);
      for (final espera in [40, 120, 200]) {
        await tester.pump(Duration(milliseconds: espera));
        expect(movidas(tester), isEmpty, reason: '$espera ms');
      }
      await tester.pumpAndSettle();
      expectQuieto(tester);
    },
  );

  testWidgets(
    'En el mismo mapa sí festeja: el número que llena una zona aparece con '
    'polvo, y las otras casillas de la zona se menean',
    (tester) async {
      final zona = zonaChica(nivel4);
      final antes = conNumeros(nivel4, zona.skip(1));
      await mostrar(tester, antes);
      await mostrar(tester, antes.conValor(zona.first, 3));

      await tester.pump(const Duration(milliseconds: 60));
      expect(polvo(tester), paints..circle());
      expect(apareciendo(tester), [zona.first.notacion]);
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        movidas(tester),
        containsAll([for (final p in zona.skip(1)) p.notacion]),
      );
      expect(movidas(tester), isNot(contains(zona.first.notacion)));
      await tester.pumpAndSettle();
      expectQuieto(tester);
    },
  );
}
