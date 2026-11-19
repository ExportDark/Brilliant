import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

/// Mientras va un pedido al servidor, lo que lo mandaría otra vez no responde: así una
/// casilla, "Pasar turno" o "Inicio" tocados dos veces mandan un solo pedido.
void main() {
  int pedidos(SalasFalsas salas, String inicio) =>
      salas.llamadas.where((l) => l.startsWith(inicio)).length;

  testWidgets('Las casillas no responden mientras va la jugada', (
    tester,
  ) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(tester, salas, partidaEnJuego());
    await tocar(tester, dadoEn(0)); // el ancla es el 1: el 3 va en D1, E2 o F1
    final soltar = Completer<void>();
    salas.esperaAntesDeActuar = soltar.future;

    await tocar(tester, casillaTocable('D1'));
    expect(
      casillaTocable('E2'),
      findsNothing,
      reason: 'mientras va, no se puede tocar',
    );

    soltar.complete();
    await tester.pumpAndSettle();
    expect(pedidos(salas, 'jugar'), 1);
  });

  testWidgets('"Pasar turno" no responde mientras va el pedido', (
    tester,
  ) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(
      tester,
      salas,
      vistaDePrueba(
        estado: 'jugando',
        ronda: 1,
        dados: const [6, 6],
        segundosRestantes: 60,
        puedePasar: true,
        jugadas: const [
          {'ancla': 6, 'valor': 6, 'casillas': <String>[]},
        ],
      ),
    );
    final soltar = Completer<void>();
    salas.esperaAntesDeActuar = soltar.future;
    final pasar = find.byKey(const ValueKey('boton-pasar'));

    await tocar(tester, pasar);
    await tester.tap(pasar, warnIfMissed: false);
    await tester.pump();

    soltar.complete();
    await tester.pumpAndSettle();
    expect(pedidos(salas, 'pasar'), 1);
  });

  testWidgets(
    '"Inicio" en el reparto en línea no responde mientras va el reparto',
    (tester) async {
      final salas = SalasFalsas();
      await abrirMultijugador(tester, salas);
      await crearSala(
        tester,
        salas,
        vistaDePrueba(estado: 'preparando', segundosRestantes: 60),
      );
      await tocar(tester, find.widgetWithText(TextButton, 'Aleatorio'));
      final soltar = Completer<void>();
      salas.esperaAntesDeActuar = soltar.future;
      final inicio = find.widgetWithText(FilledButton, 'Inicio');

      await tocar(tester, inicio);
      expect(habilitado(tester, inicio), isFalse);

      soltar.complete();
      await tester.pumpAndSettle();
      expect(pedidos(salas, 'preparar'), 1);
    },
  );
}
