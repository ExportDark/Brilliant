import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';
import 'package:brilliant/ui/widgets/tablero_widget.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('La pantalla dibuja un solo tablero: el mío', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);

    await crearSala(
      tester,
      salas,
      vistaDePrueba(
        estado: 'jugando',
        ronda: 2,
        dados: const [1, 3],
        tablero: const {'E1': 1, 'A3': 3},
        jugadores: [
          jugadorJson('ana', anfitrion: true),
          jugadorJson('beto', puntos: 6),
          jugadorJson('carla', puntos: 3),
        ],
      ),
    );

    // Un solo tablero, con sus 49 casillas: el mío. No hay tableros de beto ni de carla.
    expect(find.byType(TableroWidget), findsOneWidget);
    expect(find.byType(CeldaWidget), findsNWidgets(49));
  });

  testWidgets('De los demás jugadores solo se ve su nombre, estado, puntos y si ya jugaron', (
    tester,
  ) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);

    await crearSala(
      tester,
      salas,
      vistaDePrueba(
        estado: 'jugando',
        ronda: 2,
        dados: const [1, 3],
        tablero: const {'E1': 1, 'A3': 3},
        jugadores: [
          jugadorJson('ana', anfitrion: true),
          jugadorJson('beto', puntos: 6, listo: true, zonas: [4]),
        ],
      ),
    );

    final fila = find.byKey(const ValueKey('jugador-beto'));
    expect(find.descendant(of: fila, matching: find.text('beto')), findsOneWidget);
    expect(find.descendant(of: fila, matching: find.text('6 pts')), findsOneWidget);
    // Ninguna casilla ni número de beto: en su fila no hay ninguna celda, ningún tablero
    // ni ninguna coordenada; solo su nombre, sus puntos, un punto por zona llena y si ya
    // jugó (un ícono).
    expect(find.descendant(of: fila, matching: find.byType(CeldaWidget)), findsNothing);
    expect(find.descendant(of: fila, matching: find.byType(TableroWidget)), findsNothing);
    expect(find.descendant(of: fila, matching: find.byType(Icon)), findsOneWidget);
    expect(find.descendant(of: fila, matching: find.textContaining('E1')), findsNothing);
  });

  testWidgets('Solo se dibujan los números de mi tablero, ni uno más', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);

    await crearSala(
      tester,
      salas,
      vistaDePrueba(
        estado: 'jugando',
        ronda: 2,
        dados: const [1, 3],
        tablero: const {'E1': 1, 'A3': 3, 'D1': 3},
      ),
    );

    expect(
      celdasDibujadasDonde(tester, (c) => c.celda.valor != null),
      {'E1', 'A3', 'D1'},
    );
  });
}
