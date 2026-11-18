import 'package:brilliant/ui/animacion/cartoon.dart';
import 'package:brilliant/ui/pantallas/multijugador/marcador.dart';
import 'package:brilliant/ui/widgets/logo_brilliant.dart';
import 'package:brilliant/ui/widgets/piezas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudantes_animacion.dart';

Future<void> mostrar(WidgetTester tester, Widget hijo) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(body: Center(child: hijo)),
  ),
);

Widget fila(int puntos) => SizedBox(
  width: 320,
  child: FilaDePuntos(puesto: 1, nombre: 'ana', puntos: puntos, meta: 10),
);

/// La escala del número de puntos [texto] ("9" de "9 pts").
double escalaDePuntos(WidgetTester tester, String texto) => tester
    .widget<ScaleTransition>(
      find.ancestor(
        of: find.textContaining('$texto pts'),
        matching: find.byType(ScaleTransition),
      ),
    )
    .scale
    .value;

double avanceDeLaPista(WidgetTester tester) => tester
    .widget<FractionallySizedBox>(
      find.descendant(
        of: find.byKey(const ValueKey('pista-ana')),
        matching: find.byType(FractionallySizedBox),
      ),
    )
    .widthFactor!;

double giroDeLaSacudida(WidgetTester tester) {
  final matriz = tester
      .widget<Transform>(find.byKey(const ValueKey('sacudida')))
      .transform;
  return matriz.entry(1, 0); // sin(ángulo)
}

double escalaDeLaInsignia(WidgetTester tester) => tester
    .widget<Transform>(find.byKey(const ValueKey('entrada-de-la-insignia')))
    .transform
    .entry(0, 0);

RenderObject brilloDeLaInsignia(WidgetTester tester) =>
    tester.renderObject(find.byKey(const ValueKey('brillo-de-la-insignia')));

void main() {
  testWidgets(
    'Al subir los puntos, el número nuevo hace "¡boing!": se pasa de tamaño y '
    'vuelve; la pista crece pasándose un poco y se asienta',
    (tester) async {
      await mostrar(tester, fila(5));
      expect(
        avanceDeLaPista(tester),
        0.5,
        reason: 'la primera vez se dibuja donde está',
      );

      await mostrar(tester, fila(8));
      var maximo = 0.0;
      var masLejos = 0.0;
      for (var i = 0; i < 25; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        final escala = escalaDePuntos(tester, '8');
        if (escala > maximo) maximo = escala;
        final avance = avanceDeLaPista(tester);
        if (avance > masLejos) masLejos = avance;
      }
      expect(maximo, greaterThan(1.1));
      expect(masLejos, greaterThan(0.8));

      await tester.pumpAndSettle();
      expect(find.textContaining('5 pts'), findsNothing);
      expect(escalaDePuntos(tester, '8'), 1);
      expect(avanceDeLaPista(tester), 0.8);
      expectQuieto(tester);
    },
  );

  testWidgets(
    'La ficha del tiempo tiembla con cada segundo, solo en los últimos',
    (tester) async {
      Widget ficha(int segundos) => Sacudida(
        disparador: segundos,
        activa: segundos <= 10,
        child: Text('$segundos s'),
      );

      await mostrar(tester, ficha(12));
      await mostrar(tester, ficha(11));
      await tester.pump(const Duration(milliseconds: 30));
      expect(giroDeLaSacudida(tester), 0, reason: 'todavía no está apurado');

      await mostrar(tester, ficha(10));
      await tester.pump(const Duration(milliseconds: 30));
      expect(giroDeLaSacudida(tester), isNot(0));

      await tester.pumpAndSettle();
      expect(giroDeLaSacudida(tester), 0);
      expectQuieto(tester);
    },
  );

  testWidgets(
    'Al aparecer el logo, sus fichas caen una tras otra y se asientan',
    (tester) async {
      await mostrar(tester, const LogoBrilliant());
      await tester.pump(const Duration(milliseconds: 80));

      double alto(int i) => -tester
          .widget<Transform>(find.byKey(ValueKey('ficha-del-logo-$i')))
          .transform
          .getTranslation()
          .y;
      expect(alto(0), greaterThan(0), reason: 'la primera ya viene cayendo');
      expect(
        tester
            .widget<Opacity>(
              find.ancestor(
                of: find.byKey(const ValueKey('ficha-del-logo-4')),
                matching: find.byType(Opacity),
              ),
            )
            .opacity,
        0,
        reason: 'la última todavía no salió',
      );

      await tester.pumpAndSettle();
      for (var i = 0; i < 5; i++) {
        expect(alto(i), 0);
      }
      expectQuieto(tester);
    },
  );

  testWidgets(
    'La insignia entra rebotando y suelta rayitas de brillo, que se van',
    (tester) async {
      await mostrar(tester, const Insignia(icono: Icons.emoji_events_rounded));
      await tester.pump(const Duration(milliseconds: 30));
      expect(escalaDeLaInsignia(tester), lessThan(1));

      await tester.pump(const Duration(milliseconds: 220));
      expect(brilloDeLaInsignia(tester), paints..line());

      await tester.pumpAndSettle();
      expect(escalaDeLaInsignia(tester), 1);
      expect(brilloDeLaInsignia(tester), isNot(paints..line()));
      expectQuieto(tester);
    },
  );

  testWidgets('Con movimiento reducido no hay festejos', (tester) async {
    conMovimientoReducido(tester);
    await mostrar(
      tester,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LogoBrilliant(),
          Insignia(icono: Icons.emoji_events_rounded),
        ],
      ),
    );
    await tester.pump(const Duration(milliseconds: 60));

    expect(escalaDeLaInsignia(tester), 1);
    expect(brilloDeLaInsignia(tester), isNot(paints..line()));
    expectQuieto(tester);
  });
}
