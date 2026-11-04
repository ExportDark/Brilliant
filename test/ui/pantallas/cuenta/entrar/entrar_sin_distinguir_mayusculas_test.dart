import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaEntrar: se entra a "ana" escribiendo "ANA"', (tester) async {
    final servidor = ServidorFalso()..cuentas['ana'] = contrasenaDePrueba;
    await abrirApp(tester, servidor: servidor, conSesion: false);

    await entrarCon(tester, 'ANA', contrasenaDePrueba);

    expect(find.text('Elige un mapa'), findsOneWidget);
  });
}
