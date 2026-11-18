import 'package:brilliant/ui/widgets/dado_widget.dart';
import 'package:brilliant/ui/widgets/piezas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../cuenta/ayudantes_cuenta.dart';
import '../pantallas/ayudantes_pantallas.dart';

/// Toca [objetivo] como un dedo de verdad: lo apoya, lo deja [cuadros] cuadros (un dedo
/// queda apoyado unos 100 ms) y recién entonces lo levanta. `tester.tap` levanta el dedo
/// sin dibujar ningún cuadro en el medio, y así no se ve lo que pasa mientras está apoyado.
Future<void> tocarConElDedo(
  WidgetTester tester,
  Finder objetivo, {
  int cuadros = 6,
}) async {
  await tester.ensureVisible(objetivo);
  await tester.pump();
  final dedo = await tester.startGesture(tester.getCenter(objetivo));
  for (var i = 0; i < cuadros; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  await dedo.up();
  await tester.pump();
}

void main() {
  testWidgets(
    'Un botón que se aplasta responde a un solo toque, aunque el dedo quede apoyado '
    'unos cuadros (antes se perdía el toque al aplastarse: había que tocar dos veces)',
    (tester) async {
      var toques = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PiezaPresionable(
                child: FilledButton(
                  onPressed: () => toques++,
                  child: const Text('Entrar'),
                ),
              ),
            ),
          ),
        ),
      );

      await tocarConElDedo(tester, find.text('Entrar'));
      expect(toques, 1);

      // Pasado el rebote, otra vez.
      await tester.pumpAndSettle();
      await tocarConElDedo(tester, find.text('Entrar'));
      expect(toques, 2);
    },
  );

  testWidgets('"Entrar" entra con un solo toque', (tester) async {
    final servidor = ServidorFalso()..cuentas['ana'] = contrasenaDePrueba;
    await abrirApp(tester, servidor: servidor, conSesion: false);
    await tester.pumpAndSettle();
    await escribir(tester, 'campo-usuario', 'ana');
    await escribir(tester, 'campo-contrasena', contrasenaDePrueba);

    await tocarConElDedo(tester, botonEntrar);
    await tester.pumpAndSettle();

    expect(find.text('Elige un mapa'), findsOneWidget);
  });

  testWidgets('"Tirar dados" tira con un solo toque', (tester) async {
    await abrirPartida(tester);
    await tester.pumpAndSettle();

    await tocarConElDedo(tester, botonTirar);
    await tester.pumpAndSettle();

    expect(dadoEn(0), findsOneWidget);
    expect(botonTirar, findsNothing);
  });

  testWidgets('Un dado que está cayendo se elige de ancla con un solo toque', (
    tester,
  ) async {
    await abrirPartida(tester);
    await tester.pumpAndSettle();
    await tester.tap(botonTirar);
    await tester.pump();
    // El dado todavía está cayendo, aplastado: mientras el dedo está apoyado (unos 0,3 s,
    // todavía un toque y no una pulsación larga) termina de asentarse.
    await tester.pump(const Duration(milliseconds: 300));

    await tocarConElDedo(tester, dadoEn(1), cuadros: 20);
    await tester.pumpAndSettle();

    expect(tester.widget<DadoWidget>(dadoEn(1)).anclado, isTrue);
  });
}
