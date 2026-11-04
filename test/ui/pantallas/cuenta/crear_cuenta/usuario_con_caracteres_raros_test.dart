import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/cuenta/reglas_de_cuenta.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaCrearCuenta: un usuario con caracteres raros avisa y no se manda', (
    tester,
  ) async {
    final servidor = ServidorFalso();
    await abrirApp(tester, servidor: servidor, conSesion: false);
    await tocar(tester, enlaceCrearCuenta);

    // Con espacio y acento, con una "а" cirílica, con arroba, con un emoji y
    // con código.
    for (final raro in ['ana pérez', 'аna', 'ana@correo', 'ana💎', '<script>']) {
      await crearCuentaCon(tester, raro, contrasenaDePrueba);
      expect(errorDelCampo(tester, 'campo-usuario-nuevo'), usuarioConCaracteresRaros, reason: raro);
    }

    expect(servidor.pedidos.where((pedido) => pedido.method == 'POST'), isEmpty);
    expect(servidor.cuentas, isEmpty);
  });
}
