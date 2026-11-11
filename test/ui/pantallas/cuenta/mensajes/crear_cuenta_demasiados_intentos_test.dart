import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('Crear cuenta: el límite de cuentas por hora también se explica en español', (
    tester,
  ) async {
    final servidor = ServidorFalso()..regulaConSegundos = 3000;
    await abrirApp(tester, servidor: servidor, conSesion: false);
    await tocar(tester, enlaceCrearCuenta);

    await crearCuentaCon(tester, 'beto', contrasenaDePrueba);

    expect(find.textContaining('Demasiados intentos seguidos. Espera 3000 segundos'), findsOneWidget);
  });
}
