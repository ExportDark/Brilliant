import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaEntrar: mientras no hay servidor revisa solo, y nota cuando se enciende',
      (tester) async {
    final servidor = ServidorFalso()..apagado = true;
    await abrirApp(
      tester,
      servidor: servidor,
      conSesion: false,
      revisarCada: const Duration(seconds: 10),
    );
    expect(indicadorDelServidor(tester), startsWith('Sin servidor'));

    servidor.apagado = false;
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();

    expect(indicadorDelServidor(tester), 'Servidor disponible · servidor.test');
  });
}
