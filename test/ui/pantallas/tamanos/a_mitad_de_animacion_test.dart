import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../juego/ayudantes.dart';
import '../../../multijugador/ayudantes_salas.dart';
import '../../animacion/ayudantes_animacion.dart';
import '../ayudantes_pantallas.dart';

/// Las animaciones solo transforman (nunca cambian tamaños), así que a mitad de camino
/// nada se desborda. Se prueba en el celular más chico y en el escritorio, mirando la
/// pantalla en varios momentos de cada animación.
const _tamanos = ['celular chico', 'escritorio'];

/// Deja pasar el tiempo de a [paso] y revisa en cada cuadro que nada se haya desbordado.
Future<void> sinDesbordesDurante(
  WidgetTester tester,
  String que, {
  int ms = 600,
  int paso = 50,
}) async {
  for (var t = 0; t <= ms; t += paso) {
    await tester.pump(Duration(milliseconds: paso));
    expect(tester.takeException(), isNull, reason: '$que, a los $t ms');
  }
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: '$que, al terminar');
}

void main() {
  for (final nombre in _tamanos) {
    final tamano = tamanosDePantalla[nombre]!;

    testWidgets(
      'Jugando solo, en $nombre: la tirada en el aire, las casillas que se encienden, '
      'el polvo y el iris del final',
      (tester) async {
        await abrirPartida(
          tester,
          tablero: soloCabeElSeisEnE5(),
          caras: [6, 1],
          tamano: tamano,
        );
        await tester.ensureVisible(botonTirar);
        await tester.pump();
        await tester.tap(botonTirar);
        await sinDesbordesDurante(tester, 'la tirada');

        await tester.ensureVisible(dadoEn(1));
        await tester.pump();
        await tester.tap(dadoEn(1));
        await sinDesbordesDurante(tester, 'las casillas que se encienden');
        expect(irisPintando(tester), isFalse);

        await tester.ensureVisible(casillaTocable('E5'));
        await tester.pump();
        await tester.tap(casillaTocable('E5'));
        await tester.pump();
        expect(irisPintando(tester), isFalse);
        await tester.pump(const Duration(milliseconds: 100));
        expect(irisPintando(tester), isTrue);
        await sinDesbordesDurante(
          tester,
          'el polvo y el iris del final',
          ms: 1200,
        );
      },
    );

    testWidgets(
      'En línea, en $nombre: el iris al empezar, los dados de la ronda nueva y el '
      'iris del resultado',
      (tester) async {
        final salas = SalasFalsas();
        await abrirSalaSola(tester, salas, tamano: tamano);
        await crearSala(tester, salas, vistaDePrueba());

        salas.vista = partidaEnJuego(version: 9);
        await tester.pump(const Duration(seconds: 1));
        await sinDesbordesDurante(tester, 'el iris al empezar');

        salas.vista = vistaDePrueba(
          version: 10,
          estado: 'jugando',
          ronda: 2,
          dados: const [2, 5],
          segundosRestantes: 8,
          tablero: const {'E1': 1, 'A3': 3, 'C4': 4, 'F5': 5, 'B6': 6, 'E7': 2},
          jugadas: const [
            {
              'ancla': 2,
              'valor': 5,
              'casillas': ['D2'],
            },
            {
              'ancla': 5,
              'valor': 2,
              'casillas': ['F4'],
            },
          ],
        );
        await tester.pump(const Duration(seconds: 1));
        await sinDesbordesDurante(
          tester,
          'los dados de la ronda nueva y el tiempo',
        );

        salas.vista = vistaDePrueba(
          version: 11,
          estado: 'terminada',
          resultado: {
            'motivo': 'tablero_lleno',
            'ganadores': ['ana'],
            'ranking': [],
          },
        );
        await tester.pump(const Duration(seconds: 1));
        await sinDesbordesDurante(tester, 'el iris del resultado', ms: 1200);
        expect(find.byKey(const ValueKey('resultado')), findsOneWidget);
      },
    );
  }
}
