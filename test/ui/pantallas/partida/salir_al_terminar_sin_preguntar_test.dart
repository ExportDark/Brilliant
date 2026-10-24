import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/tablero.dart';
import 'package:brilliant/ui/pantallas/pantalla_partida.dart';

void main() {
  testWidgets('PantallaPartida: con la partida terminada, la flecha de atrás sale sin preguntar', (
    tester,
  ) async {
    final vacio = Tablero.mapaOriginal();
    final lleno = vacio.conValores({for (final celda in vacio.celdas) celda.posicion: 1});
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaPartida(tablero: lleno)),
            ),
            child: const Text('Abrir la partida'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir la partida'));
    await tester.pumpAndSettle();
    expect(find.text('Partida terminada'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('¿Salir de la partida?'), findsNothing);
    expect(find.byType(PantallaPartida), findsNothing);
  });
}
