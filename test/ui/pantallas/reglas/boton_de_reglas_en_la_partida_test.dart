import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../ayudantes_pantallas.dart';

final botonReglas = find.byKey(const ValueKey('boton-reglas'));
final hoja = find.byKey(const ValueKey('hoja-de-reglas'));

void main() {
  testWidgets('En la partida, "Reglas" abre las reglas de cada color del mapa, y al cerrarlas '
      'la partida sigue igual', (tester) async {
    await abrirPartida(tester);
    await tirarYElegirAncla(tester, 0);

    await tocar(tester, botonReglas);

    expect(hoja, findsOneWidget);
    expect(find.text('Reglas del Nivel 1'), findsOneWidget);
    expect(find.textContaining('Toca un dado: es el ancla'), findsOneWidget);
    for (final regla in [
      'Todos diferentes: ningún número se repite entre las casillas amarillas.',
      'Cualquiera: sin restricción de valor.',
      'Todos iguales: todas las casillas llevan el mismo número.',
      'Solo dos números diferentes en toda la zona.',
      'Todos diferentes: ningún número se repite en la zona.',
    ]) {
      expect(find.text(regla), findsOneWidget, reason: regla);
    }

    await tester.tapAt(const Offset(20, 20)); // fuera de la hoja
    await tester.pumpAndSettle();

    expect(hoja, findsNothing);
    // Sigue el mismo turno, con el mismo dado ancla elegido.
    expect(find.textContaining('Pon el 3 en una casilla iluminada'), findsOneWidget);
  });
}
