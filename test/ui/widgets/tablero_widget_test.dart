import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/tablero.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';
import 'package:brilliant/ui/widgets/tablero_widget.dart';

Posicion _pos(String notacion) => Posicion.desdeNotacion(notacion);

Future<void> _mostrar(WidgetTester tester, TableroWidget tablero) {
  return tester.pumpWidget(MaterialApp(home: Scaffold(body: Center(child: tablero))));
}

/// El texto que muestra la celda dibujada en [notacion].
String _textoEn(WidgetTester tester, String notacion) {
  final celda = find.byWidgetPredicate(
    (widget) => widget is CeldaWidget && widget.celda.posicion == _pos(notacion),
  );
  final texto = find.descendant(of: celda, matching: find.byType(Text));
  return tester.widget<Text>(texto).data!;
}

void main() {
  group('TableroWidget', () {
    testWidgets('dibuja las 49 casillas del mapa', (tester) async {
      await _mostrar(tester, TableroWidget(tablero: Tablero.mapaOriginal()));

      expect(find.byType(CeldaWidget), findsNWidgets(49));
    });

    testWidgets('muestra el número anotado en cada casilla', (tester) async {
      final tablero = Tablero.mapaOriginal().conValores({_pos('C1'): 4, _pos('E7'): 2});

      await _mostrar(tester, TableroWidget(tablero: tablero));

      expect(_textoEn(tester, 'C1'), '4');
      expect(_textoEn(tester, 'E7'), '2');
      expect(_textoEn(tester, 'F2'), '');
    });

    testWidgets('marca como seleccionada solo la casilla indicada', (tester) async {
      await _mostrar(
        tester,
        TableroWidget(tablero: Tablero.mapaOriginal(), seleccionada: _pos('B4')),
      );

      final seleccionadas = tester
          .widgetList<CeldaWidget>(find.byType(CeldaWidget))
          .where((celda) => celda.seleccionada);
      expect(seleccionadas.map((celda) => celda.celda.posicion), [_pos('B4')]);
    });

    testWidgets('cada celda recibe la iluminación que le toca', (tester) async {
      await _mostrar(
        tester,
        TableroWidget(
          tablero: Tablero.mapaOriginal(),
          iluminacionDe: (posicion) => switch (posicion.notacion) {
            'A2' => Iluminacion.posible,
            'C2' => Iluminacion.bloqueada,
            _ => Iluminacion.normal,
          },
        ),
      );

      final iluminadas = {
        for (final celda in tester.widgetList<CeldaWidget>(find.byType(CeldaWidget)))
          if (celda.iluminacion != Iluminacion.normal) celda.celda.posicion.notacion: celda.iluminacion,
      };
      expect(iluminadas, {'A2': Iluminacion.posible, 'C2': Iluminacion.bloqueada});
    });

    testWidgets('solo las casillas indicadas llevan la marca de ancla', (tester) async {
      await _mostrar(
        tester,
        TableroWidget(
          tablero: Tablero.mapaOriginal(),
          esAncla: (posicion) => posicion == _pos('C1'),
        ),
      );

      final anclas = tester
          .widgetList<CeldaWidget>(find.byType(CeldaWidget))
          .where((celda) => celda.esAncla);
      expect(anclas.map((celda) => celda.celda.posicion), [_pos('C1')]);
      expect(find.byIcon(Icons.anchor), findsOneWidget);
    });

    testWidgets('tocar una casilla tocable avisa con su posición', (tester) async {
      final tocadas = <Posicion>[];

      await _mostrar(
        tester,
        TableroWidget(
          tablero: Tablero.mapaOriginal(),
          alTocar: tocadas.add,
          esTocable: (posicion) => posicion == _pos('F2'),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('casilla-F2')));

      expect(tocadas, [_pos('F2')]);
    });

    testWidgets('las casillas no tocables no responden', (tester) async {
      final tocadas = <Posicion>[];

      await _mostrar(
        tester,
        TableroWidget(
          tablero: Tablero.mapaOriginal(),
          alTocar: tocadas.add,
          esTocable: (posicion) => posicion == _pos('F2'),
        ),
      );

      expect(find.byKey(const ValueKey('casilla-A1')), findsNothing);
      await tester.tap(
        find.byWidgetPredicate(
          (widget) => widget is CeldaWidget && widget.celda.posicion == _pos('A1'),
        ),
      );
      expect(tocadas, isEmpty);
    });
  });
}
