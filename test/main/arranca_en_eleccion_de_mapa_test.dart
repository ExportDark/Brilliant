import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/main.dart';
import 'package:brilliant/ui/pantallas/pantalla_eleccion_de_mapa.dart';

void main() {
  testWidgets('BrilliantApp: la app arranca en la pantalla para elegir el mapa', (tester) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BrilliantApp());

    expect(find.byType(PantallaEleccionDeMapa), findsOneWidget);
    expect(find.text('Elige un mapa'), findsOneWidget);
  });
}
