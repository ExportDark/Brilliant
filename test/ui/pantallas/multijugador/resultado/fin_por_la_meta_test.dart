import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('Si alguien llegó a la meta, el resultado lo dice con los puntos de la meta, y '
      'cada fila muestra cuánto llegó a llenar de la pista', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(
      tester,
      salas,
      vistaDePrueba(
        estado: 'terminada',
        meta: 26,
        resultado: {
          'motivo': 'meta_alcanzada',
          'ganadores': ['beto'],
          'ranking': [
            {'usuario': 'beto', 'estado': 'activo', 'puntos': 27, 'primeros': 3},
            {'usuario': 'ana', 'estado': 'activo', 'puntos': 13, 'primeros': 1},
          ],
        },
      ),
    );

    expect(find.text('Ganó beto'), findsOneWidget);
    expect(find.text('Se alcanzó la meta: 26 puntos.'), findsOneWidget);
    expect(find.byKey(const ValueKey('pista-beto')), findsOneWidget);
    expect(find.byKey(const ValueKey('pista-ana')), findsOneWidget);
  });
}
