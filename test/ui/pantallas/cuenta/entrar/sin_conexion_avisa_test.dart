import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaEntrar: si el servidor se cae justo al tocar "Entrar", avisa que no se '
      'pudo conectar', (tester) async {
    final servidor = ServidorFalso();
    await abrirApp(tester, servidor: servidor, conSesion: false);
    servidor.apagado = true;

    await entrarCon(tester, 'ana', contrasenaDePrueba);

    expect(find.textContaining('No se pudo conectar con el servidor'), findsOneWidget);
  });
}
