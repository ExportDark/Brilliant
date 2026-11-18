import 'package:brilliant/ui/animacion/iris.dart';
import 'package:brilliant/ui/widgets/piezas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudantes_animacion.dart';

/// Una pantalla con un botón que entra a otra con el iris.
Future<void> abrirConRuta(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                RutaConIris<void>(
                  builder: (_) => const Scaffold(body: Text('Partida')),
                ),
              ),
              child: const Text('Inicio'),
            ),
          ),
        ),
      ),
    ),
  );
}

/// El iris encima de una columna con la insignia del trofeo abajo a la derecha.
Widget conTrofeo({Object? disparador}) => MaterialApp(
  home: Scaffold(
    body: Iris.cierre(
      disparador: disparador,
      child: const Align(
        alignment: Alignment(0.6, 0.5),
        child: Insignia(icono: Icons.emoji_events_rounded),
      ),
    ),
  ),
);

RenderObject iris(WidgetTester tester) =>
    tester.renderObject(find.byKey(const ValueKey('iris')));

void main() {
  testWidgets('"Inicio" entra con el iris: se cierra sobre la de antes y se abre sobre la '
      'nueva, que ya está (aunque todavía no se vea)', (tester) async {
    await abrirConRuta(tester);
    await tester.tap(find.text('Inicio'));
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 90));
    expect(iris(tester), paints..path());
    expect(find.text('Partida'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 200));
    expect(iris(tester), paints..path());

    await tester.pumpAndSettle();
    expect(iris(tester), isNot(paints..path()));
    expectQuieto(tester);
  });

  testWidgets('Con movimiento reducido, entra sin iris', (tester) async {
    conMovimientoReducido(tester);
    await abrirConRuta(tester);
    await tester.tap(find.text('Inicio'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 90));

    expect(find.byKey(const ValueKey('iris')), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text('Partida'), findsOneWidget);
  });

  testWidgets(
    'Al terminar, el iris se cierra sobre el trofeo, se queda un instante y se '
    'vuelve a abrir',
    (tester) async {
      await tester.pumpWidget(conTrofeo());
      await tester.pumpWidget(conTrofeo(disparador: 'fin'));

      // En el medio, se queda alrededor del trofeo.
      await tester.pump(const Duration(milliseconds: 550));
      final pintor =
          tester
                  .widget<CustomPaint>(find.byKey(const ValueKey('iris')))
                  .painter!
              as TintaConHueco;
      final trofeo = tester.getCenter(find.byType(Insignia));
      final area = tester.getTopLeft(find.byType(Iris));
      expect((pintor.centro - (trofeo - area)).distance, lessThan(1));
      expect(pintor.radio, 52);

      await tester.pumpAndSettle();
      expect(
        tester.widget(find.byKey(const ValueKey('iris'))),
        isA<SizedBox>(),
      );
      expectQuieto(tester);
    },
  );

  testWidgets('La apertura se juega al aparecer si se pide (la partida en línea puede llegar '
      'de golpe)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Iris.apertura(
          disparador: 'sala',
          alAparecer: true,
          child: Text('Ronda 1'),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(iris(tester), paints..path());

    await tester.pumpAndSettle();
    expect(tester.widget(find.byKey(const ValueKey('iris'))), isA<SizedBox>());
  });

  testWidgets('Sin disparador, o con movimiento reducido, no hay iris', (
    tester,
  ) async {
    await tester.pumpWidget(conTrofeo());
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.widget(find.byKey(const ValueKey('iris'))), isA<SizedBox>());
    await tester.pumpAndSettle(); // la entrada de la insignia

    conMovimientoReducido(tester);
    await tester.pumpWidget(conTrofeo(disparador: 'fin'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.widget(find.byKey(const ValueKey('iris'))), isA<SizedBox>());
    expectQuieto(tester);
  });
}
