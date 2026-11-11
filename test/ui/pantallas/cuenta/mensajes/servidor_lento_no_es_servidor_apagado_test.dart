import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('Si el servidor no contesta a tiempo, el mensaje dice que está ocupado y no que '
      'revises que esté encendido', (tester) async {
    final servidor = ServidorFalso()..cuentas['ana'] = contrasenaDePrueba;
    await abrirApp(tester, servidor: servidor, conSesion: false);
    servidor.tardaDemasiado = true;

    await entrarCon(tester, 'ana', contrasenaDePrueba);

    expect(find.textContaining('tardó demasiado en contestar'), findsOneWidget);
    expect(find.textContaining('Revisa que esté encendido'), findsNothing);
  });
}
