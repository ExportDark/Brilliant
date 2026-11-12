import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../multijugador/ayudantes_salas.dart';
import '../ayudantes_pantallas.dart';

final botonReglas = find.byKey(const ValueKey('boton-reglas'));

void main() {
  testWidgets('La preparación también tiene "Reglas"', (tester) async {
    await abrirPreparacion(tester);

    await tocar(tester, botonReglas);

    expect(find.text('Reglas del Nivel 1'), findsOneWidget);
  });

  testWidgets('En línea, "Reglas" aparece en la partida (con el mapa de la sala) y no en el '
      'lobby', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(tester, salas, vistaDePrueba(nivel: 3));
    expect(botonReglas, findsNothing, reason: 'en el lobby todavía no');

    salas.vista = vistaDePrueba(version: 4, nivel: 3, estado: 'jugando', ronda: 1, dados: const [1, 3]);
    await pasarSegundos(tester, 1);
    await tocar(tester, botonReglas);

    expect(find.text('Reglas del Nivel 3'), findsOneWidget);
    expect(find.textContaining('cada zona da puntos'), findsOneWidget);
  });
}
