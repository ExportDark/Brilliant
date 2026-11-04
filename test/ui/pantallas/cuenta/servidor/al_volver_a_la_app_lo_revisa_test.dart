import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaEntrar: al volver a la app, revisa otra vez el servidor', (tester) async {
    final servidor = ServidorFalso()..apagado = true;
    await abrirApp(tester, servidor: servidor, conSesion: false);
    expect(indicadorDelServidor(tester), startsWith('Sin servidor'));

    // Mientras la app estaba en segundo plano, se encendió el servidor.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    servidor.apagado = false;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(indicadorDelServidor(tester), 'Servidor disponible · servidor.test');
  });
}
