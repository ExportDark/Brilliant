import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/pantallas/pantalla_preparacion.dart';

import '../../../juego/ayudantes.dart';
import '../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaPartida: con el tablero lleno, festeja y deja jugar otra vez', (
    tester,
  ) async {
    // Las 49 casillas llenas: la partida ya terminó.
    await abrirPartida(tester, tablero: llenoMenos('E5').conValor(pos('E5'), 1));

    expect(find.text('¡Tablero completo!'), findsOneWidget);
    expect(find.text('49 de 49 casillas'), findsOneWidget);
    expect(botonTirar, findsNothing);

    await tocar(tester, find.widgetWithText(FilledButton, 'Jugar otra vez'));

    expect(find.byType(PantallaPreparacion), findsOneWidget);
    expect(find.text('Prepara tu tablero'), findsOneWidget);
  });
}
