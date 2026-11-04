import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaEntrar: con los campos vacíos avisa y no le pregunta al servidor', (
    tester,
  ) async {
    final servidor = ServidorFalso();
    await abrirApp(tester, servidor: servidor, conSesion: false);

    await tocar(tester, botonEntrar);

    expect(find.text('Escribe tu usuario'), findsOneWidget);
    expect(find.text('Escribe tu contraseña'), findsOneWidget);
    // Al abrir, la app solo revisó que el servidor estuviera: no mandó nada.
    expect(servidor.pedidos.where((pedido) => pedido.method == 'POST'), isEmpty);
  });
}
