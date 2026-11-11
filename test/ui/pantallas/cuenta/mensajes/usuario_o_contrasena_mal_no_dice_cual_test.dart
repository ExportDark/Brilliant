import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('Un usuario que no existe y una contraseña mala dan el mismo mensaje: no se revela '
      'cuál de los dos falló', (tester) async {
    final servidor = ServidorFalso()..cuentas['ana'] = contrasenaDePrueba;
    await abrirApp(tester, servidor: servidor, conSesion: false);

    await entrarCon(tester, 'nadie', contrasenaDePrueba);
    final sinUsuario = find.textContaining('No puede iniciar sesión con las credenciales');
    expect(sinUsuario, findsOneWidget);

    await entrarCon(tester, 'ana', 'contrasena-mala-1');
    expect(sinUsuario, findsOneWidget);
  });
}
