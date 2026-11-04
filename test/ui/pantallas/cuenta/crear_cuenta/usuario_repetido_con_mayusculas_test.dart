import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/pantallas/pantalla_crear_cuenta.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaCrearCuenta: "ANA" choca con "ana": son la misma cuenta', (tester) async {
    final servidor = ServidorFalso()..cuentas['ana'] = 'la-de-otra-persona';
    await abrirApp(tester, servidor: servidor, conSesion: false);
    await tocar(tester, enlaceCrearCuenta);

    await crearCuentaCon(tester, 'ANA', contrasenaDePrueba);

    expect(errorDelCampo(tester, 'campo-usuario-nuevo'), 'Ya existe un usuario con este nombre.');
    expect(find.byType(PantallaCrearCuenta), findsOneWidget);
    expect(servidor.cuentas, {'ana': 'la-de-otra-persona'});
  });
}
