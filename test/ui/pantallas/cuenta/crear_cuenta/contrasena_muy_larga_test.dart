import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaCrearCuenta: una contraseña de más de 128 caracteres avisa y no se manda', (
    tester,
  ) async {
    final servidor = ServidorFalso();
    await abrirApp(tester, servidor: servidor, conSesion: false);
    await tocar(tester, enlaceCrearCuenta);

    await crearCuentaCon(tester, 'ana', 'gema-brillante-73-${'x' * 111}');

    expect(errorDelCampo(tester, 'campo-contrasena-nueva'), 'Como mucho 128 caracteres');
    expect(servidor.pedidos.where((pedido) => pedido.method == 'POST'), isEmpty);
  });
}
