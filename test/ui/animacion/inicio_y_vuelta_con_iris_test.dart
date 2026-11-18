import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/ui/pantallas/pantalla_partida.dart';
import 'package:brilliant/ui/pantallas/pantalla_preparacion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../pantallas/ayudantes_pantallas.dart';
import 'ayudantes_animacion.dart';

final botonInicio = find.widgetWithText(FilledButton, 'Inicio');

/// Abre la app, elige el Nivel 1 y reparte al azar: queda listo para tocar "Inicio".
Future<void> listoParaEmpezar(WidgetTester tester) async {
  await abrirApp(tester, tirarDado: () => 4);
  await tocar(tester, tarjetaDe(nivel1));
  await tocar(tester, find.widgetWithText(TextButton, 'Aleatorio'));
}

void main() {
  testWidgets(
    '"Inicio" entra a la partida con el iris, y al terminar queda solo la partida',
    (tester) async {
      await listoParaEmpezar(tester);
      await tester.tap(botonInicio);
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 90));
      expect(irisPintando(tester), isTrue);
      await tester.pump(const Duration(milliseconds: 200));
      expect(irisPintando(tester), isTrue);

      await tester.pumpAndSettle();
      expect(irisPintando(tester), isFalse);
      expect(find.byType(PantallaPartida), findsOneWidget);
      expect(find.byType(PantallaPreparacion), findsNothing);
      expectQuieto(tester);
    },
  );

  testWidgets('Mientras el iris se cierra sobre la preparación, la partida (que todavía no se '
      've) no recibe toques: no se tiran los dados a ciegas', (tester) async {
    await listoParaEmpezar(tester);
    await tester.tap(botonInicio);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));

    // Donde va a estar "Tirar dados", que ya existe pero no se ve.
    await tester.tap(botonTirar, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(botonTirar, findsOneWidget);
    expect(dadoEn(0), findsNothing);
    expect(find.text('Turno 1'), findsOneWidget);
  });

  testWidgets('Un doble toque en "Inicio" entra una sola vez', (tester) async {
    await listoParaEmpezar(tester);
    final dondeEstaInicio = tester.getCenter(botonInicio);
    await tester.tapAt(dondeEstaInicio);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tapAt(dondeEstaInicio);
    await tester.pumpAndSettle();

    expect(find.byType(PantallaPartida), findsOneWidget);
    expect(find.byType(PantallaPreparacion), findsNothing);
    expect(dadoEn(0), findsNothing);
    // Y de ahí, atrás vuelve a elegir el mapa (no hay otra partida debajo).
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tocar(tester, find.widgetWithText(FilledButton, 'Salir'));
    expect(find.text('Elige un mapa'), findsOneWidget);
  });

  testWidgets(
    'Salir de la partida vuelve a elegir el mapa con el iris al revés',
    (tester) async {
      await listoParaEmpezar(tester);
      await tocar(tester, botonInicio);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Salir'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(irisPintando(tester), isTrue);

      await tester.pumpAndSettle();
      expect(find.text('Elige un mapa'), findsOneWidget);
      expect(find.byType(PantallaPartida), findsNothing);
      expectQuieto(tester);
    },
  );
}
