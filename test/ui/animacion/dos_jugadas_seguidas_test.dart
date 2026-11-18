import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/tablero.dart';
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

void main() {
  testWidgets('Dos números seguidos, antes de que se vaya el polvo del primero (por ejemplo, '
      'dos respuestas del servidor muy juntas): cada uno aparece, y el polvo vuelve a '
      'salir entero con el segundo', (tester) async {
    final vacio = Tablero.desdeMapa(nivel1);
    final conUno = vacio.conValor(pos('D1'), 3);
    final conDos = conUno.conValor(pos('G7'), 2);

    await mostrar(tester, vacio);
    await mostrar(tester, conUno);
    await tester.pump(const Duration(milliseconds: 100));
    await mostrar(tester, conDos);
    await tester.pump(const Duration(milliseconds: 60));

    // Los dos están apareciendo, cada uno a su tiempo.
    expect(escalaDelNumero(tester, 'D1'), isNot(1));
    expect(escalaDelNumero(tester, 'G7'), lessThan(1));
    expect(polvoEnElTablero(tester), isTrue);

    // 0,46 s después del primero (el polvo dura 0,38 s), el del segundo sigue.
    await tester.pump(const Duration(milliseconds: 300));
    expect(polvoEnElTablero(tester), isTrue);

    await tester.pumpAndSettle();
    expect(escalaDelNumero(tester, 'D1'), 1);
    expect(escalaDelNumero(tester, 'G7'), 1);
    expectNadaSeMueve(tester);
    expectQuieto(tester);
  });

  testWidgets(
    'Si el mismo tablero llega otra vez (otra respuesta igual), no vuelve a '
    'festejar',
    (tester) async {
      final vacio = Tablero.desdeMapa(nivel1);
      final conUno = vacio.conValor(pos('D1'), 3);
      await mostrar(tester, vacio);
      await mostrar(tester, conUno);
      await tester.pumpAndSettle();

      // Un tablero igual, pero otro objeto: como cuando el servidor contesta de nuevo.
      await mostrar(tester, vacio.conValor(pos('D1'), 3));
      await tester.pump(const Duration(milliseconds: 60));
      expectNadaSeMueve(tester);
      expectQuieto(tester);
    },
  );
}
