import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('Si no hay con quién hablar, el mensaje dice que revises que esté encendido y en '
      'qué dirección se intentó', (tester) async {
    final servidor = ServidorFalso()..cuentas['ana'] = contrasenaDePrueba;
    await abrirApp(tester, servidor: servidor, conSesion: false);
    servidor.apagado = true;

    await entrarCon(tester, 'ana', contrasenaDePrueba);

    expect(find.textContaining('No se pudo conectar con el servidor (servidor.test)'), findsOneWidget);
    expect(find.textContaining('Revisa que esté encendido'), findsOneWidget);
    expect(find.textContaining('tardó demasiado'), findsNothing);
  });
}
