import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('Crear una cuenta nueva también deja recordado su usuario', (tester) async {
    final almacen = AlmacenEnMemoria();
    await abrirApp(tester, conSesion: false, almacen: almacen);
    await tocar(tester, enlaceCrearCuenta);

    await crearCuentaCon(tester, 'beto', contrasenaDePrueba);

    expect(almacen.ultimoUsuario, 'beto');
  });
}
