import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/pantallas/pantalla_eleccion_de_mapa.dart';
import 'package:brilliant/ui/pantallas/pantalla_entrar.dart';

import '../ui/pantallas/ayudantes_pantallas.dart';

void main() {
  testWidgets('BrilliantApp: sin sesión, la app arranca en "Iniciar sesión" y no deja jugar', (
    tester,
  ) async {
    await abrirApp(tester, conSesion: false);

    expect(find.byType(PantallaEntrar), findsOneWidget);
    expect(find.text('Inicia sesión para jugar.'), findsOneWidget);
    expect(find.byType(PantallaEleccionDeMapa), findsNothing);
  });
}
