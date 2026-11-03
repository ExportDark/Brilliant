import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/pantallas/pantalla_crear_cuenta.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaCrearCuenta: crea la cuenta, entra sola y pasa a elegir el mapa', (
    tester,
  ) async {
    final servidor = ServidorFalso();
    await abrirApp(tester, servidor: servidor, conSesion: false);
    await tocar(tester, enlaceCrearCuenta);

    await escribir(tester, 'campo-usuario-nuevo', 'beto');
    await escribir(tester, 'campo-contrasena-nueva', contrasenaDePrueba);
    await escribir(tester, 'campo-contrasena-repetida', contrasenaDePrueba);
    await tocar(tester, botonCrearCuenta);

    expect(servidor.cuentas, {'beto': contrasenaDePrueba});
    expect(servidor.sesiones.values, ['beto']);
    expect(find.text('Elige un mapa'), findsOneWidget);
    // La pantalla de crear cuenta se cerró sola.
    expect(find.byType(PantallaCrearCuenta), findsNothing);
  });
}
