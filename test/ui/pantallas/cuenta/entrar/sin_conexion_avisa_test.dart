import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaEntrar: si el servidor se cae justo al tocar "Entrar", lo dice el '
      'indicador (una sola vez, sin un recuadro que lo repita)', (tester) async {
    final servidor = ServidorFalso();
    await abrirApp(tester, servidor: servidor, conSesion: false);
    servidor.apagado = true;

    await entrarCon(tester, 'ana', contrasenaDePrueba);

    expect(indicadorDelServidor(tester), startsWith('Sin servidor'));
    expect(find.byKey(const ValueKey('error-de-cuenta')), findsNothing);
  });
}
