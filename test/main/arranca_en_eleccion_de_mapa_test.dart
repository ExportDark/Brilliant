import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/pantallas/pantalla_eleccion_de_mapa.dart';

import '../ui/pantallas/ayudantes_pantallas.dart';

void main() {
  testWidgets('BrilliantApp: con una sesión guardada, la app arranca en elegir el mapa', (
    tester,
  ) async {
    await abrirApp(tester);

    expect(find.byType(PantallaEleccionDeMapa), findsOneWidget);
    expect(find.text('Elige un mapa'), findsOneWidget);
  });
}
