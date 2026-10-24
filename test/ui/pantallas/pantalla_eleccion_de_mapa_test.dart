import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/color_zona.dart';
import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/ui/pantallas/pantalla_preparacion.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';

import 'ayudantes_pantallas.dart';

/// Las casillas que responden al toque, en notación del manual.
Set<String> _tocables(WidgetTester tester) => {
      for (final widget in tester.allWidgets)
        if (widget.key case ValueKey<String>(:final value) when value.startsWith('casilla-'))
          value.substring('casilla-'.length),
    };

void main() {
  group('PantallaEleccionDeMapa', () {
    testWidgets('muestra los 4 mapas, cada uno con su nombre y su tablero de 49 casillas', (
      tester,
    ) async {
      await abrirApp(tester);

      for (final mapa in mapas) {
        final tarjeta = tarjetaDe(mapa);
        expect(tarjeta, findsOneWidget);
        expect(find.descendant(of: tarjeta, matching: find.text(mapa.nombre)), findsOneWidget);
        expect(
          find.descendant(of: tarjeta, matching: find.byType(CeldaWidget)),
          findsNWidgets(49),
        );
      }
    });

    testWidgets('las miniaturas son los mapas de verdad, con sus iniciales marcadas', (
      tester,
    ) async {
      await abrirApp(tester);

      final enElNivel4 = tester.widgetList<CeldaWidget>(
        find.descendant(of: tarjetaDe(nivel4), matching: find.byType(CeldaWidget)),
      );
      final porCasilla = {
        for (final celda in enElNivel4) celda.celda.posicion.notacion: celda.celda,
      };

      expect(porCasilla['A1']!.color, ColorZona.naranja);
      expect(porCasilla['D4']!.color, ColorZona.morado);
      expect(
        {for (final MapEntry(:key, :value) in porCasilla.entries) if (value.esInicial) key},
        nivel4.casillasIniciales.toSet(),
      );
    });

    testWidgets('tocar "Nivel 3" abre la preparación de ese mapa', (tester) async {
      await abrirApp(tester);

      await tocar(tester, tarjetaDe(nivel3));

      expect(find.byType(PantallaPreparacion), findsOneWidget);
      expect(find.text('Nivel 3'), findsOneWidget);
      expect(find.text('Prepara tu tablero'), findsOneWidget);
      // D1 es gris en el Nivel 3, y morado en el Nivel 1.
      expect(celdaEn(tester, 'D1').celda.color, ColorZona.gris);
      expect(_tocables(tester), nivel3.casillasIniciales.toSet());
    });
  });
}
