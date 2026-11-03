import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/pantallas/pantalla_entrar.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaEntrar: con una contraseña mala muestra el error del servidor y no entra', (
    tester,
  ) async {
    final servidor = ServidorFalso()..cuentas['ana'] = contrasenaDePrueba;
    await abrirApp(tester, servidor: servidor, conSesion: false);

    await entrarCon(tester, 'ana', 'no-es-la-buena');

    expect(
      find.text('No puede iniciar sesión con las credenciales proporcionadas.'),
      findsOneWidget,
    );
    expect(find.byType(PantallaEntrar), findsOneWidget);

    // Al volver a escribir, el error del intento anterior se va.
    await escribir(tester, 'campo-contrasena', 'otra');
    expect(
      find.text('No puede iniciar sesión con las credenciales proporcionadas.'),
      findsNothing,
    );
  });
}
