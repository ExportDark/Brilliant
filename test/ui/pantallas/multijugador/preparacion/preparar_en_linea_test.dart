import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/multijugador/modelos.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('La preparación es la de siempre: se reparten los 6 números y "Inicio" los manda', (
    tester,
  ) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(tester, salas, vistaDePrueba(estado: 'preparando', segundosRestantes: 60));
    expect(find.text('Reparte tus números · 60 s'), findsOneWidget);

    await tocar(tester, find.text('Aleatorio'));
    salas.vista = vistaDePrueba(estado: 'preparando', version: 3, preparado: true, segundosRestantes: 55);
    await tocar(tester, find.widgetWithText(FilledButton, 'Inicio'));

    expect(salas.llamadas, contains('preparar 6'));
    expect(find.byKey(const ValueKey('esperando-la-preparacion')), findsOneWidget);
  });

  testWidgets('Mientras faltan números, "Inicio" no manda nada', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(tester, salas, vistaDePrueba(estado: 'preparando'));

    expect(habilitado(tester, find.widgetWithText(FilledButton, 'Inicio')), isFalse);
    expect(salas.llamadas.where((l) => l.startsWith('preparar')), isEmpty);
  });

  testWidgets('Ya repartí: espero a los demás, y se ve quién ya terminó', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);

    await crearSala(
      tester,
      salas,
      vistaDePrueba(
        estado: 'preparando',
        preparado: true,
        segundosRestantes: 41,
        jugadores: [
          jugadorJson('ana', anfitrion: true, listo: true),
          jugadorJson('beto'),
        ],
      ),
    );

    expect(find.text('Listo. Esperando a los demás… · 41 s'), findsOneWidget);
    expect(tester.widget<Icon>(find.byKey(const ValueKey('listo-ana'))).icon, Icons.check_circle_rounded);
    expect(tester.widget<Icon>(find.byKey(const ValueKey('listo-beto'))).icon, Icons.hourglass_empty_rounded);
  });

  testWidgets('Cuando todos terminaron, pasa a la partida sola', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(
      tester,
      salas,
      vistaDePrueba(estado: 'preparando', preparado: true, segundosRestantes: 30),
    );

    salas.vista = partidaEnJuego(version: 8);
    await pasarSegundos(tester, 1);

    expect(find.byKey(const ValueKey('ronda-y-tiempo')), findsOneWidget);
    expect(find.byKey(const ValueKey('esperando-la-preparacion')), findsNothing);
  });

  testWidgets('Un reparto que el servidor rechaza muestra su mensaje y se puede corregir', (
    tester,
  ) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(tester, salas, vistaDePrueba(estado: 'preparando'));
    await tocar(tester, find.text('Aleatorio'));
    salas.errorEnElProximo = const ErrorDeSala(
      codigo: 'preparacion_invalida',
      mensaje: 'El 3 no cabe en E1.',
      estadoHttp: 400,
    );

    await tocar(tester, find.widgetWithText(FilledButton, 'Inicio'));

    expect(find.text('El 3 no cabe en E1.'), findsOneWidget);
  });
}
