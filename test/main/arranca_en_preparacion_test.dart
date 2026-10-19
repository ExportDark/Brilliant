import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/main.dart';
import 'package:brilliant/ui/pantallas/pantalla_preparacion.dart';

void main() {
  testWidgets('BrilliantApp: la app arranca en la pantalla de preparación', (tester) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BrilliantApp());

    expect(find.byType(PantallaPreparacion), findsOneWidget);
    expect(find.text('Prepara tu tablero'), findsOneWidget);
  });
}
