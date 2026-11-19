import 'dart:async';

import 'package:brilliant/multijugador/modelos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

final errorDeSala = find.byKey(const ValueKey('error-de-sala'));

void main() {
  testWidgets('Un error de la sala se va solo cuando cambia la ronda (antes quedaba ronda '
      'tras ronda)', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(tester, salas, partidaEnJuego());
    await tocar(tester, dadoEn(0));
    salas.errorEnElProximo = const ErrorDeSala(
      codigo: 'ronda_incorrecta',
      mensaje: 'Esa ronda ya pasó.',
      estadoHttp: 409,
    );
    await tocar(tester, casillaTocable('D1'));
    expect(errorDeSala, findsOneWidget);

    // La misma ronda: el aviso sigue.
    await pasarSegundos(tester, 1);
    expect(errorDeSala, findsOneWidget);

    salas.vista = vistaDePrueba(
      version: 20,
      estado: 'jugando',
      ronda: 2,
      dados: const [2, 5],
      segundosRestantes: 60,
    );
    await pasarSegundos(tester, 1);
    expect(errorDeSala, findsNothing);
  });

  testWidgets('El círculo de espera aparece en el botón que se tocó: "Crear sala" no lo pone '
      'en "Unirme"', (tester) async {
    final salas = SalasFalsas()..vista = vistaDePrueba();
    await abrirMultijugador(tester, salas);
    final soltar = Completer<void>();
    salas.esperaAntesDeActuar = soltar.future;

    await tocar(tester, botonCrearSala);
    expect(
      find.descendant(
        of: botonUnirse,
        matching: find.byType(CircularProgressIndicator),
      ),
      findsNothing,
    );

    soltar.complete();
    await tester.pumpAndSettle();
  });

  testWidgets(
    'Copiar el código lo dice: el ícono pasa a una palomita un momento',
    (tester) async {
      final copiado = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (llamada) async {
          if (llamada.method == 'Clipboard.setData') {
            copiado.add((llamada.arguments as Map)['text'] as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      final salas = SalasFalsas();
      await abrirMultijugador(tester, salas);
      await crearSala(tester, salas, vistaDePrueba());
      final copiar = find.byKey(const ValueKey('copiar-codigo'));

      await tocar(tester, copiar);
      expect(copiado, ['K7M4QX']);
      expect(
        find.descendant(of: copiar, matching: find.byIcon(Icons.check_rounded)),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: copiar, matching: find.byIcon(Icons.copy_rounded)),
        findsOneWidget,
      );
    },
  );

  testWidgets('Un dado sin jugadas se ve apagado', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(
      tester,
      salas,
      partidaEnJuego(
        jugadas: const [
          {
            'ancla': 1,
            'valor': 3,
            'casillas': ['D1'],
          },
          {'ancla': 3, 'valor': 1, 'casillas': <String>[]},
        ],
      ),
    );

    double opacidad(int dado) => tester
        .widget<Opacity>(
          find.ancestor(of: dadoEn(dado), matching: find.byType(Opacity)).first,
        )
        .opacity;
    expect(opacidad(0), 1);
    expect(opacidad(1), lessThan(1));
  });

  testWidgets('Tocar el mapa que ya está elegido no manda nada', (
    tester,
  ) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(tester, salas, vistaDePrueba(nivel: 2));

    await tocar(tester, find.byKey(const ValueKey('mapa-2')));

    expect(salas.llamadas.where((l) => l.startsWith('mapa')), isEmpty);
  });

  testWidgets('"Jugadores (n/6)" cuenta solo a los que siguen en la sala', (
    tester,
  ) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(
      tester,
      salas,
      vistaDePrueba(
        jugadores: [
          jugadorJson('ana', anfitrion: true),
          jugadorJson('beto'),
          jugadorJson('carla', estado: 'desconectado'),
        ],
      ),
    );

    expect(find.text('Jugadores (2/6)'), findsOneWidget);
  });
}
