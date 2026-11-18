import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/multijugador/modelos.dart';
import 'package:brilliant/ui/pantallas/pantalla_partida.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../multijugador/ayudantes_salas.dart';
import '../pantallas/ayudantes_pantallas.dart';
import 'ayudantes_animacion.dart';

/// Toca [objetivo] y mira el cuadro siguiente y uno un poco después: con "Quitar
/// animaciones", nada se mueve nunca (todo queda en su lugar al instante).
Future<void> tocarSinMovimiento(WidgetTester tester, Finder objetivo) async {
  await tester.ensureVisible(objetivo);
  await tester.pump();
  await tester.tap(objetivo);
  await tester.pump();
  expectNadaSeMueve(tester);
  await tester.pump(const Duration(milliseconds: 60));
  expectNadaSeMueve(tester);
  await tester.pumpAndSettle();
  expectNadaSeMueve(tester);
}

/// Que el servidor falso pase a contestar [vista], que la app pregunte, y que nada se
/// mueva en el cuadro siguiente ni un poco después.
Future<void> llegaSinMovimiento(
  WidgetTester tester,
  SalasFalsas salas,
  VistaDeSala vista,
) async {
  salas.vista = vista;
  await tester.pump(const Duration(seconds: 1));
  await tester.pump();
  expectNadaSeMueve(tester);
  await tester.pump(const Duration(milliseconds: 100));
  expectNadaSeMueve(tester);
  await tester.pumpAndSettle();
}

List<String> encendidas(WidgetTester tester) => celdasDibujadasDonde(
  tester,
  (CeldaWidget celda) => celda.iluminacion == Iluminacion.posible,
).toList();

void main() {
  testWidgets(
    'Con "Quitar animaciones", "Inicio" entra sin iris y salir vuelve sin iris',
    (tester) async {
      conMovimientoReducido(tester);
      await abrirApp(tester, tirarDado: () => 4);
      await tocarSinMovimiento(tester, tarjetaDe(nivel1));
      await tocarSinMovimiento(
        tester,
        find.widgetWithText(TextButton, 'Aleatorio'),
      );

      await tocarSinMovimiento(
        tester,
        find.widgetWithText(FilledButton, 'Inicio'),
      );
      expect(find.byType(PantallaPartida), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tocarSinMovimiento(
        tester,
        find.widgetWithText(FilledButton, 'Salir'),
      );
      expect(find.text('Elige un mapa'), findsOneWidget);
    },
  );

  testWidgets('Con "Quitar animaciones", una partida sola de punta a punta: nada se mueve en '
      'ningún turno, ni al final', (tester) async {
    conMovimientoReducido(tester);
    // Las 36 combinaciones de dos dados, en orden: la partida siempre avanza.
    await abrirPartida(
      tester,
      caras: [
        for (var a = 1; a <= 6; a++)
          for (var b = 1; b <= 6; b++) ...[a, b],
      ],
    );

    final fin = find.byKey(const ValueKey('fin-de-partida'));
    for (var turno = 1; !tester.any(fin); turno++) {
      if (turno > 300) fail('la partida no terminó');
      await tocarSinMovimiento(tester, botonTirar);
      if (tester.any(botonPasar)) {
        await tocarSinMovimiento(tester, botonPasar);
        continue;
      }
      await tocarSinMovimiento(tester, dadoEn(0));
      if (encendidas(tester).isEmpty) {
        await tocarSinMovimiento(tester, dadoEn(1));
      }
      await tocarSinMovimiento(
        tester,
        casillaTocable(encendidas(tester).first),
      );
    }

    expect(find.text('¡Tablero completo!'), findsOneWidget);
    expectQuieto(tester);
  });

  testWidgets(
    'Con "Quitar animaciones", en línea: empezar, anotar, la ronda nueva y el '
    'resultado, sin que nada se mueva',
    (tester) async {
      conMovimientoReducido(tester);
      final salas = SalasFalsas();
      await abrirSalaSola(tester, salas);
      await crearSala(tester, salas, vistaDePrueba());

      await llegaSinMovimiento(tester, salas, partidaEnJuego(version: 9));
      await tocarSinMovimiento(tester, dadoEn(0));
      salas.vista = partidaEnJuego(
        version: 10,
        accion: 'coloco',
        tablero: const {
          'E1': 1,
          'A3': 3,
          'C4': 4,
          'F5': 5,
          'B6': 6,
          'E7': 2,
          'D1': 3,
        },
      );
      await tocarSinMovimiento(tester, casillaTocable('D1'));

      await llegaSinMovimiento(
        tester,
        salas,
        vistaDePrueba(
          version: 11,
          estado: 'jugando',
          ronda: 2,
          dados: const [2, 5],
          segundosRestantes: 9,
          tablero: const {
            'E1': 1,
            'A3': 3,
            'C4': 4,
            'F5': 5,
            'B6': 6,
            'E7': 2,
            'D1': 3,
          },
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
        ),
      );
      await llegaSinMovimiento(
        tester,
        salas,
        vistaDePrueba(
          version: 12,
          estado: 'terminada',
          resultado: {
            'motivo': 'tablero_lleno',
            'ganadores': ['ana'],
            'ranking': [],
          },
        ),
      );
      expect(find.byKey(const ValueKey('resultado')), findsOneWidget);
    },
  );
}
