import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('Un usuario recordado de una cuenta que ya no existe no impide entrar con otra', (
    tester,
  ) async {
    final servidor = ServidorFalso()..cuentas['beto'] = contrasenaDePrueba;
    final almacen = AlmacenEnMemoria()..ultimoUsuario = 'ana';
    await abrirApp(tester, servidor: servidor, conSesion: false, almacen: almacen);

    await entrarCon(tester, 'beto', contrasenaDePrueba);

    expect(find.text('Elige un mapa'), findsOneWidget);
    expect(almacen.ultimoUsuario, 'beto');
    expect(find.byKey(const ValueKey('error-de-cuenta')), findsNothing);
  });
}
