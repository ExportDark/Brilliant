import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaCrearCuenta: la contraseña se manda tal cual, con los espacios del borde', (
    tester,
  ) async {
    final servidor = ServidorFalso();
    await abrirApp(tester, servidor: servidor, conSesion: false);
    await tocar(tester, enlaceCrearCuenta);
    const contrasena = '  piñata mágica 💎  ';

    // El usuario, en cambio, sí se recorta.
    await crearCuentaCon(tester, '  ana  ', contrasena);

    final creada = servidor.pedidos.firstWhere((pedido) => pedido.url.path == '/auth/users/');
    final datos = jsonDecode(creada.body) as Map<String, dynamic>;
    expect(datos['username'], 'ana');
    expect(datos['password'], contrasena);
    expect(datos['re_password'], contrasena);
    expect(find.text('Elige un mapa'), findsOneWidget);
  });
}
