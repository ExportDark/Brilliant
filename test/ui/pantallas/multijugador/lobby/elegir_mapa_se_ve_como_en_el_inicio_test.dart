import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/widgets/tablero_widget.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('El anfitrión elige el mapa viendo los 4 mapas con su tablero, no "Nivel 1, 2, 3, 4"',
      (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(tester, salas, vistaDePrueba(nivel: 2));

    for (final nivel in [1, 2, 3, 4]) {
      expect(find.byKey(ValueKey('mapa-$nivel')), findsOneWidget);
    }
    expect(find.byType(ChoiceChip), findsNothing);
    // Cada tarjeta lleva el tablero del mapa en miniatura.
    expect(find.byType(TableroWidget), findsNWidgets(4));
    expect(find.text('Nivel 3'), findsOneWidget);
  });

  testWidgets('Tocar la tarjeta de un mapa lo elige, y el elegido lleva el borde de color', (
    tester,
  ) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(tester, salas, vistaDePrueba(nivel: 2));

    Color? borde(int nivel) {
      final material = tester.widget<Material>(
        find.ancestor(of: find.byKey(ValueKey('mapa-$nivel')), matching: find.byType(Material)).first,
      );
      final forma = material.shape as RoundedRectangleBorder;
      return forma.side == BorderSide.none ? null : forma.side.color;
    }

    expect(borde(2), isNotNull);
    expect(borde(3), isNull);

    salas.vista = vistaDePrueba(nivel: 3, version: 2);
    await tocar(tester, find.byKey(const ValueKey('mapa-3')));

    expect(salas.llamadas, contains('mapa 3'));
    expect(borde(3), isNotNull);
    expect(borde(2), isNull);
  });
}
