import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/tema.dart';
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

  testWidgets('Tocar la tarjeta de un mapa lo elige, y la elegida se pinta del amarillo de ficha', (
    tester,
  ) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(tester, salas, vistaDePrueba(nivel: 2));

    bool elegida(int nivel) => tester
            .widget<Material>(
              find.ancestor(of: find.byKey(ValueKey('mapa-$nivel')), matching: find.byType(Material)).first,
            )
            .color ==
        Paleta.ficha;

    expect(elegida(2), isTrue);
    expect(elegida(3), isFalse);

    salas.vista = vistaDePrueba(nivel: 3, version: 2);
    await tocar(tester, find.byKey(const ValueKey('mapa-3')));

    expect(salas.llamadas, contains('mapa 3'));
    expect(elegida(3), isTrue);
    expect(elegida(2), isFalse);
  });
}
