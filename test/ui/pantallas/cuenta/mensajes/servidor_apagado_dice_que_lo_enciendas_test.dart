import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('Si no hay con quién hablar, lo dice el indicador ("Sin servidor"), sin la '
      'dirección (es un dato de adentro) y sin un recuadro que lo repita', (tester) async {
    final servidor = ServidorFalso()..cuentas['ana'] = contrasenaDePrueba;
    await abrirApp(tester, servidor: servidor, conSesion: false);
    servidor.apagado = true;

    await entrarCon(tester, 'ana', contrasenaDePrueba);

    expect(indicadorDelServidor(tester), 'Sin servidor · No contesta. Toca para cambiar la dirección.');
    expect(find.textContaining('servidor.test'), findsNothing);
    expect(find.byKey(const ValueKey('error-de-cuenta')), findsNothing);
    expect(find.textContaining('tardó'), findsNothing);
  });
}
