import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

final botonRendirse = find.byKey(const ValueKey('boton-rendirse'));
final botonSalir = find.byKey(const ValueKey('boton-salir'));

Future<void> atras(WidgetTester tester) async {
  await tester.pageBack();
  await tester.pumpAndSettle();
}

/// El diálogo de rendirse, el mismo desde el botón y desde la flecha.
void expectDialogoDeRendirse() {
  expect(find.text('¿Rendirte?'), findsOneWidget);
  expect(find.text('Quedarás fuera de la partida.'), findsOneWidget);
  expect(find.widgetWithText(FilledButton, 'Rendirme'), findsOneWidget);
}

void main() {
  testWidgets(
    'La flecha en la partida pregunta lo mismo que el botón "Rendirme", y '
    'confirmar vuelve a "Elige un mapa"',
    (tester) async {
      final salas = SalasFalsas();
      await abrirMultijugador(tester, salas);
      await crearSala(tester, salas, partidaEnJuego());

      await tocar(tester, botonRendirse);
      expectDialogoDeRendirse();
      await tocar(tester, find.text('Seguir jugando'));

      await atras(tester);
      expectDialogoDeRendirse();
      await tocar(tester, find.widgetWithText(FilledButton, 'Rendirme'));

      expect(salas.llamadas, contains('rendirse'));
      expect(find.text('Elige un mapa'), findsOneWidget);
    },
  );

  testWidgets(
    'La flecha mientras reparto mis números también pregunta, igual',
    (tester) async {
      final salas = SalasFalsas();
      await abrirMultijugador(tester, salas);
      await crearSala(
        tester,
        salas,
        vistaDePrueba(estado: 'preparando', segundosRestantes: 60),
      );

      await atras(tester);
      expectDialogoDeRendirse();
      await tocar(tester, find.widgetWithText(FilledButton, 'Rendirme'));

      expect(find.text('Elige un mapa'), findsOneWidget);
    },
  );

  testWidgets(
    'Quien ya quedó fuera (se desconectó) sale con la flecha sin que se le '
    'pregunte, o con "Salir"',
    (tester) async {
      final salas = SalasFalsas();
      await abrirMultijugador(tester, salas);
      final fuera = vistaDePrueba(
        estado: 'jugando',
        ronda: 3,
        dados: const [2, 2],
        miEstado: 'desconectado',
      );
      await crearSala(tester, salas, fuera);

      await atras(tester);
      expect(find.text('¿Rendirte?'), findsNothing);
      expect(find.text('Elige un mapa'), findsOneWidget);
      expect(salas.llamadas, isNot(contains('rendirse')));

      // Y otra vez, con el botón.
      await tocar(tester, botonMultijugador);
      await crearSala(tester, salas, fuera);
      await tocar(
        tester,
        find.byKey(const ValueKey('boton-salir-de-la-partida')),
      );
      expect(find.text('Elige un mapa'), findsOneWidget);
    },
  );

  testWidgets(
    'El anfitrión confirma antes de cerrar la sala, con el botón y con la flecha',
    (tester) async {
      final salas = SalasFalsas();
      await abrirMultijugador(tester, salas);
      await crearSala(tester, salas, vistaDePrueba());

      await tocar(tester, botonSalir);
      expect(find.text('¿Cerrar la sala?'), findsOneWidget);
      expect(find.text('Los demás quedarán fuera.'), findsOneWidget);
      await tocar(tester, find.text('Seguir en la sala'));
      expect(salas.llamadas, isNot(contains('rendirse')));

      await atras(tester);
      expect(find.text('¿Cerrar la sala?'), findsOneWidget);
      await tocar(tester, find.widgetWithText(FilledButton, 'Cerrar'));

      expect(salas.llamadas, contains('rendirse'));
      expect(find.text('Elige un mapa'), findsOneWidget);
    },
  );

  testWidgets(
    'El invitado sale del lobby de un toque, sin que se le pregunte',
    (tester) async {
      final salas = SalasFalsas()
        ..vista = vistaDePrueba(yo: 'beto', anfitrion: 'ana');
      await abrirMultijugador(tester, salas);
      await tester.enterText(campoCodigo, 'k7m4qx');
      await tocar(tester, botonUnirse);

      await tocar(tester, botonSalir);

      expect(find.text('¿Cerrar la sala?'), findsNothing);
      expect(salas.llamadas, contains('rendirse'));
      expect(find.text('Elige un mapa'), findsOneWidget);
    },
  );
}
