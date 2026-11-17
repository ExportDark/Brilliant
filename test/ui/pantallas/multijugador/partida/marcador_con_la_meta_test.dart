import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

/// Cuánto de la pista de [usuario] está lleno (de 0 a 1).
double avanceDe(WidgetTester tester, String usuario) => tester
    .widget<FractionallySizedBox>(
      find.descendant(
        of: find.byKey(ValueKey('pista-$usuario')),
        matching: find.byType(FractionallySizedBox),
      ),
    )
    .widthFactor!;

Future<void> abrirConMeta(WidgetTester tester, int? meta) async {
  final salas = SalasFalsas();
  await abrirMultijugador(tester, salas);
  await crearSala(
    tester,
    salas,
    vistaDePrueba(
      estado: 'jugando',
      ronda: 9,
      dados: const [1, 3],
      segundosRestantes: 30,
      meta: meta,
      jugadores: [
        jugadorJson('ana', anfitrion: true, puntos: 11),
        jugadorJson('beto', puntos: 30),
        jugadorJson('carla'),
        jugadorJson('dani'),
      ],
    ),
  );
}

void main() {
  testWidgets('El marcador dice la meta, y la pista de cada uno muestra cuánto lleva', (
    tester,
  ) async {
    await abrirConMeta(tester, 22);

    expect(
      find.text('Gana el primero que llegue a 22 puntos. Cada punto de color es una zona que llenó.'),
      findsOneWidget,
    );
    expect(avanceDe(tester, 'ana'), 0.5);
    expect(avanceDe(tester, 'carla'), 0.0);
    // Pasarse de la meta no desborda la pista.
    expect(avanceDe(tester, 'beto'), 1.0);
  });

  testWidgets('Con un servidor que no manda la meta, el marcador sigue como antes, sin pista', (
    tester,
  ) async {
    await abrirConMeta(tester, null);

    expect(find.text('Cada punto de color es una zona que llenó.'), findsOneWidget);
    expect(find.textContaining('Gana el primero'), findsNothing);
    expect(find.byKey(const ValueKey('pista-ana')), findsNothing);
  });
}
