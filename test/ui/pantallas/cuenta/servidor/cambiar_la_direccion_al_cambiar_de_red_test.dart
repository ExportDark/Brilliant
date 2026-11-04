import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaEntrar: si la PC cambió de red, se escribe la dirección nueva y se puede '
      'entrar', (tester) async {
    final servidor = ServidorFalso()..cuentas['ana'] = contrasenaDePrueba;
    await abrirApp(tester, servidor: servidor, conSesion: false);
    expect(find.text('Servidor: servidor.test'), findsOneWidget);

    // La PC cambió de red: en la dirección vieja ya no contesta nadie.
    servidor.direccion = '192.168.137.252';
    await entrarCon(tester, 'ana', contrasenaDePrueba);
    expect(
      find.textContaining('No se pudo conectar con el servidor (servidor.test)'),
      findsOneWidget,
    );

    await cambiarServidor(tester, '192.168.137.252');
    expect(find.text('Conectado con el servidor en 192.168.137.252.'), findsOneWidget);
    expect(find.text('Servidor: 192.168.137.252'), findsOneWidget);

    await entrarCon(tester, 'ana', contrasenaDePrueba);
    expect(find.text('Elige un mapa'), findsOneWidget);
  });
}
