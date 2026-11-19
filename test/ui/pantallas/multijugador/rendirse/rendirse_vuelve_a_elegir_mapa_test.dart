import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

final botonRendirse = find.byKey(const ValueKey('boton-rendirse'));
final confirmarRendirse = find.byKey(const ValueKey('confirmar-rendirse'));

/// Entra a una partida en juego de [jugadores] (yo soy "ana", que no es la anfitriona).
Future<SalasFalsas> enPartidaDe(
  WidgetTester tester,
  List<String> jugadores,
) async {
  final salas = SalasFalsas();
  await abrirMultijugador(tester, salas);
  await crearSala(
    tester,
    salas,
    vistaDePrueba(
      estado: 'jugando',
      ronda: 1,
      dados: const [1, 3],
      segundosRestantes: 60,
      anfitrion: jugadores.last,
      jugadores: [
        for (final j in jugadores)
          jugadorJson(j, anfitrion: j == jugadores.last),
      ],
    ),
  );
  return salas;
}

void main() {
  testWidgets(
    'Con 3 jugadores, sin ser anfitrión: rendirse vuelve a "Elige un mapa", aunque '
    'la partida de los demás siga (antes quedaba atrapado en la partida)',
    (tester) async {
      final salas = await enPartidaDe(tester, ['ana', 'beto', 'carla']);
      // El servidor la marca como rendida y la partida sigue entre los otros dos.
      salas.alRendirse = vistaDePrueba(
        version: 8,
        estado: 'jugando',
        ronda: 1,
        dados: const [1, 3],
        miEstado: 'se_rindio',
        anfitrion: 'carla',
      );

      await tocar(tester, botonRendirse);
      await tocar(tester, confirmarRendirse);

      expect(salas.llamadas.where((l) => l == 'rendirse'), hasLength(1));
      expect(find.text('Elige un mapa'), findsOneWidget);
    },
  );

  testWidgets('Con 2 jugadores: rendirse también vuelve a "Elige un mapa", sin pasar por el '
      'resultado', (tester) async {
    final salas = await enPartidaDe(tester, ['ana', 'beto']);
    salas.alRendirse = vistaDePrueba(
      version: 8,
      estado: 'terminada',
      miEstado: 'se_rindio',
      anfitrion: 'beto',
      resultado: {
        'motivo': 'ultimo_jugador',
        'ganadores': ['beto'],
        'ranking': [],
      },
    );

    await tocar(tester, botonRendirse);
    await tocar(tester, confirmarRendirse);

    expect(find.text('Elige un mapa'), findsOneWidget);
    expect(find.byKey(const ValueKey('resultado')), findsNothing);
  });

  testWidgets('"Rendirme" no se puede mandar dos veces: mientras va el pedido, el botón no '
      'responde', (tester) async {
    final salas = await enPartidaDe(tester, ['ana', 'beto', 'carla']);
    final soltar = Completer<void>();
    salas.esperaAntesDeRendirse = soltar.future;

    await tocar(tester, botonRendirse);
    await tocar(tester, confirmarRendirse);
    await tocar(tester, botonRendirse);
    expect(
      find.text('¿Rendirte?'),
      findsNothing,
      reason: 'no abre otro diálogo',
    );

    soltar.complete();
    await tester.pumpAndSettle();
    expect(salas.llamadas.where((l) => l == 'rendirse'), hasLength(1));
    expect(find.text('Elige un mapa'), findsOneWidget);
  });

  testWidgets(
    'Si al rendirse no hay conexión y mientras tanto se abrió la hoja de reglas, '
    'igual vuelve a "Elige un mapa" (antes cerraba la hoja y dejaba la pantalla)',
    (tester) async {
      final salas = await enPartidaDe(tester, ['ana', 'beto', 'carla']);
      final soltar = Completer<void>();
      salas.esperaAntesDeRendirse = soltar.future;

      await tocar(tester, botonRendirse);
      await tocar(tester, confirmarRendirse);
      await tocar(tester, find.byKey(const ValueKey('boton-reglas')));
      expect(find.byKey(const ValueKey('hoja-de-reglas')), findsOneWidget);

      salas.sinConexion = true;
      soltar.complete();
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('hoja-de-reglas')), findsNothing);
      expect(find.text('Elige un mapa'), findsOneWidget);
    },
  );
}
