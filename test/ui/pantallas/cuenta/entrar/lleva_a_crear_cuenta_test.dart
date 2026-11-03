import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/pantallas/pantalla_crear_cuenta.dart';
import 'package:brilliant/ui/pantallas/pantalla_entrar.dart';

import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaEntrar: el enlace lleva a crear cuenta, y atrás vuelve', (tester) async {
    await abrirApp(tester, conSesion: false);

    await tocar(tester, enlaceCrearCuenta);
    expect(find.byType(PantallaCrearCuenta), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(PantallaCrearCuenta), findsNothing);
    expect(find.byType(PantallaEntrar), findsOneWidget);
  });
}
