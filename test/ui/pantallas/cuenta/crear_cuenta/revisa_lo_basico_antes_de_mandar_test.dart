import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaCrearCuenta: revisa lo básico antes de mandar nada al servidor', (
    tester,
  ) async {
    final servidor = ServidorFalso();
    await abrirApp(tester, servidor: servidor, conSesion: false);
    await tocar(tester, enlaceCrearCuenta);

    // Todo vacío.
    await tocar(tester, botonCrearCuenta);
    expect(find.text('Elige un nombre de usuario'), findsOneWidget);
    expect(find.text('Elige una contraseña'), findsOneWidget);

    // Una contraseña corta.
    await escribir(tester, 'campo-usuario-nuevo', 'ana');
    await escribir(tester, 'campo-contrasena-nueva', 'corta');
    await tocar(tester, botonCrearCuenta);
    expect(find.text('Al menos 8 caracteres'), findsOneWidget);

    // Dos contraseñas distintas.
    await escribir(tester, 'campo-contrasena-nueva', contrasenaDePrueba);
    await escribir(tester, 'campo-contrasena-repetida', 'otra-cosa-distinta');
    await tocar(tester, botonCrearCuenta);
    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);

    // Al abrir, la app solo revisó que el servidor estuviera: no mandó nada.
    expect(servidor.pedidos.where((pedido) => pedido.method == 'POST'), isEmpty);
    expect(servidor.cuentas, isEmpty);
  });
}
