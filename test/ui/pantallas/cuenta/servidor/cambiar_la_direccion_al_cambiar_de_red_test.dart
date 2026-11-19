import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaEntrar: si la PC cambió de red, se escribe la dirección nueva y se puede '
      'entrar', (tester) async {
    final servidor = ServidorFalso()..cuentas['ana'] = contrasenaDePrueba;
    await abrirApp(tester, servidor: servidor, conSesion: false);
    expect(indicadorDelServidor(tester), servidorListo);

    // La PC cambió de red: en la dirección vieja ya no contesta nadie.
    servidor.direccion = '192.168.137.252';
    await entrarCon(tester, 'ana', contrasenaDePrueba);
    expect(indicadorDelServidor(tester), sinServidorSinBuscar);
    expect(servidorEnUso(tester), 'servidor.test');

    await cambiarServidor(tester, '192.168.137.252');
    expect(indicadorDelServidor(tester), servidorListo);
    expect(servidorEnUso(tester), '192.168.137.252');

    await entrarCon(tester, 'ana', contrasenaDePrueba);
    expect(find.text('Elige un mapa'), findsOneWidget);
  });
}
