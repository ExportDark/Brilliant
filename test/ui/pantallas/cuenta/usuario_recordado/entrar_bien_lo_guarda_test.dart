import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('Entrar bien guarda el usuario; entrar mal no', (tester) async {
    final servidor = ServidorFalso()..cuentas['ana'] = contrasenaDePrueba;
    final almacen = AlmacenEnMemoria();
    await abrirApp(tester, servidor: servidor, conSesion: false, almacen: almacen);

    await entrarCon(tester, 'ana', 'contrasena-mala-1');
    expect(almacen.ultimoUsuario, isNull);

    await entrarCon(tester, 'ana', contrasenaDePrueba);
    expect(almacen.ultimoUsuario, 'ana');
  });
}
