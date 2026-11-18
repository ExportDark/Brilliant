import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/tablero.dart';
import 'package:brilliant/ui/widgets/tablero_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

Posicion pos(String notacion) => Posicion.desdeNotacion(notacion);

/// Los elementos que el lector de pantalla ofrece para tocar.
Iterable<SemanticsNode> queSeTocan() =>
    find.semantics.byAction(SemanticsAction.tap).evaluate();

void main() {
  testWidgets(
    'Para el lector de pantalla, una casilla tocable es un solo elemento: lee su '
    'número y se puede tocar ahí mismo (no hay un botón vacío encima)',
    (tester) async {
      final semantica = tester.ensureSemantics();
      final tocadas = <Posicion>[];
      final tablero = Tablero.desdeMapa(nivel1).conValor(pos('D1'), 3);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: TableroWidget(
                tablero: tablero,
                alTocar: tocadas.add,
                esTocable: (p) => p == pos('D1') || p == pos('E1'),
              ),
            ),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.text('3')),
        isSemantics(label: '3', hasTapAction: true),
      );
      // Solo responden las dos casillas tocables, cada una una vez.
      expect(queSeTocan(), hasLength(2));

      tester.semantics.tap(find.semantics.byLabel('3'));
      expect(tocadas, [pos('D1')]);
      semantica.dispose();
    },
  );

  testWidgets('Una casilla que no responde no se ofrece para tocar', (
    tester,
  ) async {
    final semantica = tester.ensureSemantics();
    final tablero = Tablero.desdeMapa(nivel1).conValor(pos('D1'), 3);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: TableroWidget(
              tablero: tablero,
              alTocar: (_) {},
              esTocable: (_) => false,
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.text('3')),
      isSemantics(label: '3', hasTapAction: false),
    );
    expect(queSeTocan(), isEmpty);
    semantica.dispose();
  });
}
