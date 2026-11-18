import 'package:brilliant/ui/pantallas/multijugador/tablero_chico.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('El resultado también muestra el tablero chico de cada uno, como terminó', (
    tester,
  ) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(
      tester,
      salas,
      vistaDePrueba(
        estado: 'terminada',
        jugadores: [
          jugadorJson('ana', anfitrion: true, ocupadas: ['A3', 'D1'], ultima: 'D1'),
          jugadorJson('beto', ocupadas: ['A3']),
        ],
        resultado: {
          'motivo': 'tablero_lleno',
          'ganadores': ['ana'],
          'ranking': [
            {'usuario': 'ana', 'estado': 'activo', 'puntos': 9, 'primeros': 1},
            {'usuario': 'beto', 'estado': 'activo', 'puntos': 3, 'primeros': 0},
          ],
        },
      ),
    );

    final ana = tester.widget<TableroChico>(find.byKey(const ValueKey('tablero-chico-ana')));
    expect(ana.ocupadas, {'A3', 'D1'});
    expect(ana.ultima, 'D1');
    expect(find.byKey(const ValueKey('tablero-chico-beto')), findsOneWidget);
  });
}
