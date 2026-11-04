import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaEntrar: si la PC cambió de red, la app encuentra el servidor sola y entra',
      (tester) async {
    final servidor = ServidorFalso()..cuentas['ana'] = contrasenaDePrueba;
    final buscador = BuscadorFalso([anunciado('192.168.137.252')]);
    await abrirApp(tester, servidor: servidor, conSesion: false, buscador: buscador);
    expect(indicadorDelServidor(tester), 'Servidor disponible · servidor.test');

    // La PC cambió de red: en la dirección vieja ya no contesta nadie, y el
    // jugador no escribe la nueva.
    servidor.direccion = '192.168.137.252';
    await entrarCon(tester, 'ana', contrasenaDePrueba);

    expect(find.text('Elige un mapa'), findsOneWidget);
    expect(buscador.busquedas, 1);
  });
}
