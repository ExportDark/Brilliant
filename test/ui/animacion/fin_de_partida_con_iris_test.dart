import 'package:brilliant/ui/animacion/iris.dart';
import 'package:brilliant/ui/pantallas/pantalla_preparacion.dart';
import 'package:brilliant/ui/widgets/piezas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../juego/ayudantes.dart';
import '../pantallas/ayudantes_pantallas.dart';
import 'ayudantes_animacion.dart';

/// Juega la última jugada de la partida: E5 es la última casilla libre y, con el 1 de
/// ancla, el 6 va ahí. Deja la pantalla justo después del toque.
Future<void> anotarLaUltima(WidgetTester tester, {Size? tamano}) async {
  await abrirPartida(
    tester,
    tablero: soloCabeElSeisEnE5(),
    caras: [6, 1],
    tamano: tamano ?? const Size(1000, 1400),
  );
  await tirarYElegirAncla(tester, 1);
  await tester.ensureVisible(casillaTocable('E5'));
  await tester.pump();
  await tester.tap(casillaTocable('E5'));
  await tester.pump();
}

TintaConHueco pintorDelIris(WidgetTester tester) =>
    tester.widget<CustomPaint>(irisJugandose).painter! as TintaConHueco;

void main() {
  testWidgets('Con la última jugada, el iris se cierra sobre el trofeo, se queda un instante '
      'y se vuelve a abrir', (tester) async {
    await anotarLaUltima(tester);

    await tester.pump(const Duration(milliseconds: 550));
    expect(find.text('¡Tablero completo!'), findsOneWidget);
    final trofeo = tester.getCenter(find.byType(Insignia));
    final area = tester.getTopLeft(find.byType(Iris));
    expect(
      (pintorDelIris(tester).centro - (trofeo - area)).distance,
      lessThan(1),
    );
    expect(pintorDelIris(tester).radio, 52);

    await tester.pumpAndSettle();
    expect(irisPintando(tester), isFalse);
    expectNadaSeMueve(tester);
    expectQuieto(tester);
  });

  testWidgets('En un celular chico, con el trofeo más abajo, el iris lo lleva a la vista y '
      'se cierra sobre él', (tester) async {
    await anotarLaUltima(tester, tamano: const Size(320, 568));

    await tester.pump(const Duration(milliseconds: 550));
    final trofeo = tester.getCenter(find.byType(Insignia));
    expect(
      (Offset.zero & const Size(320, 568)).contains(trofeo),
      isTrue,
      reason: 'el trofeo tiene que quedar en la pantalla',
    );
    final area = tester.getTopLeft(find.byType(Iris));
    expect(
      (pintorDelIris(tester).centro - (trofeo - area)).distance,
      lessThan(1),
    );
    await tester.pumpAndSettle();
  });

  testWidgets(
    'Mientras el iris tapa la pantalla, "Jugar otra vez" no responde (no se toca a '
    'ciegas); cuando se abre, sí, y lleva a la preparación del mismo mapa',
    (tester) async {
      await anotarLaUltima(tester);
      await tester.pump(const Duration(milliseconds: 300));
      expect(irisPintando(tester), isTrue);

      final jugarOtraVez = find.widgetWithText(FilledButton, 'Jugar otra vez');
      await tester.tap(jugarOtraVez, warnIfMissed: false);
      await tester.pump();
      expect(find.byType(PantallaPreparacion), findsNothing);

      await tester.pumpAndSettle();
      await tocar(tester, jugarOtraVez);
      expect(find.byType(PantallaPreparacion), findsOneWidget);
      expect(find.text('Prepara tu tablero'), findsOneWidget);
      expect(irisPintando(tester), isFalse);
      expectQuieto(tester);
    },
  );

  testWidgets('Una partida que se abre ya terminada (sin jugada posible) no juega el iris: '
      'se juega al terminar, mientras se mira', (tester) async {
    await abrirPartida(tester, tablero: llenoMenos('E5'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(irisPintando(tester), isFalse);
    expect(find.text('Partida terminada'), findsOneWidget);
    await tester.pumpAndSettle();
  });
}
