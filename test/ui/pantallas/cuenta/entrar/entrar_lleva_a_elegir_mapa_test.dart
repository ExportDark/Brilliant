import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/pantallas/pantalla_entrar.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaEntrar: con usuario y contraseña buenos, pasa a elegir el mapa', (
    tester,
  ) async {
    final servidor = ServidorFalso()..cuentas['ana'] = contrasenaDePrueba;
    await abrirApp(tester, servidor: servidor, conSesion: false);

    await entrarCon(tester, 'ana', contrasenaDePrueba);

    expect(find.text('Elige un mapa'), findsOneWidget);
    expect(find.byType(PantallaEntrar), findsNothing);
    expect(servidor.sesiones.values, ['ana']);
  });
}
