import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/tablero.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';
import 'package:brilliant/ui/widgets/tablero_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudantes_animacion.dart';

Posicion pos(String notacion) => Posicion.desdeNotacion(notacion);

Future<void> mostrar(
  WidgetTester tester,
  Tablero tablero, {
  Posicion? marcada,
  Set<String> posibles = const {},
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: TableroWidget(
            tablero: tablero,
            marcada: marcada,
            iluminacionDe: (p) => posibles.contains(p.notacion)
                ? Iluminacion.posible
                : Iluminacion.normal,
          ),
        ),
      ),
    ),
  );
}

Finder celda(String notacion) => find.byWidgetPredicate(
  (widget) => widget is CeldaWidget && widget.celda.posicion == pos(notacion),
);

/// La escala del número de la casilla [notacion].
double escalaDelNumero(WidgetTester tester, String notacion) => tester
    .widget<Transform>(
      find.descendant(
        of: celda(notacion),
        matching: find.byKey(const ValueKey('numero-que-aparece')),
      ),
    )
    .transform
    .entry(0, 0); // la escala en x (la de los 3 ejes daría al menos 1, por z)

/// Si la casilla [notacion] está movida (sacudida, saltando o meneándose).
bool movida(WidgetTester tester, String notacion) => !tester
    .widget<Transform>(
      find.descendant(
        of: celda(notacion),
        matching: find.byKey(const ValueKey('efecto-de-celda')),
      ),
    )
    .transform
    .isIdentity();

RenderObject polvo(WidgetTester tester) =>
    tester.renderObject(find.byKey(const ValueKey('polvo-del-tablero')));

/// La zona más chica del Nivel 1 con todas sus casillas menos una anotadas, y la que falta.
(Tablero, Posicion, List<Posicion>) zonaAUnaCasilla() {
  final base = Tablero.desdeMapa(nivel1);
  final zona = base.regiones.reduce(
    (a, b) => a.casillas.length <= b.casillas.length ? a : b,
  );
  final casillas = [for (final c in zona.casillas) c.posicion];
  var tablero = base;
  for (final p in casillas.skip(1)) {
    if (tablero.celdaEn(p)!.valor == null) tablero = tablero.conValor(p, 3);
  }
  return (tablero, casillas.first, casillas);
}

void main() {
  testWidgets('Al anotar, el número aparece de golpe (se pasa y vuelve) con un "¡puf!" de '
      'polvo, y después todo queda quieto', (tester) async {
    final antes = Tablero.desdeMapa(nivel1);
    await mostrar(tester, antes);
    await mostrar(tester, antes.conValor(pos('D1'), 3));

    await tester.pump(const Duration(milliseconds: 60));
    expect(escalaDelNumero(tester, 'D1'), lessThan(1));
    expect(polvo(tester), paints..circle());
    await tester.pump(const Duration(milliseconds: 100));
    expect(escalaDelNumero(tester, 'D1'), greaterThan(1));

    await tester.pumpAndSettle();
    expect(escalaDelNumero(tester, 'D1'), 1);
    expect(polvo(tester), isNot(paints..circle()));
    expectQuieto(tester);
  });

  testWidgets(
    'Al dibujarse por primera vez, con números ya anotados, no se mueve nada',
    (tester) async {
      await mostrar(tester, Tablero.desdeMapa(nivel1).conValor(pos('D1'), 3));
      await tester.pump(const Duration(milliseconds: 60));

      expect(escalaDelNumero(tester, 'D1'), 1);
      expect(polvo(tester), isNot(paints..circle()));
      expectQuieto(tester);
    },
  );

  testWidgets('"Aquí no se puede": la casilla marcada sacude la cabeza', (
    tester,
  ) async {
    final tablero = Tablero.desdeMapa(nivel1);
    await mostrar(tester, tablero);
    await mostrar(tester, tablero, marcada: pos('D1'));

    await tester.pump(const Duration(milliseconds: 40));
    expect(movida(tester, 'D1'), isTrue);
    expect(movida(tester, 'A1'), isFalse);

    await tester.pumpAndSettle();
    expect(movida(tester, 'D1'), isFalse);
  });

  testWidgets(
    'Las casillas donde se puede anotar dan un saltito al encenderse, en ola',
    (tester) async {
      final tablero = Tablero.desdeMapa(nivel1);
      await mostrar(tester, tablero);
      await mostrar(tester, tablero, posibles: {'A1', 'G7'});

      await tester.pump(const Duration(milliseconds: 80));
      expect(movida(tester, 'A1'), isTrue);
      // G7 está lejos: sale después, en la ola.
      expect(movida(tester, 'G7'), isFalse);
      expect(movida(tester, 'B1'), isFalse, reason: 'no se encendió');

      await tester.pumpAndSettle();
      expect(movida(tester, 'A1'), isFalse);
      expect(movida(tester, 'G7'), isFalse);
    },
  );

  testWidgets('Al llenarse una zona, se menean sus casillas (y solo esa vez)', (
    tester,
  ) async {
    final (antes, falta, casillas) = zonaAUnaCasilla();
    await mostrar(tester, antes);
    await mostrar(tester, antes.conValor(falta, 3));

    await tester.pump(const Duration(milliseconds: 300));
    final otra = casillas.last;
    expect(movida(tester, otra.notacion), isTrue);
    final ajena = [for (final c in antes.celdas) c.posicion]
        .firstWhere((p) => !casillas.contains(p));
    expect(movida(tester, ajena.notacion), isFalse);
    await tester.pumpAndSettle();

    // Anotar en otra zona después no la vuelve a festejar.
    final despues = antes.conValor(falta, 3).conValor(ajena, 2);
    await mostrar(tester, despues);
    await tester.pump(const Duration(milliseconds: 300));
    expect(movida(tester, otra.notacion), isFalse);
    await tester.pumpAndSettle();
  });

  testWidgets('Con movimiento reducido, el tablero no se mueve', (
    tester,
  ) async {
    conMovimientoReducido(tester);
    final (antes, falta, casillas) = zonaAUnaCasilla();
    await mostrar(tester, antes);
    await mostrar(
      tester,
      antes.conValor(falta, 3),
      marcada: pos('A1'),
      posibles: {'B1'},
    );

    await tester.pump(const Duration(milliseconds: 100));
    expect(escalaDelNumero(tester, falta.notacion), 1);
    expect(polvo(tester), isNot(paints..circle()));
    for (final p in [...casillas, pos('A1'), pos('B1')]) {
      expect(movida(tester, p.notacion), isFalse, reason: p.notacion);
    }
    expectQuieto(tester);
  });
}
