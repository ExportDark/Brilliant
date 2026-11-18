import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../juego/ayudantes.dart';
import '../../multijugador/ayudantes_salas.dart';
import '../pantallas/ayudantes_pantallas.dart';
import 'ayudantes_animacion.dart';

const pantalla = Size(1000, 1400);

/// Que el iris esté tapando la pantalla entera, con la barra de arriba.
void expectCubreTodo(WidgetTester tester) {
  expect(
    irisJugandose,
    findsOneWidget,
    reason: 'tiene que haber un iris jugándose',
  );
  expect(tester.getRect(irisJugandose), Offset.zero & pantalla);
}

/// Que el servidor falso pase a contestar [vista], y que la app le pregunte (sin dejar
/// que se asiente: así se ve el iris a mitad de camino).
Future<void> llega(
  WidgetTester tester,
  SalasFalsas salas,
  dynamic vista,
) async {
  salas.vista = vista;
  await tester.pump(const Duration(seconds: 1));
  await tester.pump();
}

void main() {
  testWidgets(
    'Jugando solo, el iris del final tapa también la barra de arriba',
    (tester) async {
      // E5 es la última casilla libre: con el 1 de ancla, el 6 va ahí.
      await abrirPartida(tester, tablero: soloCabeElSeisEnE5(), caras: [6, 1]);
      await tirarYElegirAncla(tester, 1);
      await tester.tap(casillaTocable('E5'));
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 550));
      expect(find.text('¡Tablero completo!'), findsOneWidget);
      expectCubreTodo(tester);
      await tester.pumpAndSettle();
      expectQuieto(tester);
    },
  );

  testWidgets(
    'En línea, el iris al empezar y el del final tapan también la barra de '
    'arriba',
    (tester) async {
      final salas = SalasFalsas();
      await abrirSalaSola(tester, salas, tamano: pantalla);
      await crearSala(tester, salas, vistaDePrueba());

      await llega(tester, salas, partidaEnJuego(version: 9));
      await tester.pump(const Duration(milliseconds: 100));
      expectCubreTodo(tester);
      await tester.pumpAndSettle();

      await llega(
        tester,
        salas,
        vistaDePrueba(
          version: 10,
          estado: 'terminada',
          resultado: {
            'motivo': 'tablero_lleno',
            'ganadores': ['ana'],
            'ranking': [],
          },
        ),
      );
      await tester.pump(const Duration(milliseconds: 550));
      expectCubreTodo(tester);
      await tester.pumpAndSettle();
    },
  );
}
