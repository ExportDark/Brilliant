import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/multijugador/modelos.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('Con un solo jugador, "Empezar" está deshabilitado y dice cuántos hacen falta', (
    tester,
  ) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);

    await crearSala(
      tester,
      salas,
      vistaDePrueba(jugadores: [jugadorJson('ana', anfitrion: true)]),
    );

    expect(habilitado(tester, botonEmpezar), isFalse);
    expect(find.text('Hacen falta al menos 2 jugadores.'), findsOneWidget);
  });

  testWidgets('Con dos jugadores, "Empezar" se habilita y manda empezar', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(tester, salas, vistaDePrueba());

    expect(habilitado(tester, botonEmpezar), isTrue);
    expect(find.text('Hacen falta al menos 2 jugadores.'), findsNothing);

    salas.vista = vistaDePrueba(version: 2, estado: 'preparando');
    await tocar(tester, botonEmpezar);

    expect(salas.llamadas.last, 'empezar');
    expect(find.byKey(const ValueKey('preparacion-en-linea')), findsOneWidget);
  });

  testWidgets('Con 6 jugadores el lobby los muestra a todos', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);

    await crearSala(
      tester,
      salas,
      vistaDePrueba(jugadores: [
        jugadorJson('ana', anfitrion: true),
        for (final n in ['beto', 'carla', 'dani', 'eli', 'fer']) jugadorJson(n),
      ]),
    );

    expect(find.textContaining('Jugadores (6/6)'), findsOneWidget);
    for (final n in ['ana', 'beto', 'carla', 'dani', 'eli', 'fer']) {
      expect(find.byKey(ValueKey('jugador-$n')), findsOneWidget, reason: n);
    }
  });

  testWidgets('Quien no es el anfitrión no ve "Empezar": espera', (tester) async {
    final salas = SalasFalsas()..vista = vistaDePrueba(yo: 'beto', anfitrion: 'ana');
    await abrirMultijugador(tester, salas);

    await tester.enterText(campoCodigo, 'K7M4QX');
    await tocar(tester, botonUnirse);

    expect(botonEmpezar, findsNothing);
    expect(find.byKey(const ValueKey('esperando-al-anfitrion')), findsOneWidget);
  });

  testWidgets('Si el servidor rechaza empezar, muestra su mensaje', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(tester, salas, vistaDePrueba());
    salas.errorEnElProximo = const ErrorDeSala(
      codigo: 'pocos_jugadores',
      mensaje: 'Hacen falta al menos 2 jugadores para empezar.',
      estadoHttp: 409,
    );

    await tocar(tester, botonEmpezar);

    expect(find.text('Hacen falta al menos 2 jugadores para empezar.'), findsOneWidget);
    expect(find.byKey(const ValueKey('codigo-de-sala')), findsOneWidget);
  });
}
