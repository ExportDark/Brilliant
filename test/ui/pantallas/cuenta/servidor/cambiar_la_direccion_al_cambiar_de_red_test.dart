import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaEntrar: si la PC cambió de red, se escribe la dirección nueva y se puede '
      'entrar', (tester) async {
    final servidor = ServidorFalso()..cuentas['ana'] = contrasenaDePrueba;
    await abrirApp(tester, servidor: servidor, conSesion: false);
    expect(indicadorDelServidor(tester), 'Servidor disponible · servidor.test');

    // La PC cambió de red: en la dirección vieja ya no contesta nadie.
    servidor.direccion = '192.168.137.252';
    await entrarCon(tester, 'ana', contrasenaDePrueba);
    expect(
      find.textContaining('No se pudo conectar con el servidor (servidor.test)'),
      findsOneWidget,
    );
    expect(
      indicadorDelServidor(tester),
      'Sin servidor · No contesta en servidor.test. Toca para buscar otro.',
    );

    await cambiarServidor(tester, '192.168.137.252');
    expect(indicadorDelServidor(tester), 'Servidor disponible · 192.168.137.252');

    await entrarCon(tester, 'ana', contrasenaDePrueba);
    expect(find.text('Elige un mapa'), findsOneWidget);
  });
}
