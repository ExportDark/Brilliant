import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/multijugador/modelos.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('Unirse: lo que se escribe queda en mayúsculas, sin símbolos y de 6 como mucho', (
    tester,
  ) async {
    await abrirMultijugador(tester, SalasFalsas());

    await tester.enterText(campoCodigo, 'k7-m4 qxzz');
    await tester.pump();

    expect(tester.widget<TextField>(campoCodigo).controller!.text, 'K7M4QX');
  });

  testWidgets('Unirse con el código manda ese código y entra al lobby', (tester) async {
    final salas = SalasFalsas()..vista = vistaDePrueba(yo: 'beto', anfitrion: 'ana');
    await abrirMultijugador(tester, salas);

    await tester.enterText(campoCodigo, 'k7m4qx');
    await tocar(tester, botonUnirse);

    expect(salas.llamadas, ['unirse K7M4QX']);
    expect(find.byKey(const ValueKey('codigo-de-sala')), findsOneWidget);
    expect(find.text('beto (tú)'), findsOneWidget);
  });

  testWidgets('Unirse sin escribir el código avisa sin molestar al servidor', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);

    await tocar(tester, botonUnirse);

    expect(find.text('Escribe el código de la sala.'), findsOneWidget);
    expect(salas.llamadas, isEmpty);
  });

  testWidgets('Un código que no existe avisa y se puede intentar con otro', (tester) async {
    final salas = SalasFalsas()
      ..errorEnElProximo = const ErrorDeSala(
        codigo: 'sala_no_existe',
        mensaje: 'No hay ninguna sala con ese código.',
        estadoHttp: 404,
      );
    await abrirMultijugador(tester, salas);

    await tester.enterText(campoCodigo, 'ZZZZZZ');
    await tocar(tester, botonUnirse);

    expect(find.text('No hay ninguna sala con ese código.'), findsOneWidget);
    expect(campoCodigo, findsOneWidget, reason: 'sigue en la pantalla de unirse');
    expect(find.byKey(const ValueKey('fin-de-la-sala')), findsNothing);
  });

  testWidgets('Sala llena: muestra el mensaje del servidor', (tester) async {
    final salas = SalasFalsas()
      ..errorEnElProximo = const ErrorDeSala(
        codigo: 'sala_llena',
        mensaje: 'La sala ya tiene 6 jugadores.',
        estadoHttp: 409,
      );
    await abrirMultijugador(tester, salas);

    await tester.enterText(campoCodigo, 'K7M4QX');
    await tocar(tester, botonUnirse);

    expect(find.text('La sala ya tiene 6 jugadores.'), findsOneWidget);
  });

  testWidgets('Partida que ya empezó: muestra el mensaje del servidor', (tester) async {
    final salas = SalasFalsas()
      ..errorEnElProximo = const ErrorDeSala(
        codigo: 'ya_empezo',
        mensaje: 'La partida ya empezó o terminó.',
        estadoHttp: 409,
      );
    await abrirMultijugador(tester, salas);

    await tester.enterText(campoCodigo, 'K7M4QX');
    await tocar(tester, botonUnirse);

    expect(find.text('La partida ya empezó o terminó.'), findsOneWidget);
  });
}
