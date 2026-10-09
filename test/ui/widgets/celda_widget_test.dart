import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/celda.dart';
import 'package:brilliant/modelo/color5.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';

const _celda = Celda(posicion: Posicion(fila: 1, columna: 0), color: Color5.verde);

/// La decoración con la que se dibuja [widget].
Future<BoxDecoration> _decoracion(WidgetTester tester, CeldaWidget widget) async {
  await tester.pumpWidget(MaterialApp(home: Center(child: widget)));
  final contenedor = tester.widget<Container>(
    find.descendant(of: find.byType(CeldaWidget), matching: find.byType(Container)),
  );
  return contenedor.decoration! as BoxDecoration;
}

Future<double> _luminancia(WidgetTester tester, CeldaWidget widget) async =>
    (await _decoracion(tester, widget)).color!.computeLuminance();

void main() {
  group('CeldaWidget', () {
    testWidgets('la cuadrícula es negra sin importar cómo se resalte', (tester) async {
      final variantes = [
        const CeldaWidget(celda: _celda),
        const CeldaWidget(celda: _celda, seleccionada: true),
        for (final iluminacion in Iluminacion.values)
          CeldaWidget(celda: _celda, iluminacion: iluminacion),
      ];

      for (final variante in variantes) {
        final borde = (await _decoracion(tester, variante)).border! as Border;
        expect(borde.top.color, Colors.black);
      }
    });

    testWidgets('la posible se ilumina más que la bloqueada, y esta más que la normal', (
      tester,
    ) async {
      final normal = await _luminancia(tester, const CeldaWidget(celda: _celda));
      final bloqueada = await _luminancia(
        tester,
        const CeldaWidget(celda: _celda, iluminacion: Iluminacion.bloqueada),
      );
      final posible = await _luminancia(
        tester,
        const CeldaWidget(celda: _celda, iluminacion: Iluminacion.posible),
      );

      expect(posible, greaterThan(bloqueada));
      expect(bloqueada, greaterThan(normal));
    });

    testWidgets('la seleccionada se ilumina igual que una posible', (tester) async {
      final seleccionada = await _luminancia(
        tester,
        const CeldaWidget(celda: _celda, seleccionada: true),
      );
      final posible = await _luminancia(
        tester,
        const CeldaWidget(celda: _celda, iluminacion: Iluminacion.posible),
      );

      expect(seleccionada, posible);
    });

    testWidgets('el número resaltado va en negro sobre un círculo claro', (tester) async {
      await _mostrarConNumero(tester, numeroResaltado: true);

      expect(_circulos(tester), hasLength(1));
      expect(tester.widget<Text>(find.text('4')).style!.color, Colors.black87);
    });

    testWidgets('sin resaltar, el número va en blanco y sin círculo', (tester) async {
      await _mostrarConNumero(tester, numeroResaltado: false);

      expect(_circulos(tester), isEmpty);
      expect(tester.widget<Text>(find.text('4')).style!.color, Colors.white);
    });
  });
}

/// Una casilla azul con un 4 anotado, con o sin el número resaltado.
Future<void> _mostrarConNumero(WidgetTester tester, {required bool numeroResaltado}) {
  const conCuatro = Celda(posicion: Posicion(fila: 0, columna: 2), color: Color5.azul, valor: 4);
  return tester.pumpWidget(
    MaterialApp(
      home: Center(child: CeldaWidget(celda: conCuatro, numeroResaltado: numeroResaltado)),
    ),
  );
}

/// Los contenedores circulares dentro de la celda.
Iterable<Container> _circulos(WidgetTester tester) => tester
    .widgetList<Container>(
      find.descendant(of: find.byType(CeldaWidget), matching: find.byType(Container)),
    )
    .where((contenedor) => (contenedor.decoration as BoxDecoration?)?.shape == BoxShape.circle);
